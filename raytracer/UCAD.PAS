{$X+}

unit ucad;

interface

uses maus, Crt, vid, ugraph, schalter, calc, load, defs;

const np : TSchalter = (next : NIL; left : 289; top : 133; right: 310;
                        bottom : 152; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'N');
      sa : TSchalter = (next : @np; left : 214; top : 181; right: 285;
                        bottom : 193; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'SVE WRLD');
      lo : TSchalter = (next : @sa; left : 214; top : 165; right: 285;
                        bottom : 177; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'LOD WRLD');
      so : TSchalter = (next : @lo; left : 214; top : 149; right: 285;
                        bottom : 161; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'SET OBSV');
      sl : TSchalter = (next : @so; left : 214; top : 133; right: 285;
                        bottom : 145; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'SET LAMP');
      mo : TSchalter = (next : @sl; left : 145; top : 181; right: 210;
                        bottom : 193; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'MOV OBJ');
      ro : TSchalter = (next : @mo; left : 145; top : 165; right: 210;
                        bottom : 177; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'ROT OBJ');
      tr : TSchalter = (next : @ro; left : 145; top : 149; right: 210;
                        bottom : 161; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'TRANS');
      si : TSchalter = (next : @tr; left : 145; top : 133; right: 210;
                        bottom : 145; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'SIZE');
      os : TSchalter = (next : @si; left : 75; top : 133; right: 140;
                        bottom : 145; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'OBJ BEG');
      ap : TSchalter = (next : @os; left : 75; top : 149; right: 140;
                        bottom : 161; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'ADD POL');
      as : TSchalter = (next : @ap; left : 75; top : 165; right: 140;
                        bottom : 177; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'ADD SPH');
      ex : TSchalter = (next : @as; left : 289; top : 156; right: 310;
                        bottom : 193; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'E');

type PWin = ^TWin;
     TWin = record
              next : PWin;
              left, top, right, bottom : Word;
              curx, cury               : Word;
            end;

var
  px, py, pz, dx, dy, dz, cx, cy, cz, tx, ty, tz : Integer;
  vx, vy, vz                                     : Real;
  win1, win2, win3, win4                         : PWin;

type PSet = ^TSet;
     TSet = record
              next  : PSet;
              first : PObject;
            end;

const first  : PSet = NIL;
      actset : PSet = NIL;
      actobj : PObject = NIL;
      actlamp : PLamp = NIL;
      firstlamp : PLamp = NIL;

var
  nullpunkt, richtung : TVector;

procedure setwin(wi : PWin);
procedure showwin(beg : PWin);
procedure drawlinewin(wi : PWin; x0, y0, x1, y1 : Integer; c : Word);
procedure line3d(wi : PWin; x1, y1, z1, x2, y2, z2 : Integer; co : Word);
procedure circle2d(wi : PWin; x, y, r : Real);
procedure circle3d(wi : PWin; x, y, z, r : Integer);
procedure clswin(wi : PWin);
procedure changeview(wi : PWin);
procedure showpos(act : PWin; x, y : Word);
function genpol : PObject;
procedure genobs;
function genlamp : PLamp;
function gencir : PObject;
procedure rotvect(dx, dy, dz : Real; var x, y, z : Real; wi : Integer; str : String);
procedure rotobj(x, y, z : Real; o : PObject; wi : Integer; str : String);
procedure rotset(s : PSet);
procedure movobj(x, y, z : Integer; o : PObject);
procedure movset(s : PSet);
procedure mergeworld;
function saveall : Integer;
function loadall(x, y : Integer) : Integer;
procedure cad;

implementation

procedure Init;
begin
  New(win1);
  win1^.next := @win2;
  win1^.left := 1;
  win1^.top  := 1;
  win1^.right := 105;
  win1^.bottom := 105;
  win1^.curx := 103;
  win1^.cury := 62;

  New(win2);
  win2^.next := @win3;
  win2^.left := 107;
  win2^.top := 1;
  win2^.right := 211;
  win2^.bottom := 105;
  win2^.curx := 103;
  win2^.cury := 62;

  New(win3);
  win3^.next := @win4;
  win3^.left := 213;
  win3^.top := 1;
  win3^.right := 317;
  win3^.bottom := 105;
  win3^.curx := 103;
  win3^.cury := 62;

  New(win4);
  win4^.next := @win1;
  win4^.left := 1;
  win4^.top := 125;
  win4^.right := 317;
  win4^.bottom := 198;
  win4^.curx := 0;
  win4^.cury := 0;
