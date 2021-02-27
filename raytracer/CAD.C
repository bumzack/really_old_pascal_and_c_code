#ifndef CAD
#define CAD

#include "vid.c"
#include "maus.c"
#include "graph.c"
#include "schalter.c"
#include "calc.c"
#include "load.c"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <alloc.h>
#include <mem.h>
#include <string.h>

schalter np = {
  0,
  289, 133, 310, 152,
  56, 0, 215,
  2,
  "N",
};

schalter sa = {
  &np,
  214, 181, 285, 193,
  56, 0, 215,
  2,
  "SVE WRLD",
};

schalter lo = {
  &sa,
  214, 165, 285, 177,
  56, 0, 215,
  2,
  "LOD WRLD",
};

schalter so = {
  &lo,
  214, 149, 285, 161,
  56, 0, 215,
  2,
  "SET OBSV",
};

schalter sl = {
  &so,
  214, 133, 285, 145,
  56, 0, 215,
  2,
  "SET LAMP",
};

schalter mo = {
  &sl,
  145, 181, 210, 193,
  56, 0, 215,
  2,
  "MOV OBJ",
};

schalter ro = {
  &mo,
  145, 165, 210, 177,
  56, 0, 215,
  2,
  "ROT OBJ",
};

schalter tr = {
  &ro,
  145, 149, 210, 161,
  56, 0, 215,
  2,
  "TRANS",
};

schalter si = {
  &tr,
  145, 133, 210, 145,
  56, 0, 215,
  2,
  "SIZE",
};

schalter os = {
  &si,
  75, 133, 140, 145,
  56, 0, 215,
  2,
  "OBJ BEG",
};

schalter ap = {
  &os,
  75, 149, 140, 161,
  56, 0, 215,
  2,
  "ADD POL",
};

schalter as = {
  &ap,
  75, 165, 140, 177,
  56, 0, 215,
  2,
  "ADD SPH",
};

schalter ex = {
  &as,
  289, 156, 310, 193,
  56, 0, 215,
  2,
  "E",
};

typedef struct win {
  struct win *next;
  word left, top, right, bottom;
  word curx, cury;
  } win;

int px, py, pz, dx, dy, dz, cx, cy, cz, tx, ty, tz;
double vx, vy, vz;

win win3;
win win2;
win win4;
win win1 = {
  &win2,
  1, 1, 105, 105,
  103, 62,
};

win win2 = {
  &win3,
  107, 1, 211, 105,
  103, 62,
};

win win3 = {
  &win4,
  213, 1, 317, 105,
  103, 62,
};

win win4 = {
  &win1,
  1, 125, 317, 198,
  0, 0,
};

typedef struct set {
  struct set *next;
  object *first;
  } set;

set *first = 0, *actset = 0;
object *actobj = 0;
lamp *actlamp = 0, *firstlamp = 0;
vector nullpunkt, richtung;

void setwin(win *wi);
void showwin(win *begin);
void drawlinewin(win *wi, int x0, int y0, int x1, int y1, word c);
void line3d(win *wi, int x1, int y1, int z1,
            int x2, int y2, int z2, word co);
void circle2d(win *wi, double x, double y, double r);
void circle3d(win *wi, int x, int y, int z, int r);
void clswin(win *wi);
void changeview(win *wi);
void showpos(win *act, word x, word y);
object *genpol(void);
void genobs(void);
lamp *genlamp(void);
object *gencir(void);
void rotvect(double dx, double dy, double dz,
             double *x, double *y, double *z,
             int wi, char *str);
void rotobj(double x, double y, double z,
            object *o, int wi, char *str);
void rotset(set *s);
void movobj(int x, int y, int z, object *o);
void movset(set *s);
void mergeworld(void);
int saveall(void);
int loadall(int x, int y);
void cad(void);


