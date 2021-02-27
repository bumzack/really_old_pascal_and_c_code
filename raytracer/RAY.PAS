{$X+}

program ray;

uses Crt, vid, maus, ugraph, schalter, usave, texture, calc, load, ucad, defs;

const
  countlamp : Word = 0;
  countobj  : Word = 0;

const ne2 : TSchalter = (next : NIL; left : 203; top : 180; right: 304;
                         bottom : 195; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'EXIT');
      ex1 : TSchalter = (next : @ne2; left : 203; top : 165; right: 304;
                         bottom : 178; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'CALC WORLD');
      cw1 : TSchalter = (next : @ex1; left : 203; top : 148; right: 304;
                         bottom : 162; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'LOAD WORLD');
      md1 : TSchalter = (next : @cw1; left : 203; top : 133; right: 304;
                         bottom : 145; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'SAVE WORLD');
      mt1 : TSchalter = (next : @md1; left : 102; top : 165; right: 201;
                         bottom : 178; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'EDIT OBSV');
      eob1: TSchalter = (next : @mt1; left : 102; top : 148; right: 201;
                         bottom : 162; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'EDIT LAMP');
      el1 : TSchalter = (next : @eob1; left : 102; top : 133; right: 201;
                         bottom : 145; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'EDIT OBJ');
      eo1 : TSchalter = (next : @el1; left : 1; top : 165; right: 100;
                         bottom : 178; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'MAKE TEXT');
      sw1 : TSchalter = (next : @eo1; left : 1; top : 148; right: 100;
                         bottom : 162; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'LOAD PIC');
      ld1 : TSchalter = (next : @sw1; left : 1; top : 133; right: 100;
                         bottom : 145; framecol : 56; col : 0; ilucol : 215;
                         backcol : 2; msg : 'MAKE 3DATA');

function countl(lamp : PLamp) : Integer;
var
  l : PLamp;
  i : Integer;
begin
  l := lamp;
  i := 0;
  while l <> NIL do
  begin
    Inc(i);
    l := l^.next;
  end;
  countl := i;
end;

function counto(obj : PObject) : Integer;
var
  o : PObject;
  i : Integer;
begin
  o := obj;
  i := 0;
  while o <> NIL do
  begin
    Inc(i);
    o := o^.next;
  end;
  counto := i;
end;

{
  loadtexture(o): lÑdt texture fÅr
  ein Object o in den reservierten
  Speicher ein
  1 falls erfolgreich
}

function loadtexture(o : PObject) : Integer;
var
  fp    : File;
  i, j  : Integer;
  col   : Byte;
  c     : PByte;
  name  : str80;
  Error : Integer;
begin
  gotoxy(1, 3);
  print('Dateiname: ', 215);
  getstr(name);
  gotoxy(1, 3);
  print('                   ', 215);
  Assign(fp, name);
  {$I-}
  Rewrite(fp);
  {$I+}
  if IOResult <> 0 then
  begin
    loadtexture := 0;
    Exit;
  end;
  BlockRead(fp, o^.text.x, SizeOf(Word));
  BlockRead(fp, o^.text.y, SizeOf(Word));
  if o^.text.map <> NIL then
    Dispose(o^.text.map);

  GetMem(c, SizeOf(Byte) * o^.text.x * o^.text.y);
  o^.text.map := c;
  if o^.text.map = NIL then
  begin
    gotoxy(1, 3);
    print('Nicht genug Speicher', 215);
    Close(fp);
    loadtexture := 0;
    Exit;
  end;
  for i := 0 to o^.text.x - 1 do
    for j := 0 to o^.text.y - 1 do
    begin
      BlockRead(fp, col, SizeOf(Byte));
      Mem[Seg(c^) : Ofs(c^) + o^.text.y * i + j] := col;
    end;
  Close(fp);
  gotoxy(1, 3);
  print('Streckung: ', 215);
  getstr(name);
  Val(name, o^.text.big, Error);
  if o^.typ = SPHERE then
  begin
    gotoxy(13, 3);
    print('                     ', 215);
    gotoxy(1, 3);
    print('Um die Kugel Vertikal Horizontal (V/H): ', 215);
    getstr(name);
    if (name = 'V') OR (name = 'v') then
      o^.text.typ := 1
    else
      o^.text.typ := 2;
  end;
  loadtexture := 1;
end;

