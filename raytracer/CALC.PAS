{$X+}

unit calc;

interface

uses Crt, defs, vid, math;

const
  background : TColor = (r : 0.0; g : 0.0; b : 0.5);
  amb        : Real   = 0.1;
  ambient    : TColor = (r : 0.01; g : 0.01; b : 0.01);
  black      : TColor = (r : 1.0; g : 1.0; b : 1.0);
  maxdepth   : Word   = 6;

var
  w1 : TWorld;

function hit_object(var point, dir : TVector; var obj : TObject;
                    var int_point, norma : TVector) : Word;
function line_trace(var point, dir : TVector; var world : TWorld;
                    var int_point, normal : TVector) : PObject;
procedure colcpy(var dest, src : TColor);
procedure add_color(var dest, col1, col2 : TColor);
procedure intens_col(var dest : TColor; k : Real; var col1 : TColor);
procedure Combine(var colour, local_col : TColor; local_weight : Real;
                  var ref_col : TColor; ref_weight : Real;
                  var trans_col : TColor; trans_weight : Real);
procedure trans_vector(var o : TObject;
                       var normal, dir, trans_dir : TVector);
procedure ref_vector(var dir, normal, ref_dir : TVector);
procedure local_color(var obj : PObject; var dir, normal, int_point : TVector;
                      var world : TWorld; var local_col : TColor);
procedure surfaceCol(var colour : TColor; var objects : TObject;
                      var intpoint : TVector);
procedure bckgrnd(var colour, back : TColor;
                  var dir : TVector;
                      am  : Real);
procedure raytrace(var point, dir : TVector;
                       depth : Word;
                   var world : TWorld;
                   var colour : TColor);
procedure to_LUT(var col : TColor);
function interpret_col(var col : TColor) : Word;
function showpoint(x, y : Word;
                   var w : TWorld) : Word;
procedure show_world(w : PWorld);

implementation

FUNCTION Acos(X : REAL) : REAL;
var Error : Integer;
    C     : Real;
  BEGIN
    IF Abs(X) > 1 THEN
      Error := 2
    ELSE IF Abs(X) = 1 THEN
      C := (1 - X) * Pi / 2
    ELSE
      C := -ArcTan(X / Sqrt(1 - X * X)) + Pi / 2;
    Acos := C / (Pi / 180);
  END;

FUNCTION Asin(X : REAL) : REAL;
  BEGIN
    Asin := Pi / 2 / (Pi / 180) - Acos(X);
  END;

function pow(x, y : Real) : Real;
var Error : Integer;
begin
    IF X = 0 THEN BEGIN
      IF Y <= 0 THEN
        Error := 2
      ELSE pow := 0;
    END ELSE IF X > 0 THEN
      pow := Exp(Y * Ln(X))
    ELSE BEGIN
      X := Abs(X);
      IF Y = Trunc(Y) THEN
        IF Odd(Trunc(Y)) THEN
          pow := -pow(X, Y)
        ELSE
          pow := pow(X, Y)
      ELSE BEGIN
        IF (Abs(Round(1/Y)-1/Y) < 1E-8) AND
           (Odd(Round(1/Y))) THEN
          pow := -pow(X, Y)
        ELSE
          Error := 2;
      END;
    END;
  END;

FUNCTION Log(X : REAL) : REAL;
  BEGIN
    IF X > 0 THEN
      Log := Ln(X)/Ln(10)
  END;
{
  ÅberprÅft ob eine Gerade ein bestimmtes Objekt trifft
}

function hit_object(var point, dir : TVector; var obj : TObject;
                    var int_point, norma : TVector) : Word;
var
  ppolygon : TPolygon;
  ssphere  : TSphere;
  normal, a, b : TVector;
  t, help      : Real;
  i            : Integer;
  l, m, n, innen, orient : Real;
