#ifndef CALC
#define CALC

#include "defs.h"
#include "vid.c"
#include "math.c"
#include <conio.h>

world w1;
color background = {0., 0.0, 0.5};
double amb = 0.1;
color ambient = {0.01, 0.01, 0.01};
color black = {0., 0., 0.};
word maxdepth = 6;

word hit_object(vector *point, vector *dir, object *obj,
                vector *int_point, vector *norma);
object *line_trace(vector *point, vector *dir, world *world,
                   vector *int_point, vector *normal);
void colcpy(color *dest, color *src);
void add_color(color *dest, color *col1, color *col2);
void intens_col(color *dest, double k, color *col1);
void Combine(color *colour, color *local_col, double local_weight,
             color *ref_col, double ref_weight,
             color *trans_col, double trans_weight);

void trans_vector(object *obj, vector *normal, vector *dir, vector *trans_dir);
void ref_vector(vector *dir, vector *normal, vector *ref_dir);
void local_color(object *obj, vector *dir, vector *normal,
                 vector *int_point, world *world, color *local_col);
void surfaceCol(color *colour, object *object, vector *intpoint);
void bckgrnd(color *colour, color *back, vector *dir, double am);
void raytrace(vector *point, vector *dir, word depth,
              world *world, color *colour);
void to_LUT(color *col);
word interpret_col(color *col);
word showpoint(word x, word y, world *w);
void show_world(world *w);


word hit_object(point, dir, obj, int_point, norma)
vector *point, *dir, *int_point, *norma;
object *obj;
{
  polygon *polygon = &(obj->form.polygon);
  sphere  *sphere  = &(obj->form.sphere);
  vector normal, a, b;
  double t, help;
  int i;
  double l, m, n, orient, innen;

  switch (obj->type)
  {
    case POLYGON:
      vecsub(&a, &(polygon->vector[1]), &(polygon->vector[0]));
      vecsub(&b, &(polygon->vector[2]), &(polygon->vector[0]));
      vecprod(norma, &a, &b);
      help = -(dot(norma, point) - dot(&(polygon->vector[0]), norma));
      if (help > 0)
        vecmul(norma, -1 / sqrt(dot(norma, norma)), norma);
      else
        vecmul(norma, 1 / sqrt(dot(norma, norma)), norma);

      t = dot(norma, dir);
      if (t == 0.0)
        return(0);
      t = -(dot(norma, point) - dot(&(polygon->vector[0]), norma)) / t;

      if (t <= 0)
        return(0);

      vecmul(int_point, t, dir);
      vecadd(int_point, point, int_point);

      t = 0;

      for (i = 0; i < polygon->num_vec; i++)
      {
        vecsub(&a, &(polygon->vector[i]), int_point);
	vecsub(&a, &(polygon->vector[(i + 1) % polygon->num_vec]), int_point);
        norm(&a, &a);
        norm(&b, &b);
        innen = dot(&a, &b);
        if (innen >= -1.0 && innen <= 1.0)
          t = t + acos(innen);
        else
          return(0);
      }
      if (t > 6.2830 && t < 6.2833)
        return(1);
      else
        return(0);

    case SPHERE:
      l = dot(dir, dir);
      m = 2 * dir->x * (point->x - sphere->vector.x) +
          2 * dir->y * (point->y - sphere->vector.y) +
	  2 * dir->z * (point->z - sphere->vector.z);

      n = dot(&(sphere->vector), &(sphere->vector)) +
          dot(point, point) - 2 * dot(&(sphere->vector), point) -
          sphere->radius * sphere->radius;
      t = m * m - 4 * l * n;

      if (t < 0)
        return(0);

      if (t == 0)
      {
        t = -m / (2 * l);
        if (t <= 0)
          return(0);

        vecmul(int_point, t, dir);
        vecadd(int_point, point, int_point);
        vecsub(norma, int_point, &(sphere->vector));
        vecmul(int_point, 1.001, norma);
        vecadd(int_point, int_point, &(sphere->vector));
        norm(norma, norma);
        return(1);
      }
      else
      {
        orient = 1.00;
        help = (-m + sqrt(t)) / (2 * l);
        t = (-m - sqrt(t)) / (2 * l);

        if (t < 0.001)
          t = 0.0;
        if (help < 0.001)
          help = 0.0;

        if (t > 0)
        {
          if (help > 0)
            t = (help < t) ? help : t;
          else
          {
            orient = -orient;
          }
        }
        else
          if (help > 0)
          {
            orient = -orient;
            t = help;
          }
          else
            return(0);

        vecmul(int_point, t, dir);
        vecadd(int_point, point, int_point);
        vecsub(norma, int_point, &(sphere->vector));
        norm(norma, norma);
        vecmul(norma, orient, norma);
        return(1);
      }
  }
}

