#!/usr/bin/env python3
"""
LingoTune - Translation Audio Generator
=======================================
Generates a spoken-translation audio track that is time-aligned to the
original song's LRC timestamps, then mixes it with the source audio.
Intended for karaoke-style language learning.

Pipeline (per LRC line):
    1. Parse LRC  -> (start_time, original_text)
    2. Look up the translated text for the target language in the JSON file
    3. Synthesize TTS via edge-tts (free, no API key)
    4. Fit the TTS clip into the line's time slot:
       speed up (capped, pitch-preserving) or pad with silence
    5. Overlay the clip onto a silent canvas at the line's start time
    6. Mix the canvas with the base audio (mode-dependent):
       - 'mixed'/'ducked'/'tts_only' use the original song
       - 'karaoke' uses the Demucs-separated instrumental (vocal removed)
    7. Export the result as a 320 kbps MP3

Inputs match the formats produced by `scripts/process_song.py` and
`scripts/create_full_json_from_lrc.py`.

Optional dependencies
---------------------
- Demucs + torch (only required for `--mode karaoke`):
      pip install torch demucs

Example
-------
    python scripts/generate_translation_audio.py \
        --audio input/song.mp3 \
        --lrc input/song.lrc \
        --translations input/song.json \
        --language ru \
        --mode mixed
"""

import argparse
import json
import os
import random
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import edge_tts
from pydub import AudioSegment

from voices_map import get_female_voice_for_language, get_voice_for_language


# Matches an LRC timestamp like [01:23.45] or [01:23.456]
LRC_LINE_RE = re.compile(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)')


# --------------------------------------------------------------------------- #
# Parsing
# --------------------------------------------------------------------------- #

def parse_lrc(lrc_path: Path) -> List[Dict]:
    """Parse an .lrc file into a list of {'time': float_seconds, 'text': str}."""
    out: List[Dict] = []
    with open(lrc_path, 'r', encoding='utf-8') as f:
        for raw in f:
            m = LRC_LINE_RE.search(raw)
            if not m:
                continue
            minutes = int(m.group(1))
            seconds = int(m.group(2))
            frac = m.group(3)
            # 2-digit fraction -> centiseconds (*10); 3-digit -> milliseconds
            ms = int(frac) * 10 if len(frac) == 2 else int(frac)
            total = minutes * 60 + seconds + ms / 1000.0
            out.append({'time': total, 'text': m.group(4).strip()})
    return out


def load_translations(json_path: Path, language: str) -> Dict[int, str]:
    """Load translated text for the given language from the JSON file.

    Returns a dict keyed by `round(startTime * 100)` (centiseconds) to make
    lookups resilient to sub-centisecond float jitter.

    Raises ValueError if the language is not present in the file.
    """
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    available: List[str] = []
    for tr in data.get('translations', []):
        lang = tr.get('language')
        available.append(lang)
        if lang != language:
            continue
        result: Dict[int, str] = {}
        for line in tr.get('lines', []):
            t = float(line.get('startTime', 0.0))
            text = (line.get('text') or '').strip()
            result[round(t * 100)] = text
        return result

    raise ValueError(
        f"Language '{language}' not found in {json_path}. "
        f"Available languages: {available}"
    )


def find_translation(line_time: float, translations: Dict[int, str],
                     tolerance_cs: int = 50) -> Optional[str]:
    """Return the translated text for the given line time, or None.

    Exact centisecond match first, then a fuzzy match within `tolerance_cs`
    centiseconds (default = 0.5 s) to absorb LRC/JSON rounding differences.
    """
    key = round(line_time * 100)
    exact = translations.get(key)
    if exact:
        return exact
    for k, text in translations.items():
        if text and abs(k - key) <= tolerance_cs:
            return text
    return None


# --------------------------------------------------------------------------- #
# TTS
# --------------------------------------------------------------------------- #

