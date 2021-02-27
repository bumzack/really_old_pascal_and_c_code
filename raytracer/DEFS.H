#ifndef DEFS
#define DEFS

#define POLYGON      0
#define SPHERE       1
#define MAXVECTS     10
#define MAXRED       1.0
#define MAXGREEN     1.0
#define MAXBLUE      1.0

typedef unsigned char byte;
typedef unsigned int  word;

typedef struct vector {
  double x, y, z;
  } vector;

typedef struct polygon {
  byte num_vec;
  vector vector[MAXVECTS];
  } polygon;

typedef struct sphere {
  vector vector;
  double radius;
  } sphere;

typedef struct color {
  double r, g, b;
  } color;

typedef struct {
  word x, y;
  word big;
  byte typ;
  byte *map;
  } texture;

typedef struct object {
  struct object *next;
  color color;
  double material;
  double mirror;
  double trans;
  double dif_const;
  double spec_const;
  double high_const;
  double N;
  texture text;
  byte type;
  union {
    polygon polygon;
    sphere sphere;
    } form;
  } object;

typedef struct lamp {
  struct lamp *next;
  vector vector;
  color color;
  double intens;
  } lamp;

typedef struct {
  int p_width;
  int p_height;
  int dx, dy;
  } observer;

typedef struct {
  lamp *lamp;
  object *object;
  observer *observer;
  } world;

#endif