object *line_trace(point, dir, world, int_point, normal)
vector *point, *dir, *int_point, *normal;
world *world;
{
  object *next = world->object;
  vector r, n;
  object *object = 0;

  while (next)
  {
    if (hit_object(point, dir, next, &r, &n))
    {
      if (!object)
      {
        object = next;
        veccpy(int_point, &r);
        veccpy(normal, &n);
      }
      else
        if (distance(&r, point) < distance(int_point, point))
        {
          object = next;
          veccpy(int_point, &r);
          veccpy(normal, &n);
        }
    }
    next = next->next;
  }
  return(object);
}

void colcpy(dest, src)
color *dest, *src;
{
  dest->r = src->r;
  dest->g = src->g;
  dest->b = src->b;
}

void add_color(dest, col1, col2)
color *dest, *col1, *col2;
{
  dest->r = col1->r + col2->r;
  if (dest->r > MAXRED)
    dest->r = MAXRED;
  dest->g = col1->g + col2->g;
  if (dest->g > MAXGREEN)
    dest->g = MAXGREEN;
  dest->b = col1->b + col2->b;
  if (dest->b > MAXBLUE)
    dest->b = MAXBLUE;
}

void intens_col(dest, k, col1)
color *dest, *col1;
double k;
{
  if (k > 1.0)
    k = 1.0;
  dest->r = k * col1->r;
  dest->g = k * col1->g;
  dest->b = k * col1->b;
}

void Combine(colour, local_col, local_weight, ref_col, ref_weight,
             trans_col, trans_weight)
color *colour, *local_col, *ref_col, *trans_col;
double local_weight, ref_weight, trans_weight;
{
  color col;
  col.r = 1.0;
  col.g = 1.0;
  col.b = 1.0;
  intens_col(colour, local_weight, local_col);
  intens_col(&col, ref_weight, ref_col);
  add_color(colour, &col, colour);
  intens_col(&col, trans_weight, trans_col);
  add_color(colour, &col, colour);
}

void ref_vector(dir, normal, ref_dir)
vector *dir, *normal, *ref_dir;
{
  vector i;
  veccpy(&i, dir);
  norm(&i, &i);
  veccpy(ref_dir, &i);
  vecmul(&i, -1.0, &i);
  vecmul(&i, dot(normal, &i) * 2, normal);
  vecadd(ref_dir, &i, ref_dir);
}

void trans_vector(obj, normal, dir, trans_dir)
object *obj;
vector *normal, *dir, *trans_dir;
{
  vector i;
  double cosvieh;
  veccpy(&i, dir),
  norm(&i, &i);
  vecmul(trans_dir, 1 / obj->N, &i);
  vecmul(&i, -1.0, &i);
  cosvieh = dot(normal, &i);
  cosvieh = sqrt(1 - (1 - cosvieh * cosvieh) / (obj->N * obj->N));
  cosvieh = cosvieh - dot(normal, &i) / obj->N;
  vecmul(&i, cosvieh, normal);
  vecsub(trans_dir, trans_dir, &i);
}

void local_color(obj, dir, normal, int_point, world, local_col)
object *obj;
vector *dir, *normal, *int_point;
world *world;
color *local_col;
{
  lamp *lamp = world->lamp;
  vector L, V, dummy1, dummy2;
  double licht;
  color  col;

  colcpy(local_col, &black);
  while (lamp)
  {
    vecsub(&L, int_point, &(lamp->vector));
    if (obj == line_trace(&(lamp->vector), &L, world, &dummy1, &dummy2))
    {
      vecmul(&L, -1.0, &L);
      norm(&L, &L);
      licht = dot(&L, normal) * obj->dif_const;
      if (licht > 0)
      {
        vecsub(&V, &L, dir);
        vecmul(&V, .5, &V);
        norm(&V, &V);
        licht = licht + obj->spec_const * pow(dot(&V, normal),
		obj->high_const);
      }
      else
        licht = 0;

      intens_col(&col, licht, &(lamp->color));
      if (licht)
        intens_col(&col, exp(log(.5) / lamp->intens *
                   distance(int_point, &(lamp->vector))), &col);
      add_color(local_col, local_col, &col);
    }
    lamp = lamp->next;
  }
  add_color(local_col, local_col, &ambient);
}

