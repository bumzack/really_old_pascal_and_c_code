unit UListe;

interface

uses Strukt;

type
  PKnoten = ^TKnoten;
  TKnoten = record
              Inhalt : TFilm;
              next   : PKnoten;
              prev   : PKnoten;
            end;

  PKnotenObjekt = ^TKnotenObjekt;
  TKnotenObjekt = object
                    constructor Init(Dateiname : String);
                    procedure Anhaengen(Buch : TFilm);
                    procedure SortiereEin(Buch : TFilm);
                    procedure AendereSortTyp(ASortTyp : SortTyp);
                    procedure SpeichereListe(Dateiname : String);
                    function LadeListe(Dateiname : String) : Boolean;
                    function Suche(const s : String; const Wonach : SuchTyp; var Ergebnis : PKnotenObjekt) : Boolean;
                    procedure LoescheAktuelles;
                    function IstErstes : Boolean;
                    function IstLetztes : Boolean;
                    procedure GeheZuAnfang;
                    procedure GeheZuEnde;
                    procedure GeheZurueck;
                    procedure GeheVor;
                    function GeheZurueckMoeglich : Boolean;
                    function GeheVorMoeglich : Boolean;
                    procedure GibAktuelles(var a : TFilm);
                    procedure SchreibeAktuelles(a : TFilm);
                    function ListeLeer : Boolean;
                    procedure SpeichereAktuelles;
                    procedure RestauriereAktuelles;
                    destructor Done;

                  private
                    Wurzel       : PKnoten;
                    Aktuelles    : PKnoten;
                    SortiereNach : SortTyp;
                    Knoten       : Integer;
                    Temp         : PKnoten;
                    procedure SortiereListe;
                    procedure LoescheListe;
                    function Vergleiche(a, b : TFilm) : Integer;
                    procedure Hole(i : Word; var a : TFilm);
                    procedure Schreibe(i : Word; a : TFilm);
                    procedure SchreibeListe;
                  end;

implementation

function ExistiertDatei(DateiName: String) : Boolean;
var
  F: file;
begin
  {$I-}
  Assign(F, DateiName);
  Reset(F);
  Close(F);
  {$I+}
  ExistiertDatei := (IOResult = 0) and (DateiName <> '');
end;

constructor TKnotenObjekt.Init;
begin
  Wurzel := NIL;
  Aktuelles := NIL;
  SortiereNach := SortKassettennr;
  Knoten := 0;
  if Dateiname <> '' then
    LadeListe(Dateiname);
end;

function TKnotenObjekt.IstErstes;
begin
  IstErstes := (Wurzel = Aktuelles);
end;

function TKnotenObjekt.IstLetztes;
begin
  IstLetztes := (Aktuelles^.next = NIL);
end;

procedure TKnotenObjekt.GeheZuAnfang;
begin
  Aktuelles := Wurzel;
end;

procedure TKnotenObjekt.GeheZuEnde;
begin
  while Aktuelles^.next <> NIL do
    Aktuelles := Aktuelles^.next;
end;

procedure TKnotenObjekt.GeheZurueck;
begin
  Aktuelles := Aktuelles^.prev
end;

procedure TKnotenObjekt.GeheVor;
begin
  Aktuelles := Aktuelles^.next
end;

function TKnotenObjekt.GeheZurueckMoeglich;
begin
  GeheZurueckMoeglich := True;
  if Aktuelles^.prev = NIL then
    GeheZurueckMoeglich := False;
end;

function TKnotenObjekt.GeheVorMoeglich;
begin
  GeheVorMoeglich := True;
  if Aktuelles^.next = NIL then
    GeheVorMoeglich := False;
end;

procedure TKnotenObjekt.GibAktuelles;
begin
  a := Aktuelles^.Inhalt;
end;

procedure TKnotenObjekt.SchreibeAktuelles;
begin
  if Wurzel = NIL then
    Anhaengen(a)
  else
    Aktuelles^.Inhalt := a;
end;

function TKnotenObjekt.ListeLeer;
begin
  ListeLeer := (Wurzel = NIL);
end;

procedure TKnotenObjekt.SpeichereListe;
var
  f : File of TFilm;
  a : PKnoten;
