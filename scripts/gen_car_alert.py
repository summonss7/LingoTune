"""Generate car_alert.wav: 3 short beeps (880 Hz) for car detection warning."""
import math
import struct
import wave
from pathlib import Path

OUT = Path(r"D:\LingoTune\app\assets\sounds\car_alert.wav")
SR = 44100
FREQ = 880.0
DUR_ON = 0.12   # секунды звучания
DUR_OFF = 0.09  # секунды тишины
REPEATS = 3
AMP = 0.55      # амплитуда (0..1)


def env(j: int, n: int) -> float:
    """Огибающая: плавное атака/затухание, чтобы избежать щелчков."""
    attack = min(1.0, j / 400)
    decay = min(1.0, (n - j) / 400)
    return attack * decay


def main() -> None:
    samples: list[int] = []
    n_on = int(SR * DUR_ON)
    n_off = int(SR * DUR_OFF)
    for _ in range(REPEATS):
        for j in range(n_on):
            s = int(32767 * AMP * env(j, n_on) * math.sin(2 * math.pi * FREQ * j / SR))
            samples.append(s)
        for _ in range(n_off):
            samples.append(0)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", x) for x in samples))

    print(f"OK {OUT.name}: {len(samples)} samples, {len(samples)/SR:.3f}s")


if __name__ == "__main__":
    main()
