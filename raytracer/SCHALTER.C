#ifndef SCHALTER
#define SCHALTER

#include "vid.c"
#include "maus.c"
#include "graph.c"
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

typedef struct schalter {
  struct schalter *next;
  word left, top;
  word right, bottom;
  word framecol, col, ilucol;
  word backcol;
  char *msg;
  } schalter;

word testsch(word x, word y, schalter *sch, schalter **sha);
void print(char *str, word co);
void printnum(word nr);
void getstr(char *str);
void showsch(schalter *sch);

word testsch(x, y, sch, sha)
word x, y;
schalter *sch, **sha;
{
  schalter *s = sch;
  int i = 1;
  while (s)
  {
    if (x >= s->left && x <= s->right && y >= s->top && y <= s->bottom)
    {
      if (s->backcol)
      {
        mouse_hide();
        drawtangle(s->left, s->top, s->right, s->bottom, s->ilucol);
        if (s->backcol == 1)
        {
          delay(100);
          drawtangle(s->left, s->top, s->right, s->bottom, s->framecol);
        }
	mouse_show();
      }
      *sha = s;
      return(i);
    }
    i++;
    s = s->next;
  }
  return(0);
}

void print(str, co)
char *str;
word co;
{
  struct REGPACK reg;
  int i = 0;
  while (*(str + i))
  {
    reg.r_ax = 0x0900 | *(str + i);
    reg.r_bx = co & 0x00ff;
    reg.r_cx = 1;
    intr(0x10, &reg);
    gotoxy(wherex() + 1, wherey());
    i++;
  }
}

void getstr(str)
char *str;
{
  char ch[2];
  ch[1] = 0;
  do
  {
    ch[0] = getch();
    switch(ch[0])
    {
      case '\r':
      case '\n':
        break;
      case 8:
        str--;
        gotoxy(wherex() - 1, wherey());
        print(" ", 215);
        gotoxy(wherex() - 1, wherey());
        break;
      default:
        print(ch, 215);
        *str++ = ch[0];
        break;
    }
  }
  while (ch[0] != '\r');
  *str = 0;
}

void printnum(nr)
word nr;
{
  char str[10];
  itoa(nr, str, 10);
  print(str, 215);
}

void showsch(sch)
schalter *sch;
{
  schalter *s = sch;
  while (s)
  {
    drawtangle(s->left, s->top, s->right, s->bottom, s->framecol);
    fill(s->left + 1, s->top + 1, s->col);
    if (s->msg)
    {
      gotoxy(s->left / 8 + 2, s->top / 8 + 2);
      print(s->msg, 215);
    }
    s = s->next;
  }
}

#endif