{
  clssc: lîscht gesamten Grafikbildschirm
}

procedure clssc;
var
  x, y : Word;
begin
  for x := 1 to 80 do
    for y := 1 to 14 do
    begin
      gotoxy(x, y);
      print(' ', 215);
    end;
end;

{
  getcol: holt Farbwert von Benutzer
}

procedure getcol(c : PColor);
var
  str   : str80;
  help  : Real;
  Error : Integer;
begin
  gotoxy(13, 3);
  print('                         ', 215);
  gotoxy(1, 3);
  print('Rotanteil (0.0-1.0): ', 215);
  getstr(str);
  Val(str, Help, Error);
  if (help >= 0.0) AND (help <= 1.0) then
    c^.r := help;
  gotoxy(13, 3);
  print('                         ', 215);
  gotoxy(1, 3);
  print('Gruenanteil (0.0-1.0): ', 215);
  getstr(str);
  Val(str, Help, Error);
  if (help >= 0.0) AND (help <= 1.0) then
    c^.g := help;
  gotoxy(13, 3);
  print('                         ', 215);
  gotoxy(1, 3);
  print('Blauanteil (0.0-1.0): ', 215);
  getstr(str);
  Val(str, Help, Error);
  if (help >= 0.0) AND (help <= 1.0) then
    c^.b := help;
end;

{
  edobj(w) : Benutzereditor fÅr Objekte
}

procedure edobj(w : PWorld);
var
  str   : str80;
  nr, i : Integer;
  o     : PObject;
  help  : Real;
  Error : Integer;
