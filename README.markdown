AeroQuad LCD Battery Monitor
========================================

Version 0.1(13/01/2011)
-----------------------
This uses an Arduino Mega, a 4x20 line LCD and an XBEE with level shifter to display battery volts from your AeroQuad with the voltage displayed on the top 2 lines in big digits. Big digits use 5 of the 8 available user defined characters in the HD447780 LCD.

To produce a nice bargraph spaning the whole bottom line of the display and having incrimental pixels accross each character I had to come up with a method of modifing only 1 user character which is done on the fly see void pixelchars below.

The bargraph only displays the top 2.5 volts from 10.0v to 12.5v or there abouts which make for a very quick visual indication of the battery condition ie. if there are very few segments left LAND NOW.

Line 2 shows status ie GOOD, WARNING or CRITICAL depending on you limits.

See LCDBattMon.jpg above as to how it looks.

V0.1 13/01/2011

johnnyquad