void setwin(wi)
win *wi;
{
  word x, y;
  mouse_hide();
  mouse_area(wi->left << 1, wi->top, wi->right << 1, wi->bottom);
  if (wi == &win1)
    mouse_move((px << 1) + (wi->left << 1), pz + wi->top);
  else
    if (wi == &win2)
      mouse_move((px << 1) + (wi->left << 1), py + wi->top);
    else
      if (wi == &win3)
        mouse_move((pz << 1) + (wi->left << 1), py + wi->top);
      else
        mouse_move(wi->curx + (wi->left << 1), wi->top + wi->cury);
  mouse_show();
}

void showwin(begin)
win *begin;
{
  win *wi = begin;
  do
  {
    drawtangle(wi->left - 1, wi->top - 1, wi->right + 1, wi->bottom + 1, 215);
    wi = wi->next;
  }
  while (wi != begin);
}

void drawlinewin(wi, x0, y0, x1, y1, c)
win *wi;
int x0, y0, x1, y1;
word c;
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

  if (x0 >= wi->left && x0 <= wi->right &&
      y0 >= wi->top  && y0 <= wi->bottom)
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
    if (x0 >= wi->left && x0 <= wi->right &&
        y0 >= wi->top  && y0 <= wi->bottom)
      put_pixel(x0, y0, c);
  }
}

void line3d(wi, x1, y1, z1, x2, y2, z2, co)
win *wi;
int x1, y1, z1, x2, y2, z2;
word co;
{
  int xa, ya, xb, yb;
  mouse_hide();
  xa = wi->left - dx - tx + x1 / vx;
  xb = wi->left - dx - tx + x2 / vx;
  ya = wi->top  - dz - tz - z1 / vz;
  yb = wi->top  - dz - tz - z2 / vz;
  drawlinewin(wi, xa, ya, xb, yb, co);
  wi = wi->next;
  xa = wi->left - dx - tx + x1 / vx;
  xb = wi->left - dx - tx + x2 / vx;
  ya = wi->top  - dy - ty - y1 / vy;
  yb = wi->top  - dy - ty - y2 / vy;
  drawlinewin(wi, xa, ya, xb, yb, co);
  wi = wi->next;
  xa = wi->left - dz - tz - z1 / vz;
  xb = wi->left - dz - tz - z2 / vz;
  ya = wi->top  - dy - ty - y1 / vy;
  yb = wi->top  - dy - ty - y2 / vy;
  drawlinewin(wi, xa, ya, xb, yb, co);
  mouse_show();
}

void circle2d(wi, x, y, r)
win *wi;
double x, y, r;
{
  int i, j, io = (int)(x - r), jo = (int)y;
  for (i = (int)-r; i <= (int)r; i++)
  {
    j = (int)sqrt((double)(r * r - i * i));
    drawlinewin(wi, io, jo, (int)(i + x), (int)(j + y), 30);
    io = (int)(i + x);
    jo = (int)(j + y);
  }
  io = (int)(x + r);
  jo = (int)(y);
  for (i = (int)r; i >= (int)-r; i--)
  {
    j = (int)-sqrt((double)(r * r - i * i));
    drawlinewin(wi, io, jo, (int)(i + x), (int)(j + y), 30);
    io = (int)(i + x);
    jo = (int)(j + y);
  }
}

void circle3d(wi, x, y, z, r)
win *wi;
int x, y, z, r;
{
  int xa, ya;
  mouse_hide();
  line3d(wi, x, y, z, x, y, z, 30);
  xa = wi->left - dx - tx + x / vx;
  ya = wi->top  - dz - tz - z / vz;
  r = r / vz;
  circle2d(wi, (double)xa, (double)ya, (double)r);
  wi = wi->next;
  xa = wi->left - dx - tx + x / vx;
  ya = wi->top  - dy - ty - y / vy;
  circle2d(wi, (double)xa, (double)ya, (double)r);
  wi = wi->next;
  xa = wi->left - dz - tz - z / vz;
  ya = wi->top  - dy - ty - y / vy;
  circle2d(wi, (double)xa, (double)ya, (double)r);
  mouse_show();
}

void clswin(wi)
win *wi;
{
  word x, y;
  for (x = wi->left; x <= wi->right; x++)
    for (y = wi->top; y <= wi->bottom; y++)
      put_pixel(x, y, 0);
}

