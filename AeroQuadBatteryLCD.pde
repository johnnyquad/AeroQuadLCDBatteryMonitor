 /*
Version 0.1a John Hamill 13/01/2011 
This uses an Arduino Mega, a 4x20 line LCD and an XBEE with level shifter
to display battery volts from your AeroQuad with the voltage displayed on the top 2 lines 
in big digits. Big digits use 5 of the 8 available user defined characters in the HD447780 LCD.
To produce a nice bargraph spaning the whole bottom line of the display and having 
incrimental pixels accross each character I had to come up with a method of modifing 
only 1 user character which is done on the fly see void pixelchars below.
The bargraph only displays the top 2.5 volts from 10.0v to 12.5v or there abouts 
which make for a very quick visual indication of the battery condition ie. if 
there are very few segments left LAND NOW.
Line 2 shows status ie GOOD, WARNING or CRITICAL depending on you limits.
 The circuit:
 * LCD 04 RS pin to digital pin 12
 * LCD 06 Enable pin to digital pin 11
 * LCD 11 D4 pin to digital pin 5
 * LCD 12 D5 pin to digital pin 4
 * LCD 13 D6 pin to digital pin 3
 * LCD 14 D7 pin to digital pin 2
 * 10K var resistor:
 * ends to +5V and ground mine actually needs -3v
 * wiper to LCD VO pin (pin 3)
 * XBEE connected to Serial port 1 pins 18/19 mega
  */

// include the library code:
#include <string.h>
#include <stdlib.h>
#include <LiquidCrystal.h>
#define XBEE Serial1
#define BATGOOD 10.8
#define BATWARNING 10.6
#define BATCRITICAL 10.4
int V1;

// initialize the library with the numbers of the interface pins
// LiquidCrystal(rs, enable, d4, d5, d6, d7) 
LiquidCrystal lcd(12, 11, 7, 6, 5, 4);


//BIG FONTS
byte custchar[8][8] = {  // I'm only using the first 2 for BIGNUMS
 {
   B11111,
   B11111,
   B11111,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000
 }, {
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B11111,
   B11111,
   B11111
 }, {
   B11111,
   B11111,
   B11111,
   B00000,
   B00000,
   B11111,
   B11111,
   B11111
 }, {
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B01110,
   B01110,
   B01110
 }, {
   B00000,
   B00000,
   B00000,
   B01110,
   B01110,
   B01110,
   B00000,
   B00000
 }, {
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000
 }, {
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000,
   B00000
 }, {
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000
 }
};


//Pixel line chars for bargraph only 1 of these sub arrays is stuffed into CGRAM char 7
byte pixel[4][8] = {
 {
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000,
   B10000
 }, {
   B11000,
   B11000,
   B11000,
   B11000,
   B11000,
   B11000,
   B11000,
   B11000
 }, {
   B11100,
   B11100,
   B11100,
   B11100,
   B11100,
   B11100,
   B11100,
   B11100
 }, {
   B11110,
   B11110,
   B11110,
   B11110,
   B11110,
   B11110,
   B11110,
   B11110
 }
};


byte bignums[10][2][3] = {
 {
   {255, 0, 255},
   {255, 1, 255}
 },{
   {0, 255, 254},
   {1, 255, 1}
 },{
   {2, 2, 255},
   {255, 1, 1}
 },{
   {0, 2, 255},
   {1, 1, 255}
 },{
   {255, 1, 255},
   {254, 254, 255}
 },{
   {255, 2, 2},
   {1, 1, 255}
 },{
   {255, 2, 2},
   {255, 1, 255}
 },{
   {0, 0, 255},
   {254, 255, 254}
 },{
   {255, 2, 255},
   {255, 1, 255}
 },{
   {255, 2, 255},
   {254, 254, 255}
 }
};

void loadchars() 
{
 lcd.command(64);
 for (int i = 0; i < 8; i++)
   for (int j = 0; j < 8; j++)
     lcd.write(custchar[i][j]);
 lcd.home();
}

void pixelchars(int numPixels)
{
 lcd.command(120); //go to CGRAM address of start of char 7 
 for (int i = 0; i < 8; i++)
     lcd.write(pixel[numPixels-1][i]);//change CGRAM data to have the correct number of pixels
}