end;

{
  aktiviert das Fenster wi
}

procedure setwin(wi : PWin);
var
  x, y : Word;
begin
  mouse_hide;
  mouse_area(wi^.left SHL 1, wi^.top, wi^.right SHL 1, wi^.bottom);
  if wi = @win1 then
    mouse_move((px SHL 1) + (wi^.left SHL 1), pz + wi^.top)
  else
    if wi = @win2 then
      mouse_move((px SHL 1) + (wi^.left SHL 1), py + wi^.top)
    else
      if wi = @win3 then
        mouse_move((pz SHL 1) + (wi^.left SHL 1), py + wi^.top)
      else
        mouse_move(wi^.curx + (wi^.left SHL 1), wi^.top + wi^.cury);
  mouse_show;
end;

{
  zeichnet alle Fensterumrandungen
}

procedure showwin(beg : PWin);
var
  wi : PWin;
begin
  wi := beg;
  repeat
    drawtangle(wi^.left - 1, wi^.top - 1,
               wi^.right + 1, wi^.bottom + 1, 215);
    wi := wi^.next;
  until wi = beg;
end;

{
  zeichnet Linie von x0, y0 nach x1, y1 in Farbe c
}

procedure drawlinewin(wi : PWin; x0, y0, x1, y1 : Integer; c : Word);
var
  ax, ay, dx, dy, iy, ix, h, off, ct : Integer;
begin
  ax := 0;
  ay := 0;
  if x1 >= x0 then
  begin
    dx := x1 - x0;
    ix := 1;
  end
  else
  begin
    dx := x1 - x0;
    ix := -1;
  end;
  if y1 >= y0 then
  begin
    dy := y1 - y0;
    iy := 1;
  end
  else
  begin
    dy := y0 - y1;
    iy := -1;
  end;
  if dx < dy then
  begin
    h := dx; dx := dy; dy := h;
    ay := ix; ax := iy; ix := 0; iy := 0;
  end;
  off := dx SHR 1;
  ct := 1;

  if (x0 >= wi^.left) AND (x0 <= wi^.right) AND
     (y0 >= wi^.top) AND (y0 <= wi^.bottom) then
    put_pixel(x0, y0, c);

  while dx >= ct do
  begin
    Inc(x0, ct);
    Inc(y0, ax);
    Inc(ct);
    Inc(off, dy);
    if off > dx then
    begin
      Dec(off, dx);
      Inc(x0, ay);
      Inc(y0, iy);
    end;
    if (x0 >= wi^.left) AND (x0 <= wi^.right) AND
       (y0 >= wi^.top) AND (y0 <= wi^.bottom) then
      put_pixel(x0, y0, c);
  end;
end;

{
  zeichnet dreidimensionale Linie in ein Fenster
}

procedure line3d(wi : PWin; x1, y1, z1, x2, y2, z2 : Integer; co : Word);
var
  xa, ya, xb, yb : Integer;
begin
  mouse_hide;
  xa := wi^.left - dx - tx + Round(x1 / vx);
  xb := wi^.left - dx - tx + Round(x2 / vx);
  ya := wi^.top - dz - tz + Round(z1 / vz);
  yb := wi^.top - dz - tz + Round(z2 / vz);
  drawlinewin(wi, xa, ya, xb, yb, co);
  wi := wi^.next;
  xa := wi^.left - dx - tx + Round(x1 / vx);
  xb := wi^.left - dx - tx + Round(x2 / vx);
  ya := wi^.top - dy - ty + Round(y1 / vy);
  yb := wi^.top - dy - ty + Round(y2 / vy);
  drawlinewin(wi, xa, ya, xb, yb, co);
  wi := wi^.next;
  xa := wi^.left - dz - tz + Round(z1 / vz);
  xb := wi^.left - dz - tz + Round(z2 / vz);
  ya := wi^.top - dy - ty + Round(y1 / vy);
  yb := wi^.top - dy - ty + Round(y2 / vy);
  drawlinewin(wi, xa, ya, xb, yb, co);
  mouse_show;
end;

{
  zeichnet Kreis in ein Fenster
}

procedure circle2d(wi : PWin; x, y, r : Real);
var
  i, j, io, jo : Integer;
