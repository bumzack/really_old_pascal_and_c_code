{$X+}

unit Texture;

interface

uses Crt, vid, maus, ugraph, schalter, usave;

const
  Scha11 : TSchalter = (next : NIL; left : 242; top : 142; right: 300;
                        bottom : 154; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'TEXT');
  Scha10 : TSchalter = (next : @Scha11; left : 170; top : 142; right: 240;
                        bottom : 154; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'CLEAR');
  Scha9  : TSchalter = (next : @Scha10; left : 170; top : 157; right: 240;
                        bottom : 169; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'EXIT');
  Scha8  : TSchalter = (next : @Scha9; left : 138; top : 142; right: 147;
                        bottom : 186; framecol : 56; col : 0; ilucol : 215;
                        backcol : 0; msg : '');
{ Zeichenfeld }
  Scha1  : TSchalter = (next : @Scha8; left : 0; top : 0; right: 319;
                        bottom : 140; framecol : 0; col : 0; ilucol : 0;
                        backcol : 0; msg : '');
  Scha2  : TSchalter = (next : @Scha1; left : 0; top : 142; right: 64;
                        bottom : 154; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'DRAW');
  Scha3  : TSchalter = (next : @Scha2; left : 66; top : 142; right: 128;
                        bottom : 154; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'LINE');
  Scha4  : TSchalter = (next : @Scha3; left : 0; top : 157; right: 64;
                        bottom : 169; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'LOAD');
  Scha5  : TSchalter = (next : @Scha4; left : 66; top : 157; right: 128;
                        bottom : 169; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'SAVE');
  Scha6  : TSchalter = (next : @Scha5; left : 0; top : 172; right: 64;
                        bottom : 184; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'FILL');
  Scha7  : TSchalter = (next : @Scha6; left : 66; top : 172; right: 128;
                        bottom : 184; framecol : 56; col : 0; ilucol : 215;
                        backcol : 2; msg : 'BOX');

const First : PSchalter = @Scha7;

procedure cls;
procedure maketexture;

implementation

{
  lîscht den Bildschirm des Malprogramms
}

procedure cls;
var
  x, y : Word;
begin
  for x := 0 to 319 do
    for y := 0 to 140 do
      put_pixel(x, y, 0);
end;

{
  Editor fÅr Muster auf dreidimensionalen Kîrpern
}

procedure maketexture;
var
  r, g, b : Word;
  x, y, i : Word;
  help    : String[2];
  xold, yold, farbe : Word;
  ready, drawnr     : Word;
  sch, dummy        : PSchalter;
  name              : str80;
