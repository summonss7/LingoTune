#!/usr/bin/env python3
"""
LingoTune - Batch Translation Audio Generator
=============================================
Walks the song library and runs `generate_translation_audio.py` for every
song that has both an audio file and a translation package (.zip with LRC +
JSON). Skips outputs that already exist (unless --force).

Expected library layout (matches the project's `media/Songs/` tree)::

    <library>/
        Romanian/
            Song A.mp3
            Song B.mp3
            LRC-JSON/
                Song A.zip      # contains Song A.lrc + Song A_<lang>.json
                Song B.zip
        English/
            ...

The matching between a .zip and a .mp3 is done by stem, with a
diacritics-insensitive fallback (so "Două Linii" matches "Doua Linii").

Example
-------
    # Generate Russian + English karaoke versions for every song in Romanian
    python scripts/batch_generate.py \\
        --library media/Songs/Romanian \\
        --languages ru,en \\
        --mode karaoke

    # Just scan and report (no audio generated)
    python scripts/batch_generate.py --library media/Songs --dry-run
"""

import argparse
import re
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path
from typing import List, Optional, Tuple


AUDIO_EXTS = {'.mp3', '.wav', '.m4a', '.ogg', '.flac'}


def normalize(name: str) -> str:
    """Lowercase, strip diacritics and non-alphanumeric chars for fuzzy match."""
    s = name.lower().strip()
    # Common Romanian/East-European diacritics
    repl = {'ă': 'a', 'â': 'a', 'î': 'i', 'ș': 's', 'ş': 's', 'ț': 't',
            'ţ': 't', 'ă': 'a', 'ä': 'a', 'ö': 'o', 'ü': 'u', 'ß': 'ss',
            'é': 'e', 'è': 'e', 'ê': 'e', 'á': 'a', 'à': 'a', 'ñ': 'n',
            'ç': 'c', 'ï': 'i', 'ō': 'o', 'ū': 'u'}
    for k, v in repl.items():
        s = s.replace(k, v)
    s = re.sub(r'[^a-z0-9]+', '', s)
    return s


def find_audio_for(zip_stem: str, search_dirs: List[Path]) -> Optional[Path]:
    """Find the audio file matching a song (zip stem) in the given directories."""
    # Exact match first
    for d in search_dirs:
        for ext in AUDIO_EXTS:
            cand = d / f'{zip_stem}{ext}'
            if cand.exists():
                return cand
    # Normalized match (diacritics-insensitive)
    target = normalize(zip_stem)
    for d in search_dirs:
        if not d.exists():
            continue
        for f in d.iterdir():
            if f.suffix.lower() in AUDIO_EXTS and normalize(f.stem) == target:
                return f
    return None


def inspect_zip(zip_path: Path) -> Tuple[Optional[str], List[str]]:
    """Return (lrc_name_inside, list_of_language_codes) found inside a zip.

    Language codes are read from each JSON's ``translations[].language`` field
    (source of truth). This correctly handles multi-segment codes like
    ``ru_literal`` that would be mis-parsed from the filename.
    """
    import json as _json

    lrc_name = None
    langs: List[str] = []
    with zipfile.ZipFile(zip_path) as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            name = Path(info.filename).name.lower()
            if name.endswith('.lrc') and lrc_name is None:
                lrc_name = info.filename
            elif name.endswith('.json'):
                code = None
                try:
                    with zf.open(info) as f:
                        data = _json.load(f)
                    for tr in data.get('translations', []):
                        if tr.get('language'):
                            code = tr['language']
                            break
                except Exception:
                    # Fallback: parse from filename (best-effort)
                    stem = Path(info.filename).stem
                    if '_' in stem:
                        code = stem.rsplit('_', 1)[-1].lower()
                if code:
                    langs.append(code)
    return lrc_name, sorted(set(langs))


def extract_zip(zip_path: Path, dest: Path) -> None:
    """Extract a zip (flattened into a single directory)."""
    with zipfile.ZipFile(zip_path) as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            # Flatten: keep only the basename
            target = dest / Path(info.filename).name
            with zf.open(info) as src, open(target, 'wb') as dst:
                dst.write(src.read())