def synth_line(text: str, voice: str, out_path: Path, rate: str = '+0%',
               max_retries: int = 5, base_delay: float = 2.0) -> bool:
    """Synthesize a single line via edge-tts (synchronous wrapper).

    `rate` is an edge-tts rate string like '+30%' (faster) or '-10%' (slower);
    it is applied at generation time so the voice quality stays natural.

    Retries up to `max_retries` times with exponential backoff
    (`base_delay` * 2**(attempt-1) + jitter) on exceptions or empty output.
    This makes long batch runs resilient to edge-tts throttling (HTTP 429)
    and transient network errors, so lines are not silently dropped.

    Returns True on success, False otherwise.
    """
    last_err: Optional[Exception] = None
    for attempt in range(1, max_retries + 1):
        try:
            edge_tts.Communicate(text, voice, rate=rate).save_sync(str(out_path))
            if out_path.exists() and out_path.stat().st_size > 0:
                return True
            last_err = RuntimeError('empty output')
        except Exception as e:
            last_err = e
        try:
            if out_path.exists():
                out_path.unlink()
        except OSError:
            pass
        if attempt < max_retries:
            delay = base_delay * (2 ** (attempt - 1)) + random.uniform(0.0, 1.0)
            print(f'  \u26a0 TTS attempt {attempt}/{max_retries} failed '
                  f'({last_err}); retrying in {delay:.1f}s', file=sys.stderr)
            time.sleep(delay)
    print(f'  \u2717 TTS error after {max_retries} attempts: {last_err}',
          file=sys.stderr)
    return False


# --------------------------------------------------------------------------- #
# Audio manipulation
# --------------------------------------------------------------------------- #

