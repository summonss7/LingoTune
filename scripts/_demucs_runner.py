#!/usr/bin/env python3
"""Internal Demucs runner for LingoTune.

Invoked by `demucs_service.py` via subprocess so that torch/torchcodec stay
out of the main process. Saves stems with `soundfile` instead of
`torchaudio.save`, which avoids the torchcodec / FFmpeg-shared-DLL
requirement on Windows.

Usage (not meant to be called directly)::

    python _demucs_runner.py <audio_path> <output_dir> [model] [device]
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 3:
        print('usage: _demucs_runner.py <audio> <output_dir> [model] [device]',
              file=sys.stderr)
        return 2

    audio_path = Path(sys.argv[1])
    output_dir = Path(sys.argv[2])
    model_name = sys.argv[3] if len(sys.argv) > 3 else 'htdemucs'
    device = sys.argv[4] if len(sys.argv) > 4 else 'cpu'

    # Heavy imports live here so the runner can fail loudly without affecting
    # the caller's import surface.
    import numpy as np
    import soundfile as sf
    import torch
    from demucs.apply import apply_model
    from demucs.pretrained import get_model

    output_dir.mkdir(parents=True, exist_ok=True)
    stem_dir = output_dir / model_name / audio_path.stem
    stem_dir.mkdir(parents=True, exist_ok=True)

    model = get_model(model_name)
    model.to(device)
    sr_target = int(model.samplerate)

    # Decode any audio -> stereo WAV at the model's sample rate via ffmpeg.
    # This avoids torchaudio.load (which on some builds also routes through
    # torchcodec) and guarantees a known sample rate / channel layout.
    fd, wav_tmp = tempfile.mkstemp(suffix='.wav')
    os.close(fd)
    try:
        subprocess.run(
            ['ffmpeg', '-y', '-i', str(audio_path),
             '-vn', '-ac', '2', '-ar', str(sr_target),
             '-f', 'wav', wav_tmp],
            check=True, capture_output=True,
        )
        wav_np, sr = sf.read(wav_tmp)  # (samples, channels), float64
    finally:
        try:
            os.unlink(wav_tmp)
        except OSError:
            pass

    if sr != sr_target:
        print(f'✗ unexpected sample rate {sr} (expected {sr_target})',
              file=sys.stderr)
        return 3

    # -> torch tensor shaped (1, channels, samples)
    wav = np.ascontiguousarray(wav_np.T)  # (channels, samples)
    wav_t = torch.from_numpy(wav).float().to(device)
    if wav_t.dim() == 1:
        wav_t = wav_t.unsqueeze(0)
    wav_t = wav_t.unsqueeze(0)  # batch dim

    with torch.no_grad():
        # sources shape: (n_sources, channels, samples)
        sources = apply_model(model, wav_t, split=True, overlap=0.25,
                              progress=True)[0]

    names = list(model.sources)
    for name, src in zip(names, sources):
        out = stem_dir / f'{name}.wav'
        sf.write(str(out), src.cpu().numpy().T, sr_target)

    # Instrumental = everything except vocals
    instr_idx = [i for i, n in enumerate(names) if n != 'vocals']
    if instr_idx:
        instr = sum(int(1) * sources[i] for i in instr_idx)
        sf.write(str(stem_dir / 'no_vocals.wav'),
                 instr.cpu().numpy().T, sr_target)

    print(f'✓ stems written to {stem_dir}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