begin
  if Wurzel <> NIL then
  begin
    a := Aktuelles;
    Assign(f, Dateiname);
    Rewrite(f);
    Aktuelles := Wurzel;
    while Aktuelles^.next <> NIL do
    begin
      if Aktuelles^.Inhalt.Titel <> '' then
        Write(f, Aktuelles^.Inhalt);
      Aktuelles := Aktuelles^.next;
    end;
    Write(f, Aktuelles^.Inhalt);
    Close(f);
    Aktuelles := a;
  end;
end;

function TKnotenObjekt.LadeListe;
var
  f : File of TFilm;
  a : TFilm;
begin
  if NOT ExistiertDatei(Dateiname) then
    Exit;
  Assign(f, Dateiname);
  Reset(f);
  while NOT EoF(f) do
  begin
    Read(f, a);
    if a.Titel <> '' then
      Anhaengen(a);
  end;
  Close(f);
{  AendereSortTyp(SortZaehlwerk);}
  AendereSortTyp(SortKassettennr);
end;

procedure TKnotenObjekt.SchreibeListe;
begin
  {ClrScr;}
  Aktuelles := Wurzel;
  if SortiereNach = SortKassettennr then
  begin
    while Aktuelles^.next <> NIL do
    begin
      WriteLn(Aktuelles^.Inhalt.Kassettennr);
      Aktuelles := Aktuelles^.next;
    end;
    WriteLn(Aktuelles^.Inhalt.Kassettennr);
  end;
  ReadLn;
end;

procedure TKnotenObjekt.Anhaengen;
var
  dummy : PKnoten;
begin
  if Wurzel = NIL then
  begin
    New(Wurzel);
    Wurzel^.prev := NIL;
    Wurzel^.next := NIL;
    FillChar(Wurzel^.Inhalt, SizeOf(Wurzel^.Inhalt), 0);
    Wurzel^.Inhalt := Buch;
    Aktuelles := Wurzel;
    Inc(Knoten);
  end
  else
  begin
    { zu letztem Element in Liste gehen }
    while Aktuelles^.next <> NIL do
      Aktuelles := Aktuelles^.next;
    { neuen Knoten anlegen }
    New(dummy);
    { prev von neuen Knoten zeigt auf letztes Listenelement }
    dummy^.prev := Aktuelles;
    { next von neuen Knoten zeigt auf NIL }
    dummy^.next := NIL;
    { next von letztem Listenelement zeigt auf dummy }
    Aktuelles^.next := dummy;
    { neuer Knoten bekommt etwas zu speichern }
    FillChar(dummy^.Inhalt, SizeOf(dummy^.Inhalt), 0);
    dummy^.Inhalt := Buch;
    Aktuelles := dummy;
    Inc(Knoten);
  end;
end;

procedure TKnotenObjekt.SortiereEin;
var
  dummy : PKnoten;
  Links : PKnoten;
  Rechts : PKnoten;
begin
  if Wurzel = NIL then
  begin
    New(Wurzel);
    Wurzel^.prev := NIL;
    Wurzel^.next := NIL;
    FillChar(Wurzel^.Inhalt, SizeOf(Wurzel^.Inhalt), 0);
    Wurzel^.Inhalt := Buch;
    Aktuelles := Wurzel;
    Inc(Knoten);
  end
  else
  begin
    { an der Wurzel beginnen }
    Aktuelles := Wurzel;
    { Position suchen, an der das Element eingefÅgt wird }
    while (Vergleiche(Aktuelles^.Inhalt, Buch) = -1) AND
          (Aktuelles^.next <> NIL) do
      Aktuelles := Aktuelles^.next;
    { Wenn das neue Element als letztes angehÑngt wird -> Anhaengen aufrufen }
    if (Vergleiche(Aktuelles^.Inhalt, Buch) = -1) then
    begin
      if Aktuelles^.next = NIL then
        Anhaengen(Buch);
    end
    else
    begin
      if Aktuelles <> Wurzel then
      begin
        Aktuelles := Aktuelles^.prev;
        Links := Aktuelles;
        Rechts := Aktuelles^.next;
        { neuen Knoten anlegen }
        New(dummy);
        { neuer Knoten bekommt etwas zu speichern }
        FillChar(dummy^.Inhalt, SizeOf(dummy^.Inhalt), 0);
        dummy^.Inhalt := Buch;
        { prev von neuen Knoten zeigt auf links }
        dummy^.prev := Links;
        { next von neuen Knoten zeigt auf rechts }
        dummy^.next := Rechts;
        { Links^.next zeigt auf neuen Knoten }
        Links^.next := dummy;
        { Rechts^.prev zeigt auf neuen Knoten }
        Rechts^.prev := dummy;
        Aktuelles := dummy;
        Inc(Knoten);
      end
      else
      begin
        { Neue Wurzel einfÅgen }
        { neuen Knoten anlegen }
        New(dummy);
        { neuer Knoten bekommt etwas zu speichern }
        FillChar(dummy^.Inhalt, SizeOf(dummy^.Inhalt), 0);
        dummy^.Inhalt := Buch;
        { prev von neuen Knoten zeigt auf NIL, da neuer Knoten = Wurzel }
        dummy^.prev := NIL;
        { next von neuen Knoten zeigt auf Wurzel }
        dummy^.next := Wurzel;
        { prev von Wurzel zeigt auf neuen Knoten }
        Wurzel^.prev := dummy;
        { neue Wurzel }
        Wurzel := dummy;
        Aktuelles := Wurzel;
        Inc(Knoten);
      end;
    end;
  end;
