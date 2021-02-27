unit vid;

interface

uses Dos;

const
  GR320 = $13;

function setmod(mode : Word) : Word;
procedure put_pixel(x, y, c : Word);
function get_pixel(x, y : Word) : Word;
procedure init_pal;

implementation

{ setzt Grafikmodus }

function setmod(mode : Word) : Word;
var
  Regs : Registers;
  old  : Word;
begin
  Regs.ax := $0F00;
  Intr($10, Regs);
  old := Regs.ax AND $F;
  Regs.ax := mode;
  Intr($10, Regs);
  setmod := old;
end;

{ putpixel: setzt Farbwert an einen Grafikpunkt }

procedure put_pixel(x, y, c : Word);
var
  Regs : Registers;
begin
  Regs.ah := $0C;
  Regs.al := c;
  if (x < 640) AND (y < 640) then
  begin
    Regs.cx := x;
    Regs.dx := y;
    Intr($10, Regs);
  end;
end;

function get_pixel(x, y : Word) : Word;
var
  Regs : Registers;
begin
  Regs.ah := $0D;
  Regs.cx := x;
  Regs.dx := y;
  Intr($10, Regs);
  get_pixel := Regs.al;
end;

procedure init_pal;
var
  r, g, b : Integer;
  Regs : Registers;
begin
  for b := 0 to 5 do
    for g := 0 to 5 do
      for r := 0 to 5 do
      begin
        Regs.ax := $1010;
        Regs.bx := r + g * 6 + b * 36;
        Regs.cx := (Round(Round(g) * 10.5) SHL 8) OR Round(Round(b) * 10.5);
        Regs.dx := Round(Round(r) * 10.5) SHL 8;
        Intr($10, Regs);
      end;
end;
end.