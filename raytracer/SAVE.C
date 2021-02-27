#ifndef SAVE
#define SAVE

#include "vid.c"
#include "graph.c"
#include <stdlib.h>
#include <stdio.h>

int savepic(word x1, word y1, word x2, word y2, char *name);
int loadpic(char *name);

int savepic(x1, y1, x2, y2, name)
word x1, y1, x2, y2;
char *name;
{
  FILE *fp;
  byte c;
  int i, j;
  word width = x2 - x1 + 1, height = y2 - y1 + 1;

  fp = fopen(name, "wb");
  if (!fp)
    return(0);
  fwrite(&width, sizeof(width), 1, fp);
  fwrite(&height, sizeof(height), 1, fp);
  for (i = x1; i <= x2; i++)
    for (j = y1; j <= y2; j++)
    {
      c = get_pixel(i, j);
      fwrite(&c, sizeof(c), 1, fp);
    }
  fclose(fp);
  return(1);
}

int loadpic(name)
char *name;
{
  FILE *fp;
  byte c;
  int i, j;
  word width, height;

  fp = fopen(name, "rb");
  if (!fp)
    return(0);
  fread(&width, sizeof(width), 1, fp);
  fread(&height, sizeof(height), 1, fp);
  for (i = 0; i < width; i++)
    for (j = 0; j < height; j++)
    {
      fread(&c, sizeof(c), 1, fp);
      put_pixel(i, j, c);
    }
  fclose(fp);
  return(1);
}

#endif