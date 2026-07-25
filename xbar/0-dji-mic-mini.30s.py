#!/usr/bin/env python3
"""xbar: whether the DJI Mic Mini is connected, and whether it is the default input."""

import json
import subprocess

MIC = "DJI Mic Mini"


def main() -> None:
    devices = [d for d in audio_devices() if d["_name"].startswith(MIC)]
    if not devices:
        print("🎙️🔴")
        print("---")
        print(f"{MIC} not connected")
        return
    is_input = is_default(devices, "input")
    print("🎙️🟢" if is_input else "🎙️🟡")
    print("---")
    print(devices[0]["_name"])
    print(f"Transport: {transport(devices[0])}")
    print(f"Sample rate: {devices[0]['coreaudio_device_srate'] / 1000:g} kHz")
    print(f"Default input: {yes_no(is_input)}")
    print(f"Default output: {yes_no(is_default(devices, 'output'))}")
    print("Sound settings… | shell=open param1=x-apple.systempreferences:com.apple.Sound-Settings.extension")


def audio_devices() -> list[dict]:
    output = subprocess.run(
        ["system_profiler", "-json", "SPAudioDataType"], check=True, capture_output=True
    ).stdout
    return json.loads(output)["SPAudioDataType"][0]["_items"]


def is_default(devices: list[dict], direction: str) -> bool:
    key = f"coreaudio_default_audio_{direction}_device"
    return any(device.get(key) == "spaudio_yes" for device in devices)


def transport(device: dict) -> str:
    return device["coreaudio_device_transport"].removeprefix("coreaudio_device_type_").capitalize()


def yes_no(value: bool) -> str:
    return "yes" if value else "no"


if __name__ == "__main__":
    main()
