#ifndef MAUS
#define MAUS

#include <dos.h>
#include "defs.h"
#define MOUSEINT   0x33

unsigned mouse_check(void);
void mouse_show(void);
void mouse_hide(void);
void mouse_move(word x, word y);
void mouse_def(byte *bitfield, word x, word y);
void mouse_pos(word *x, word *y);
word mouse_press(void);
word mouse_key(word nr);
void mouse_area(word left, word top, word right, word bottom);

byte pointer[64] = {
  127, 255, 127, 255, 127, 255, 127, 255,
  127, 255, 255, 255, 192, 129, 255, 255,
  127, 255, 127, 255, 127, 255, 127, 255,
  127, 255, 255, 255, 255, 255, 255, 255,
  128, 0, 128, 0, 128, 0, 128, 0,
  128, 0, 0, 0, 63, 126, 0, 0,
  128, 0, 128, 0, 128, 0, 128, 0,
  128, 0, 0, 0, 0, 0, 0, 0,
  };

unsigned mouse_check()
{
  struct REGPACK reg;
  reg.r_ax = 0x00;
  intr(MOUSEINT, &reg);
  return(reg.r_ax != 0xffff ? 0 : reg.r_bx);
}

void mouse_show()
{
  struct REGPACK reg;
  reg.r_ax = 0x01;
  intr(MOUSEINT, &reg);
}

void mouse_hide()
{
  struct REGPACK reg;
  reg.r_ax = 0x02;
  intr(MOUSEINT, &reg);
}

void mouse_def(bitfield, x, y)
byte *bitfield;
word x, y;
{
  struct REGPACK reg;
  reg.r_ax = 0x09;
  reg.r_bx = x;
  reg.r_cx = y;
  reg.r_es = FP_SEG(bitfield);
  reg.r_dx = FP_OFF(bitfield);
  intr(MOUSEINT, &reg);
}

void mouse_pos(x, y)
word *x, *y;
{
  struct REGPACK reg;
  reg.r_ax = 0x03;
  intr(MOUSEINT, &reg);
  *x = reg.r_cx;
  *y = reg.r_dx;
}

word mouse_press()
{
  struct REGPACK reg;
  reg.r_ax = 0x03;
  intr(MOUSEINT, &reg);
  return(reg.r_bx);
}

word mouse_key(nr)
word nr;
{
  struct REGPACK reg;
  reg.r_ax = 0x06;
  reg.r_bx = nr;
  intr(MOUSEINT, &reg);
  return(reg.r_bx);
}

void mouse_move(x, y)
word x, y;
{
  struct REGPACK reg;
  reg.r_ax = 0x04;
  reg.r_cx = x;
  reg.r_dx = y;
  intr(MOUSEINT, &reg);
}

void mouse_area(left, top, right, bottom)
word left, top, right, bottom;
{
  struct REGPACK reg;
  reg.r_ax = 0x07;
  reg.r_cx = left;
  reg.r_dx = right;
  intr(MOUSEINT, &reg);
  reg.r_ax = 0x08;
  reg.r_cx = top;
  reg.r_dx = bottom;
  intr(MOUSEINT, &reg);
}

#endif