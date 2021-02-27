unit Maus;

interface

uses Dos;

const
  MouseInt = $33;

type
  ByteArray = array[0..63] of Byte;

const
  Pointer : ByteArray =
              (127, 255, 127, 255, 127, 255, 127, 255,
               127, 255, 255, 255, 192, 129, 255, 255,
               127, 255, 127, 255, 127, 255, 127, 255,
               127, 255, 255, 255, 255, 255, 255, 255,
               128, 0, 128, 0, 128, 0, 128, 0,
               128, 0, 0, 0, 63, 126, 0, 0,
               128, 0, 128, 0, 128, 0, 128, 0,
               128, 0, 0, 0, 0, 0, 0, 0);

function mouse_check : word;
procedure mouse_show;
procedure mouse_hide;
procedure mouse_move(x, y : word);
procedure mouse_def(bitfield : ByteArray; x, y : Word);
procedure mouse_pos(var x, y : Word);
function mouse_press : Word;
function mouse_key(nr : Word) : Word;
procedure mouse_area(left, top, right, bottom : Word);

implementation

{
  öberprÅft ob ein Maustreiber instaliert ist oder nicht
  0 : kein Maustreiber
  <> 0 : Anzahl der Knîpfe
}

function mouse_check : word;
var
  Regs : Registers;
begin
  Regs.ax := $00;
  Intr(MouseInt, Regs);
  if Regs.ax <> $FFFF then
    mouse_check := 0
  else
    mouse_check := Regs.bx;
end;

{
  macht Mauszeiger sichtbar
}

procedure mouse_show;
var
  Regs : Registers;
begin
  Regs.ax := $01;
  Intr(MouseInt, Regs);
end;

{
  macht Mauszeiger unsichtbar
}

procedure mouse_hide;
var
  Regs : Registers;
begin
  Regs.ax := $02;
  Intr(MouseInt, Regs);
end;

{
  definiert das Aussehen des Mauszeigers
}

procedure mouse_def(bitfield : ByteArray; x, y : Word);
var
  Regs : Registers;
begin
  Regs.ax := $09;
  Regs.bx := x;
  Regs.cx := y;
  Regs.es := Seg(bitfield);
  Regs.dx := Ofs(bitfield);
  Intr(MouseInt, Regs);
end;

{
  liefert die Mausposition
}

procedure mouse_pos(var x, y : Word);
var
  Regs : Registers;
begin
  Regs.ax := $03;
  Intr(MouseInt, Regs);
  x := Regs.cx;
  y := Regs.dx;
end;

{
  liefert den Maustastenstatus:
  bit 0 = linker, bit 1 = rechter, bit 2 = mittlerer
}

function mouse_press : Word;
var
  Regs : Registers;
begin
  Regs.ax := $03;
  Intr(MouseInt, Regs);
  mouse_press := Regs.bx;
end;

{
  liefert Anzahl wie oft eine Maustaste
  gedrÅckt wurde
  0 = linke Maustaste
  1 = rechte Maustaste
  2 = mittlere Maustaste
}

function mouse_key(nr : Word) : Word;
var
  Regs : Registers;
begin
  Regs.ax := $06;
  Regs.bx := nr;
  Intr(MouseInt, Regs);
  mouse_key := Regs.bx;
end;

{
  bewegt den Mauscursor an Position x, y
}

procedure mouse_move(x, y : word);
var
  Regs : Registers;
begin
  Regs.ax := $04;
  Regs.cx := x;
  Regs.dx := y;
  Intr(MouseInt, Regs);
end;

{
  legt Area fest, in der der Mauscursor bewegt werden darf
}

procedure mouse_area(left, top, right, bottom : Word);
var
  Regs : Registers;
begin
  Regs.ax := $07;
  Regs.cx := left;
  Regs.dx := right;
  Intr(MouseInt, Regs);
  Regs.ax := $08;
  Regs.cx := top;
  Regs.dx := bottom;
  Intr(MouseInt, Regs);
end;
end.