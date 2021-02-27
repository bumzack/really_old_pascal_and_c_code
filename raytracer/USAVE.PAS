unit usave;

interface

uses vid, ugraph;

function savepic(x1, y1, x2, y2 : Word; name : String) : Integer;
function loadpic(name : String) : Integer;

implementation

{
  speichert Bildausschnitt unter name ab
  width, height: Bildbreite, Bildh”he
  1 wenn erfolgreich
}

function savepic(x1, y1, x2, y2 : Word; name : String) : Integer;
var
  fp : File;
  c  : Byte;
  i, j : Integer;
  width, height : Word;
begin
  width := x2 - x1 + 1;
  height := y2 - y1 + 1;

  Assign(fp, name);
  {$I-}
  Rewrite(fp);
  {$I+}
  if IOResult <> 0 then
  begin
    savepic := 0;
    Exit;
  end;
  BlockWrite(fp, width, SizeOf(width));
  BlockWrite(fp, height, SizeOf(height));
  for i := x1 to x2 do
    for j := y1 to y2 do
    begin
      c := get_pixel(i, j);
      BlockWrite(fp, c, SizeOf(c));
    end;
  Close(fp);
  savepic := 1;
end;

{
  l„dt Bild mit name ein
  liefert 1 falls erfolgreich
}

function loadpic(name : String) : Integer;
var
  fp : File;
  c  : Byte;
  i, j : Integer;
  width, height : Word;
begin
  Assign(fp, name);
  {$I-}
  Reset(fp);
  {$I+}
  if IOResult <> 0 then
  begin
    loadpic := 0;
    Exit;
  end;
  BlockRead(fp, width, SizeOf(width));
  BlockRead(fp, height, SizeOf(height));
  for i := 1 to width - 1 do
    for j := 1 to height - 1do
    begin
      BlockRead(fp, c, SizeOf(c));
      put_pixel(i, j, c);
    end;
  Close(fp);
  loadpic := 1;
end;
end.