void surfaceCol(colour, object, intpoint)
color *colour;
object *object;
vector *intpoint;
{
  vector a, b, c, d;
  double winkel, x, y, r, r2;
  word l, h;
  byte *co = object->text.map, col;
  double ro, g, bl;

  if (object->text.map)
  {
    switch(object->type)
    {
      case POLYGON:
        vecsub(&c, intpoint, &(object->form.polygon.vector[0]));
        vecsub(&a, &(object->form.polygon.vector[1]),
                   &(object->form.polygon.vector[0]));
        norm(&b, &a);
        norm(&d, &c);

        winkel = dot(&b, &d);
        x = sqrt(dot(&c, &c)) * winkel / object->text.big;
        winkel = sin(acos(winkel));
	y = sqrt(dot(&c, &c)) * winkel / object->text.big;
        h = ((word)(x + 0.5)) % object->text.x;
        l = ((word)(y + 0.5)) % object->text.y;
        col = *(co + object->text.y * h + l);

        bl = ((double)((int)(col / 36))) / 5;
        col = col % 36;
        g = ((double)((int)(col / 6))) / 5;
        col = col % 6;
        ro = (double)(col) / 5;
        colour->r = ro * colour->r;
        colour->g = g  * colour->g;
        colour->b = bl * colour->b;
        break;

      case SPHERE:
	x = intpoint->x - object->form.sphere.vector.x;
        switch(object->text.typ)
        {
          case 1:
            y = intpoint->z - object->form.sphere.vector.z;
            break;
          case 2:
            y = intpoint->y - object->form.sphere.vector.y;
            break;
        }
        r = object->form.sphere.radius;
        x = (asin(x / r) * r + r) / object->text.big;
        y = (asin(y / r) * r + r) / object->text.big;
        h = ((word)(x + .5)) % object->text.x;
        l = ((word)(y + .5)) % object->text.y;

        col = *(co + object->text.y * h + l);

        bl = ((double)((int)(col / 36))) / 5;
        col = col % 36;
        g = ((double)((int)(col / 6))) / 5;
        col = col % 6;
        ro = (double)(col) / 5;
        colour->r = ro * colour->r;
        colour->g = g  * colour->g;
        colour->b = bl * colour->b;
        break;
    }
  }
  else
  {
    colour->r = object->color.r * colour->r;
    colour->g = object->color.g * colour->g;
    colour->b = object->color.b * colour->b;
  }
}

void bckgrnd(colour, back, dir, am)
color *colour, *back;
vector *dir;
double am;
{
  vector v, d;
  double n;
  veccpy(&d, dir);
  norm(&d, &d);
  v.x = 0;
  v.y = 1;
  v.z = 0;
  n = 1.5707 / acos(dot(&v, &d));
  colour->r = back->r * n + back->r * am;
  colour->g = back->g * n + back->g * am;
  colour->b = back->b * n + back->b * am;
}

void raytrace(point, dir, depth, world, colour)
vector *point, *dir;
word depth;
world *world;
color *colour;
{
  color local_col, ref_col, trans_col;
  vector ref_dir, trans_dir, int_point, normal;
  object *object = 0;

  object = line_trace(point, dir, world, &int_point, &normal);
  if (!object)
    bckgrnd(colour, &background, dir, amb);
  else
  {
    local_color(object, dir, &normal, &int_point, world, &local_col);
    if (depth == maxdepth)
    {
      colcpy(&ref_col, &black);
      colcpy(&trans_col, &black);
    }
    else
    {
      if (object->mirror > 0.0)
      {
        ref_vector(&normal, dir, &ref_dir);
        raytrace(&int_point, &ref_dir, depth + 1, world, &ref_col);
      }
      else
        colcpy(&ref_col, &black);

      if (object->trans > 0.0)
      {
	trans_vector(object, &normal, dir, &trans_dir);
        raytrace(&int_point, &trans_dir, depth + 1, world, &trans_col);
      }
      else
        colcpy(&trans_col, &black);
    }
    Combine(colour, &local_col, object->material,
                    &ref_col, object->mirror,
                    &trans_col, object->trans);
    surfaceCol(colour, object, &int_point);
  }
}

void to_LUT(col)
color *col;
{
  double r, g, b;
  r = col->r * 2 - 1;
  g = col->g * 2 - 1;
  b = col->b * 2 - 1;

  if (r > 0)
  {
    col->r = 1.0;
    col->b += r;
    col->g += r;
  }
  else
    col->r = 2 * col->r;

  if (b > 0)
  {
    col->b = 1.0;
    col->r += b;
    col->g += b;
  }
  else
    col->b = 2 * col->b;

  if (g > 0)
  {
    col->g = 1.0;
    col->r += g;
    col->b += g;
  }
  else
    col->g = 2 * col->g;

  if (col->r > 1.0)
    col->r = 1.0;
  if (col->g > 1.0)
    col->g = 1.0;
  if (col->b > 1.0)
    col->b = 1.0;
}

word interpret_col(col)
color *col;
{
  if (col->r < 0 || col->g < 0 || col->b < 0)
    return(0);
  return((word)(col->r * 5 + .5) +
         (word)(col->g * 5 + .5) * 6 +
	 (word)(col->b * 5 + .5) * 36);
}

word showpoint(x, y, w)
word x, y;
world *w;
{
  vector g1, g2;
  color col;
  word s = 0;
  g1.x = g1.y = 0;
  g1.z = 1;
  g2.x = -((double)(w->observer->p_width >> 1) - x) / w->observer->dx;
  g2.y = -((double)(w->observer->p_height >> 1) - y) / w->observer->dy;
  g2.z = (double) 1;
  raytrace(&g1, &g2, s, w, &col);
  to_LUT(&col);
  return(interpret_col(&col));
}

void show_world(w)
world *w;
{
  word x, y;
  for (y = 0; y < w->observer->p_height && !kbhit(); y++)
    for (x = 0; x < w->observer->p_width && !kbhit(); x++)
      put_pixel(x, y, showpoint(x, y, w));
  if (kbhit())
    getch();
}

#endif