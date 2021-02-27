#ifndef TEXTURE
#define TEXTURE

#include "vid.c"
#include "maus.c"
#include "graph.c"
#include "schalter.c"
#include "save.c"
#include <stdlib.h>
#include <stdio.h>

void cls(void);
void maketexture(void);

schalter scha11 = {
  0,
  242, 142, 300, 154,
  56, 0, 215,
  2,
  "TEXT",
};

schalter scha10 = {
  &scha11,
  170, 142, 240, 154,
  56, 0, 215,
  2,
  "CLEAR",
};

schalter scha9 = {
  &scha10,
  170, 157, 240, 169,
  56, 0, 215,
  2,
  "EXIT",
};

schalter scha8 = {
  &scha9,
  138, 142, 147, 186,
  56, 0, 215,
  0,
  0,
};

schalter scha1 = {
  &scha8,
  0, 0, 319, 140,
  0, 0, 0,
  0,
  0,
};

schalter scha2 = {
  &scha1,
  0, 142, 64, 154,
  56, 0, 215,
  2,
  "DRAW",
};

schalter scha3 = {
  &scha2,
  66, 142, 128, 154,
  56, 0, 215,
  2,
  "LINE",
};

schalter scha4 = {
  &scha3,
  0, 157, 128, 169,
  56, 0, 215,
  2,
  "LOAD",
};

schalter scha5 = {
  &scha4,
  66, 157, 128, 169,
  56, 0, 215,
  2,
  "SAVE",
};

schalter scha6 = {
  &scha5,
  0, 172, 64, 184,
  56, 0, 215,
  2,
  "FILL",
};

schalter scha7 = {
  &scha6,
  66, 172, 128, 184,
  56, 0, 215,
  2,
  "BOX",
};

#define       FIRST     &scha7

void cls()
{
  word x, y;
  for (x = 0; x < 320; x++)
    for (y = 0; y < 141; y++)
      put_pixel(x, y, 0);
}

void maketexture()
{
  word r, g, b;
  word x, y, i;
  char help[2];
  word xold, yold, farbe = 0;
  word ready = 0, drawnr = 1;
  schalter *sch = &scha2, *dummy;
  char name[30];

  textattr(0);
  clrscr();
  for (b = 0; b < 6; b++)
    for (g = 0; g < 6; g++)
      for (r = 0; r < 6; r++)
        put_pixel(g + 140, r + 7 * b + 144, r + g * 6 + b * 36);
  showsch(FIRST);
  mouse_hide();
  drawtangle(scha2.left, scha2.top, scha2.right, scha2.bottom, scha2.ilucol);
  drawtangle(150, 142, 160, 152, 215);
  fill(151, 143, farbe);
  gotoxy(32, 21);
  print("by M.O.", 215);
  mouse_show();

  mouse_def(pointer, 17, 6);
  mouse_show();
  mouse_key(0);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      x = x >> 1;
      gotoxy(21, 24);
      print("POS: ", 215);
      printnum(x);
      print(" ", 215);
      printnum(y);
      print("           ", 215);
    }

    testsch(x, y, FIRST, &dummy);
    if (dummy != &scha1 && dummy != &scha8)
    {
      mouse_hide();
      drawtangle(sch->left, sch->top, sch->right, sch->bottom, sch->framecol);
      mouse_show();
    }
    mouse_hide();
    dummy = sch;
    switch(testsch(x, y, FIRST, &sch))
    {
      case 1:
        drawnr = 4;
        break;
      case 2:
        drawnr = 3;
        break;
      case 4:
        gotoxy(21, 23);
        print("Dateiname: ", 215);
        getstr(name);
        gotoxy(21, 23);
        print("                     ", 215);
        cls();
        loadpic(name);
        break;
      case 3:
        gotoxy(21, 23);
        print("Dateiname: ", 215);
        getstr(name);
        gotoxy(21, 23);
        print("links oben mit Maus  ", 215);
        while (mouse_press());
        mouse_key(0);
        mouse_show();
        while (!mouse_press());
        gotoxy(21, 23);
        print("Maus rechts unten", 215);
        mouse_pos(&x, &y);
        x = x >> 1;
        xold = x;
        yold = y;
        while (mouse_press());
        gotoxy(21, 23);
        print("                     ", 215);
        mouse_hide();
        mouse_pos(&x, &y);
        x = x >> 1;
        if (x > xold)
        { i = x; x = xold; xold = i; }
        if (y > yold)
        { i = y; y = yold; yold = i; }
        savepic(x, y, xold, yold, name);
        drawtangle(x, y, xold, yold, 215);
        break;
      case 5:
        drawnr = 2;
        break;
      case 6:
        drawnr = 1;
        break;
      case 7:
        mouse_pos(&x, &y);
        x = x >> 1;
        xold = x;
        yold = y;
        switch(drawnr)
        {
          case 1:
            if (!mouse_key(0))
              while (mouse_press())
              {
                xold = x;
                yold = y;
                mouse_pos(&x, &y);
                x = x >> 1;
                if (x >= sch->left && x <= sch->right &&
                    y >= sch->top  && y <= sch->bottom)
                  drawline(xold, yold, x, y, farbe);
              }
            break;
          case 2:
            mouse_show();
            while (mouse_press());
            mouse_hide();
            mouse_pos(&x, &y);
            x = x >> 1;
            drawline(x, y, xold, yold, farbe);
            break;
          case 3:
            fill(x, y, farbe);
            break;
          case 4:
            mouse_show();
            while (mouse_press());
            mouse_hide();
            mouse_pos(&x, &y);
            x = x >> 1;
            drawtangle(x, y, xold, yold, farbe);
            break;
          case 5:
            help[1] = 0;
            do
            {
              mouse_show();
              while (!kbhit())
              {
                if (mouse_press())
                {
                  mouse_pos(&x, &y);
                  x = x >> 1;
                  gotoxy(x / 8 + 1, y / 8 + 1);
                }
              }
              help[0] = getch();
              if (help[0] != '\r')
              {
                mouse_hide();
                print(help, farbe);
              }
            }
            while (help[0] != '\r');
            sch = dummy;
            break;
        }
        sch = dummy;
        break;
      case 8:
        if (!mouse_key(0))
          while (mouse_press())
          {
            farbe = get_pixel(x, y);
            if (get_pixel(150, 143) == farbe)
              drawtangle(150, 142, 160, 152, farbe >= 215 ? 214 : 215);
            fill(151, 143, farbe);
          }
        sch = dummy;
        break;
      case 9:
        ready = 1;
        break;
      case 10:
        cls();
        break;
      case 11:
        drawnr = 5;
        break;
      default:
        sound(440);
        delay(2);
        nosound();
        break;
    }
    mouse_show();
  }
  while (!ready);
  mouse_hide();
}

#endif