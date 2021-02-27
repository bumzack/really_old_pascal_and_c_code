unit UGraph;

interface

uses vid, maus;

procedure drawline(x0, y0, x1, y1, c : Word);
procedure drawtangle(left, top, right, bottom, c : Word);
procedure fill(x, y, co : Word);

implementation

{ zeichnet Linie }

procedure drawline(x0, y0, x1, y1, c : Word);
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
    put_pixel(x0, y0, c);
  end;
end;

{ Zeichnet Rechteck in Farbe c }

procedure drawtangle(left, top, right, bottom, c : Word);
var
  i : Word;
begin
  if left > right then
  begin
    i := left;
    left := right;
    right := i;
  end;
  if top > bottom then
  begin
    i := top;
    top := bottom;
    bottom := i;
  end;
  for i := left to right do
  begin
    put_pixel(i, top, c);
    put_pixel(i, bottom, c);
  end;
  for i := top to bottom do
  begin
    put_pixel(left, i, c);
    put_pixel(right, i, c);
  end;
end;

{ fÅllt Rechteck mit Farbe auf }
procedure fillhelp(x, y, co, c, dx, dy : Integer);
var
  h, b : Word;
begin
  while get_pixel(x, y) = c do
  begin
    h := x;
    b := y;
    while get_pixel(h, b) = c do
    begin
      put_pixel(h, b, co);
      Inc(h);
    end;
    h := x;
    b := y - 1;
    while get_pixel(h, b) = c do
    begin
      put_pixel(h, b, co);
      Dec(b);
    end;
    h := x - 1;
    b := y;
    while get_pixel(h, b) = c do
    begin
      put_pixel(h, b, co);
      Dec(h);
    end;
    h := x;
    b := y + 1;
    while get_pixel(h, b) = c do
    begin
      put_pixel(h, b, co);
      Inc(b);
    end;
    Inc(x, dx);
    Inc(y, dy);
  end;
end;

procedure fill(x, y, co : Word);
var
  c : Word;
begin
  c := get_pixel(x, y);
  if c = co then
    Exit;
  if (x < 0) OR
     (y < 0) OR
     (x > 319) OR
     (y > 199) then
    Exit;
  fillhelp(x, y, co, c, 1, 1);
  fillhelp(x + 1, y - 1, co, c, 1, -1);
  fillhelp(x - 1, y - 1, co, c, -1, -1);
  fillhelp(x - 1, y + 1, co, c, -1, 1);
end;
end.