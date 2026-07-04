"""Demucs stem-separation service for LingoTune.

Separates a song into vocals and instrumental (no_vocals). Used by the
"karaoke" output mode of `generate_translation_audio.py` to replace the
original vocal with a spoken translation over a clean instrumental.

Implementation notes
--------------------
- Demucs + torch are **optional** dependencies. They are invoked via a
  subprocess (`_demucs_runner.py`) so that the rest of the pipeline keeps
  working without them installed.
- Stems are saved with `soundfile` (not `torchaudio.save`), which avoids the
  torchcodec / FFmpeg-shared-DLL requirement that bites torchaudio >= 2.6 on
  Windows.
- Results are cached on disk (one folder per song/model) so re-running the
  same song is instant.
"""

import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple


def _expected_paths(output_dir: Path, model: str, stem: str) -> Tuple[Path, Path]:
    """Return (instrumental_path, vocals_path) for the runner's output layout."""
    cache_dir = output_dir / model / stem
    return cache_dir / 'no_vocals.wav', cache_dir / 'vocals.wav'


def separate_vocals(
    audio_path: Path,
    output_dir: Path,
    model: str = 'htdemucs',
    device: Optional[str] = None,
    verbose: bool = False,
) -> Tuple[Path, Path]:
    """Separate `audio_path` into instrumental + vocals.

    Parameters
    ----------
    audio_path : Path
        Source song file (mp3/wav/...).
    output_dir : Path
        Directory where stems are cached. Layout: ``<output_dir>/<model>/<stem>/``.
    model : str
        Demucs model name (default: ``htdemucs``).
    device : str, optional
        ``'cpu'`` or ``'cuda'``. ``None`` lets the runner default to ``'cpu'``.
    verbose : bool
        If True, stream the runner's stdout/stderr to the console.

    Returns
    -------
    (instrumental_path, vocals_path)

    Raises
    ------
    RuntimeError
        If demucs/torch is not installed, or separation fails.
    """
    audio_path = Path(audio_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    instrumental, vocals = _expected_paths(output_dir, model, audio_path.stem)
    if instrumental.exists() and vocals.exists():
        if verbose:
            print(f'♻ Demucs: cached stems found for "{audio_path.stem}"')
        return instrumental, vocals

    runner = Path(__file__).parent / '_demucs_runner.py'
    cmd = [sys.executable, str(runner),
           str(audio_path), str(output_dir), model]
    if device:
        cmd.append(device)

    try:
        res = subprocess.run(cmd, capture_output=not verbose, text=True)
    except FileNotFoundError as e:
        raise RuntimeError(
            'Could not invoke Python for Demucs separation. '
            'Install deps with: pip install torch torchaudio soundfile demucs'
        ) from e

    if res.returncode != 0:
        stderr = getattr(res, 'stderr', '') or ''
        if 'ModuleNotFoundError' in stderr or 'ImportError' in stderr:
            raise RuntimeError(
                'Demucs dependencies are missing. Install with:\n'
                '  pip install torch torchaudio soundfile demucs\n'
                f'Detail: {stderr.strip()[:300]}'
            )
        raise RuntimeError(
            f'Demucs runner failed (code {res.returncode}): {stderr[:500]}'
        )

    if not instrumental.exists():
        found = list(output_dir.rglob('no_vocals.wav'))
        if not found:
            raise RuntimeError(
                f'Demucs finished but no_vocals.wav not found under {output_dir}'
            )
        instrumental = found[0]
        vocals = instrumental.parent / 'vocals.wav'
        if not vocals.exists():
            found_v = list(instrumental.parent.glob('vocals.wav'))
            if found_v:
                vocals = found_v[0]
    return instrumental, vocals


def check_demucs_available() -> bool:
    """Return True if demucs + soundfile + torch can be imported by the runner."""
    runner = Path(__file__).parent / '_demucs_runner.py'
    if not runner.exists():
        return False
    res = subprocess.run(
        [sys.executable, '-c',
         'import torch, soundfile, demucs, torchaudio'],
        capture_output=True, text=True, timeout=30,
    )
    return res.returncode == 0
