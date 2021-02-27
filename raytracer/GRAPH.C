#ifndef GRAPH
#define GRAPH

#include "vid.c"
#include "maus.c"

void drawline(word x0, word y0, word x1, word y1, word c);
void drawtangle(word left, word top, word right, word bottom, word c);
void fillhelp(int x, int y, int co, int c, int dx, int dy);
void fill(word x, word y, word co);

void drawline(x0, y0, x1, y1, c)
word x0, y0, x1, y1, c;
{
  word ax, ay, dx, dy, iy, ix, h, of, ct;
  ax = ay = 0;
  if (x1 >= x0)
  {
    dx = x1 - x0; ix = 1;
  }
  else
  {
    dx = x0 - x1; ix = -1;
  }
  if (y1 >= y0)
  {
    dy = y1 - y0; iy = 1;
  }
  else
  {
    dy = y0 - y1; iy = -1;
  }
  if (dx < dy)
  {
    h = dx; dx = dy; dy = h;
    ay = ix; ax = iy; ix = 0; iy = 0;
  }
  of = dx >> 1;
  ct = 1;
  put_pixel(x0, y0, c);
  while (dx >= ct)
  {
    x0 += ix; y0 += ax;
    ct++; of += dy;
    if (of > dx)
    {
      of -= dx; x0 += ay;
      y0 += iy;
    }
    put_pixel(x0, y0, c);
  }
}

void drawtangle(left, top, right, bottom, c)
word left, top, right, bottom, c;
{
  word i;
  if (left > right)
  { i = left; left = right; right = i; }
  if (top > bottom)
  { i = top; top = bottom; bottom = i; }

  for (i = left; i <= right; i++)
  {
    put_pixel(i, top, c);
    put_pixel(i, bottom, c);
  }
  for (i = top; i <= bottom; i++)
  {
    put_pixel(left, i, c);
    put_pixel(right, i, c);
  }
}

void fillhelp(x, y, co, c, dx, dy)
int x, y, co, c, dx, dy;
{
  int h, b;
  while (get_pixel(x, y) == c)
  {
    h = x, b = y;
    while (get_pixel(h, b) == c)
      put_pixel(h++, b, co);
    h = x;
    b = y - 1;
    while (get_pixel(h, b) == c)
      put_pixel(h, b--, co);
    h = x - 1;
    b = y;
    while (get_pixel(h, b) == c)
      put_pixel(h--, b, co);
    h = x;
    b = y + 1;
    while (get_pixel(h, b) == c)
      put_pixel(h, b++, co);
    x = x + dx;
    y = y + dy;
  }
}

void fill(x, y, co)
word x, y, co;
{
  word c = get_pixel(x, y);
  if (c == co)
    return;
  if (x < 0 || y < 0 || x > 319 || y > 199)
    return;
  fillhelp(x, y, co, c, 1, 1);
  fillhelp(x + 1, y - 1, co, c, 1, -1);
  fillhelp(x - 1, y - 1, co, c, -1, -1);
  fillhelp(x - 1, y + 1, co, c, -1, 1);
}

#endif