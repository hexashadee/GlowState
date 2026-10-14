# arduino setup

this is how to upload the GlowState firmware to an arduino nano using linux

## requirements

arduino nano
addressable WS2812B rgb led strip
usb cable
arduino cli
adafruit neopixel library

## install arduino cli

follow the official installation instructions at https://arduino.github.io/arduino-cli/latest/installation/

## install board support and libraries

```bash
arduino-cli core update-index
arduino-cli core install arduino:avr
arduino-cli lib install "Adafruit NeoPixel"
```

## find the arduino

plug in the nano and run:

```bash
arduino-cli board list
```

look for the serial port, usually `/dev/ttyUSB0` or `/dev/ttyACM0`

## compile firmware

from the GlowState repository folder:

```bash
arduino-cli compile --fqbn arduino:avr:nano:cpu=atmega328 firmware/GlowState
```

## upload firmware

replace the port if yours is different

```bash
arduino-cli upload -p /dev/ttyUSB0 --fqbn arduino:avr:nano:cpu=atmega328 firmware/GlowState
```

if your nano has an older bootloader, try `arduino:avr:nano:cpu=atmega328old` instead

## led wiring

arduino nano to led strip
DIN / DI to D6
+5V to 5V 
GND to GND

connect data to the input side of the strip. arrows on the strip should point away from the arduino

## testing

the firmware receives single character commands over serial at 9600 baud

command color
A = green
B = red
D = purple
W = orange
O = off

automatic Teams synchronization requires the separate Windows PowerShell script
