#ifndef _CUSTOM_CHARS_
#define _CUSTOM_CHARS_

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

void loadchars(void) 
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

#endif