void changeview(wi)
win *wi;
{
  set *s = first;
  polygon *p;
  sphere *sh;
  object *o;
  lamp *l = firstlamp;
  int i;
  mouse_hide();
  clswin(wi);
  clswin(wi->next);
  clswin(wi->next->next);

  while (s)
  {
    o = s->first;
    while (o)
    {
      if (o->type == POLYGON)
      {
        p = &(o->form.polygon);

        for (i = 0; i < p->num_vec - 1; i++)
        {
          line3d(wi, (int)p->vector[i].x,
                     (int)p->vector[i].y,
                     (int)p->vector[i].z,
                     (int)p->vector[i + 1].x,
                     (int)p->vector[i + 1].y,
                     (int)p->vector[i + 1].z, 4);
        }
        line3d(wi, (int)p->vector[i].x,
                   (int)p->vector[i].y,
                   (int)p->vector[i].z,
                   (int)p->vector[0].x,
                   (int)p->vector[0].y,
                   (int)p->vector[0].z, 4);
      }
      else
      {
        sh = &(o->form.sphere);
	circle3d(wi, (int)sh->vector.x,
		     (int)sh->vector.y,
		     (int)sh->vector.z,
		     (int)sh->radius);
      }
      o = o->next;
    }
    s = s->next;
  }
  while(l)
  {
    line3d(&win1, (int)l->vector.x,
                  (int)l->vector.y,
                  (int)l->vector.z,
                  (int)l->vector.x,
                  (int)l->vector.y,
                  (int)l->vector.z, 150);
    l = l->next;
  }
  line3d(&win1, (int)nullpunkt.x,
                (int)nullpunkt.y,
                (int)nullpunkt.z,
		(int)richtung.x,
		(int)richtung.y,
		(int)richtung.z, 35);
  mouse_show();
}

void showpos(act, x, y)
win *act;
word x, y;
{
  int xo, yo, zo;
  x = x - (act->left << 1);
  y = y - act->top;
  x = x >> 1;
  if (act == &win1 || act == &win2)
    px = x;
  if (act == &win1 || act == &win3)
    pz = y;
  if (act == &win2)
    py = y;
  if (act == &win3)
  {
    pz = x;
    py = y;
  }
  xo = cx;
  yo = cy;
  zo = cz;
  cx = (int)((px + dx + tx) * vx);
  cy = (int)(-(py + dy + ty) * vy);
  cz = (int)(-(pz + dz + tz) * vz);
  gotoxy(2, 17);
  print("X:", 215);

  if (cx != xo)
  {
    gotoxy(2, 17);
    print("X:     ", 215);
    gotoxy(4, 17);
    printnum(cx);
  }
  if (cy != yo)
  {
    gotoxy(2, 18);
    print("Y:     ", 215);
    gotoxy(4, 18);
    printnum(cy);
  }
  if (cz != zo)
  {
    gotoxy(2, 19);
    print("Z:     ", 215);
    gotoxy(4, 19);
    printnum(cz);
  }
}

object *genpol()
{
  word ready = 0, x, y;
  int xo, yo, zo, flag = 0;
  win *act = &win1;
  object *o;
  polygon *p;
  o = malloc(sizeof(object));
  if (!o)
    return(0);
  memset(o, 0, sizeof(object));
  o->next = 0;
  o->type = POLYGON;

  p = &(o->form.polygon);
  p->num_vec = 0;
  setwin(act);
  mouse_show();
  while (mouse_press());
  mouse_key(0);
  mouse_key(1);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      showpos(act, x, y);
    }
    while(mouse_press());

    if (mouse_key(1))
    {
      mouse_pos(&x, &y);
      act->curx = x - (act->left << 1);
      act->cury = y - act->top;
      act = act->next;
      if (act == &win4)
        act = act->next;
      setwin(act);
      if (mouse_key(0))
        ready = 1;
    }
    if (mouse_key(0))
    {
      p->vector[p->num_vec].x = (double)cx;
      p->vector[p->num_vec].y = (double)cy;
      p->vector[p->num_vec].z = (double)cz;
      p->num_vec++;
      if (!flag)
      {
        flag++;
        xo = cx;
        yo = cy;
        zo = cz;
        line3d(&win1, cx, cy, cz, cx, cy, cz, 4);
      }
      else
        line3d(&win1, xo, yo, zo, cx, cy, cz, 4);
      xo = cx; yo = cy; zo = cz;
    }
  } while(!ready && p->num_vec < MAXVECTS);
  if (p->num_vec)
    line3d(&win1, xo, yo, zo,
                  (int)p->vector[0].x,
                  (int)p->vector[0].y,
                  (int)p->vector[0].z, 4);
  else
  {
    free(o);
    o = 0;
  }
  return(o);
}