def apply_atempo(segment: AudioSegment, speed: float) -> AudioSegment:
    """Pitch-preserving tempo change using ffmpeg's `atempo` filter.

    ffmpeg (>= 4.0) supports a single atempo in the range 0.5-100.0, so no
    chaining is required for realistic speech speed-ups.
    """
    if abs(speed - 1.0) < 0.01:
        return segment
    speed = max(0.5, min(speed, 100.0))

    # Use mkstemp + close so the files are writable by ffmpeg on Windows.
    fd, in_path = tempfile.mkstemp(suffix='.wav')
    os.close(fd)
    fd, out_path = tempfile.mkstemp(suffix='.wav')
    os.close(fd)
    try:
        segment.export(in_path, format='wav')
        cmd = [
            'ffmpeg', '-y', '-i', in_path,
            '-filter:a', f'atempo={speed:.4f}',
            '-vn', out_path,
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0 or not os.path.exists(out_path):
            raise RuntimeError(f'ffmpeg atempo failed: {res.stderr[:200]}')
        return AudioSegment.from_file(out_path, format='wav')
    finally:
        for p in (in_path, out_path):
            try:
                os.unlink(p)
            except OSError:
                pass


def fit_to_slot(segment: AudioSegment, target_ms: int, max_speed: float,
                align: str = 'stretch', pad: bool = True) -> AudioSegment:
    """Fit a segment into `target_ms`.

    `align` controls the strategy when the clip is longer or shorter than the
    slot:
    - 'stretch' (default): pitch-preserving speed-up (capped) or pad silence.
    - 'words': distribute spoken words across the slot by expanding pauses,
      keeping each word at natural speed (see word_align.align_words).

    `pad` controls what happens when the clip is SHORTER than the slot:
    - True (default): pad with trailing silence so the clip fills the slot.
    - False: return the clip as-is (compact). Used by variant v2 so a fast,
      short translation does not get stretched across the whole line slot.
    """
    if align == 'words':
        # Lazy import so the rest of the script runs without pydub.silence
        from word_align import align_words
        return align_words(segment, target_ms, max_speed)

    if target_ms <= 0:
        return AudioSegment.silent(duration=0)
    cur_ms = len(segment)
    if cur_ms <= 0:
        return AudioSegment.silent(duration=target_ms) if pad else AudioSegment.empty()

    if cur_ms > target_ms:
        # Speed up only as much as `max_speed` allows; truncate the remainder
        speed = min(cur_ms / target_ms, max_speed)
        segment = apply_atempo(segment, speed)
        if len(segment) > target_ms:
            segment = segment[:target_ms]
        return segment

    if not pad:
        # Compact: keep the natural (already possibly fast) length.
        return segment

    # Shorter than the slot -> pad with trailing silence
    return segment + AudioSegment.silent(duration=target_ms - cur_ms)


def fit_to_gap(segment: AudioSegment, slot_start_ms: int, slot_end_ms: int,
               original_text: str, max_speed: float,
               pre_gap_ms: int = 150, min_gap_ms: int = 400):
    """End-anchored gap placement.

    The spoken translation is anchored to **end** right before the next phrase
    begins (i.e. just before `slot_end_ms`, which is the LRC timestamp of the
    next line — the real "end-of-phrase" boundary marker). This pushes the
    translation into the instrumental tail of the slot and avoids overlapping
    the current vocal, which the previous start-anchored estimate did.

    Logic:
    - The clip may occupy any window inside ``[slot_start, slot_end - pre_gap]``.
    - It is sped up (stretch, up to `max_speed`) only as much as needed to fit.
    - It is then placed so its **tail** aligns with ``slot_end - pre_gap``:
      you hear the original line, then the translation right before the next
      line kicks in.

    `original_text` is accepted for API symmetry but no longer used for an
    estimate (the next-line timestamp is the reliable boundary).

    Returns (fitted_segment, position_ms) or (None, 0) if there is no room.
    """
    if slot_end_ms <= slot_start_ms:
        return None, 0
    tts_end = slot_end_ms - pre_gap_ms
    available_ms = tts_end - slot_start_ms
    if available_ms < min_gap_ms:
        return None, 0

    clip = segment
    cur_ms = len(clip)
    # Speed up ONLY when the natural clip is longer than the window.
    # Short clips keep their natural length (no padding) so that end-anchoring
    # actually places the *speech* (not trailing silence) just before the next phrase.
    if cur_ms > available_ms:
        speed = min(cur_ms / available_ms, max_speed)
        clip = apply_atempo(clip, speed)
        if len(clip) > available_ms:
            clip = clip[:available_ms]

    # End-anchor: the clip's tail sits just before the next phrase begins.
    pos_ms = max(slot_start_ms, tts_end - len(clip))
    return clip, pos_ms


def generate_tts_canvas(
    lines: List[Dict],
    translations: Dict[int, str],
    voice: str,
    total_ms: int,
    max_speed: float,
    align: str = 'stretch',
    placement: str = 'inline',
    gap_speed: float = 2.2,
    rate: str = '+0%',
    pad: bool = True,
    lead_ms: int = 0,
) -> Tuple[AudioSegment, int, int]:
    """Build a silent canvas of length `total_ms` with one TTS clip per line.

    Placement strategies:
    - 'inline' (default): the TTS clip is placed at the line's start time.
      With `pad=True` it fills the whole slot; with `pad=False` (v2/v3) it stays
      compact. `rate` controls the speaking speed at generation time.
      `lead_ms` shifts the start (negative = earlier, e.g. -1000 for 1s before).
    - 'gap' ("echo"): the clip is end-anchored just before the next line,
      spoken quickly (stretch + gap_speed). Leaves room for the original vocal.

    Returns (canvas, lines_ok, lines_skipped).
    """
    canvas = AudioSegment.silent(duration=total_ms)
    ok = 0
    skipped = 0
    n = len(lines)
    # Gap placement always speaks quickly with stretch fitting.
    speed_for_placement = gap_speed if placement == 'gap' else max_speed

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir_p = Path(tmpdir)
        for i, line in enumerate(lines):
            start_ms = int(line['time'] * 1000)
            if i + 1 < n:
                end_ms = int(lines[i + 1]['time'] * 1000)
            else:
                end_ms = total_ms
            slot_ms = max(0, end_ms - start_ms)

            text = find_translation(line['time'], translations)
            if not text:
                skipped += 1
                print(f'  [{i + 1}/{n}] skip (no translation)')
                continue

            tts_path = tmpdir_p / f'line_{i:04d}.mp3'
            if not synth_line(text, voice, tts_path, rate=rate):
                skipped += 1
                continue

            try:
                tts_seg = AudioSegment.from_file(str(tts_path), format='mp3')
            except Exception as e:
                print(f'  [{i + 1}/{n}] ✗ cannot read TTS: {e}', file=sys.stderr)
                skipped += 1
                continue

            if placement == 'gap':
                fitted, pos_ms = fit_to_gap(
                    tts_seg, start_ms, end_ms, line['text'],
                    speed_for_placement,
                )
                if fitted is None:
                    skipped += 1
                    print(f'  [{i + 1}/{n}] skip (no room in gap)')
                    continue
                canvas = canvas.overlay(fitted, position=pos_ms)
                preview = text[:50].replace('\n', ' ')
                print(f'  [{i + 1}/{n}] ok gap '
                      f'(@{pos_ms}ms, {len(tts_seg)}ms->'
                      f'{len(fitted)}ms): "{preview}"')
            else:
                fitted = fit_to_slot(tts_seg, slot_ms, max_speed,
                                     align=align, pad=pad)
                # Apply lead-in offset (clamped to >= 0); inline placement only.
                pos_ms = max(0, start_ms + lead_ms)
                if len(fitted) > 0:
                    canvas = canvas.overlay(fitted, position=pos_ms)
                ok += 1
                preview = text[:50].replace('\n', ' ')
                mode = 'compact' if not pad else align
                lead_txt = f', lead={lead_ms}ms' if lead_ms else ''
                print(f'  [{i + 1}/{n}] ok inline '
                      f'(@{pos_ms}ms, {len(tts_seg)}ms->'
                      f'{len(fitted)}ms, {mode}, rate={rate}{lead_txt}): '
                      f'"{preview}"')
                continue
            ok += 1

    return canvas, ok, skipped


# --------------------------------------------------------------------------- #
# Mixing
# --------------------------------------------------------------------------- #

def mix_audio(base: AudioSegment, tts: AudioSegment, mode: str,
              orig_gain_db: float = 0.0, tts_gain_db: float = 0.0) -> AudioSegment:
    """Mix the base audio (original song or instrumental) and the TTS canvas.

    `orig_gain_db` / `tts_gain_db` are ABSOLUTE gains (dB) applied to the base
    and TTS respectively. The mode-based loudness presets are resolved by the
    caller (in `main`) and passed in here, so this function stays predictable:
    result = (base + orig_gain_db) overlaid with (tts + tts_gain_db).

    `mode == 'tts_only'` is the only special case (returns TTS alone).
    """
    if mode == 'tts_only':
        return tts + tts_gain_db
    return (base + orig_gain_db).overlay(tts + tts_gain_db)


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description='Generate a spoken translation track time-aligned to LRC timestamps.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            'Example:\n'
            '  python scripts/generate_translation_audio.py \\\n'
            '      --audio input/song.mp3 --lrc input/song.lrc \\\n'
            '      --translations input/song.json --language ru --mode mixed\n'
        ),
    )
    p.add_argument('--audio', required=True, type=Path,
                   help='Path to source audio (mp3/wav/m4a/ogg)')
    p.add_argument('--lrc', required=True, type=Path,
                   help='Path to .lrc file with timestamps')
    p.add_argument('--translations', required=True, type=Path,
                   help='Path to .json file with translations')
    p.add_argument('--language', required=True,
                   help='Target language code (ru, en, de, trans, ...)')
    p.add_argument('--variant', choices=['v1', 'v2', 'v3'], default='v1',
                   help='Generation preset. v1 = inline padded. v2 (RECOMMENDED) '
                        '= female, fast (+50%%), compact, tts boosted, over the '
                        'full-volume original. v3 = EXPERIMENTAL / not recommended: '
                        'v2 + slowed original (slow-factor 1.10) and translation '
                        'leading 1s — slows the song, which changes its feel.')
    p.add_argument('--mode', choices=['mixed', 'tts_only', 'ducked', 'karaoke'],
                   default='mixed',
                   help='Output mix mode (default: mixed). "karaoke" removes the '
                        'original vocal via Demucs and overlays the spoken translation '
                        'on the clean instrumental.')
    p.add_argument('--placement', choices=['inline', 'gap'], default=None,
                   help='Where to put the TTS within each line slot. "inline" = '
                        'at the line start timestamp (default). "gap" = end-anchored '
                        'just before the next line (spoken quickly). Defaults are '
                        'driven by --variant (v1/v2 = inline).')
    p.add_argument('--align', choices=['stretch', 'words'], default='stretch',
                   help='TTS fitting for inline+padded placement: "stretch" = '
                        'uniform speed-up/pad (default); "words" = keep words at '
                        'natural speed and stretch the pauses between them. '
                        'Ignored for v2 (compact) and gap placement.')
    p.add_argument('--rate', default=None,
                   help='edge-tts speaking rate, e.g. "+50%%" (faster) or "-10%%". '
                        'Default depends on --variant: v1="+0%%", v2="+50%%", v3="+40%%".')
    p.add_argument('--slow-factor', type=float, default=None,
                   help='Slow down the BASE audio (and stretch the LRC timeline '
                        'accordingly, so the translation stays in sync). 1.10 = '
                        '10%% slower / longer. Default: v3=1.10, else 1.0.')
    p.add_argument('--lead-ms', type=int, default=None,
                   help='Shift (ms) for the translation start vs the line '
                        'timestamp. Negative = earlier. Default: v3=-1000, else 0.')
    p.add_argument('--orig-gain', type=float, default=None,
                   help='Loudness gain (dB) for the base audio (original or '
                        'instrumental). Default depends on --variant/--mode: '
                        'v2 = 0; v3 = -1; v1 mixed = -12; v1 ducked/karaoke = 0.')
    p.add_argument('--tts-gain', type=float, default=None,
                   help='Loudness gain (dB) for the spoken translation. '
                        'Default: v2 = +3; v3 = +4; v1 = 0.')
    p.add_argument('--voice', default='',
                   help='edge-tts voice name. Auto-selected by --language and '
                        '--variant if empty (v1=default voice, v2=female voice).')
    p.add_argument('--max-speed', type=float, default=1.5,
                   help='Max TTS speed-up for inline placement (default: 1.5)')
    p.add_argument('--gap-speed', type=float, default=2.2,
                   help='Max TTS speed-up for gap placement (default: 2.2)')
    p.add_argument('--stems-dir', type=Path, default=None,
                   help='Directory to cache Demucs stems (karaoke mode). '
                        'Default: <audio parent>/.stems')
    p.add_argument('--demucs-model', default='htdemucs',
                   help='Demucs model name (default: htdemucs)')
    p.add_argument('--device', default='',
                   help='Demucs device: "cpu" or "cuda" (default: auto)')
    p.add_argument('--test', type=int, default=0,
                   help='Process only the first N lines (0 = all)')
    p.add_argument('--output', '-o', type=Path, default=None,
                   help='Output MP3 path (default: alongside audio, with _<lang> suffix)')
    return p