begin
  ppolygon := obj.polygon;
  ssphere := obj.sphere;
  case obj.typ of
    POLYGON: begin
               { Normale auf Ebene rechnen }
               vecsub(a, ppolygon.vector[1], ppolygon.vector[0]);
               vecsub(b, ppolygon.vector[2], ppolygon.vector[0]);
               vecprod(norma, a, b);
               { Normieren und Orientierung }
               help := -(dot(norma, point) - dot(ppolygon.vector[0], norma));
               if help > 0 then
                 vecmul(norma, -1 / Sqrt(dot(norma, norma)), norma)
               else
                 vecmul(norma, 1 / Sqrt(dot(norma, norma)), norma);
               { Gerade und Ebene parallel ? }

               t := dot(norma, dir);

               if t = 0.0 then         { no way; parallel }
               begin
                 hit_object := 0;
                 Exit;
               end;

               t := -(dot(norma, point) - dot(ppolygon.vector[0], norma)) / t;

               if t <= 0.0 then         { trifft, aber falsch }
               begin
                 hit_object := 0;
                 Exit;
               end;

               vecmul(int_point, t, dir);
               vecadd(int_point, point, int_point);

               { Liegt Schnittpunkt innerhalb von
                 Polygon ? Die Summe aller Winkel
                 zwischen Schnittpunkt und
                 Eckpunkten muss 360 Grad ergeben
                 t = 2 * PI sein
               }
               t := 0;
               for i := 0 to ppolygon.num_vec - 1 do
               begin
                 vecsub(a, ppolygon.vector[i], int_point);
                 vecsub(b, ppolygon.vector[(i + 1) MOD ppolygon.num_vec], int_point);
                 norm(a, a);
                 norm(b, b);
                 innen := dot(a, b);
                 if (innen >= -1) AND (innen <= 1) then
                   t := t + acos(innen)
                 else
                 begin
                   hit_object := 0;
                   Exit;
                 end;
               end;

               { Nobody calculates perfect }
               if (t > 6.2830) AND (t < 6.2833) then
               begin
                 hit_object := 1;
                 Exit;
               end
               else
               begin
                 hit_object := 0;
                 Exit;
               end;
             end;
    SPHERE:  begin
               l := dot(dir, dir);
               m := 2 * dir.x * (point.x - ssphere.vector.x) +
                    2 * dir.y * (point.y - ssphere.vector.y) +
                    2 * dir.z * (point.z - ssphere.vector.z);

               n := dot(ssphere.vector, ssphere.vector) +
                    dot(point, point) - 2 * dot(ssphere.vector, point) -
                    ssphere.radius * ssphere.radius;
               t := m * m - 4 * l * n;

               if t < 0 then
               begin
                 hit_object := 0;  { geht vorbei }
                 Exit;
               end;

               if t = 0 then       { tangiert }
               begin
                 t := -m / (2 * l);
                 if t <= 0 then
                 begin
                   hit_object := 0;
                   Exit;
                 end;

                 vecmul(int_point, t, dir);
                 vecadd(int_point, point, int_point);
                 vecsub(norma, int_point, ssphere.vector);
                 { raus aus der Kugel }
                 vecmul(int_point, 1.001, norma);
                 vecadd(int_point, int_point, ssphere.vector);
                 norm(norma, norma);

                 hit_object := 1;
                 Exit;
               end
               else
               begin               { 2 Schnittpunkte }
                 orient := 1.00;
                 help := (-m + Sqrt(t)) / (2 * l);
                 t := (-m - Sqrt(t)) / (2 * l);

                 { Nobody calculates perfect }

                 if t < 0.001 then
                   t := 0.0;
                 if help < 0.001 then
                   help := 0.0;

                 if t > 0.0 then
                 begin
                   if help > 0 then
                   begin
                     if help < t then
                       t := help
                     else
                       t := t;
                   end
                   else
                     orient := -orient;
                     { in der Kugel }
                 end
                 else
                 begin
                   if help > 0 then
                   begin
                     orient := -orient;
                     t := help;
                   end
                   else
                   begin
                     hit_object := 0;  { kein Treffer }
                     Exit;             { War wohl nix }
                   end;
                 end;
                 vecmul(int_point, t, dir);
                 vecadd(int_point, point, int_point);
                 vecsub(norma, int_point, ssphere.vector);

                 { raus aus der Kugel }

                 norm(norma, norma);
                 vecmul(norma, orient, norma);
                 hit_object := 1;
                 Exit;
               end;
             end;
  end;
end;

{
  schneidet Gerade, dir durch g1 und g2
  geht; mit allen in Welt vorhandenen
  Objekten und liefert den Schnittpunkt
  in treffpunkt zurÅck sowie einen Zeiger
  auf das Object
}

function line_trace(var point, dir : TVector; var world : TWorld;
                    var int_point, normal : TVector) : PObject;
var
  next : PObject;
  r, n : TVector;                      { Treffpunktspeicher }
  objects : PObject;                   { wird dargestellt }
