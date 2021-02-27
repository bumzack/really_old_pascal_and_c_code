#ifndef RAY
#define RAY

#include "vid.c"
#include "maus.c"
#include "graph.c"
#include "schalter.c"
#include "save.c"
#include "texture.c"
#include "calc.c"
#include "load.c"
#include "cad.c"

word countlamp = 0, countobj = 0;

schalter ne2= {
  0,
  203, 180, 304, 195,
  56, 0, 215,
  2,
  "EXIT",
  };

schalter ex1 = {
  &ne2,
  203, 165, 304, 178,
  56, 0, 215,
  2,
  "CALC WORLD",
  };

schalter cw1 = {
  &ex1,
  203, 148, 304, 162,
  56, 0, 215,
  2,
  "LOAD WORLD",
  };

schalter md1 = {
  &cw1,
  203, 133, 304, 145,
  56, 0, 215,
  2,
  "SAVE WORLD",
  };

schalter mt1 = {
  &md1,
  102, 165, 201, 178,
  56, 0, 215,
  2,
  "EDIT OBSV",
  };

schalter eob1 = {
  &mt1,
  102, 148, 201, 162,
  56, 0, 215,
  2,
  "EDIT LAMP",
  };

schalter el1 = {
  &eob1,
  102, 133, 201, 145,
  56, 0, 215,
  2,
  "EDIT OBJ",
  };

schalter eo1 = {
  &el1,
  1, 165, 100, 178,
  56, 0, 215,
  2,
  "MAKE TEXT",
  };

schalter sw1 = {
  &eo1,
  1, 148, 100, 162,
  56, 0, 215,
  2,
  "LOAD PIC",
  };

schalter ld1 = {
  &sw1,
  1, 133, 100, 145,
  56, 0, 215,
  2,
  "MAKE 3DATA",
  };

int count(void **f);
int loadtexture(object *o);
void clssc(void);
void getcol(color *c);
void edobj(world *w);
void edlamp(world *w);
void edobs(world *w);
int save(int x, int y, world *w);


int count(f)
void **f;
{
  int i = 0;
  while (f)
  {
    i++;
    f = *f;
  }
  return(i);
}

int loadtexture(o)
object *o;
{
  FILE *fp;
  int i, j;
  byte col;
  byte *c;
  char name[30];

  gotoxy(1, 3);
  print("Dateiname: ", 215);
  getstr(name);
  gotoxy(1, 3);
  print("                        ", 215);
  fp = fopen(name, "rb");
  if (!fp)
    return(0);
  fread(&(o->text.x), sizeof(word), 1, fp);
  fread(&(o->text.y), sizeof(word), 1, fp);
  if (o->text.map)
    free(o->text.map);

  o->text.map = c = malloc(sizeof(byte) * o->text.x * o->text.y);
  if (!o->text.map)
  {
    gotoxy(1, 3);
    print("Nicht genug Speicher", 215);
    fclose(fp);
    return(0);
  }
  for (i = 0; i < o->text.x; i++)
    for (j = 0; j < o->text.y; j++)
    {
      fread(&col, sizeof(col), 1, fp);
      *(c + o->text.y * i + j) = (unsigned)col;
    }
  fclose(fp);
  gotoxy(1, 3);
  print("Streckung: ", 215);
  getstr(name);
  o->text.big = atoi(name);
  if (o->type == SPHERE)
  {
    gotoxy(13, 3);
    print("                        ", 215);
    gotoxy(1, 3);
    print("Um die Kugel Vertikal Horizontal (V/H): ", 215);
    getstr(name);
    if (*name == 'V' || *name == 'v')
      o->text.typ = 1;
    else
      o->text.typ = 2;
  }
  return(1);
}

void clssc()
{
  int x, y;
  for (x = 1; x <= 80; x++)
    for (y = 1; y <= 14; y++)
    {
      gotoxy(x, y);
      print(" ", 215);
    }
}