begin
  io := Round(x - r);
  jo := Round(y);
  for i := Round(-r) to Round(r) do
  begin
    j := Round(Sqrt(r * r - i * i));
    drawlinewin(wi, io, jo, Round(i + x), Round(j + y), 30);
    io := Round(i + x);
    jo := Round(j + y);
  end;
  io := Round(x + r);
  jo := Round(y);
  for i := Round(r) downto Round(-r) do
  begin
    j := -Round(Sqrt(r * r - i * i));
    drawlinewin(wi, io, jo, Round(i + x), Round(j + y), 30);
    io := Round(i + x);
    jo := Round(j + y);
  end;
end;

{
  zeichnet Kugel in ein Fenster
}

procedure circle3d(wi : PWin; x, y, z, r : Integer);
var
  xa, ya : Integer;
begin
  mouse_hide;
  line3d(wi, x, y, z, x, y, z, 30);
  xa := wi^.left - dx - tx + Round(x / vx);
  ya := wi^.top - dz - tx - Round(z / vz);
  r := Round(r / vz);
  Circle2d(wi, xa, ya, r);
  wi := wi^.next;
  xa := wi^.left - dx - tx + Round(x / vx);
  ya := wi^.top - dy - ty - Round(y / vy);
  Circle2d(wi, xa, ya, r);
  wi := wi^.next;
  xa := wi^.left - dz - tz + Round(z / vz);
  ya := wi^.top - dy - ty - Round(y / vy);
  Circle2d(wi, xa, ya, r);
  mouse_show;
end;

{
  lîscht ein Fenster
}

procedure clswin(wi : PWin);
var
  x, y : Word;
begin
  for x := wi^.left to wi^.right do
    for y := wi^.top to wi^.bottom do
      put_pixel(x, y, 0);
end;

{
  berechnet Ansicht neu fÅr alle Fenster
}

procedure changeview(wi : PWin);
var
  s  : PSet;
  p  : PPolygon;
  sh : PSphere;
  o  : PObject;
  l  : PLamp;
  i  : Integer;
begin
  s := First;
  l := firstlamp;

  mouse_hide;
  clswin(wi);
  clswin(wi^.next);
  clswin(wi^.next^.next);

  while s <> NIL do
  begin
    o := s^.first;
    while o <> NIL do
    begin
      if o^.typ = POLYGON then
      begin
        p := @o^.polygon;
        for i := 0 to p^.num_vec - 1 do
        begin
          line3d(@wi, Round(p^.vector[i].x),
                      Round(p^.vector[i].y),
                      Round(p^.vector[i].z),
                      Round(p^.vector[i + 1].x),
                      Round(p^.vector[i + 1].y),
                      Round(p^.vector[i + 1].z),
                      4);
        end;
        line3d(@wi, Round(p^.vector[i].x),
                    Round(p^.vector[i].y),
                    Round(p^.vector[i].z),
                    Round(p^.vector[i + 1].x),
                    Round(p^.vector[i + 1].y),
                    Round(p^.vector[i + 1].z),
                    4);
      end
      else
      begin
        sh := @o^.sphere;
        circle3d(@win1, Round(sh^.vector.x),
                        Round(sh^.vector.y),
                        Round(sh^.vector.z),
                        Round(sh^.radius));
      end;
      o := o^.next;
    end;
    s := s^.next;
  end;
  while l <> NIL do
  begin
    line3d(@win1, Round(l^.vector.x),
                  Round(l^.vector.y),
                  Round(l^.vector.z),
                  Round(l^.vector.x),
                  Round(l^.vector.y),
                  Round(l^.vector.z),
                  150);
    l := l^.next;
  end;
  line3d(@win1, Round(nullpunkt.x),
                Round(nullpunkt.y),
                Round(nullpunkt.z),
                Round(richtung.x),
                Round(richtung.y),
                Round(richtung.z),
                35);
  mouse_show;
end;

{
  zeigt aktuelle dreidimensinale Mauspositionan
}

procedure showpos(act : PWin; x, y : Word);
var
  xo, yo, zo : Integer;