begin
  next := world.objects;
  objects := NIL;
  while next <> NIL do
  begin
    if hit_object(point, dir, next^, r, n) <> 0 then
    begin
      { erstes Objekt getroffen }
      if (objects = NIL) then
      begin
        objects := next;
        veccpy(int_point, r);
        veccpy(normal, n);
      end
      else
      begin                            { nÑhestes Objekt aussuchen }
        if distance(r, point) < distance(int_point, point) then
        begin
          objects := next;
          veccpy(int_point, r);
          veccpy(normal, n);
        end;
      end;
    end;
    next := next^.next;              { und noch eins }
  end;
  line_trace := objects;
end;

{
  kopiert Frabe von src nach dest
}

procedure colcpy(var dest, src : TColor);
begin
  dest.r := src.r;
  dest.g := src.g;
  dest.b := src.b;
end;

{
  addiert zwei Farben
}

procedure add_color(var dest, col1, col2 : TColor);
begin
  dest.r := col1.r + col2.r;
  if dest.r > MAXRED then
    dest.r := MAXRED;
  dest.g := col1.g + col2.g;
  if dest.g > MAXGREEN then
    dest.g := MAXGREEN;
  dest.b := col1.b + col2.b;
  if dest.b > MAXBLUE then
    dest.b := MAXBLUE;
end;

{
  Dimmerfunktion zur Helligkeitsregelung
  0 <= k <= 1
}

procedure intens_col(var dest : TColor; k : Real; var col1 : TColor);
begin
  if k >= 1.0 then
    k := 1.0;
  dest.r := k * col1.r;
  dest.g := k * col1.g;
  dest.b := k * col1.b;
end;

{
  kombiniert alle Farben zur Gesamtfarbe
}

procedure Combine(var colour, local_col : TColor; local_weight : Real;
                  var ref_col : TColor; ref_weight : Real;
                  var trans_col : TColor; trans_weight : Real);
var
  col : TColor;
begin
  col.r := 1.0;
  col.g := 1.0;
  col.b := 1.0;
  intens_col(colour, local_weight, local_col);
  intens_col(col, ref_weight, ref_col);
  add_color(colour, col, colour);
  intens_col(col, trans_weight, trans_col);
  add_color(colour, col, colour);
end;

{
  berechnet reflections  Richtung auf
  eine SpiegelflÑche
}

procedure ref_vector(var dir, normal, ref_dir : TVector);
var
  i : TVector;
begin
  veccpy(i, dir);
  norm(i, i);
  veccpy(ref_dir, i);
  vecmul(i, -1.0, i);
  vecmul(i, dot(normal, i), normal);
  vecadd(ref_dir, i, ref_dir);
end;

{
  berechnet transmittierende Richtung
  durch eine durchsichtige Wand
}
 
procedure trans_vector(var o : TObject;
                       var normal, dir, trans_dir : TVector);
var
  i : TVector;
  cosvieh : Real;
begin
  veccpy(i, dir);
  norm(i, i);
  vecmul(trans_dir, 1 / o.N, i);
  vecmul(i, -1.0, i);
  cosvieh := dot(normal, i);
  cosvieh := Sqrt(1 - (1 - cosvieh * cosvieh) / (o.N * o.N));
  cosvieh := cosvieh - dot(normal, i) / o.N;
  vecmul(i, cosvieh, normal);
  vecsub(trans_dir, trans_dir, i);
end;

{
  berechnet den lokalen Farbwert des Schnittpunktes des Objekts
}

procedure local_color(var obj : PObject; var dir, normal, int_point : TVector;
                      var world : TWorld; var local_col : TColor);
var
  lamp : PLamp;
  L, V, dummy1, dummy2 : TVector;
  licht                : Real;
  col                  : TColor;
