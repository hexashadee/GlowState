# GlowState Firmware

Arduino firmware for the GlowState MS Teams light.

## hardware

* Arduino Nano
* 7 addressable RGB LEDs
* USB connection

## Progress

LED communication and color testing are working.

Automatic MS Teams presence sync is under dev.

## firmware

the arduino firmware is available in [`GlowState/GlowState.ino`](GlowState/GlowState.ino)

it controls the neopixel leds using serial commands sent over usb

automatic teams presence syncing is handled separately by the windows powershell script