begin
  x := x - (act^.left SHL 1);
  y := y - act^.top;
  x := x SHR 1;
  if (act = @win1) OR (act = @win2) then
    px := x;
  if (act = @win1) OR (act = @win3) then
    pz := y;
  if (act = @win2) then
    py := y;
  if (act = @win3) then
  begin
    pz := x;
    py := y;
  end;
  xo := cx;
  yo := cy;
  zo := cz;
  cx := Round((px + dx + tx) * vx);
  cy := Round(-(py + dy + ty) * vy);
  cz := Round(-(pz + dz + tz) * vz);
  gotoxy(2, 17);
  print('X: ', 215);

  if cx <> xo then
  begin
    gotoxy(2, 17);
    print('X:        ', 215);
    gotoxy(4, 17);
    printnum(cx);
  end;
  if cy <> yo then
  begin
    gotoxy(2, 18);
    print('Y:        ', 215);
    gotoxy(4, 18);
    printnum(cy);
  end;
  if cz <> zo then
  begin
    gotoxy(2, 19);
    print('Z:        ', 215);
    gotoxy(4, 19);
    printnum(cz);
  end;
end;

{
  generiert ein Polygon
}

function genpol : PObject;
var
  ready, x, y : Word;
  xo, yo, zo, flag : Integer;
  act              : PWin;
  o                : PObject;
  p                : PPolygon;
begin
  ready := 0;
  flag := 0;
  act := @win1;

  GetMem(o, SizeOf(TObject));
  if o = NIL then
  begin
    genpol := NIL;
    Exit;
  end;
  FillChar(o^, SizeOf(TObject), 0);
  o^.next := NIL;
  o^.typ := POLYGON;

  p := @o^.polygon;
  p^.num_vec := 0;
  setwin(act);
  mouse_show;
  while mouse_press <> 0 do;
  mouse_key(0);
  mouse_key(1);

  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      showpos(act, x, y);
    end;
    while mouse_press <> 0 do;

    { wechseln des Fensters }

    if mouse_key(1) <> 0 then
    begin
      mouse_pos(x, y);
      act^.curx := x - (act^.left SHL 1);
      act^.cury := y - act^.top;
      act := act^.next;
      if act = @win4 then
        act := act^.next;
      setwin(act);
      if mouse_key(0) <> 0 then
        ready := 1;
    end;
    { Punkt setzen }
    if mouse_key(0) <> 0 then
    begin
      p^.vector[p^.num_vec].x := cx;
      p^.vector[p^.num_vec].y := cy;
      p^.vector[p^.num_vec].z := cz;
      Inc(p^.num_vec);
      if flag = 0 then
      begin
        Inc(flag);
        xo := cx;
        yo := cy;
        zo := cz;
        line3d(@win1, cx, cy, cz, cx, cy, cz, 4);
      end
      else
        line3d(@win1, xo, yo, zo, cx, cy, cz, 4);
      xo := cx;
      yo := cy;
      zo := cz;
    end;
  until (ready <> 0) OR (p^.num_vec > MAXVECTS);
  if p^.num_vec <> 0 then
    line3d(@win1, xo, yo, zo,
                  Round(p^.vector[0].x),
                  Round(p^.vector[0].y),
                  Round(p^.vector[0].z),
                  4)
  else
  begin
    FreeMem(o, SizeOf(TObject));
    o := NIL;
  end;
  genpol := o;
end;

{
  generiert Observer
}

procedure genobs;
var
  ready, x, y, flag : Word;
  act               : PWin;
begin
  ready := 0;
  flag := 0;
  act := @win1;

  setwin(act);
  mouse_show;
  while mouse_press <> 0 do;
  mouse_key(0);
  mouse_key(1);

  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      showpos(act, x, y);
    end;
    while mouse_press <> 0 do;

    { wechseln des Fensters }

    if mouse_key(1) <> 0 then
    begin
      mouse_pos(x, y);
      act^.curx := x - (act^.left SHL 1);
      act^.cury := y - act^.top;
      act := act^.next;
      if act = @win4 then
        act := act^.next;
      if mouse_key(0) <> 0 then
        ready := 1;
    end;

    { Punkt setzen }
    if mouse_key(0) <> 0 then
    begin
      if flag = 0 then
      begin
        Inc(flag);
        nullpunkt.x := cx;
        nullpunkt.y := cy;
        nullpunkt.z := cz;
        line3d(@win1, cx, cy, cz, cx, cy, cz, 35);
      end
      else
      begin
        ready := 1;
        richtung.x := cx;
        richtung.y := cy;
        richtung.z := cz;
        line3d(@win1, Round(nullpunkt.x),
                      Round(nullpunkt.y),
                      Round(nullpunkt.z),
                      Round(richtung.x),
                      Round(richtung.y),
                      Round(richtung.z),
                      35);
      end;
    end;
  until ready <> 0;