begin
  lamp := world.lamp;

  { Erstmal dunkel }

  colcpy(local_col, black);

  { alle Lampen leuchten }
  while lamp <> NIL do
  begin
  { Wie Hell wird er Punkt ? }
  { abhÑngig von Winkel und Abstand }
  { Lampe auf der richtigen Seite }
  { Schatten von anderen Objekten ? }

  { diffuses Licht }

    vecsub(L, int_point, lamp^.vector);

    { Schatten ? }

    if obj = line_trace(lamp^.vector, L, world, dummy1, dummy2) then
    begin
      vecmul(L, -1.0, L);
      norm(L, L);

      { Lichtfarbe und StÑrke von Lampe }

      licht := dot(L, normal) * obj^.dif_const;

      { Winkel zwischen -90 und 90 }
      if licht > 0 then
      begin
        { Specular Licht }
        vecsub(V, L, dir);
        vecmul(V, 0.5, V);
        norm(V, V);
        licht := licht + obj^.spec_const * pow(dot(V, normal), obj^.high_const);
      end
      else
        licht := 0;

      { so wirds beleuchtet }

      intens_col(col, licht, lamp^.color);

      { Licht distance }

      if licht <> 0 then
        intens_col(col, exp(log(0.5) / lamp^.intens *
                    distance(int_point, lamp^.vector)), col);
      add_color(local_col, local_col, col);
    end;
    lamp := lamp^.next;
  end;
  add_color(local_col, local_col, ambient);
end;


{
  Åberzieht Objekte mit Texturen
}

procedure surfaceCol(var colour : TColor; var objects : TObject;
                      var intpoint : TVector);
var
  a, b, c, d : TVector;
  winkel, x, y, r, r2 : Real;
  l, h                : Word;
  co                  : PByte;
  col                 : Byte;
  ro, g, bl           : Real;
begin
  co := objects.text.map;
  if (objects.text.map <> NIL) then
  begin
    { Abstand von int und Anfang }
    case objects.typ of
      POLYGON : begin
                  vecsub(c, intpoint, objects.polygon.vector[0]);
                  vecsub(a, objects.polygon.vector[1],
                            objects.polygon.vector[0]);
                  norm(b, a);
                  norm(d, c);

                  winkel := dot(b, d);
                  x := Sqrt(dot(c, c)) * winkel / objects.text.big;
                  winkel := sin(acos(Winkel));
                  y := Sqrt(dot(c, c)) * winkel / objects.text.big;
                  h := Round(x + 0.5) MOD objects.text.x;
                  l := Round(y + 0.5) MOD objects.text.y;

                  col := Mem[Seg(co^): Ofs(co^) + objects.text.y * h + 1];

                  bl := (col / 36) / 5;
                  col := col DIV 36;
                  g := (col / 6) / 5;
                  col := col DIV 6;
                  ro := col / 5;
                  colour.r := ro * colour.r;
                  colour.g := g  * colour.g;
                  colour.b := bl * colour.b;
                end;
      SPHERE :  begin
                  x := intpoint.x - objects.sphere.vector.x;

                  { Wie wird texture aufgetragen }

                  case objects.text.typ of
                    1 : y := intpoint.z - objects.sphere.vector.z;
                    2 : y := intpoint.y - objects.sphere.vector.y;
                  end;

                  r := objects.sphere.radius;
                  x := (asin(x / r) * r + r) / objects.text.big;
                  y := (acos(y / r) * r + r) / objects.text.big;
                  h := Round(x + 0.5) MOD objects.text.x;
                  l := Round(y + 0.5) MOD objects.text.y;

                  col := Mem[Seg(co^): Ofs(co^) + objects.text.y * h + 1];

                  bl := (col / 36) / 5;
                  col := col DIV 36;
                  g := (col / 6) / 5;
                  col := col DIV 6;
                  ro := col / 5;
                  colour.r := ro * colour.r;
                  colour.g := g  * colour.g;
                  colour.b := bl * colour.b;
                end;
    end;
  end
  else
  begin
    { Keine Texture monochrom }
    colour.r := objects.color.r * colour.r;
    colour.g := objects.color.g * colour.g;
    colour.b := objects.color.b * colour.b;
  end;
end;

{
  erzeugt Hintergrund
}

procedure bckgrnd(var colour, back : TColor;
                  var dir : TVector;
                      am  : Real);
var
  v, d : TVector;
  n    : Real;
begin
  veccpy(d, dir);
  norm(d, d);
  v.x := 0.0; v.y := 1.0; v.z := 0.0;
  n := 1.5707 / acos(dot(v, d));
  colour.r := back.r * n + back.r * am;
  colour.g := back.g * n + back.g * am;
  colour.b := back.b * n + back.b * am;
end;

{
  liefert die Farbe und IntensitÑt eines
  Bildpunktes in der Welt
}

procedure raytrace(var point, dir : TVector;
                       depth : Word;
                   var world : TWorld;
                   var colour : TColor);