void genobs()
{
  word ready = 0, x, y, flag = 0;
  win *act = &win1;

  setwin(act);
  mouse_show();
  while (mouse_press());
  mouse_key(0);
  mouse_key(1);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      showpos(act, x, y);
    }
    while(mouse_press());

    if (mouse_key(1))
    {
      mouse_pos(&x, &y);
      act->curx = x - (act->left << 1);
      act->cury = y - act->top;
      act = act->next;
      if (act == &win4)
        act = act->next;
      setwin(act);
      if (mouse_key(0))
        ready = 1;
    }
    if (mouse_key(0))
    {
      if (!flag)
      {
        flag++;
        nullpunkt.x = (double)cx;
        nullpunkt.y = (double)cy;
        nullpunkt.z = (double)cz;
        line3d(&win1, cx, cy, cz, cx, cy, cz, 35);
      }
      else
      {
        ready = 1;
        richtung.x = (double)cx;
        richtung.y = (double)cy;
        richtung.z = (double)cz;
        line3d(&win1, (int)nullpunkt.x,
                      (int)nullpunkt.y,
                      (int)nullpunkt.z,
                      (int)richtung.x,
                      (int)richtung.y,
                      (int)richtung.z, 35);
      }
    }
  }
  while (!ready);
}

lamp *genlamp()
{
  word ready = 0, x, y;
  win *act = &win1;
  lamp *l;

  l = malloc(sizeof(lamp));
  if (!l)
    return(0);
  memset(l, 0, sizeof(lamp));
  l->next = 0;
  setwin(act);
  mouse_show();
  while (mouse_press());
  mouse_key(0);
  mouse_key(1);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      showpos(act, x, y);
    }
    while(mouse_press());

    if (mouse_key(1))
    {
      mouse_pos(&x, &y);
      act->curx = x - (act->left << 1);
      act->cury = y - act->top;
      act = act->next;
      if (act == &win4)
        act = act->next;
      setwin(act);
      if (mouse_key(0))
        ready = 2;
    }
    if (mouse_key(0))
    {
      l->vector.x = (double)cx;
      l->vector.y = (double)cy;
      l->vector.z = (double)cz;
      line3d(&win1, cx, cy, cz, cx, cy, cz, 150);
      ready = 1;
    }
  }
  while (!ready);
  if (ready == 2)
  {
    free(l);
    l = 0;
  }
  return(l);
}

object *gencir(void)
{
  word ready = 0, x, y;
  double xo, yo, zo;
  int flag = 0;
  win *act = &win1;
  object *o;
  sphere *sh;

  o = malloc(sizeof(object));
  if (!o)
    return(0);
  memset(o, 0, sizeof(object));
  o->next = 0;
  o->type = SPHERE;

  sh = &(o->form.sphere);
  setwin(act);
  mouse_show();
  while (mouse_press());
  mouse_key(0);
  mouse_key(1);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      showpos(act, x, y);
    }
    while(mouse_press());

    if (mouse_key(1))
    {
      mouse_pos(&x, &y);
      act->curx = x - (act->left << 1);
      act->cury = y - act->top;
      act = act->next;
      if (act == &win4)
        act = act->next;
      setwin(act);
      if (mouse_key(0))
        ready = 2;
    }
    if (mouse_key(0))
    {
      if (!flag)
      {
        flag++;
        sh->vector.x = (double)cx;
        sh->vector.y = (double)cy;
        sh->vector.z = (double)cz;
        line3d(&win1, cx, cy, cz, cx, cy, cz, 4);
        xo = (double)cx;
        yo = (double)cy;
        zo = (double)cz;
      }
      else
      {
        ready = 1;
        xo = cx - xo;
        yo = cy - yo;
        zo = cz - zo;
        sh->radius = sqrt((double)((double)xo * xo + yo * yo + zo * zo));
        circle3d(&win1, (int)sh->vector.x,
                        (int)sh->vector.y,
                        (int)sh->vector.z,
                        (int)sh->radius);
      }
    }
  }
  while (!ready);
  if (ready == 2)
  {
    free(o);
    o = 0;
  }
  return(o);
}

