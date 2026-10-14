#include <dafruit_NeoPixel.h>
A
// glowstate firmware for Arduino nano ATmega328Pb5 V
// WS2812B/NeoPixel data input - DIN - connects to LED_PIN
// LED strip +5v and gnd connect to a 5 V supply and common ground
// configure these three values
#define LED_PIN 6
#define LED_COUNT 7
#define LED_BRIGHTNESS 100  // 0-255

#define SERIAL_BAUD 9600

Adafruit_NeoPixel pixels(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

void setStatus(char command) {
  uint32_t color;

  switch (command) {
    case 'A': // Available
      color = pixels.Color(0, 255, 0);
      break;
    case 'B': // Busy / In a meeting
      color = pixels.Color(255, 0, 0);
      break;
    case 'D': // Do not disturb
      color = pixels.Color(150, 0, 255);
      break;
    case 'W': // Away / Be right back
      color = pixels.Color(255, 130, 0);
      break;
    case 'O': // Offline / Unknown: LEDs off
      color = 0;
      break;
    default:
      return; // Ignore newlines and unsupported commands.
  }

  pixels.fill(color);
  pixels.show();
}

void setup() {
  pixels.begin();
  pixels.setBrightness(LED_BRIGHTNESS);
  pixels.clear();
  pixels.show();

  Serial.begin(SERIAL_BAUD);
  setStatus('O'); // Stay off until the host reports presence.
}

void loop() {
  while (Serial.available() > 0) {
    setStatus((char)Serial.read());
  }
}