var
  local_col, ref_col, trans_col : TColor;
  ref_dir, trans_dir, int_point, normal : TVector;
  objects : PObject;
begin
  objects := NIL;

  { finde nÑchstes Objekt das vom Strahl
    getroffen wird }

  objects := line_trace(point, dir, world, int_point, normal);

  { Kein Objekt wird getroffen }
  if objects = NIL then
  { Hintergrund zeigen }
    bckgrnd(colour, background, dir, amb)
  else
  begin
    { Farbe des Schnittpunktes }

    local_color(objects, dir, normal, int_point, world, local_col);

    { Rekursionstiefe erreicht ? }
    if depth = maxdepth then
    begin
      { Alles ist schwarz }
      colcpy(ref_col, black);
      colcpy(trans_col, black);
    end
    else
    begin
      { berechne reflektions
        Strahlenvektor }

      if objects^.mirror > 0.0 then
      begin
        ref_vector(normal, dir, ref_dir);
        raytrace(int_point, ref_dir, depth + 1, world, ref_col);
      end
      else
        colcpy(ref_col, black);

      { berechne durchgehenden
        Strahlenvector }
      if objects^.trans > 0.0 then
      begin
        trans_vector(objects^, normal, dir, trans_dir);
        raytrace(int_point, trans_dir, depth + 1, world, trans_col);
      end
      else
        colcpy(trans_col,black);
    end;

    Combine(colour, local_col, objects^.material,
                    ref_col, objects^.mirror,
                    trans_col, objects^.trans);

    { Verbinde lamplight mit
      Objectfarbe }
    surfaceCol(colour, objects^, int_point);
  end;
end;

{
  Åbersetzt RGB-Farbenin LUT-Werte
  Look Up Table
}

procedure to_LUT(var col : TColor);
var
  r, g, b : Real;
begin
  r := col.r * 2 - 1;
  g := col.g * 2 - 1;
  b := col.b * 2 - 1;

  if r > 0 then
  begin
    col.r := 1.0;
    col.b := col.b + r;
    col.g := col.g + r;
  end
  else
    col.r := 2 * col.r;

  if b > 0 then
  begin
    col.b := 1.0;
    col.r := col.r + b;
    col.g := col.g + b;
  end
  else
    col.b := 2 * col.b;

  if g > 0 then
  begin
    col.g := 1.0;
    col.r := col.r + g;
    col.b := col.b + g;
  end
  else
    col.g := 2 * col.g;

  if col.r > 1.0 then
    col.r := 1.0;
  if col.b > 1.0 then
    col.b := 1.0;
  if col.g > 1.0 then
    col.g := 1.0;
end;

{
  interpretiert RGB-Werte in ein
  Palettenregister
}

function interpret_col(var col : TColor) : Word;
begin
  if (col.r < 0) OR (col.g < 0) OR (col.b < 0) then
  begin
    interpret_col := 0;
    Exit;
  end;
  interpret_col := Round(col.r * 5 + 0.5) +
                   Round(col.g * 5 + 0.5) * 6 +
                   Round(col.b * 5 + 0.5) * 36;
end;

{
  verfolgt Strahl durch das Universum und
  gibt Nummer des Palettenregisters zurÅck
  d.h. Umrechnung der von raytrace
  gelieferte Helligkeits und Farbinfos
  in Tabelle
}

function showpoint(x, y : Word;
                   var w : TWorld) : Word;
var
  g1, g2 : TVector;
  col    : TColor;
  s      : Word;                       { Spiegelungstiefe }
begin
  s := 0;
  { Gerade durch den Raum
    durch zwei Punkte definieren }
  g1.x := 0;
  g1.y := 0;
  g1.z := 1;
  g2.x := -((w.observer^.p_width SHR 1) - x) / w.observer^.dx;
  g2.y := ((w.observer^.p_height SHR 1) - y) / w.observer^.dy;
  g2.z := 1;
  raytrace(g1, g2, s, w, col);
  to_LUT(col);
  showpoint := interpret_col(col);
end;

{
  stellt Welt auf dem Bildschirm dar
}

procedure show_world(w : PWorld);
var
  x, y : Word;
begin
  for y := 0 to w^.observer^.p_height do
    for x := 0 to w^.observer^.p_width do
    begin
      if KeyPressed then Exit;
      put_pixel(x, y, showpoint(x, y, w^));
    end;
  if KeyPressed then ReadKey;
end;
end.