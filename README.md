# GlowState 

a diy microsoft teams presence light built using an arduino nano, addressable rgb leds, and a 3d printed enclosure

the idea is pretty simple. your light changes color based on your microsoft teams availability so people can tell when you're busy without having to check teams

## features

- automatic teams presence syncing via microsoft graph (in development)
- 7 addressable rgb leds
- adjustable brightness
- usb powered
- custom 3d printed enclosure
- no third party powershell modules required

## status colors

teams status = led color
available = green 
busy = red 
do not disturb = purple 
away = orange 
offline = off 

## getting started

**hardware**

see [wiring instructions](hardware/wiring.md)

**arduino**

see [arduino setup](docs/arduino-setup.md)

**windows**

see [windows setup](docs/windows-setup.md)

## how it works

the windows powershell script checks your teams status through microsoft graph and sends a command to the arduino over usb

the arduino reads that command and changes the leds to match your status

## project status

the arduino hardware and led controls are working

## 3d printed enclosure

the enclosure is based on the [Radig Status Light](https://makerworld.com/en/models/2955341-radig-status-light) from MakerWorld

i only used the 3d printed design. all firmware, led control, and microsoft teams integration were developed separately for GlowState

credit for the physical enclosure design goes to the original creator
