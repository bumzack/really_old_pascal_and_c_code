#ifndef VID
#define VID

#include <dos.h>
#include "defs.h"

word setmod(word mode);
void put_pixel(word x, word y, word c);
unsigned get_pixel(word x, word y);
void init_pal(void);

#define GR320      0x0013

word setmod(mode)
word mode;
{
  struct REGPACK reg;
  word old;
  reg.r_ax = 0x0f00;
  intr(0x10, &reg);
  old = reg.r_ax & 0xf;
  reg.r_ax = mode;
  intr(0x10, &reg);
  return(old);
}

void put_pixel(x, y, c)
word x, y, c;
{
  struct REGPACK reg;
  reg.r_ax = 0x0c00 | c;
  if (x < 640 && y < 640)
  {
    reg.r_cx = x;
    reg.r_dx = y;
    intr(0x10, &reg);
  }
}

unsigned get_pixel(x, y)
word x, y;
{
  struct REGPACK reg;
  reg.r_ax = 0x0d00;
  reg.r_cx = x;
  reg.r_dx = y;
  intr(0x10, &reg);
  return(reg.r_ax & 0x00ff);
}

void init_pal()
{
  int r, g, b;
  struct REGPACK reg;
  for (b = 0; b < 6; b++)
  for (g = 0; g < 6; g++)
  for (r = 0; r < 6; r++)
  {
    reg.r_ax = 0x1010;
    reg.r_bx = r + g * 6 + b * 36;
    reg.r_cx = (word)((g) * 10.5) << 8 |
               (word)((b) * 10.5);
    reg.r_dx = (word)((r) * 10.5) << 8;
    intr(0x10, &reg);
  }
}

#endif