end;

{
  generiert Lampe im dreidimensinalen Raum
}

function genlamp : PLamp;
var
  ready, x, y : Word;
  act         : PWin;
  l           : PLamp;
begin
  ready := 0;
  act := @win1;
  GetMem(l, SizeOf(TLamp));
  if l = NIL then
  begin
    genlamp := NIL;
    Exit;
  end;
  FillChar(l^, SizeOf(TLamp), 0);
  l^.next := NIL;
  setwin(act);
  mouse_show;
  while mouse_press <> 0 do;
  mouse_key(0);
  mouse_key(1);

  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      showpos(act, x, y);
    end;
    while mouse_press <> 0 do;

    { wechseln des Fensters }

    if mouse_key(1) <> 0 then
    begin
      mouse_pos(x, y);
      act^.curx := x - (act^.left SHL 1);
      act^.cury := y - act^.top;
      act := act^.next;
      if act = @win4 then
        act := act^.next;
      if mouse_key(0) <> 0 then
        ready := 2;
    end;

    { Punkt setzen }
    if mouse_key(0) <> 0 then
    begin
      l^.vector.x := cx;
      l^.vector.y := cy;
      l^.vector.z := cz;
      line3d(@win1, cx, cy, cz, cx, cy, cz, 150);
      ready := 1;
    end;
  until ready <> 0;
  if ready = 2 then
  begin
    FreeMem(l, SizeOf(TLamp));
    l := NIL;
  end;
  genlamp := l;
end;

{
  generiert Kugel im dreidimensionalen Raum
}

function gencir : PObject;
var
  ready, x, y : Word;
  xo, yo, zo  : Real;
  flag        : Integer;
  act         : PWin;
  o           : PObject;
  sh          : PSphere;
begin
  ready := 0;
  act := @win1;

  GetMem(o, SIzeOf(TObject));
  if o = NIL then
  begin
    gencir := NIL;
    Exit;
  end;
  FillChar(o^, SizeOf(TObject), 0);
  o^.next := NIL;
  o^.typ := SPHERE;

  sh := @o^.sphere;
  setwin(act);
  mouse_show;
  while mouse_press <> 0 do;
  mouse_key(0);
  mouse_key(1);

  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      showpos(act, x, y);
    end;
    while mouse_press <> 0 do;

    { wechseln des Fensters }

    if mouse_key(1) <> 0 then
    begin
      mouse_pos(x, y);
      act^.curx := x - (act^.left SHL 1);
      act^.cury := y - act^.top;
      act := act^.next;
      if act = @win4 then
        act := act^.next;
      setwin(act);
      if mouse_key(0) <> 0 then
        ready := 2;
    end;
    { Punkt setzen }
    if mouse_key(0) <> 0 then
    begin
      if flag = 0 then
      begin
        Inc(flag);
        sh^.vector.x := cx;
        sh^.vector.y := cy;
        sh^.vector.z := cz;
        line3d(@win1, cx, cy, cz, cx, cy, cz, 4);
        xo := cx;
        yo := cy;
        zo := cz;
      end
      else
      begin
        ready := 1;
        xo := cx - xo;
        yo := cy - yo;
        zo := cz - zo;
        sh^.radius := Sqrt(xo * xo + yo * yo + zo * zo);
        circle3d(@win1, Round(sh^.vector.x),
                        Round(sh^.vector.y),
                        Round(sh^.vector.z),
                        Round(sh^.radius));
      end;
    end;
  until ready <> 0;
  if ready = 2 then
  begin
    FreeMem(o, SizeOf(TObject));
    o := NIL;
  end;
  gencir := o;
end;

{
  dreht Vector x, y, z um dx, dy, dz mit Winkel wi
}

procedure rotvect(dx, dy, dz : Real; var x, y, z : Real; wi : Integer; str : String);
var
  xn, yn, tx, ty, w, nx, ny, nz : Real;