void rotvect(dx, dy, dz, x, y, z, wi, str)
double dx, dy, dz, *x, *y, *z;
int wi;
char *str;
{
  double xn, yn, tx, ty, w, *nx, *ny, *nz;
  w = (double) wi * 3.1415927 / 180;
  switch(*str)
  {
    case 'X':
    case 'x':
      xn = *z; tx = dz;
      yn = *y; nx = z;
      ty = dy; ny = y;
      break;
    case 'Y':
    case 'y':
      xn = *x; tx = dx;
      yn = *z; nx = x;
      ty = dz; ny = z;
      break;
    case 'Z':
    case 'z':
      xn = *x; tx = dx;
      yn = *y; nx = x;
      ty = dy; ny = y;
      break;
    default:
      return;
  }
  *nx = (xn - tx) * cos(w) - (yn - ty) * sin(w) + tx;
  *ny = (yn - ty) * cos(w) + (xn - tx) * sin(w) + ty;
}

void rotobj(x, y, z, o, wi, str)
double x, y, z;
object *o;
int wi;
char *str;
{
  int i;

  switch(o->type)
  {
    case POLYGON:
      for (i = 0; i < o->form.polygon.num_vec; i++)
	rotvect(x, y, z, &(o->form.polygon.vector[i].x),
			 &(o->form.polygon.vector[i].y),
			 &(o->form.polygon.vector[i].z), wi, str);
      break;
    case SPHERE:
      rotvect(x, y, z, &(o->form.sphere.vector.x),
		       &(o->form.sphere.vector.y),
		       &(o->form.sphere.vector.z), wi, str);
      break;
  }
}

void rotset(s)
set *s;
{
  char str[10];
  int wi;
  object *o;
  double x, y, z;

  gotoxy(2, 21);
  print("W:         ", 215);
  gotoxy(4, 21);
  getstr(str);
  if (strlen(str) > 0)
    wi = atoi(str);
  gotoxy(2, 22);
  print("Achse:     ", 215);
  gotoxy(8, 22);
  getstr(str);
  if (s)
  {
    o = s->first;
    if (o)
      switch(o->type)
      {
	case POLYGON:
	  x = o->form.polygon.vector[0].x;
	  y = o->form.polygon.vector[0].y;
	  z = o->form.polygon.vector[0].z;
	  break;
	case SPHERE:
	  x = o->form.sphere.vector.x;
	  y = o->form.sphere.vector.y;
	  z = o->form.sphere.vector.z;
	  break;
      }
      while (o)
      {
	rotobj(x, y, z, o, wi, str);
	o = o->next;
      }
  }
}

void movobj(x, y, z, o)
int x, y, z;
object *o;
{
  int i;
  switch(o->type)
  {
    case POLYGON:
      for (i = 0; i < o->form.polygon.num_vec; i++)
      {
        o->form.polygon.vector[i].x += (double)x;
        o->form.polygon.vector[i].y += (double)y;
        o->form.polygon.vector[i].z += (double)z;
      }
      break;
    case SPHERE:
      o->form.sphere.vector.x += (double)x;
      o->form.sphere.vector.y += (double)y;
      o->form.sphere.vector.z += (double)z;
      break;
  }
}

