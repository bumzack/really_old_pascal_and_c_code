#ifndef MATH
#define MATH

#include "defs.h"
#include <math.h>

void vecsub(vector *r, vector *a, vector *b);
double dot(vector *a, vector *b);
double distance(vector *p1, vector *p2);
void vecsub(vector *r, vector *a, vector *b);
void vecadd(vector *r, vector *a, vector *b);
void vecmul(vector *r, double t, vector *a);
vecprod(vector *a, vector *b, vector *c);
void norm(vector *dest, vector *src);
void veccpy(vector *dest, vector *src);


double dot(a, b)
vector *a, *b;
{
  return((a->x * b->x + a->y * b->y + a->z * b->z));
}

double distance(p1, p2)
vector *p1, *p2;
{
  vector t;
  vecsub(&t, p1, p2);
  return(sqrt(dot(&t, &t)));
}

void vecsub(r, a, b)
vector *r, *a, *b;
{
  r->x = a->x - b->x;
  r->y = a->y - b->y;
  r->z = a->z - b->z;
}

void vecadd(r, a, b)
vector *r, *a, *b;
{
  r->x = a->x + b->x;
  r->y = a->y + b->y;
  r->z = a->z + b->z;
}

void vecmul(r, t, a)
vector *r, *a;
double t;
{
  r->x = t * a->x;
  r->y = t * a->y;
  r->z = t * a->z;
}

vecprod(a, b, c)
vector *a, *b, *c;
{
  c->x = a->y * b->z - a->z * b->y;
  c->y = -a->x * b->z + a->z * b->x;
  c->z = a->x * b->y - a->y * b->x;
}

void veccpy(dest, src)
vector *dest, *src;
{
  dest->x = src->x;
  dest->y = src->y;
  dest->z = src->z;
}

void norm(dest, src)
vector *dest, *src;
{
  double d = 1 / sqrt(dot(src, src));
  vecmul(dest, d, src);
}

#endif