begin
  w := wi * 3.141597 / 180;
  case str[1] of
    'X', 'x' : begin
                 xn := z;
                 tx := dz;
                 yn := y;
                 nx := z;
                 ty := dy;
                 ny := y;
               end;
    'Y', 'y' : begin
                 xn := x;
                 tx := dx;
                 yn := z;
                 nx := x;
                 ty := dz;
                 ny:= z;
               end;
    'Z', 'z' : begin
                 xn := x;
                 tx := dx;
                 yn := y;
                 nx := x;
                 ty := dy;
                 ny := y;
               end;
  end;
  nx := (xn - tx) * cos(w) - (yn - ty) * sin(w) + tx;
  ny := (yn - ty) * cos(w) - (xn - tx) * sin(w) + ty;
end;

{
  dreht Object o um x, y, z mit Winkel wi
}

procedure rotobj(x, y, z : Real; o : PObject; wi : Integer; str : String);
var
  i : Integer;
begin
  case o^.typ of
    POLYGON : for i := 0 to o^.polygon.num_vec - 1 do
                rotvect(x, y, z, o^.polygon.vector[i].x,
                                 o^.polygon.vector[i].y,
                                 o^.polygon.vector[i].z, wi,str);
    SPHERE :  rotvect(x, y, z, o^.sphere.vector.x,
                               o^.sphere.vector.y,
                               o^.sphere.vector.z, wi, str);
  end;
end;

{
  dreht set s
}

procedure rotset(s : PSet);
var
  Error   : Integer;
  str     : str80;
  wi      : Integer;
  o       : PObject;
  x, y, z : Real;
begin
  GotoXY(2, 21);
  print('W:        ', 215);
  gotoxy(4, 21);
  getstr(str);
  if Length(str) > 0 then
    Val(str, wi, Error);
  gotoxy(2, 22);
  print('Achse:    ', 215);
  gotoxy(8, 22);
  getstr(str);
  if s <> NIL then
  begin
    o := s^.first;
    if o <> NIL then
      case o^.typ of
        POLYGON : begin
                    x := o^.polygon.vector[0].x;
                    y := o^.polygon.vector[0].y;
                    z := o^.polygon.vector[0].z;
                  end;
        SPHERE  : begin
                    x := o^.sphere.vector.x;
                    y := o^.sphere.vector.y;
                    z := o^.sphere.vector.z;
                  end;
      end;
    while o <> NIL do
    begin
      rotobj(x, y, z, o, wi, str);
      o := o^.next;
    end;
  end;
end;

{
  bewegt Objekt o um x, y, z weiter
}

procedure movobj(x, y, z : Integer; o : PObject);
var
  i : Integer;
begin
  case o^.typ of
    POLYGON : begin
                for i := 0 to o^.polygon.num_vec - 1 do
                begin
                  o^.polygon.vector[i].x := o^.polygon.vector[i].x + x;
                  o^.polygon.vector[i].y := o^.polygon.vector[i].y + y;
                  o^.polygon.vector[i].z := o^.polygon.vector[i].z + z;
                end;
              end;
    SPHERE :  begin
                o^.sphere.vector.x := o^.sphere.vector.x + x;
                o^.sphere.vector.y := o^.sphere.vector.y + y;
                o^.sphere.vector.z := o^.sphere.vector.z + z;
              end;
  end;
end;

{
  bewegt set s im Raum
}

procedure movset(s : PSet);
var
  Error      : Integer;
  tx, ty, tz : Integer;
  o          : PObject;
  str        : str80;
begin
  gotoxy(2, 21);
  print('X:        ', 215);
  gotoxy(4, 21);
  getstr(str);
  if Length(str) > 0 then
    Val(str, tx, Error);
  GotoXY(2, 22);
  print('Y:        ', 215);
  gotoxy(4, 22);
  getstr(str);
  if Length(str) > 0 then
    Val(str, ty, Error);
  GotoXY(2, 23);
  print('Z:        ', 215);
  gotoxy(4, 23);
  getstr(str);
  if Length(str) > 0 then
    Val(str, tz, Error);
  if s <> NIL then
  begin
    o := s^.first;
    while o <> NIL do
    begin
      movobj(tx, ty, tz, o);
      o := o^.next;
    end;
  end;
end;

{
  berechnet Ansicht der Welt nach dem gesetzten Observer
}

procedure mergeworld;
var
  s, s1                : PSet;
  tx, ty, tz, wi1, wi2 : Integer;
  o, old               : PObject;
  l                    : PLamp;
