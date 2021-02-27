unit Versch;

interface

uses Dialogs, Drivers, Strukt,
     Objects, U_Liste, Views;

{ ZahlInputLine: Nachfolger von TInputLine, der nur Eingabe von Zahlen zul„át }
type PZahlInputLine = ^TZahlInputLine;
     TZahlInputLine = object (TInputLine)
                        procedure HandleEvent(var Event : TEvent); virtual;
                      end;

function NumToStr(a : Word) : String;
procedure BerechneNeu(const Liste : PListe; const Nummer : Word);
procedure SortiereEin(const Liste : PListe; const a : TTransferRecordDOS);
procedure SchreibeAktuelles(const Liste : PListe; const a : TTransferRecordDOS);
procedure GibAktuelles(const Liste : PListe; var a : TTransferRecordDOS);

implementation

function NumToStr;
var
  dummy : String;
begin
  Str(a, dummy);
  NumToStr := dummy;
end;

procedure BerechneNeu;
var
  Kassette : array[1..20] of TFilm;
  Position : array[1..20] of Word;
  Gesamtlaenge : Word;
  AnzahlFilme  : Word;
  i            : Word;
  j            : Word;
  Frei         : Word;

  procedure Swap(var a, b : TFilm);
  var
    c : TFilm;
  begin
    c := a;
    a := b;
    b := c;
  end;

  procedure Sortiere;
  var
    i     : Word;
    Marke : Boolean;
    a, b  : TFilm;
    Ergebnis : Integer;
  begin
    if Anzahlfilme > 1 then
    begin
      repeat
        Marke := True;
        for i := 1 to AnzahlFilme - 1 do
        begin
          if Kassette[i + 1].Zaehlwerk_von < Kassette[i].Zaehlwerk_von then
          begin
            Swap(Kassette[i + 1], Kassette[i]);
            Marke := False;
          end;
        end;
      until Marke;
    end;
  end;

begin
  with Liste^ do
  begin
    SpeichereAktuelles;
    GeheZuAnfang;
    AnzahlFilme := 1;
    i           := 1;
    if PFilmObj(Liste^.Collection^.At(Aktuelles))^.Kassettennr = Nummer then
    begin
      PFilmObj(Liste^.Collection^.At(Aktuelles))^.Gib(Kassette[AnzahlFilme]);
      Position[AnzahlFilme] := i;
      Inc(AnzahlFilme);
    end;
    Inc(i);
    repeat
      GeheVor;
      if PFilmObj(Liste^.Collection^.At(Aktuelles))^.Kassettennr = Nummer then
      begin
        PFilmObj(Liste^.Collection^.At(Aktuelles))^.Gib(Kassette[AnzahlFilme]);
        Position[AnzahlFilme] := i;
        Inc(AnzahlFilme);
      end;
      Inc(i);
    until NOT GeheVorMoeglich;
    Dec(AnzahlFilme);
    Sortiere;
    Gesamtlaenge := 0;
    for i := 1 to AnzahlFilme do
    begin
      Gesamtlaenge := Gesamtlaenge + Kassette[i].Filmlaenge;
      Kassette[i].Wievielter_Film := i;
      Kassette[i].GesamtFilme := AnzahlFilme;
    end;
    if Kassette[1].Gesamtlaenge > 0 then
    begin
      if Gesamtlaenge > Kassette[1].Gesamtlaenge then
        Frei := 0
      else
        Frei := Kassette[1].Gesamtlaenge - Gesamtlaenge;
      for i := 1 to AnzahlFilme do
        Kassette[i].Frei := Frei;
    end;
    for j := 1 to AnzahlFilme do
    begin
      GeheZuAnfang;
      for i := 1 to Position[j] - 1 do
        GeheVor;
      SchreibeAktuelles(Kassette[j]);
    end;
    RestauriereAktuelles;
  end;
end;

procedure SortiereEin;
var
  Film : TFilm;
  Error : Integer;
begin
  FillChar(Film, SizeOf(Film), 0);
  Val(a.Kassettennr, Film.Kassettennr, Error);
  Film.Titel := a.Titel;
  Film.Darsteller := a.Darsteller;
  Film.Datum := a.Datum;
  Val(a.Filmlaenge, Film.Filmlaenge, Error);
  Val(a.Gesamtlaenge, Film.Gesamtlaenge, Error);
  Val(a.Zaehlwerk_von, Film.Zaehlwerk_von, Error);
  Val(a.Zaehlwerk_bis, Film.Zaehlwerk_bis, Error);
  Film.Gattung := a.Gattung;
  Film.Sender  := a.Sender;
  if a.Loeschen= 0 then
    Film.Loeschen := True
  else
    Film.Loeschen := False;
  Liste^.SortiereEin(Film);
  BerechneNeu(Liste, Film.Kassettennr);
end;

procedure SchreibeAktuelles;
var
  Film : TFilm;
  Error : Integer;
begin
  FillChar(Film, SizeOf(Film), 0);
  Val(a.Kassettennr, Film.Kassettennr, Error);
  Film.Titel := a.Titel;
  Film.Darsteller := a.Darsteller;
  Film.Datum := a.Datum;
  Val(a.Filmlaenge, Film.Filmlaenge, Error);
  Val(a.Gesamtlaenge, Film.Gesamtlaenge, Error);
  Val(a.Zaehlwerk_von, Film.Zaehlwerk_von, Error);
  Val(a.Zaehlwerk_bis, Film.Zaehlwerk_bis, Error);
  Film.Gattung := a.Gattung;
  Film.Sender  := a.Sender;
  if a.Loeschen= 0 then
    Film.Loeschen := True
  else
    Film.Loeschen := False;
  Liste^.SchreibeAktuelles(Film);
  BerechneNeu(Liste, Film.Kassettennr);
end;

procedure GibAktuelles;
var
  Film : TFilm;
  s    : String;
  t    : String;
begin
  Liste^.GibAktuelles(Film);
  Str(Film.Kassettennr, a.Kassettennr);
  a.Titel := Film.Titel;
  a.Darsteller := Film.Darsteller;
  a.Datum := Film.Datum;
  Str(Film.Filmlaenge, a.Filmlaenge);
  Str(Film.Gesamtlaenge, a.Gesamtlaenge);
  Str(Film.Zaehlwerk_von, a.Zaehlwerk_von);
  Str(Film.Zaehlwerk_bis, a.Zaehlwerk_bis);
  a.Gattung := Film.Gattung;
  a.Sender := Film.Sender;
  if Film.Loeschen then
    a.Loeschen := 0
  else
    a.Loeschen := 1;
  Str(Film.Frei, a.Frei);
  Str(Film.Wievielter_Film, s);
  Str(Film.Gesamtfilme, t);
  a.Wievielter_Film := s + '/'+ t;
end;

procedure TZahlInputLine.HandleEvent;
const
  Verboten : set of Char =
    ['a'..'z','A'..'Z', ' '..'.', '~'..#255];
begin
  if (Event.What <> evKeyDown) OR
     NOT (Event.CharCode IN Verboten) then
    inherited HandleEvent(Event)
  else
    ClearEvent(Event);
end;
end.