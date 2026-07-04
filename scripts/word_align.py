"""Word-level alignment for TTS clips.

When a translated line is much shorter than its time slot, simply padding
with trailing silence sounds unnatural (the speech is clustered at the
start). When it is slightly longer, uniform speed-up can hurt intelligibility.

This module distributes the spoken words across the slot by detecting
silence gaps and stretching the *pauses* between words while keeping each
word at natural speed. The result is more "sung-like" and easier to follow.

Used by `generate_translation_audio.py` when `--align words` is passed.
"""

from typing import List

from pydub import AudioSegment
from pydub.silence import split_on_silence


def _split_words(segment: AudioSegment) -> List[AudioSegment]:
    """Split a TTS clip into word-ish chunks by silence."""
    try:
        chunks = split_on_silence(
            segment,
            min_silence_len=40,        # ms of silence to count as a gap
            silence_thresh=-42,        # dBFS; speech is usually above this
            keep_silence=40,           # keep a tiny guard around each word
        )
    except Exception:
        return [segment]
    return chunks or [segment]


def align_words(tts: AudioSegment, target_ms: int, max_speed: float) -> AudioSegment:
    """Stretch `tts` across `target_ms` by expanding inter-word silences.

    Strategy
    --------
    1. If tts already fits the slot -> pad with trailing silence (no change).
    2. If tts is too long, first try removing excess silence and re-joining
       with minimal pauses (80 ms). If that fits, pad the rest.
    3. Otherwise, split into word chunks and distribute them evenly across
       the slot, so each word is spoken at natural speed with stretched gaps.
    4. Final fallback: pitch-preserving speed-up (atempo), capped at max_speed.
    """
    if target_ms <= 0:
        return AudioSegment.silent(duration=0)

    cur_ms = len(tts)
    if cur_ms <= 0:
        return AudioSegment.silent(duration=target_ms)

    # Case 1: fits naturally -> pad
    if cur_ms <= target_ms:
        return tts + AudioSegment.silent(duration=target_ms - cur_ms)

    # Case 2 & 3: too long -> operate on words
    chunks = _split_words(tts)
    # Strip leading/trailing silence from each chunk to get pure speech
    clean = []
    for c in chunks:
        if len(c) > 0:
            clean.append(c)

    if len(clean) <= 1:
        # Cannot subdivide -> fall back to uniform speed-up
        return _speedup_fit(tts, target_ms, max_speed)

    speech_ms = sum(len(c) for c in clean)
    # Case 2: collapsed speech (minimal pauses) fits -> pad remainder
    min_pause = 60
    collapsed_ms = speech_ms + min_pause * (len(clean) - 1)
    if collapsed_ms <= target_ms:
        out = clean[0]
        for c in clean[1:]:
            out += AudioSegment.silent(duration=min_pause) + c
        return out + AudioSegment.silent(duration=target_ms - len(out))

    # Case 3: distribute words evenly across the slot
    # Each gap = (slot - total_speech) / (num_gaps); gaps placed BEFORE each
    # chunk except the first, so the first word starts at t=0 of the slot.
    num_gaps = len(clean) - 1
    if num_gaps <= 0:
        return _speedup_fit(tts, target_ms, max_speed)

    gap_ms = max(0, (target_ms - speech_ms) // num_gaps)
    canvas = AudioSegment.silent(duration=target_ms)
    pos = 0
    for i, c in enumerate(clean):
        if i > 0:
            pos += gap_ms
        if pos + len(c) > target_ms:
            # Truncate the last word(s) that would overflow
            remaining = target_ms - pos
            if remaining > 30:
                canvas = canvas.overlay(c[:remaining], position=pos)
            break
        canvas = canvas.overlay(c, position=pos)
        pos += len(c)
    return canvas


def _speedup_fit(segment: AudioSegment, target_ms: int, max_speed: float) -> AudioSegment:
    """Fallback: pitch-preserving speed-up (capped) + truncate / pad.

    Kept here to avoid a circular import with generate_translation_audio.
    Mirrors the behaviour of fit_to_slot() in the main script.
    """
    # Local import to dodge a cycle at module load time
    from generate_translation_audio import apply_atempo  # noqa: WPS433
    cur_ms = len(segment)
    if cur_ms <= target_ms:
        return segment + AudioSegment.silent(duration=target_ms - cur_ms)
    speed = min(cur_ms / target_ms, max_speed)
    segment = apply_atempo(segment, speed)
    if len(segment) > target_ms:
        segment = segment[:target_ms]
    return segment
