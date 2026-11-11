#!/usr/bin/env python3
"""
Создание keystore для подписи Android APK
Требует установленных: Java (для keytool)
"""
import subprocess
import os
import sys
from pathlib import Path

def create_keystore():
    """Создает keystore для подписи APK"""

    keystore_path = str(Path(__file__).resolve().parent / "android" / "app" / "lingotune-release.jks")

    if os.path.exists(keystore_path):
        print(f"✅ Keystore уже существует: {keystore_path}")
        return keystore_path

    # Попытка найти keytool
    possible_paths = [
        "/c/Program Files/Java/*/bin/keytool.exe",
        "/c/Program Files (x86)/Java/*/bin/keytool.exe",
    ]

    keytool_path = None
    for path_pattern in possible_paths:
        import glob
        matches = glob.glob(path_pattern)
        if matches:
            keytool_path = matches[0]
            break

    if not keytool_path:
        print("❌ keytool не найден в стандартных директориях Java")
        print("❌ Keystore не может быть создан")
        return None

    print(f"🔧 Используем keytool: {keytool_path}")

    # Пароль — из переменной окружения (или ввод вручную); в коде не хранится
    password = os.environ.get("LINGOTUNE_KEYSTORE_PASSWORD")
    if not password:
        import getpass
        password = getpass.getpass("🔐 Пароль для нового keystore: ")

    # Параметры для создания keystore
    command = [
        keytool_path,
        "-genkey",
        "-v",
        "-keystore", keystore_path,
        "-keyalg", "RSA",
        "-keysize", "2048",
        "-validity", "10000",
        "-alias", "lingotune",
        "-storepass", password,
        "-keypass", password,
        "-dname", "CN=LingoTune, OU=Development, O=LingoTune, L=City, S=State, C=US"
    ]

    try:
        print("🔧 Создание keystore...")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True
        )
        print("✅ Keystore успешно создан!")
        print(f"📍 Путь: {keystore_path}")
        print("🔐 Пароль: задан через LINGOTUNE_KEYSTORE_PASSWORD или ввод (не выводится)")
        print(f"🔑 Alias: lingotune")
        return keystore_path

    except subprocess.CalledProcessError as e:
        print(f"❌ Ошибка при создании keystore: {e}")
        print(f"❌ Stderr: {e.stderr}")
        return None
    except Exception as e:
        print(f"❌ Неожиданная ошибка: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Создание keystore для LingoTune\n")
    keystore = create_keystore()
    if keystore:
        print("\n✅ Keystore готов к использованию!")
    else:
        print("\n❌ Не удалось создать keystore")
        sys.exit(1)