def discover_songs(library: Path) -> List[dict]:
    """Scan the library and return one record per song with a translation zip.

    Handles three layouts:
    - ``<library>/<Language>/LRC-JSON/*.zip``  (library = media/Songs)
    - ``<library>/LRC-JSON/*.zip``             (library = media/Songs/Romanian)
    - ``<library>/*.zip`` + audio next to it   (flat, e.g. a "translate" folder)

    Each record: {'song': str, 'zip': Path, 'audio': Optional[Path],
                  'langs': List[str], 'lang_folder': Path,
                  'lang_folder_name': Optional[str]}  (None when flat)
    """
    candidates: List[tuple] = []  # (zip_path, audio_search_dir, lang_folder_name)

    # Flat layout: zips directly in library, audio next to them.
    flat_zips = sorted(library.glob('*.zip'))
    for z in flat_zips:
        candidates.append((z, library, None))

    # Single-language layout: <library>/LRC-JSON/*.zip
    lrc_json = library / 'LRC-JSON'
    if lrc_json.is_dir():
        for z in sorted(lrc_json.glob('*.zip')):
            candidates.append((z, library, library.name))

    # Full library layout: <library>/<Language>/LRC-JSON/*.zip
    for lang_dir in sorted(library.iterdir()):
        if not lang_dir.is_dir():
            continue
        lj = lang_dir / 'LRC-JSON'
        if lj.is_dir():
            for z in sorted(lj.glob('*.zip')):
                candidates.append((z, lang_dir, lang_dir.name))

    # Dedupe by zip path (a song may match more than one layout), keep first.
    seen = set()
    records: List[dict] = []
    for z, search_dir, lang_name in candidates:
        if z in seen:
            continue
        seen.add(z)
        _, langs = inspect_zip(z)
        audio = find_audio_for(z.stem, [search_dir])
        records.append({
            'song': z.stem,
            'zip': z,
            'audio': audio,
            'langs': langs,
            'lang_folder': search_dir,
            'lang_folder_name': lang_name,
        })
    return records


def output_path_for(audio: Path, language: str, mode: str,
                    out_root: Optional[Path], variant: str = 'v1',
                    lang_folder_name: Optional[str] = None) -> Path:
    """Compute the output path for a generated file.

    When `lang_folder_name` is None (flat layout) and `out_root` is given,
    the file is placed directly under `out_root` (no language subfolder).
    """
    suffix = f'_{language}'
    if variant in ('v2', 'v3'):
        suffix += f'_{variant}'
    elif mode != 'mixed':
        suffix += f'_{mode}'
    name = f'{audio.stem}{suffix}.mp3'
    if out_root is not None:
        if lang_folder_name:
            return out_root / lang_folder_name / name
        return out_root / name
    return audio.parent / name


def run_one(script: Path, audio: Path, lrc: Path, json_path: Path,
            language: str, mode: str, align: str, out: Path,
            max_speed: float, device: str, dry_run: bool,
            variant: str = 'v1', gap_speed: float = 2.2,
            rate: Optional[str] = None,
            orig_gain: Optional[float] = None,
            tts_gain: Optional[float] = None,
            slow_factor: Optional[float] = None,
            lead_ms: Optional[int] = None) -> bool:
    """Invoke generate_translation_audio.py for one song/language. Returns ok."""
    cmd = [
        sys.executable, str(script),
        '--audio', str(audio),
        '--lrc', str(lrc),
        '--translations', str(json_path),
        '--language', language,
        '--mode', mode,
        '--variant', variant,
        '--align', align,
        '--max-speed', str(max_speed),
        '--gap-speed', str(gap_speed),
        '--output', str(out),
    ]
    if rate is not None:
        cmd += ['--rate', rate]
    if orig_gain is not None:
        cmd += ['--orig-gain', str(orig_gain)]
    if tts_gain is not None:
        cmd += ['--tts-gain', str(tts_gain)]
    if slow_factor is not None:
        cmd += ['--slow-factor', str(slow_factor)]
    if lead_ms is not None:
        cmd += ['--lead-ms', str(lead_ms)]
    if mode == 'karaoke':
        cmd += ['--demucs-model', 'htdemucs']
        if device:
            cmd += ['--device', device]
    if dry_run:
        print(f'   [dry-run] would run: {" ".join(cmd[:2])} ... --language {language} '
              f'--variant {variant}')
        return True
    res = subprocess.run(cmd)
    return res.returncode == 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description='Batch-generate spoken translation audio for the whole library.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument('--library', required=True, type=Path,
                   help='Root of the song library (e.g. media/Songs or media/Songs/Romanian)')
    p.add_argument('--languages', default='',
                   help='Comma-separated language codes to generate (e.g. ru,en). '
                        'Default = all languages found in each zip.')
    p.add_argument('--mode', choices=['mixed', 'tts_only', 'ducked', 'karaoke'],
                   default='mixed', help='Output mix mode (default: mixed)')
    p.add_argument('--variant', choices=['v1', 'v2', 'v3'], default='v1',
                   help='Generation preset (default: v1). v2 = female voice + '
                        'compact fast inline. v3 = v2 + slowed original (×1.10) '
                        'and translation leading 1s before each timestamp.')
    p.add_argument('--align', choices=['stretch', 'words'], default='stretch',
                   help='TTS fitting strategy for inline placement (default: stretch)')
    p.add_argument('--max-speed', type=float, default=1.5,
                   help='Max TTS speed-up for inline placement (default: 1.5)')
    p.add_argument('--gap-speed', type=float, default=2.2,
                   help='Max TTS speed-up for gap placement / variant v2 (default: 2.2)')
    p.add_argument('--rate', default=None,
                   help='edge-tts speaking rate override, e.g. "+55%%" or "-10%%" '
                        '(default: driven by --variant)')
    p.add_argument('--orig-gain', type=float, default=None,
                   help='Base audio gain (dB) override (default: variant/mode-driven)')
    p.add_argument('--tts-gain', type=float, default=None,
                   help='TTS gain (dB) override (default: variant-driven)')
    p.add_argument('--slow-factor', type=float, default=None,
                   help='Slow base audio by this factor (default: v3=1.10, else 1.0)')
    p.add_argument('--lead-ms', type=int, default=None,
                   help='Translation start offset in ms (default: v3=-1000, else 0)')
    p.add_argument('--device', default='',
                   help='Demucs device for karaoke mode: "cpu" or "cuda" (default: auto)')
    p.add_argument('--output-root', '-o', type=Path, default=None,
                   help='Root output dir. Default: alongside each audio file.')
    p.add_argument('--force', action='store_true',
                   help='Regenerate even if the output already exists')
    p.add_argument('--dry-run', action='store_true',
                   help='Scan and report only; do not generate any audio')
    p.add_argument('--only', default='',
                   help='Comma-separated song-name substrings to include '
                        '(e.g. "Alexia,Doua"). Default: all.')
    p.add_argument('--script', type=Path, default=None,
                   help='Path to generate_translation_audio.py '
                        '(default: this script\'s directory)')
    return p