void getcol(c)
color *c;
{
  char str[20];
  double help;

  gotoxy(13, 3);
  print("                        ", 215);
  gotoxy(1, 3);
  print("Rotanteil (0.0 - 1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    c->r = atof(str);
  gotoxy(13, 3);
  print("                        ", 215);
  gotoxy(1, 3);
  print("Gruenanteil (0.0 - 1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    c->g = atof(str);
  gotoxy(13, 3);
  print("                        ", 215);
  gotoxy(1, 3);
  print("Blauanteil (0.0 - 1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    c->b = atof(str);
}

void edobj(w)
world *w;
{
  char str[30];
  word nr, i;
  object *o;
  double help;
  clssc();
  gotoxy(1, 1);
  print("Nr des Objektes: ", 215);
  getstr(str);
  nr = atoi(str);
  if (nr > countobj || nr <= 0)
    return;
  o = w->object;
  for (i = 1; i < nr; i++)
    o = o->next;
  if (o->type == SPHERE)
  {
    print(" Kugel mit Radius ", 215);
    printnum((int)o->form.sphere.radius);
  }
  else
  {
    print(" Flaeche mit ", 215);
    printnum((int)o->form.polygon.num_vec);
    print(" Pktn", 215);
  }
  gotoxy(1, 2);
  print("Texture oder einfarbig (t/e): ", 215);
  getstr(str);
  if (*str == 'T' || *str == 't')
    loadtexture(o);
  else
  {
    o->text.x = 0;
    o->text.y = 0;
    o->text.map = 0;
    getcol(&(o->color));
  }
  gotoxy(1, 4);
  print("Materialdefinition ", 215);
  gotoxy(1, 5);
  print("Undurchsichtigkeit (0.0-1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    o->material = help;
  gotoxy(1, 6);
  print("Spiegelung (0.0-1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    o->mirror = help;
  gotoxy(1, 7);
  print("Transparenz (0.0-1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    o->trans = help;
  gotoxy(1, 8);
  print("Matte Reflexion (0.0-1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    o->dif_const = help;
  gotoxy(1, 9);
  print("Spiegelnde Reflexion (0.0-1.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 1.0 && strlen(str) > 0)
    o->spec_const = help;
  gotoxy(1, 10);
  print("Konzentr. spie. Refl. (0.0-100.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && help <= 100.0 && strlen(str) > 0)
    o->high_const = help;
  gotoxy(1, 11);
  print("Velzitaet (>0.0): ", 215);
  getstr(str);
  help = atof(str);
  if (help > 0)
    o->N = help;
  else
    o->N = 1.0;
  clssc();
}

void edlamp(w)
world *w;
{
  char str[30];
  word nr, i;
  lamp *l;
  double help;
  clssc();
  gotoxy(1, 1);
  print("Nr der Lampe: ", 215);
  getstr(str);
  nr = atoi(str);
  if (nr > countlamp || nr <= 0)
    return;
  l = w->lamp;
  for (i = 1; i < nr; i++)
    l = l->next;
  gotoxy(1, 2);
  print("Intensitaet wie weit >0.0: ", 215);
  getstr(str);
  help = atof(str);
  if (help >= 0.0 && strlen(str) > 0)
    l->intens = help;
  getcol(&(l->color));
  clssc();
}

int auf = 0;

void edobs(w)
world *w;
{
  char str[30];
  word nr, i;
  observer *o = w->observer;
  int help;
  double h;
  clssc();
  gotoxy(1, 1);
  print("Aufloesung (320/640/800/1024): ", 215);
  getstr(str);
  gotoxy(1, 1);
  print("                                      ", 215);
  help = atof(str);
  if (help > 320 && strlen(str) > 0)
    auf = 1;
  if (help > 640 && strlen(str) > 0)
    auf = 2;
  if (help > 800 && strlen(str) > 0)
    auf = 3;
  gotoxy(1, 1);
  print("Bildbreite in Pixel: ", 215);
  getstr(str);
  help = atoi(str);
  if (help > 0 && strlen(str) > 0)
    o->p_width = help;
  else
    o->p_width = 60;
  gotoxy(1, 2);
  print("Bildhoehe in Pixel: ", 215);
  getstr(str);
  help = atoi(str);
  if (help > 0 && strlen(str) > 0)
    o->p_height = help;
  else
    o->p_height = 40;
  o->dx = (int)(o->p_width * 1.14);
  o->dy = (int)(o->p_width);
  gotoxy(1, 2);
  print("Hintergrundfarbe                 ", 215);
  getcol(&background);
  background.r = background.r / 2;
  background.b = background.b / 2;
  background.g = background.g / 2;
  gotoxy(1, 2);
  print("Grundhelligkeit                  ", 215);
  getcol(&ambient);
  gotoxy(1, 3);
  print("St„rke der Grundhelligkeit (0.0-1.0):", 215);
  getstr(str);
  h = atof(str);
  if (h >= 0.0 && h <= 1.0 && strlen(str) > 0)
    amb = h;
  else
    amb = 0.0;
  gotoxy(1, 4);
  print("Berechnungstiefe >= 0): ", 215);
  getstr(str),
  help = atoi(str);
  if (help >= 0 && strlen(str) > 0)
    maxdepth = help;
  else
    maxdepth = 6;
  clssc();
}

int save(x, y, w)
int x, y;
world *w;
{
  char name[30];
  gotoxy(x, y);
  print("Name:                                             ", 215);
  gotoxy(x + 5, y);
  getstr(name);
  saveworld(w, name);
}

main()
{
  word x, y, ready = 0, help;
  word vidmod = setmod(GR320);
  char name[30], str[30];
  schalter *sch = &ld1;

  w1.lamp = 0;
  w1.object = 0;
  w1.observer = 0;

  delay(0);
  init_pal();
  showsch(sch);
  mouse_def(pointer, 17, 6);
  mouse_show();
  mouse_key(0);

  gotoxy(3, 5);
  print("   Welcome to the world of ", 35);
  gotoxy(3, 7);
  print("       RAY TRACING", 30);
  gotoxy(3, 9);
  print("  (c) 1992 DMV Widuch GmbH & Co. KG ", 35);

  w1.lamp = 0;
  w1.object = 0;
  w1.observer = 0;

  do
  {
    while (!mouse_press())
    {
      mouse_pos(&x, &y);
      x = x >> 1;
    }
    mouse_hide();
    switch(testsch(x, y, &ld1, &sch))
    {
      case 10:
        ready = 1;
        break;
      case 1:
        cad();
        w1.lamp = firstlamp;
        w1.object = first->first;
        if (!w1.observer)
        {
          w1.observer = malloc(sizeof(observer));
          memset(w1.observer, 0, sizeof(observer));
        }
        mouse_area(0, 0, 640, 200);
        textattr(0);
        clrscr();
        showsch(&ld1);
        mouse_def(pointer, 17, 6);
        mouse_show();
        mouse_key(0);
        countlamp = count((void **)firstlamp);
        countobj = count((void **)first->first);
        gotoxy(1, 16);
        print("Objekte: ", 215);
        printnum(countobj);
        print(" - Lampen: ", 215);
        printnum(countlamp);
        break;
      case 2:
        gotoxy(1, 16);
        print("Name:                                       ", 215);
        gotoxy(6, 16);
        getstr(name);
        gotoxy(1, 16);
        print("                      ", 215);
        gotoxy(1, 1);
        print("Aufloesung (320/640/800/1024): ", 215);
        getstr(str);
        help = atof(str);
        auf = 0;
        if (help > 320 && strlen(str) > 0)
          auf = 1;
        if (help > 640 && strlen(str) > 0)
          auf = 2;
        if (help > 800 && strlen(str) > 0)
          auf = 3;

        textattr(0);
        clrscr();

        switch(auf)
        {
          case 1:
            setmod(0x2f);
            break;
          case 2:
            setmod(0x30);
            break;
          case 3:
            setmod(0x38);
            break;
        }
        if (auf)
          init_pal();
        loadpic(name);
        mouse_show();
        while (!mouse_press() && !kbhit());
        if (auf)
        {
          setmod(GR320);
          init_pal();
        }
        if (kbhit())
          getch();
        mouse_hide();
        textattr(0);
        clrscr();
        showsch(&ld1);
        mouse_def(pointer, 17, 6);
        mouse_show();
        mouse_key(0);
        gotoxy(1, 16);
        print("Objekte: ", 215);
        printnum(countobj);
        print(" - Lampen: ", 215);
        printnum(countlamp);
        break;
      case 3:
        maketexture();
        textattr(0);
        clrscr();
        showsch(&ld1);
        mouse_def(pointer, 17, 6);
        mouse_show();
        mouse_key(0);
        gotoxy(1, 16);
        print("Objekte: ", 215);
        printnum(countobj);
        print(" - Lampen: ", 215);
        printnum(countlamp);
        break;
      case 4:
        edobj(&w1);
        break;
      case 5:
        edlamp(&w1);
        break;
      case 6:
        edobs(&w1);
        break;
      case 7:
        save(1, 16, &w1);
        break;
      case 8:
        gotoxy(1, 16);
        print("                                            ", 215);
        loadall(1, 16);
        w1.lamp = firstlamp;
        w1.object = first->first;
        countlamp = count((void **)firstlamp);
        countobj = count((void **)first->first);
        gotoxy(1, 16);
        print("Objekte: ", 215);
        printnum(countobj);
        print(" - Lampen: ", 215);
        printnum(countlamp);
        break;
      case 9:
        textattr(0);
        clrscr();
        gotoxy(1, 1);
        print("Zum Speichern des Bildes rechte ", 215);
        gotoxy(1, 2);
        print("Maustaste druecken; sonst linke", 215);
        gotoxy(1, 3);
        print("Name:                 ", 215);
        gotoxy(6, 3);
        getstr(name);
        gotoxy(1, 3);
        print("                      ", 215);
        textattr(0);
        clrscr();
        switch(auf)
        {
          case 1:
            setmod(0x2f);
            break;
          case 2:
            setmod(0x30);
            break;
          case 3:
            setmod(0x38);
            break;
        }
        if (auf)
          init_pal();
        show_world(&w1);
        mouse_show();
        while (!mouse_press() && !kbhit());
        if (kbhit())
          getch();
        mouse_hide();
        while (mouse_press());
        if (mouse_key(1))
          savepic(0, 0,
                  w1.observer->p_width,
                  w1.observer->p_height, name);
        if (auf)
        {
          setmod(GR320);
          init_pal();
        }
        textattr(0);
        clrscr();
        showsch(&ld1);
        mouse_def(pointer, 17, 6);
        mouse_show();
        mouse_key(0);
        gotoxy(1, 16);
        print("Objekte: ", 215);
        printnum(countobj);
        print(" - Lampen: ", 215);
        printnum(countlamp);
        break;
      default:
        sound(440);
        delay(2);
        nosound();
        break;
    }
    drawtangle(sch->left, sch->top, sch->right, sch->bottom, sch->framecol);
    mouse_show();
  }
  while (!ready);
  mouse_hide();
  setmod(vidmod);
}

#endif