begin
  s := NIL;
  s1 := NIL;
  o := NIL;
  old := NIL;

  s := first;
  { Transformation }
  tx := Round(-nullpunkt.x);
  ty := Round(-nullpunkt.y);
  tz := Round(-nullpunkt.z);
  while s <> NIL do
  begin
    o := s^.first;
    while o <> NIL do
    begin
      movobj(tx, ty, tz, o);
      old := o;
      o := o^.next;
    end;
    s1 := s;
    s := s^.next;
    if s <> NIL then
      if old <> NIL then
        old^.next := s^.first;
    if s1 <> first then
      FreeMem(s1, SizeOf(TSet))
    else
      s1^.next := NIL;
  end;
  actset := first;
  l := firstlamp;
  while l <> NIL do
  begin
    l^.vector.x := l^.vector.x + (-nullpunkt.x);
    l^.vector.y := l^.vector.y + (-nullpunkt.y);
    l^.vector.z := l^.vector.z + (-nullpunkt.z);
    l := l^.next;
  end;
  { Rotation des Ursprungs }
  if richtung.z <> nullpunkt.z then
  begin
    wi1 := Round(arctan((richtung.x - nullpunkt.x) /
           (richtung.z - nullpunkt.z)) * 180 / 3.1415927);
    wi2 := Round(arctan((richtung.y - nullpunkt.y) /
           (richtung.z - nullpunkt.z)) * 180 / 3.1415927);
    s := first;
    if s <> NIL then
    begin
      o := s^.first;
      while o <> NIL do
      begin
        rotobj(0.0, 0.0, 0.0, o, wi1, 'y');
        rotobj(0.0, 0.0, 0.0, o, -wi2, 'x');
        o := o^.next;
      end;
    end;

    l := firstlamp;
    while l <> NIL do
    begin
      rotvect(0.0, 0.0, 0.0, l^.vector.x,
                             l^.vector.y,
                             l^.vector.z, wi1, 'y');
      rotvect(0.0, 0.0, 0.0, l^.vector.x,
                             l^.vector.y,
                             l^.vector.z, -wi2, 'x');
      l := l^.next;
    end;
  end;
  richtung.x := 0;
  richtung.y := 0;
  richtung.z := 1;
  nullpunkt.x := 0;
  nullpunkt.y := 0;
  nullpunkt.z := 0;
end;

{
  speichert 3D Daten als Welt ab
}

function saveall : Integer;
var
  name : str80;
begin
  mergeworld;
  changeview(@win1);

  w1.objects := first^.first;
  w1.lamp := firstlamp;

  gotoxy(2, 24);
  print('Name:           ', 215);
  gotoxy(7, 24);
  getstr(name);
  gotoxy(2, 24);
  print('                ', 215);
  saveall := saveworld(@w1, name);
end;

{
  lÑdt 3D Daten ein
}

function loadall(x, y : Integer) : Integer;
var
  name : str80;
  l    : PLamp;
  o    : PObject;
begin
  gotoxy(x, y);
  print('Name:           ', 215);
  gotoxy(x + 5, y);
  getstr(name);
  gotoxy(x, y);
  print('                ', 215);
  mergeworld;
  if actset <> NIL then
    FreeMem(actset, SizeOf(TSet));
  if loadworld(@w1, name) <> 0 then
  begin
    firstlamp := w1.lamp;
    if first = NIL then
    begin
      GetMem(first, SizeOf(TSet));
      actset := first;
      first^.next := NIL;
    end;
    first^.first := w1.objects;
    actlamp := NIL;
    actobj := NIL;
    loadall := 1;
    Exit;
  end;

  if first = NIL then
  begin
    GetMem(first, SizeOf(TSet));
    actset := first;
  end;
  if first = NIL then
  begin
    loadall := 1;
    Exit;
  end;

  firstlamp := w1.lamp;
  first^.next := NIL;
  first^.first := w1.objects;

  o := first^.first;
  if o <> NIL then
    while o^.next <> NIL do
      o := o^.next;
  actobj := o;
  l := firstlamp;
  if l <> NIL then
    while l^.next <> NIL do
      l := l^.next;
  actlamp := l;
  loadall := 0;
end;

{
  Editor fÅr Kîrperdaten
  der neuen Welt
}

procedure cad;
var
  x, y, ready : Word;
  xo, yo, zo  : Integer;
  str         : str80;
  act         : PWin;
  sch         : PSchalter;
  newobj      : PObject;
  newlamp     : PLamp;
  Error       : Integer;
  help        : Real;