begin
  farbe := 0;
  ready := 0;
  drawnr := 1;
  sch := @Scha2;
  TextAttr := 0;
  ClrScr;

  { Farbpalette zeigen }
  for b := 0 to 5 do
    for g := 0 to 5 do
      for r := 0 to 5 do
        put_pixel(g + 140, r + 7 * b + 144, r + g * 6 + b * 36);
  showsch(First);
  mouse_hide;
  drawtangle(scha2.left, scha2.top, scha2.left, scha2.bottom, scha2.ilucol);
  drawtangle(151, 142, 160, 152, 215);
  fill(151, 143, farbe);
  gotoxy(32, 21);
  print('by M.O.', 215);
  mouse_show;

  mouse_def(Pointer, 17, 6);
  mouse_show;
  mouse_key(0);

  repeat
    while (mouse_press = 0) do
    begin
      mouse_pos(x, y);
      x := x SHR 1;
      gotoxy(21, 24);
      print('POS: ', 215);
      printnum(x);
      print(' ', 215);
      printnum(y);
      print('              ', 215);
    end;

    testsch(x, y, First, dummy);

    if (dummy <> @scha1) AND (dummy <> @scha8) then
    begin
      mouse_hide;
      drawtangle(sch^.left, sch^.top, sch^.right, sch^.bottom, sch^.framecol);
      mouse_show;
    end;
    mouse_hide;
    dummy := sch;
    case testsch(x, y, First, sch) of
      1: drawnr := 4;
      2: drawnr := 3;
      4: begin
           gotoxy(21, 23);
           print('Dateiname: ', 215);
           getstr(name);
           gotoxy(21, 23);
           print('                      ', 215);
           cls;
           loadpic(name);
         end;
      3: begin
           gotoxy(21, 23);
           print('Dateiname: ', 215);
           getstr(name);
           gotoxy(21, 23);
           print('links oben mit Maus', 215);
           while (mouse_press = 0) do;
           mouse_key(0);
           mouse_show;
           while (mouse_press <> 0) do;
           gotoxy(21, 23);
           print('Maus rechts unten', 215);
           mouse_pos(x, y);
           x := x SHR 1;
           xold := x; yold := y;
           while (mouse_press = 0) do;
           gotoxy(21, 23);
           print('                    ', 215);
           mouse_hide;
           mouse_pos(x, y);
           x := x SHR 1;
           if x > xold then
           begin
             i := x;
             x := xold;
             xold := i;
           end;
           if y > yold then
           begin
             i := y;
             y := yold;
             yold := i;
           end;
           savepic(x, y, xold, yold, name);
           drawtangle(x, y, xold, yold, 215);
         end;
      5: drawnr := 2;
      6: drawnr := 1;
      7: begin
           mouse_pos(x, y);
           x := x SHR 1;
           xold := x;
           yold := y;
           case drawnr of
             1: begin
                  if mouse_key(0) = 0 then
                  { Noch nicht losgelassen }
                  begin
                    while (mouse_press = 0) do
                    begin
                      xold := x;
                      yold := y;
                      mouse_pos(x, y);
                      x := x SHR 1;
                      if (x >= sch^.left) AND (x <= sch^.right) AND
                         (y >= sch^.top) AND (y <= sch^.bottom) then
                        drawline(xold, yold, x, y, farbe);
                    end;
                  end;
                end;
             2: begin
                  mouse_show;
                  while (mouse_press = 0) do;
                  mouse_hide;
                  mouse_pos(x, y);
                  x := x SHR 1;
                  drawline(x, y, xold, yold, farbe);
                end;
             3: fill(x, y, farbe);
             4: begin
                  mouse_show;
                  while mouse_press = 0 do;
                  mouse_hide;
                  mouse_pos(x, y);
                  x := x SHR 1;
                  drawtangle(x, y, xold, yold, farbe);
                end;
             5: begin
                  help[2] := #0;
                  repeat
                    while NOT KeyPressed do
                    begin
                      if mouse_press <> 0 then
                      begin
                        mouse_pos(x, y);
                        x := x SHR 1;
                        gotoxy(x DIV 8 + 1, y DIV 8 + 1);
                      end;
                    end;
                    help[1] := ReadKey;
                    if help[1] <> #13 then
                    begin
                      mouse_hide;
                      print(help, farbe);
                    end;
                  until help[1] = #13;
                  sch := dummy;
                end;
              end;
           end;
      8: begin
           if mouse_key(0) = 0 then
           { Noch nicht losgelassen }
           begin
             while (mouse_press = 0) do
             begin
               farbe := get_pixel(x, y);
               if get_pixel(150, 143) = farbe then
               begin
                 if Farbe >= 215 then
                   Farbe := 215
                 else
                   Farbe := 214;
                 drawtangle(150, 142, 160, 152, Farbe);
                 fill(151, 143, farbe);
               end;
             end;
           end;
           sch := dummy;
         end;
      9: ready := 1;
     10: cls;
     11: drawnr := 5;
    else
    begin
      Sound(440);
      Delay(2);
      NoSound;
    end;
    end;  { end Case }
    mouse_show;
  until (ready <> 0);
  mouse_hide;
end;
end.