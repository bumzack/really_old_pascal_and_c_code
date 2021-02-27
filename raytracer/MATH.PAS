unit math;

interface

uses Defs;

function dot(var a, b : TVector) : Real;
function distance(var p1, p2 : TVector) : Real;
procedure vecsub(var r, a, b : TVector);
procedure vecadd(var r, a, b : TVector);
procedure vecmul(var r : TVector; t : Real; var a : TVector);
procedure vecprod(var a, b, c : TVector);
procedure norm(var dest, src : TVector);
procedure veccpy(var dest, src : TVector);

implementation

{
  rechnet Skalarprodukt zweier Vektoren aus
}

function dot(var a, b : TVector) : Real;
begin
  dot := (a.x * b.x + a.y * b.y + a.z * b.z);
end;

{
  rechnet Betrag oder Abstand zweier Vektoren aus
}

function distance(var p1, p2 : TVector) : Real;
var
  t : TVector;
begin
  vecsub(t, p1, p2);
  distance := Sqrt(dot(t, t));
end;

{
  Vektor Subtraktion r = a - b
}

procedure vecsub(var r, a, b : TVector);
begin
  r.x := a.x - b.x;
  r.y := a.y - b.y;
  r.z := a.z - b.z;
end;

{
  Vektor Addition r = a + b
}

procedure vecadd(var r, a, b : TVector);
begin
  r.x := a.x + b.x;
  r.y := a.y + b.y;
  r.z := a.z + b.z;
end;

{
  Multipliziert Vektor mit konstanter r = t * a
}
procedure vecmul(var r : TVector; t : Real; var a : TVector);
begin
  r.x := t * a.x;
  r.y := t * a.y;
  r.z := t * a.z;
end;

{
  bildet das Vektorprodukt c = a * b
}

procedure vecprod(var a, b, c : TVector);
begin
  c.x := a.y * b.z - a.z * b.y;
  c.y := -a.x * b.z + a.z * b.x;
  c.z := a.x * b.y - a.y * b.x;
end;

{
  kopiert Vektor src in dest um
}

procedure veccpy(var dest, src : TVector);
begin
  dest.x := src.x;
  dest.y := src.y;
  dest.z := src.z;
end;

{
  normiert einen Vektor
}

procedure norm(var dest, src : TVector);
var
  d : Real;
begin
  d := 1 / Sqrt(dot(src, src));
  vecmul(dest, d,src);
end;
end.