void printbigchar(byte digit, byte col, byte row, byte symbol = 0)
{
 if (digit > 9) return;
 for (int i = 0; i < 2; i++) {
   lcd.setCursor(col, row + i);
   for (int j = 0; j < 3; j++) {
     lcd.write(bignums[digit][i][j]);
   }
   lcd.write(254);
 }
 if (symbol == 1) {
   lcd.setCursor(col + 3, row + 1);
   lcd.write(3);
 } else if (symbol == 2) {
   lcd.setCursor(col + 3, row);
   lcd.write(4);
   lcd.setCursor(col + 3, row + 1);
   lcd.write(4);
 }
 
 lcd.setCursor(col + 4, row);
}


void setup() 
{
  Serial.begin(115200);
  XBEE.begin(115200); // xbee port
  // set up the LCD's number of rows and columns: 
  lcd.begin(20, 4);
  loadchars();
  // Print a message to the LCD.
  lcd.setCursor(0,0);
  lcd.print("      AeroQuad      ");
  lcd.setCursor(0,1);
  lcd.print("  Battery Monitor   ");
  lcd.setCursor(0,2);
  lcd.print("JDH 12/01/2011 V 0.1");
  lcd.setCursor(0,3);
  lcd.print("* Turn on AeroQuad *");
  delay(1800);
  lcd.clear();
  XBEE.print("S"); // send get all flight data
}

void displayFloat(float num) // Display the Battery volts in big digits on top 2 lines
{
  int t = (int)(num * 100.0);
  printbigchar((t % 10),15,0);
  t /=  10;
  printbigchar((t % 10),11,0);
  t /= 10;
  printbigchar((t % 10),6,0,1);
  t /= 10;
  printbigchar((t % 10),2,0);
  
}

void displayBarGraph(float batV)
{
  lcd.setCursor(0,2);
  lcd.print("                    "); //print 20 spaces to clear line
  if (batV < BATCRITICAL)
  {
    lcd.setCursor(0,2);
    lcd.print(" CRITICAL CRITICAL  "); 
  }
  if (batV >BATCRITICAL && batV < BATGOOD)
  {
    lcd.setCursor(0,2);
    lcd.print("* WARNING WARNING  *");
  }
  if (batV >BATGOOD)
  {
    lcd.setCursor(0,2);
    lcd.print("   BATTERY GOOD     ");
  }
  batV -= 10;
  //2.5V range
  // bottom line of LCD has 20 chars so display bar graph of top 2.5v ie. 10.0v to 12.5v
  float percentage = 100*(batV / 2.5);
  int percenti = int (percentage); // cast float to int
  int numWholeBlocks = (percentage / 5);
  if (numWholeBlocks > 20) // so we dont overwrite round back to line 0
  {
    numWholeBlocks = 20;
  }
  int numPixels = (percenti % 5);
  int i;
  lcd.setCursor(0,3);
  lcd.print("                    "); //print 20 spaces to clear line 3
  

  lcd.setCursor(0,3);
  for(i = 0; i < numWholeBlocks; i++)
  {
    lcd.print(255,BYTE); //print a solid block
  }
  if(numPixels > 0)
  {
    pixelchars(numPixels); //change CGRAM for character 7 using array pixel
    if (numWholeBlocks < 20) // so we dont overwrite round back to line 0
    {
    lcd.setCursor(numWholeBlocks,3); //move cursor back to correct pos for bar
    lcd.print(7,BYTE); // only print chr 7 if needed
    }
  }
}
String buf;

void processBuffer()
{
  int i;
  int index;
  for(i = 0; i < 4; i++)
  {
    index = buf.indexOf(',');
    if(index != -1)
    {
      buf = buf.substring(index + 1); 
    }
  }
  index = buf.indexOf(',');
  buf = buf.substring(0, index);
  //Serial.println(buf);
  char tmp[10];
  buf.toCharArray(tmp, 10);
  float batV = atof(tmp);
  //Serial.println(x);
  displayFloat(batV);
  displayBarGraph(batV);
}



void loop() 
{
  if (Serial1.available()) {
    char s1Char = Serial1.read();
    buf  += s1Char;
    if (s1Char == '\n') // wait till we get a full line from the quad
    {
      processBuffer();
    } 
  }
}