def main(argv: Optional[List[str]] = None) -> int:
    args = build_parser().parse_args(argv)

    if not args.library.exists():
        print(f'✗ Library not found: {args.library}', file=sys.stderr)
        return 2

    script = args.script or (Path(__file__).parent / 'generate_translation_audio.py')
    if not script.exists():
        print(f'✗ generate_translation_audio.py not found at {script}', file=sys.stderr)
        return 2

    wanted_langs = [x.strip() for x in args.languages.split(',') if x.strip()]
    only_filters = [x.strip().lower() for x in args.only.split(',') if x.strip()]

    print(f'🔎 Scanning library: {args.library}')
    records = discover_songs(args.library)
    if only_filters:
        records = [r for r in records
                   if any(f in r['song'].lower() for f in only_filters)]

    total = len(records)
    have_audio = sum(1 for r in records if r['audio'])
    print(f'   found {total} song(s) with translation zips; '
          f'{have_audio} have matching audio')

    if args.dry_run:
        print('\n--- DRY RUN (no audio will be generated) ---')
        for r in records:
            audio_str = str(r['audio']) if r['audio'] else '❌ NO AUDIO'
            print(f'  • {r["song"]}')
            print(f'      langs: {", ".join(r["langs"]) or "(none)"}')
            print(f'      audio: {audio_str}')
        return 0

    # Stats
    done = 0
    failed = 0
    skipped = 0

    for r in records:
        song = r['song']
        if not r['audio']:
            print(f'\n⏭  "{song}": no matching audio file, skipping')
            skipped += 1
            continue

        langs = wanted_langs or r['langs']
        if not langs:
            print(f'\n⏭  "{song}": no translation languages in zip, skipping')
            skipped += 1
            continue

        print(f'\n🎵 "{song}"  (audio: {r["audio"].name})')
        with tempfile.TemporaryDirectory() as td:
            td_path = Path(td)
            try:
                extract_zip(r['zip'], td_path)
            except Exception as e:
                print(f'   ✗ cannot extract zip: {e}', file=sys.stderr)
                failed += 1
                continue

            lrc_files = list(td_path.glob('*.lrc'))
            if not lrc_files:
                print(f'   ✗ no .lrc inside zip, skipping')
                failed += 1
                continue
            lrc_file = lrc_files[0]

            for lang in langs:
                # Prefer an exact "<song>_<lang>.json" match, then any
                # "*_<lang>.json" (robust against renamed zips).
                json_file = td_path / f'{song}_{lang}.json'
                if not json_file.exists():
                    candidates = list(td_path.glob(f'*_{lang}.json'))
                    if candidates:
                        json_file = candidates[0]
                    else:
                        single = td_path / f'{song}.json'
                        if single.exists():
                            json_file = single
                        else:
                            print(f'   ⏭  no {lang} translation in zip, skipping lang')
                            continue

                out = output_path_for(r['audio'], lang, args.mode,
                                      args.output_root, args.variant,
                                      lang_folder_name=r.get('lang_folder_name'))
                if out.exists() and not args.force:
                    print(f'   ✓ exists, skip (use --force): {out.name}')
                    skipped += 1
                    continue

                ok = run_one(script, r['audio'], lrc_file, json_file, lang,
                             args.mode, args.align, out, args.max_speed,
                             args.device, args.dry_run,
                             variant=args.variant, gap_speed=args.gap_speed,
                             rate=args.rate,
                             orig_gain=args.orig_gain, tts_gain=args.tts_gain,
                             slow_factor=args.slow_factor, lead_ms=args.lead_ms)
                if ok:
                    done += 1
                else:
                    failed += 1

    print(f'\n{"=" * 50}')
    print(f'📊 Done: {done} generated, {skipped} skipped, {failed} failed '
          f'(of {total} songs)')
    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