void movset(s)
set *s;
{
  int tx, ty, tz;
  object *o;
  char str[10];

  gotoxy(2, 21);
  print("X:        ", 215);
  gotoxy(4, 21);
  getstr(str);
  if (strlen(str) > 0)
    tx = atoi(str);
  gotoxy(2, 22);
  print("Y:        ", 215);
  gotoxy(4, 22);
  getstr(str);
  if (strlen(str) > 0)
    ty = atoi(str);
  gotoxy(2, 23);
  print("Z:        ", 215);
  gotoxy(4, 23);
  getstr(str);
  if (strlen(str) > 0)
    tz = atoi(str);
  if (s)
  {
    o = s->first;
    while (o)
    {
      movobj(tx, ty, tz, o);
      o = o->next;
    }
  }
}

void mergeworld()
{
  set *s = 0, *s1 = 0;
  int tx, ty, tz, wi1, wi2;
  object *o = 0, *old = 0;
  lamp *l;

  s = first;
  tx = (int)-nullpunkt.x;
  ty = (int)-nullpunkt.y;
  tz = (int)-nullpunkt.z;
  while (s)
  {
    o = s->first;
    while (o)
    {
      movobj(tx, ty, tz, o);
      old = o;
      o = o->next;
    }
    s1 = s;
    s = s->next;
    if (s)
      if (old)
        old->next = s->first;
    if (s1 != first)
      free(s1);
    else
      s1->next = 0;
  }
  actset = first;
  l = firstlamp;
  while (l)
  {
    l->vector.x += -nullpunkt.x;
    l->vector.y += -nullpunkt.y;
    l->vector.z += -nullpunkt.z;
    l = l->next;
  }
  if (richtung.z != nullpunkt.z)
  {
    wi1 = (int)(atan((richtung.x - nullpunkt.x) /
          (richtung.z - nullpunkt.z)) * 180 / 3.1415927);
    wi2 = (int)(atan((richtung.y - nullpunkt.y) /
          (richtung.z - nullpunkt.z)) * 180 / 3.1415927);
    s = first;
    if (s)
    {
      o = s->first;
      while (o)
      {
        rotobj(0.0, 0.0, 0.0, o, wi1, "y");
        rotobj(0.0, 0.0, 0.0, o, -wi2, "x");
        o = o->next;
      }
    }
    l = firstlamp;
    while (l)
    {
      rotvect(0.0, 0.0, 0.0,
              &(l->vector.x),
              &(l->vector.y),
              &(l->vector.z), wi1, "y");
      rotvect(0.0, 0.0, 0.0,
              &(l->vector.x),
              &(l->vector.y),
              &(l->vector.z), -wi2, "x");
      l = l->next;
    }
  }
  richtung.x = richtung.y = 0;
  richtung.z = 1;
  nullpunkt.x = nullpunkt.y = nullpunkt.z = 0;
}

int saveall()
{
  char name[30];

  mergeworld();
  changeview(&win1);

  w1.object = first->first;
  w1.lamp = firstlamp;

  gotoxy(2, 24);
  print("Name:            ", 215);
  gotoxy(7, 24);
  getstr(name);
  gotoxy(2, 24);
  print("                 ", 215);
  return(saveworld(&w1, name));
}

int loadall(x, y)
int x, y;
{
  char name[30];
  lamp *l;
  object *o;

  gotoxy(x, y);
  print("Name:            ", 215);
  gotoxy(x + 5, y);
  getstr(name);
  gotoxy(x, y);
  print("                 ", 215);
  mergeworld();
  if (actset)
    free(actset);
  if (loadworld(&w1, name))
  {
    firstlamp = w1.lamp;
    if (!first)
      first = actset = malloc(sizeof(set));
    first->next = 0;
    first->first = w1.object;
    actlamp = 0;
    actobj = 0;
    return(1);
  }
  if (!first)
    first = actset = malloc(sizeof(set));
  if (!first)
    return(1);

  firstlamp = w1.lamp;
  first->next = 0;
  first->first = w1.object;

  o = first->first;
  if (o)
    while (o->next)
      o = o->next;
  actobj = o;
  l = firstlamp;
  if (l)
    while (l->next)
      l = l->next;
  actlamp = l;
  return(0);
}

