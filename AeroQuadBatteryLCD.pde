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

LiquidCrystal lcd(12, 11, 7, 6, 5, 4);
#include "CustomChars.h"

#define XBEE Serial1
#define BATGOOD 10.8
#define BATWARNING 10.6
#define BATCRITICAL 10.4
int V1;

// initialize the library with the numbers of the interface pins
// LiquidCrystal(rs, enable, d4, d5, d6, d7) 


String buf;
unsigned long previousTime;
unsigned long retryTime;

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

void processBuffer(void)
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
  //Clear buffer
  buf = "";
  float batV = atof(tmp);
  Serial.println(batV);
  displayFloat(batV);
  displayBarGraph(batV);
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

void displayDisconnected(void)
{
  lcd.setCursor(0,0);
  lcd.print("                   ");
  lcd.setCursor(0,1);
  lcd.print("                    ");
  lcd.setCursor(0,2);
  lcd.print("     DISCONECTED    ");
  lcd.setCursor(0,3);
  lcd.print("* Turn on AeroQuad *");
}

void retryConnection(void)
{
  Serial.println("S sent");
  XBEE.print("S");
  displayDataSent();
}

void displayDataSent(void)
{
  //Indicate data sent
  lcd.setCursor(19,0);
  lcd.print((char)0x7e);
}

void clearDataSent(void)
{
  lcd.setCursor(19,0);
  lcd.print(" ");
}

void displayDataReceived(void)
{
  lcd.setCursor(0,0);
  lcd.print((char)0x7e);
}

void clearDataReceived(void)
{
  lcd.setCursor(0,0);
  lcd.print(" "); 
}

byte disconnected;

void loop() 
{
  unsigned long currentTime = millis();
  unsigned long delta = currentTime - previousTime;
  //Serial.println(delta);

  //We haven't received bytes in 1.5 seconds
  if(delta > 1500)
  {
    //Only clear screen once
    if(!disconnected)
    {
      displayDisconnected();
      disconnected = true;
    }
    
    //Retry every 500ms
    if(currentTime - retryTime > 500)
    { 
      retryTime = currentTime;
      retryConnection();
    }else if(currentTime - retryTime > 250)
    {
      //Clear the send indicator before the next retry. Creates a nice pulse effect
      clearDataSent();
    }
  }
  
  if (XBEE.available()) {
    previousTime = currentTime;
    disconnected = false;

    char s1Char = XBEE.read();
    buf  += s1Char;
    Serial.println(buf);
    if (s1Char == '\n') // wait till we get a full line from the quad
    {
      processBuffer();
    } 
    displayDataReceived();
    clearDataSent();
  }else
  {
    clearDataReceived();
  }
}