end;

procedure TKnotenObjekt.AendereSortTyp;
begin
  SortiereNach := ASortTyp;
  SortiereListe;
end;

function TKnotenObjekt.Suche;
var
  Erfolg : Boolean;
  s1     : String;
  s2     : String;
  i      : Byte;
  SollFreiSein : Byte;

  procedure Kassettennr;
  var
    i : Byte;
    Nr : Word;
    Error : Integer;
  begin
    Aktuelles := Wurzel;
    Val(s, Nr, Error);
    if Error <> 0 then
      Exit;
    while Aktuelles <> NIL do
    begin
      if Aktuelles^.Inhalt.Kassettennr = Nr then
      begin
        Erfolg := True;
        Ergebnis^.SortiereEin(Aktuelles^.Inhalt);
      end;
      Aktuelles := Aktuelles^.next;
    end;
  end;

  procedure Titel;
  var
    i : Byte;
  begin
    Aktuelles := Wurzel;
    while Aktuelles <> NIL do
    begin
      s1 := '';
      for i := 1 to Length(Aktuelles^.Inhalt.Titel) do
        s1 := s1 + UpCase(Aktuelles^.Inhalt.Titel[i]);
      if Pos(s2, s1) > 0 then
      begin
        Erfolg := True;
        Ergebnis^.SortiereEin(Aktuelles^.Inhalt);
      end;
      Aktuelles := Aktuelles^.next;
    end;
  end;

  procedure Loeschen;
  var
    i : Byte;
    a : Boolean;
  begin
    Aktuelles := Wurzel;
    while Aktuelles <> NIL do
    begin
      if Aktuelles^.Inhalt.Loeschen then
      begin
        Erfolg := True;
        Ergebnis^.SortiereEin(Aktuelles^.Inhalt);
      end;
      Aktuelles := Aktuelles^.next;
    end;
  end;

  procedure Darsteller;
  var
    i : Byte;
  begin
    Aktuelles := Wurzel;
    while Aktuelles <> NIL do
    begin
      s1 := '';
      for i := 1 to Length(Aktuelles^.Inhalt.Darsteller) do
        s1 := s1 + UpCase(Aktuelles^.Inhalt.Darsteller[i]);
      if Pos(s2, s1) > 0 then
      begin
        Erfolg := True;
        Ergebnis^.SortiereEin(Aktuelles^.Inhalt);
      end;
      Aktuelles := Aktuelles^.next;
    end;
  end;

  procedure Frei;
  var
    i : Byte;
    Error : Integer;
  begin
    Val(s2, SollFreiSein, Error);
    if Error <> 0 then
      Exit;
    Aktuelles := Wurzel;
    while Aktuelles <> NIL do
    begin
      if Aktuelles^.Inhalt.Frei > SollFreiSein then
      begin
        Erfolg := True;
        Ergebnis^.SortiereEin(Aktuelles^.Inhalt);
      end;
      Aktuelles := Aktuelles^.next;
    end;
  end;

