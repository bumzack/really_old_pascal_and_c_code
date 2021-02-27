unit defs;

interface

const
  POLYGON  = 0;
  SPHERE   = 1;
  MAXVECTS = 10;
  MAXRED   = 1.0;
  MAXGREEN = 1.0;
  MAXBLUE  = 1.0;

type PByte = ^Byte;

{ Vektor oder Punkt im Universum }

type TVector = record
                 x, y, z : Real;        { Position }
               end;

{ Polygondefinition }
type PPolygon = ^TPolygon;
     TPolygon = record
                  num_vec : Byte;       { Anzahl der Ecken }
                  vector  : Array[0..9] of TVector;
                end;

{ Kugeldefinition }
type PSphere = ^TSphere;
     TSphere = record
                 vector : TVector;     { ihr Mittelpunkt }
                 radius : Real;       { ihr Radius }
               end;

{ Farbe }
type PColor = ^TColor;
     TColor = record
                r, g, b : Real;
              end;

{ Texture }
type TTexture = record
                  x, y : Word;         { Ma·e der Map }
                  big  : Word;         { Streckung }
                  typ  : Byte;         { wie auf die OberflÑche
                                         nur fÅr Kugel }
                  map  : PByte;
                end;

{ sichtbares Objekt im Universum }
type PObject = ^TObject;
     TObject = record
                 next : PObject;       { nÑchstes Objekt }
                 color : TColor;       { Farbe im Spiel }
                 material : Real;      { Wieviel Prozent
                                         des Materials }
                 mirror : Real;        { Wieviel Prozent werden
                                         von Spiegelung dargestellt }
                 trans : Real;         { Wieviel Prozent des durchscheinden Lichts
                                         werden dargestellt }
                 dif_const : Real;     { 0 <= x <= 1 }
                 spec_const : Real;    { 0 <= x <= 1 }
                 high_const : Real;    { 0 <= x <= 100 }
                 n          : Real;    { VelocitÑtfactor }
                 text       : TTexture;{ OberflÑchenfarbe }
                 typ        : Byte;    { Objecttyp }
                 case form : Byte of
                   1 : (polygon : TPolygon);
                   2 : (sphere  : TSphere);
               end;

{ Lichtquelle im Universum }
type PLamp = ^TLamp;                   { Lichtquellen }
     TLamp = record
               next : PLamp;           { nÑchste Lampen }
               vector : TVector;       { Position }
               color : TColor;         { Farbe des Lichts }
               intens : Real;          { StÑrke }
             end;

{ Beobachter im Universum }
type PObserver = ^TObserver;
     TObserver = record                { wir / Bildschirm }
                   p_width : Integer;  { Pixelbreite }
                   p_height : Integer; { Pixelhîhe }
                   dx, dy   : Integer; { Abstand vom Screen }
                 end;

{ neues Universum }
type PWorld = ^TWorld;
     TWorld = record                   { unsere neue Welt }
                lamp : PLamp;          { erste Lampe }
                objects : PObject;      { erstes Objekt }
                observer : PObserver;  { wir }
              end;

implementation

end.