def main(argv: Optional[List[str]] = None) -> int:
    args = build_parser().parse_args(argv)

    # Validate inputs
    for label, path in [('audio', args.audio),
                        ('lrc', args.lrc),
                        ('translations', args.translations)]:
        if not path.exists():
            print(f'✗ {label} file not found: {path}', file=sys.stderr)
            return 2

    # Resolve voice
    # Resolve placement from --variant when not explicitly set.
    # Both v1 and v2 default to "inline" (at the line timestamp); "gap" is
    # available as an explicit opt-in via --placement for end-anchored echo.
    placement = args.placement or 'inline'

    # Resolve rate from --variant when not explicitly set.
    # v3 speaks a bit slower than v2 (better intelligibility over a slowed song).
    if args.rate is not None:
        rate = args.rate
    elif args.variant == 'v3':
        rate = '+40%'
    elif args.variant == 'v2':
        rate = '+50%'
    else:
        rate = '+0%'

    # Resolve slow-factor (v3 slows the base audio by 10%).
    slow_factor = args.slow_factor if args.slow_factor is not None else (
        1.10 if args.variant == 'v3' else 1.0
    )

    # Resolve lead-in offset (v3 starts the translation 1s before the timestamp).
    lead_ms = args.lead_ms if args.lead_ms is not None else (
        -1000 if args.variant == 'v3' else 0
    )

    # v2/v3 = compact (no padding): the fast translation stays short and does
    # not get stretched across the whole line slot.
    pad = args.variant not in ('v2', 'v3')

    # Resolve loudness gains (dB) for base audio and TTS.
    if args.variant in ('v2', 'v3'):
        # v3 quiets the original a bit (-1 dB) so the translation stands out.
        default_orig_gain = -1.0 if args.variant == 'v3' else 0.0
        default_tts_gain = 4.0 if args.variant == 'v3' else 3.0
    else:
        if args.mode == 'mixed':
            default_orig_gain, default_tts_gain = -12.0, 0.0
        elif args.mode == 'ducked':
            default_orig_gain, default_tts_gain = 0.0, -6.0
        else:  # karaoke, tts_only
            default_orig_gain, default_tts_gain = 0.0, 0.0
    orig_gain_db = args.orig_gain if args.orig_gain is not None else default_orig_gain
    tts_gain_db = args.tts_gain if args.tts_gain is not None else default_tts_gain

    # Resolve voice: explicit --voice wins; otherwise v2/v3 pick a female voice.
    if args.voice:
        voice = args.voice
    elif args.variant in ('v2', 'v3'):
        voice = get_female_voice_for_language(args.language)
    else:
        voice = get_voice_for_language(args.language)
    if not voice:
        print(f'✗ No voice mapping for language "{args.language}". '
              f'Pass --voice explicitly.', file=sys.stderr)
        return 2
    print(f'🎤 Voice: {voice}  (language: {args.language}, '
          f'variant: {args.variant}, placement: {placement}, '
          f'rate: {rate}, pad: {pad}, slow: {slow_factor}, lead: {lead_ms}ms, '
          f'orig: {orig_gain_db:+.1f}dB, tts: {tts_gain_db:+.1f}dB)')

    # Parse LRC
    lines = parse_lrc(args.lrc)
    if not lines:
        print(f'✗ No timestamped lines found in {args.lrc}', file=sys.stderr)
        return 3
    if args.test > 0:
        lines = lines[:args.test]
        print(f'⚠ TEST MODE: processing only first {len(lines)} lines')

    # Parse translations
    try:
        translations = load_translations(args.translations, args.language)
    except ValueError as e:
        print(f'✗ {e}', file=sys.stderr)
        return 3
    print(f'📝 LRC lines: {len(lines)}; translations loaded: {len(translations)}')

    # Load source audio (original, or instrumental for karaoke mode)
    if args.mode == 'karaoke':
        print(f'🎙 Karaoke mode: separating vocals with Demucs...')
        from demucs_service import separate_vocals
        stems_dir = args.stems_dir or args.audio.parent / '.stems'
        device = args.device or None
        try:
            instrumental_path, _ = separate_vocals(
                args.audio, stems_dir, model=args.demucs_model, device=device,
                verbose=True,
            )
        except RuntimeError as e:
            print(f'✗ Demucs separation failed: {e}', file=sys.stderr)
            return 5
        print(f'   ✓ instrumental: {instrumental_path}')
        load_path = instrumental_path
    else:
        load_path = args.audio

    print(f'🎵 Loading audio: {load_path.name}')
    try:
        original = AudioSegment.from_file(str(load_path))
    except Exception as e:
        print(f'✗ Cannot load audio ({e}). Is ffmpeg installed and in PATH?',
              file=sys.stderr)
        return 4
    total_ms = len(original)
    print(f'   duration: {total_ms / 1000:.1f}s')

    # Slow down the base audio if requested (v3). Pitch is preserved (atempo).
    # The LRC timeline is stretched by the same factor so the translation stays
    # in sync with the (now slower) vocal.
    if slow_factor and abs(slow_factor - 1.0) > 1e-3:
        speed = 1.0 / slow_factor
        print(f'🐢 Slowing base audio by factor {slow_factor:.2f} '
              f'(speed {speed:.3f}, pitch preserved)...')
        original = apply_atempo(original, speed)
        total_ms = len(original)
        print(f'   new duration: {total_ms / 1000:.1f}s')
        for ln in lines:
            ln['time'] = ln['time'] * slow_factor

    # Generate TTS canvas
    print(f'🔊 Synthesizing TTS per line '
          f'(placement={placement}, rate={rate}, pad={pad}, lead={lead_ms}ms)...')
    tts_canvas, ok, skipped = generate_tts_canvas(
        lines, translations, voice, total_ms, args.max_speed,
        align=args.align, placement=placement, gap_speed=args.gap_speed,
        rate=rate, pad=pad, lead_ms=lead_ms,
    )
    print(f'   ✓ {ok} lines synthesized, {skipped} skipped')

    # Mix and export
    print(f'🎚 Mixing (mode={args.mode}, '
          f'orig {orig_gain_db:+.1f}dB, tts {tts_gain_db:+.1f}dB)...')
    result = mix_audio(original, tts_canvas, args.mode,
                       orig_gain_db=orig_gain_db, tts_gain_db=tts_gain_db)

    out_path = args.output or args.audio.with_name(f'{args.audio.stem}_{args.language}.mp3')
    out_path.parent.mkdir(parents=True, exist_ok=True)
    print(f'💾 Exporting: {out_path}')
    result.export(str(out_path), format='mp3', bitrate='320k')
    print(f'✅ Done: {out_path}  ({len(result) / 1000:.1f}s)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