void cad()
{
  word ready = 0, x, y;
  int xo, yo, zo;
  char str[20];
  win *act = &win4;
  schalter *sch = &ex;
  object *newobj;
  lamp *newlamp;

  nullpunkt.x = 0;
  nullpunkt.y = 0;
  nullpunkt.z = 0;
  richtung.x  = 0;
  richtung.y  = 0;
  richtung.z  = 0;
  textattr(0);
  clrscr();
  setwin(act);
  showwin(act);
  showsch(sch);
  gotoxy(6, 15);
  print("DOWN           NORTH          WEST", 215);
  gotoxy(38, 19);
  print("P", 215);
  gotoxy(38, 22);
  print("X", 215);
  gotoxy(38, 23);
  print("I", 215);
  gotoxy(38, 24);
  print("T", 215);
  mouse_def(pointer, 17, 6);
  mouse_show();
  mouse_key(0);
  px = py = pz = 52;
  tx = ty = tz = 0;
  dx = dy = dz = -52;
  vx = vy = vz = 10;
  gotoxy(2, 17);
  print("X:0", 215);
  gotoxy(2, 18);
  print("Y:0", 215);
  gotoxy(2, 19);
  print("Z:0", 215);
  changeview(&win1);

  do
  {
    while(!mouse_press())
    {
      mouse_pos(&x, &y);
      showpos(act, x, y);
      act->curx = x - act->left;
      act->cury = y - act->top;
      x = x >> 1;
    }
    mouse_hide();

    switch(testsch(x, y, &ex, &sch))
    {
      case 1:
        ready = 1;
        mergeworld();
        break;
      case 13:
        mergeworld();
        changeview(&win1);
        break;
      case 12:
        saveall();
        break;
      case 11:
        loadall(2, 24);
        changeview(&win1);
        break;
      case 10:
        genobs();
        changeview(&win1);
        break;
      case 9:
        newlamp = genlamp();
        if (!firstlamp)
          firstlamp = newlamp;
        else
          actlamp->next = newlamp;
        if (newlamp)
          actlamp = newlamp;
        break;
      case 8:
        movset(actset);
        changeview(&win1);
        break;
      case 7:
        rotset(actset);
        changeview(&win1);
        break;
      case 6:
        gotoxy(2, 21);
        print("X:        ", 215);
        gotoxy(4, 21);
        getstr(str);
        if (strlen(str) > 0)
          tx = atoi(str);
          gotoxy(2, 22);
        print("Y:        ", 215);
        gotoxy(4, 22);
        getstr(str);
        if (strlen(str) > 0)
          ty = atoi(str);
        gotoxy(2, 23);
        print("Z:        ", 215);
        gotoxy(4, 23);
        getstr(str);
        if (strlen(str) > 0)
          tz = atoi(str);
        changeview(&win1);
        break;
      case 5:
        gotoxy(2, 24);
        print("M:       ", 215);
        gotoxy(4, 24);
        getstr(str);
        if (atof(str) != 0.0 && atof(str) <= 600.0)
          vx = vy = vz = atof(str);
        changeview(&win1);
        break;
      case 4:
        while(mouse_press());
        mouse_key(0);
        mouse_key(1);
        if (!first)
          first = actset = malloc(sizeof(set));
        else
        {
          actset->next = malloc(sizeof(set));
          actset = actset->next;
        }
        if (actset)
        {
          actset->next = 0;
          actset->first = 0;
          actobj = 0;
        }
        break;
      case 3:
        if (actset)
        {
          newobj = genpol();
          if (actobj)
            actobj->next = newobj;
          else
            actset->first = newobj;
          if (newobj)
            actobj = newobj;
        }
        break;
      case 2:
	if (actset)
	{
          newobj = gencir();
          if (actobj)
            actobj->next = newobj;
          else
            actset->first = newobj;
          if (newobj)
            actobj = newobj;
        }
        break;
      default:
        sound(440);
        delay(2);
        nosound();
        break;
    }
    drawtangle(sch->left, sch->top, sch->right, sch->bottom, sch->framecol);
    setwin(act);
    mouse_show();
  }
  while (!ready);
  mouse_hide();
}

#endif