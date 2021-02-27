#ifndef LOAD
#define LOAD

#include <stdio.h>
#include <alloc.h>
#include "defs.h"
#include "calc.c"

int saveworld(world *w, char *name);
int loadworld(world *w, char *name);

int saveworld(w, name)
world *w;
char *name;
{
  FILE *fp;
  lamp   *l = w->lamp;
  object *o = w->object;
  int i;

  fp = fopen(name, "wb");
  if (fp != NULL)
  {
    fwrite(w, sizeof(world), 1, fp);
    i = 0;
    while (l)
    {
      i++;
      l = l->next;
    }
    fwrite(&i, sizeof(i), 1, fp);
    l = w->lamp;
    while (l)
    {
      fwrite(l, sizeof(lamp), 1, fp);
      l = l->next;
    }
    i = 0;
    while (o)
    {
      i++;
      o = o->next;
    }
    fwrite(&i, sizeof(i), 1, fp);
    o = w->object;
    while (o)
    {
      fwrite(o, sizeof(object), 1, fp);
      if (o->text.map)
        fwrite(o->text.map, sizeof(byte), o->text.x * o->text.y, fp);
      o = o->next;
    }
    fwrite(w->observer, sizeof(observer), 1, fp);

    fwrite(&background, sizeof(color), 1, fp);
    fwrite(&black, sizeof(color), 1, fp);
    fwrite(&ambient, sizeof(color), 1, fp);
    fwrite(&maxdepth, sizeof(word), 1, fp);
    fwrite(&amb, sizeof(double), 1, fp);

    fclose(fp);
    return(0);
  }
  return(-1);
}

int loadworld(w, name)
world *w;
char *name;
{
  FILE *fp;
  lamp   *l = w->lamp, *l1;
  object *o = w->object, *o1;
  int i;

  while (l)
  {
    l1 = l;
    l = l->next;
    free(l1);
  }
  while (o)
  {
    o1 = o;
    if (o->text.map && o->text.x != 0 && o->text.y != 0)
      free(o->text.map);
    o = o->next;
    free(o1);
  }

  if (w->observer)
    free(w->observer);

  w->lamp = 0;
  w->object = 0;
  w->observer = 0;

  fp = fopen(name, "rb");
  if (fp != NULL)
  {
    fread(w, sizeof(world), 1, fp);
    fread(&i, sizeof(i), 1, fp);
    l1 = 0;
    while (i--)
    {
      l = malloc(sizeof(lamp));
      if (!l)
      {
        fclose(fp);
        return(2);
      }
      if (l1)
        l1->next = l;
      else
        w->lamp = l;
      fread(l, sizeof(lamp), 1, fp);
      l1 = l;
    }
    l->next = 0;
    fread(&i, sizeof(i), 1, fp);
    o1 = 0;
    while (i--)
    {
      o = malloc(sizeof(object));
      if (!o)
      {
        fclose(fp);
        return(2);
      }
      if (o1)
        o1->next = o;
      else
        w->object = o;

      fread(o, sizeof(object), 1, fp);

      if (o->text.map && o->text.x != 0 && o->text.y != 0)
      {
        o->text.map = malloc(o->text.x * o->text.y * sizeof(byte));
        if (!o->text.map)
        {
          o->text.x = o->text.y = 0;
          o->text.map = 0;
          w->observer = malloc(sizeof(observer));
          fclose(fp);
          return(2);
        }
        fread(o->text.map, sizeof(byte), o->text.x * o->text.y, fp);
      }
      o1 = o;
    }

    w->observer = malloc(sizeof(observer));
    if (!w->observer)
    {
      fclose(fp);
      return(2);
    }
    fread(w->observer, sizeof(observer), 1, fp);

    fread(&background, sizeof(color), 1, fp);
    fread(&black, sizeof(color), 1, fp);
    fread(&ambient, sizeof(color), 1, fp);
    fread(&maxdepth, sizeof(word), 1, fp);
    fread(&amb, sizeof(double), 1, fp);

    fclose(fp);
    return(0);
  }
  w->observer = malloc(sizeof(observer));
  return(-1);
}

#endif