begin
  ready := 0;
  act := @win4;
  sch := @ex;

  nullpunkt.x := 0;
  nullpunkt.y := 0;
  nullpunkt.z := 0;
  richtung.x := 0;
  richtung.y := 0;
  richtung.z := 0;

  textattr := 0;
  clrscr;
  setwin(act);
  showwin(act);
  showsch(sch);
  gotoxy(6, 15);
  print('DOWN       NORTH        WEST', 215);
  gotoxy(38, 19);
  print('P', 215);
  gotoxy(38, 22);
  print('X', 215);
  gotoxy(38, 23);
  print('I', 215);
  gotoxy(38, 24);
  print('T', 215);
  mouse_check;
  mouse_def(Pointer, 17, 6);
  mouse_show;
  mouse_key(0);
  px := 52;
  py := 52;
  pz := 52;
  tx := 0;
  ty := 0;
  tz := 0;
  dx := -52;
  dy := -52;
  dz := -52;
  vx := 10;
  vy := 10;
  vz := 10;
  gotoxy(2, 17);
  print('X:0', 215);
  gotoxy(2, 18);
  print('Y:0', 215);
  gotoxy(2, 19);
  print('Z:0', 215);
  changeview(@win1);
  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      showpos(act, x, y);
      act^.curx := x - act^.left;
      act^.cury := y - act^.top;
      x := x SHR 1;
    end;

    mouse_hide;
    case testsch(x, y, @ex, @sch) of
       1 : begin
             ready := 1;
             mergeworld;
           end;
      13 : begin
             mergeworld;
             changeview(@win1);
           end;
      12 : saveall;
      11 : begin
             loadall(2, 24);
             changeview(@win1);
           end;
      10 : begin
             genobs;
             changeview(@win1);
           end;
       9 : begin
             newlamp := genlamp;
             if firstlamp = NIL then
               firstlamp := newlamp
             else
               actlamp^.next := newlamp;
             if newlamp <> NIL then
               actlamp := newlamp;
           end;
       8 : begin
             movset(actset);
             changeview(@win1);
           end;
       7 : begin
             rotset(actset);
             changeview(@win1);
            end;
       6 : begin
             gotoxy(2, 21);
             print('X:        ', 215);
             gotoxy(4, 21);
             getstr(str);
             if Length(str) > 0 then
               Val(str, tx, Error);
             GotoXY(2, 22);
             print('Y:        ', 215);
             gotoxy(4, 22);
             getstr(str);
             if Length(str) > 0 then
               Val(str, ty, Error);
             GotoXY(2, 23);
             print('Z:        ', 215);
             gotoxy(4, 23);
             getstr(str);
             if Length(str) > 0 then
               Val(str, tz, Error);
             changeview(@win1);
           end;
       5 : begin
             gotoxy(2, 24);
             print('M:        ', 215);
             gotoxy(4, 24);
             getstr(str);
             Val(str, help, Error);
             if (help <> 0.0) AND (help <= 600.0) then
             begin
               vx := help;
               vy := help;
               vz := help;
             end;
             changeview(@win1);
           end;
       4 : begin                       { neues Set }
             while mouse_press <> 0 do;
             mouse_key(0);
             mouse_key(1);
             if first = NIL then
             begin
               GetMem(actset, SizeOf(TSet));
               first := actset;
             end
             else
             begin
               GetMem(actset^.next, SizeOf(TSet));
               actset := actset^.next;
             end;
             if actset <> NIL then
             begin
               actset^.next := NIL;
               actset^.first := NIL;
               actobj := NIL;
             end;
           end;
       3 : begin                       { addpol }
             if actset <> NIL then
             begin
               newobj := genpol;
               if actobj <> NIL then
                 actobj^.next := newobj
               else
                 actset^.first := newobj;
               if newobj <> NIL then
                 actobj := newobj;
             end;
           end;
       2 : begin                       { add sphere }
             if actset <> NIL then
             begin
               newobj := gencir;
               if actobj <> NIL then
                 actobj^.next := newobj
               else
                 actset^.first := newobj;
               if newobj <> NIL then
                 actobj := newobj;
             end;
           end;
    else
      Sound(440);
      Delay(2);
      NoSound;
    end;
    drawtangle(sch^.left, sch^.top, sch^.right, sch^.bottom, sch^.framecol);
    setwin(act);
    mouse_show;
  until ready <> 0;
  mouse_hide;
end;

begin
  Init;            { Fenster initialisieren }
end.