begin
  clssc;
  gotoxy(1, 1);
  print('Nr des Objekts: ', 215);
  getstr(str);
  Val(str, nr, Error);
  if (nr > countobj) OR (nr <= 0) then
    Exit;
  o := w^.objects;
  for i := 1 to nr - 1 do
    o := o^.next;
  if o^.typ = SPHERE then
  begin
    print(' Kugel mit Radius ', 215);
    printnum(Round(o^.sphere.radius));
  end
  else
  begin
    print(' Flaeche mit ', 215);
    printnum(Round(o^.polygon.num_vec));
    print(' Pktn', 215);
  end;
  gotoxy(1, 2);
  print('Texture oder einfarbig', 215);
  getstr(str);
  if (str = 't') OR (str = 'T') then
    loadtexture(o)
  else
  begin
    o^.text.x := 0;
    o^.text.y := 0;
    o^.text.map := NIL;
    getcol(@o^.color);
  end;
  gotoxy(1, 4);
  print('Materialdefinition ', 215);
  gotoxy(1, 5);
  print('Undurchsichtigkeit (0.0-1.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 1.0) AND (Length(str) > 0) then
    o^.material := help;
  gotoxy(1, 6);
  print('Spiegelung (0.0-1.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 1.0) AND (Length(str) > 0) then
    o^.mirror := help;
  gotoxy(1, 7);
  print('Transparenz (0.0-1.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 1.0) AND (Length(str) > 0) then
    o^.trans := help;
  gotoxy(1, 8);
  print('Matte Reflexion (0.0-1.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 1.0) AND (Length(str) > 0) then
    o^.dif_const := help;
  gotoxy(1, 9);
  print('Spiegelnde Reflexion (0.0-1.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 1.0) AND (Length(str) > 0) then
    o^.spec_const := help;
  gotoxy(1, 10);
  print('Konzentr.spie.Refl. (0.0-100.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (help <= 100.0) AND (Length(str) > 0) then
    o^.high_const := help;
  gotoxy(1, 11);
  print('Velozitaet (>0.0): ', 215);
  getstr(str);
  Val(str, help, Error);
  if help >= 0.0 then
    o^.N := help
  else
    o^.N := 1.0;
  clssc;
end;

{
  edlamp(w): Benutzereditor fÅr Lampen
}

procedure edlamp(w : PWorld);
var
  str   : str80;
  nr, i : Integer;
  l     : PLamp;
  help  : Real;
  Error : Integer;
begin
  gotoxy(1, 1);
  print('Nr der Lampe: ', 215);
  getstr(str);
  Val(str, nr, Error);
  if (nr >= countlamp) OR (nr <= 0) then
    Exit;
  for i := 1 to nr - 1 do
    l := l^.next;
  gotoxy(1, 2);
  print('Intensitaet wie weit >0.0: ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help >= 0.0) AND (Length(str) > 0) then
    l^.intens := help;
  getcol(@l^.color);
  clssc;
end;

{
  edobs(w) : Benutzereditor fÅr Observer
}

const
  auf : Integer = 0;

procedure edobs(w : PWorld);
var
  str   : str80;
  nr, i : Word;
  o     : PObserver;
  help  : Integer;
  h     : Real;
  Error : Integer;
begin
  o := @w^.observer;
  clssc;
  gotoxy(1, 1);
  print('Aufloesung (320/640/800/1024): ', 215);
  getstr(str);
  gotoxy(1, 1);
  print('                               ', 215);
  Val(str, help, Error);
  if (help >= 320) AND (Length(str) > 0) then
    auf := 1;
  if (help >= 640) AND (Length(str) > 0) then
    auf := 2;
  if (help >= 800) AND (Length(str) > 0) then
    auf := 3;
  gotoxy(1, 1);
  print('Bildbreite in Pixel: ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help > 0) AND (Length(str) > 0) then
    o^.p_width := help
  else
    o^.p_width := 60;
  gotoxy(1, 2);
  print('Bildhoehe in Pixel: ', 215);
  getstr(str);
  Val(str, help, Error);
  if (help > 0) AND (Length(str) > 0) then
    o^.p_height := help
  else
    o^.p_height := 40;
  o^.dx := Round(o^.p_width * 1.14);
  o^.dy := Round(o^.p_width);
  gotoxy(1, 2);
  print('Hintergrundfarbe               ', 215);
  getcol(@background);
  background.r := background.r / 2;
  background.g := background.g / 2;
  background.b := background.b / 2;
  gotoxy(1, 2);
  print('Grundhelligkeit                ', 215);
  getcol(@ambient);
  gotoxy(1, 3);
  print('Staerke der Grundhelligkeit (0.0-1.0):', 215);
  getstr(str);
  Val(str, h, Error);
  if (h >= 0.0) AND (h <= 1.0) AND (Length(str) > 0) then
    amb := h
  else
    amb := 0.0;
  gotoxy(1, 4);
  print('Berechnungstiefe >=0: ', 215);
  getstr(str);

  Val(str, help, Error);
  if (help >= 0.0) AND (Length(str) > 0) then
    maxdepth := help
  else
    maxdepth := 6;
  clssc;
end;

{
  save(x, y, w): sichert die Daten der Welt
}

function save(x, y : Integer; w : PWorld) :Integer;
var
  name : str80;
begin
  gotoxy(x, y);
  print('Name:                                 ', 215);
  gotoxy(x + 5, y);
  getstr(name);
  saveworld(w, name);
end;

var
  x, y, ready, help : Word;
  vidmod            : Word;
  name, str         : str80;
  sch               : PSchalter;
  Error             : Integer;
begin
  vidmod := setmod(GR320);
  sch := @ld1;
  ready := 0;

  w1.lamp     := NIL;
  w1.objects  := NIL;
  w1.observer := NIL;

  delay(0);
  init_pal;
  showsch(sch);
  mouse_def(Pointer, 17, 6);
  mouse_show;
  mouse_key(0);

  gotoxy(3, 5);
  print('   Welcome to the world of', 135);
  gotoxy(3, 7);
  print('          RAY TRACING', 130);
  gotoxy(3, 9);
  print('   (c) 1992 Widuch GmbH & Co. KG', 135);

  w1.lamp     := NIL;
  w1.objects  := NIL;
  w1.observer := NIL;

  repeat
    while mouse_press = 0 do
    begin
      mouse_pos(x, y);
      x := x SHR 1;
    end;
    mouse_hide;
    case testsch(x, y, @ld1, @sch) of
      10 : ready := 1;
       1 : begin
             cad;
             w1.lamp := firstlamp;
             w1.objects := first^.first;
             if w1.observer = NIL then
             begin
               GetMem(w1.observer, SizeOf(TObserver));
               FillChar(w1.observer^, SizeOf(TObserver), 0);
             end;
             mouse_area(0, 0, 640, 200);
             textattr := 0;
             ClrScr;
             showsch(@ld1);
             mouse_def(Pointer, 17, 6);
             mouse_show;
             mouse_key(0);
             countlamp := countl(firstlamp);
             countobj := counto(first^.first);
             gotoxy(1, 16);
             print('Objekte: ', 215);
             printnum(countobj);
             print(' - Lampen: ', 215);
             printnum(countlamp);
           end;
       2 : begin
             gotoxy(1, 16);
             print('Name:                                  ', 215);
             gotoxy(6, 16);
             getstr(str);
             gotoxy(1, 16);
             print('                         ', 215);
             gotoxy(1, 1);
             print('Aufloesung (320/640/800/1024): ', 215);
             getstr(str);
             gotoxy(1, 1);
             print('                               ', 215);
             Val(str, help, Error);
             auf := 0;
             if (help >= 320) AND (Length(str) > 0) then
               auf := 1;
             if (help >= 640) AND (Length(str) > 0) then
               auf := 2;
             if (help >= 800) AND (Length(str) > 0) then
               auf := 3;

             textattr := 0;
             clrscr;

             case auf of
               1 : setmod($2F);
               2 : setmod($30);
               3 : setmod($38);
             end;
             if auf <> 0 then
               init_pal;
             loadpic(name);
             mouse_show;
             while (mouse_press = 0) AND NOT KeyPressed do;
             if auf <> 0 then
             begin
               setmod(GR320);
               init_pal;
             end;
             if KeyPressed then ReadKey;
             textattr := 0;
             clrscr;
             showsch(@ld1);
             mouse_def(Pointer, 17, 6);
             mouse_show;
             mouse_key(0);
             gotoxy(1, 16);
             print('Objekte: ', 215);
             printnum(countobj);
             print(' - Lampen: ', 215);
             printnum(countlamp);
           end;
       3 : begin
             maketexture;
             textattr := 0;
             clrscr;
             showsch(@ld1);
             mouse_def(Pointer, 17, 6);
             mouse_show;
             mouse_key(0);
             gotoxy(1, 16);
             print('Objekte: ', 215);
             printnum(countobj);
             print(' - Lampen: ', 215);
             printnum(countlamp);
           end;
       4 : edobj(@w1);                 { Edit Object }
       5 : edlamp(@w1);                { Edit Lamp }
       6 : edobs(@w1);                 { Edit Observer }
       7 : save(1, 16, @w1);           { Save World }
       8 : begin                       { Load World }
             gotoxy(1, 16);
             print('                                                  ', 215);
             loadall(1, 16);
             w1.lamp := firstlamp;
             w1.objects := first^.first;
             countlamp := countl(firstlamp);
             countobj := counto(first^.first);
             gotoxy(1, 16);
             print('Objekte: ', 215);
             printnum(countobj);
             print(' - Lampen: ', 215);
             printnum(countlamp);
           end;
       9 : begin                       { Calc World }
             textattr := 0;
             clrscr;
             gotoxy(1, 1);
             print('Zum Speichern des Bildes rechte ', 215);
             gotoxy(1, 2);
             print('Maustaste druecken; sonst linke', 215);
             gotoxy(1, 3);
             print('Name:           ', 215);
             gotoxy(6, 3);
             getstr(name);
             gotoxy(1, 3);
             print('                ', 215);
             textattr := 0;
             clrscr;
             case auf of
               1 : setmod($2F);
               2 : setmod($30);
               3 : setmod($38);
             end;
             if auf <> 0 then
               init_pal;
             show_world(@w1);
             mouse_show;
             while (mouse_press = 0) AND (NOT KeyPressed) do;
             if KeyPressed then ReadKey;
             mouse_hide;
             while mouse_press <> 0 do;
             if mouse_key(1) <> 0 then
               savepic(0, 0, w1.observer^.p_width,
                             w1.observer^.p_height,
                             name);
             if auf <> 0 then
             begin
               setmod(GR320);
               init_pal;
             end;
             textattr := 0;
             clrscr;
             showsch(@ld1);
             mouse_def(Pointer, 17, 6);
             mouse_show;
             mouse_key(0);
             gotoxy(1, 16);
             print('Objekte: ', 215);
             printnum(countobj);
             print(' - Lampen: ', 215);
             printnum(countlamp);
           end;
    else
    begin
      Sound(440);
      Delay(2);
      NoSound;
    end;
    end;
    drawtangle(sch^.left, sch^.top, sch^.right, sch^.bottom, sch^.framecol);
    mouse_show;
  until ready <> 0;
  setmod(vidmod);
end.