wiring

data goes to DIN or DI on the led strip. don't go by wire color, check the labels on the strip itself

arduino nano to LED strip
DIN / DI to D6 
+5V to 5V 
GND GND 

the led strip has an input side and an output side. make sure you're connecting the arduino to the input side look for DIN or DI printed on the strip. that's where the data wire from D6 connects some strips have arrows printed on them. the arrows should point away from the arduino, in the direction the data travels through the leds don't connect D6 to DOUT or DO, that's the output side and won't receive the signal correctly