begin
  Erfolg := False;
  s1 := '';
  s2 := '';
  for i := 1 to Length(s) do
    s2 := s2 + UpCase(s[i]);
  Ergebnis := New(PKnotenObjekt, Init(''));
  case Wonach of
    SuchKassettennr : Kassettennr;
    SuchTitel       : Titel;
    SuchDarsteller  : Darsteller;
    SuchFrei        : Frei;
    SuchLoeschen    : Loeschen;
  end;
  Suche := Erfolg;
  Aktuelles := Wurzel;
end;

procedure TKnotenObjekt.SpeichereAktuelles;
begin
  Temp := Aktuelles;
end;

procedure TKnotenObjekt.RestauriereAktuelles;
begin
  Aktuelles := Temp;
end;
{
  GeheZuAnfang;
  while (Aktuelles <> Temp) AND GeheVorMoeglich do
    GeheVor;
  Aktuelles :=}

procedure TKnotenObjekt.LoescheAktuelles;
var
  Links, Rechts : PKnoten;
  dummy         : PKnoten;
begin
  if Aktuelles = Wurzel then
  begin
    Wurzel := Wurzel^.next;
    Wurzel^.prev := NIL;
    Dispose(Aktuelles);
    Aktuelles := Wurzel;
  end
  else
  begin
    if Aktuelles^.next = NIL then
    begin
      Aktuelles := Aktuelles^.prev;
      dummy := Aktuelles^.next;
      Dispose(dummy);
      Aktuelles^.next := NIL;
    end
    else
    begin
      links := Aktuelles^.prev;
      rechts := Aktuelles^.next;
      dummy := Aktuelles;
      Dispose(dummy);
      links^.next := rechts;
      rechts^.prev := links;
      Aktuelles := links;
    end;
  end;
end;

procedure TKnotenObjekt.SortiereListe;
var
  i     : Word;
  Marke : Boolean;
  a, b  : TFilm;
  Ergebnis : Integer;
begin
  repeat
    Marke := True;
    for i := 1 to Knoten - 1 do
    begin
      Hole(i + 1, a);
      Hole(i, b);
      Ergebnis := Vergleiche(a, b);
      if (Ergebnis = -1) then
      begin
        Schreibe(i, a);
        Schreibe(i + 1, b);
        Marke := False;
      end;
    end;
  until Marke;
end;

procedure TKnotenObjekt.LoescheListe;
var
  dummy : PKnoten;
begin
  if Wurzel <> NIL then
  begin
    { zu letztem Element in Liste gehen }
    while Aktuelles^.next <> NIL do
      Aktuelles := Aktuelles^.next;
    { von hinten solange nach vorne arbeiten bis Wurzel erreicht }
    while Aktuelles <> Wurzel do
    begin
      { dummy wird immer gelîscht }
      dummy := Aktuelles;
      { Aktuelles nÑhert sich Wurzel }
      Aktuelles := Aktuelles^.prev;
      { dummy wird aus Speicher entfernt }
      Dispose(dummy);
    end;
    Dispose(Wurzel);
    Wurzel := NIL;
    Aktuelles := NIL;
  end;
end;

function TKnotenObjekt.Vergleiche;
var
  Ergebnis : Integer;
begin
  case SortiereNach of
    SortKassettennr : begin
                        if a.Kassettennr < b.Kassettennr then
                          Ergebnis := -1;
                        if a.Kassettennr = b.Kassettennr then
                          Ergebnis := 0;
                        if a.Kassettennr > b.Kassettennr then
                          Ergebnis := 1;
                      end;
  end;
  Vergleiche := Ergebnis;
end;

procedure TKnotenObjekt.Hole;
var
  j : Word;
begin
  Aktuelles := Wurzel;
  if i = 1 then
    a := Wurzel^.Inhalt
  else
    begin
    j := 1;
    repeat
      Aktuelles := Aktuelles^.next;
      Inc(j);
    until j = i;
    a := Aktuelles^.Inhalt;
  end;
end;

procedure TKnotenObjekt.Schreibe;
var
  j : Word;
begin
  Aktuelles := Wurzel;
  if i = 1 then
    Wurzel^.Inhalt := a
  else
    begin
    j := 1;
    repeat
      Aktuelles := Aktuelles^.next;
      Inc(j);
    until j = i;
    Aktuelles^.Inhalt := a;
  end;
end;

destructor TKnotenObjekt.Done;
begin
  LoescheListe;
end;
end.