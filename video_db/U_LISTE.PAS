unit U_Liste;

interface

uses Objects, Strings, Strukt;

type
  PFilmObj = ^TFilmObj;
  TFilmObj = object (TObject)
               Kassettennr     : Word;
               Titel           : String[250];
               Datum           : String[8];
               Gesamtlaenge    : Word;
               Frei            : Word;
               Wievielter_Film : Byte;
               GesamtFilme     : Byte;
               Zaehlwerk_von   : Word;
               Zaehlwerk_bis   : Word;
               Filmlaenge      : Word;
               Sender          : Word;
               Gattung         : Word;
               Darsteller      : String[250];
               Loeschen        : Boolean;

               constructor Init(aInhalt : TFilm);
               constructor Load(var S : TStream);
               procedure Store(var S : TStream); virtual;
               procedure Gib(var aInhalt : TFilm);
               procedure Schreib(aInhalt : TFilm);
               procedure SchreibAn;
               destructor Done; virtual;
             end;

  PMeinStream = ^TMeinStream;
  TMeinStream = object (TBufStream)
                  Laden : Boolean;
                  procedure Error(Code, Info: Integer); virtual;
                end;

type
  PMeineCollection = ^TMeineCollection;
  TMeineCollection = object (TSortedCollection)
    constructor Init(ALimit, ADelta : Integer);
    constructor Load(var S : TStream);
    procedure Store(var S : TStream); virtual;
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function KeyOf(Item: Pointer): Pointer; virtual;
    procedure Error(Code, Info : Integer); virtual;
  end;

  PListe = ^TListe;
  TListe = object
    Collection : PMeineCollection;
    Aktuelles  : Integer;
{$IFDEF WINDOWS}
    constructor Init(Dateiname : FNameStr);
    procedure SpeichereListe(Dateiname : FNameStr);
    function LadeListe(Dateiname : FNameStr) : Boolean;
{$ELSE}
    constructor Init(Dateiname : String);
    procedure SpeichereListe(Dateiname : String);
    function LadeListe(Dateiname : String) : Boolean;
{$ENDIF}
    procedure SortiereEin(Film : TFilm);
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
    function Suche(const s : String; const Wonach : SuchTyp; var Ergebnis : PListe) : Boolean;
    procedure LoescheAktuelles;
    procedure SchreibAn;
    destructor Done;

  private
    Stream : TMeinStream;

    Temp       : Integer;

             {
             procedure AendereSortTyp(ASortTyp : SortTyp);

             }
  end;

implementation

constructor TFilmObj.Init;
begin
  Kassettennr     := aInhalt.Kassettennr;
  Titel           := aInhalt.Titel;
  Datum           := aInhalt.Datum;
  Gesamtlaenge    := aInhalt.Gesamtlaenge;
  Frei            := aInhalt.Frei;
  Wievielter_Film := aInhalt.Wievielter_Film;
  GesamtFilme     := aInhalt.Gesamtfilme;
  Zaehlwerk_von   := aInhalt.Zaehlwerk_von;
  Zaehlwerk_bis   := aInhalt.Zaehlwerk_bis;
  Filmlaenge      := aInhalt.Filmlaenge;
  Sender          := aInhalt.Sender;
  Gattung         := aInhalt.Gattung;
  Darsteller      := aInhalt.Darsteller;
  Loeschen        := aInhalt.Loeschen;
end;

procedure TFilmObj.Gib;
begin
  aInhalt.Kassettennr     := Kassettennr;
  aInhalt.Titel           := Titel;
  aInhalt.Datum           := Datum;
  aInhalt.Gesamtlaenge    := Gesamtlaenge;
  aInhalt.Frei            := Frei;
  aInhalt.Wievielter_Film := Wievielter_Film;
  aInhalt.GesamtFilme     := Gesamtfilme;
  aInhalt.Zaehlwerk_von   := Zaehlwerk_von;
  aInhalt.Zaehlwerk_bis   := Zaehlwerk_bis;
  aInhalt.Filmlaenge      := Filmlaenge;
  aInhalt.Sender          := Sender;
  aInhalt.Gattung         := Gattung;
  aInhalt.Darsteller      := Darsteller;
  aInhalt.Loeschen        := Loeschen;
end;

procedure TFilmObj.Schreib(aInhalt : TFilm);
begin
  Kassettennr     := aInhalt.Kassettennr;
  Titel           := aInhalt.Titel;
  Datum           := aInhalt.Datum;
  Gesamtlaenge    := aInhalt.Gesamtlaenge;
  Frei            := aInhalt.Frei;
  Wievielter_Film := aInhalt.Wievielter_Film;
  GesamtFilme     := aInhalt.Gesamtfilme;
  Zaehlwerk_von   := aInhalt.Zaehlwerk_von;
  Zaehlwerk_bis   := aInhalt.Zaehlwerk_bis;
  Filmlaenge      := aInhalt.Filmlaenge;
  Sender          := aInhalt.Sender;
  Gattung         := aInhalt.Gattung;
  Darsteller      := aInhalt.Darsteller;
  Loeschen        := aInhalt.Loeschen;
end;

constructor TFilmObj.Load(var S : TStream);
begin
  S.Read(Kassettennr     , SizeOf(Kassettennr));
  S.Read(Titel           , SizeOf(Titel));
  S.Read(Datum           , SizeOf(Datum));
  S.Read(Gesamtlaenge    , SizeOf(Gesamtlaenge));
  S.Read(Frei            , SizeOf(Frei));
  S.Read(Wievielter_Film , SizeOf(Wievielter_Film));
  S.Read(GesamtFilme     , SizeOf(Gesamtfilme));
  S.Read(Zaehlwerk_von   , SizeOf(Zaehlwerk_von));
  S.Read(Zaehlwerk_bis   , SizeOf(Zaehlwerk_bis));
  S.Read(Filmlaenge      , SizeOf(Filmlaenge));
  S.Read(Sender          , SizeOf(Sender));
  S.Read(Gattung         , SizeOf(Gattung));
  S.Read(Darsteller      , SizeOf(Darsteller));
  S.Read(Loeschen        , SizeOf(Loeschen));
end;

procedure TFilmObj.Store(var S : TStream);
begin
  S.Write(Kassettennr     , SizeOf(Kassettennr));
  S.Write(Titel           , SizeOf(Titel));
  S.Write(Datum           , SizeOf(Datum));
  S.Write(Gesamtlaenge    , SizeOf(Gesamtlaenge));
  S.Write(Frei            , SizeOf(Frei));
  S.Write(Wievielter_Film , SizeOf(Wievielter_Film));
  S.Write(GesamtFilme     , SizeOf(Gesamtfilme));
  S.Write(Zaehlwerk_von   , SizeOf(Zaehlwerk_von));
  S.Write(Zaehlwerk_bis   , SizeOf(Zaehlwerk_bis));
  S.Write(Filmlaenge      , SizeOf(Filmlaenge));
  S.Write(Sender          , SizeOf(Sender));
  S.Write(Gattung         , SizeOf(Gattung));
  S.Write(Darsteller      , SizeOf(Darsteller));
  S.Write(Loeschen        , SizeOf(Loeschen));
end;

procedure TFilmObj.SchreibAn;
begin
  WriteLn(Kassettennr : 5, Titel : 60);
end;

destructor TFilmObj.Done;
begin
end;

constructor TMeineCollection.Init(ALimit, ADelta : Integer);
begin
  inherited Init(ALimit, ADelta);
  Duplicates := True;
end;

constructor TMeineCollection.Load(var S : TStream);
begin
  inherited Load(S);
end;

procedure TMeineCollection.Store(var S : TStream);
begin
  inherited Store(S);
end;

function TMeineCollection.Compare(Key1, Key2 : Pointer) : Integer;
begin
  if PFilm(Key1)^.Kassettennr = PFilm(Key2)^.Kassettennr then
    Compare := 0;
  if PFilm(Key1)^.Kassettennr < PFilm(Key2)^.Kassettennr then
    Compare := -1
  else
    Compare := 1;
end;

function TMeineCollection.KeyOf(Item : Pointer) : Pointer;
begin
  KeyOf := @PFilm(Item)^.Titel;
end;

procedure TMeineCollection.Error(Code, Info : Integer);
begin
  case Code of
    coIndexError : WriteLn('Index au·erhalb des zulÑssigen Bereichs.', Info : 3);
    coOverflow   : WriteLn('öberlauf in der Kollektion.');
  end;
end;

{$IFDEF WINDOWS}

constructor TListe.Init;
begin
  Collection := NIL;
  if StrLen(Dateiname) > 0 then
  begin
    Stream.Init(Dateiname, stCreate, 2048);
    Collection := PMeineCollection(Stream.Get);
    Stream.Done;
  end
  else
    Collection := New(PMeineCollection, Init(10, 5));
  Aktuelles := 0;
end;

procedure TListe.SpeichereListe(Dateiname : FNameStr);
begin
  Stream.Init(Dateiname, stCreate, 2048);
  Stream.Put(Collection);
  Stream.Done;
end;

function TListe.LadeListe(Dateiname : FNameStr) : Boolean;
begin
  Stream.Init(Dateiname, stOpen, 2048);
  Collection := PMeineCollection(Stream.Get);
  if Stream.Laden then
    LadeListe := True
  else
    LadeListe := False;
  Stream.Done;
end;

{$ELSE}

constructor TListe.Init;
begin
  Collection := NIL;
  if Dateiname <> '' then
  begin
    Stream.Init(Dateiname, stOpen, 2048);
    Collection := PMeineCollection(Stream.Get);
    Stream.Done;
  end
  else
    Collection := New(PMeineCollection, Init(10, 5));
  Aktuelles := 0;
end;

procedure TListe.SpeichereListe(Dateiname : String);
begin
  Stream.Init(Dateiname, stCreate, 2048);
  Stream.Put(Collection);
  Stream.Done;
end;

function TListe.LadeListe(Dateiname : String) : Boolean;
begin
  Stream.Init(Dateiname, stOpen, 2048);
  Collection := PMeineCollection(Stream.Get);
  if Stream.Laden then
    LadeListe := True
  else
    LadeListe := False;
  Stream.Done;
end;

{$ENDIF}

procedure TListe.SortiereEin(Film : TFilm);
begin
  Collection^.Insert(New(PFilmObj, Init(Film)));
end;

function TListe.IstErstes : Boolean;
begin
  IstErstes := (Aktuelles = 0);
end;

function TListe.IstLetztes : Boolean;
begin
  IstLetztes := (Aktuelles = Collection^.Count - 1);
end;

procedure TListe.GeheZuAnfang;
begin
  Aktuelles := 0;
end;

procedure TListe.GeheZuEnde;
begin
  Aktuelles := Collection^.Count - 1;
end;

procedure TListe.GeheZurueck;
begin
  if Aktuelles > 0 then
    Dec(Aktuelles);
end;

procedure TListe.GeheVor;
begin
  if Aktuelles < Collection^.Count then
    Inc(Aktuelles);
end;

function TListe.GeheZurueckMoeglich : Boolean;
begin
  GeheZurueckMoeglich := (Aktuelles > 0);
end;

function TListe.GeheVorMoeglich : Boolean;
begin
  GeheVorMoeglich := (Aktuelles < Collection^.Count - 1);
end;

procedure TListe.GibAktuelles(var a : TFilm);
var
  dummy : PFilmObj;
begin
  dummy := Collection^.At(Aktuelles);
  if dummy <> NIL then
    dummy^.Gib(a);
end;

procedure TListe.SchreibeAktuelles(a : TFilm);
var
  dummy : PFilmObj;
begin
  dummy := Collection^.At(Aktuelles);
  dummy^.Schreib(a);
end;

function TListe.ListeLeer : Boolean;
begin
  ListeLeer := (Collection^.Count = 0);
end;

procedure TListe.SpeichereAktuelles;
begin
  Temp := Aktuelles;
end;

procedure TListe.RestauriereAktuelles;
begin
  Aktuelles := Temp;
end;

function TListe.Suche;
var
  Gefunden : Boolean;

  procedure SuchTitelProc(P : PFilmObj); far;
  var
    s1 : String;
    s2 : String;
    i  : Integer;
    f  : TFilm;
  begin
    s1 := s;
    for i := 1 to Length(s1) do
      s1[i] := UpCase(s1[i]);
    s2 := P^.Titel;
    for i := 1 to Length(s2) do
      s2[i] := UpCase(s2[i]);
    if Pos(s1, s2) > 0 then
    begin
      Gefunden := True;
      P^.Gib(F);
      Ergebnis^.SortiereEin(F);
    end;
  end;

  procedure SuchDarstellerProc(P : PFilmObj); far;
  var
    s1 : String;
    s2 : String;
    i  : Integer;
    f  : TFilm;
  begin
    s1 := s;
    for i := 1 to Length(s1) do
      s1[i] := UpCase(s1[i]);
    s2 := P^.Darsteller;
    for i := 1 to Length(s2) do
      s2[i] := UpCase(s2[i]);
    if Pos(s1, s2) > 0 then
    begin
      Gefunden := True;
      P^.Gib(F);
      Ergebnis^.SortiereEin(F);
    end;
  end;

  procedure SuchKassettennrProc(P : PFilmObj); far;
  var
    Nr : Word;
    Error : Integer;
    f  : TFilm;
  begin
    Val(s, Nr, Error);
    if Error = 0 then
    begin
      if Nr = P^.Kassettennr then
      begin
        Gefunden := True;
        P^.Gib(F);
        Ergebnis^.SortiereEin(F);
      end;
    end;
  end;

  procedure SuchFreiProc(P : PFilmObj); far;
  var
    Frei  : Word;
    Error : Integer;
    f     : TFilm;
  begin
    Val(s, Frei, Error);
    if Error = 0 then
    begin
      if Frei = P^.Frei then
      begin
        Gefunden := True;
        P^.Gib(F);
        Ergebnis^.SortiereEin(F);
      end;
    end;
  end;

  procedure SuchLoeschenProc(P : PFilmObj); far;
  var
    f     : TFilm;
  begin
    if P^.Loeschen then
    begin
      Gefunden := True;
      P^.Gib(F);
      Ergebnis^.SortiereEin(F);
    end;
  end;

begin
  Ergebnis := New(PListe, Init(''));
  case Wonach of
    SuchFrei        : Collection^.ForEach(@SuchFreiProc);
    SuchDarsteller  : Collection^.ForEach(@SuchDarstellerProc);
    SuchLoeschen    : Collection^.ForEach(@SuchLoeschenProc);
    SuchTitel       : Collection^.ForEach(@SuchTitelProc);
    SuchKassettennr : Collection^.ForEach(@SuchKassettennrProc);
  end;
  if Gefunden then
    Suche := True
  else
    Suche := False;
end;

procedure TListe.LoescheAktuelles;
begin
  Collection^.AtDelete(Aktuelles);
end;

const
  Zeilen : Word = 1;

procedure TListe.SchreibAn;
  procedure Zeige(P : PFilmObj); far;
  begin
    Inc(Zeilen);
    P^.SchreibAn;
    if Zeilen >= 20 then
    begin
      ReadLn;
      Zeilen := 1;
    end;
  end;

begin
  Collection^.ForEach(@Zeige);
end;

destructor TListe.Done;
begin
  Aktuelles := 0;
  Dispose(Collection, Done);
end;

procedure TMeinStream.Error(Code, Info: Integer);
begin
  case Code of
    stOk         : Laden := True;
    stError      : Laden := False;
    stInitError  : Laden := False;
    stReadError  : Laden := False;
    stWriteError : Laden := False;
    stGetError   : Laden := False;
    stPutError   : Laden := False;
  end;
  WriteLn(#7);
  case Code of
    stOk : WriteLn('Kein Fehler aufgetreten');
    stError : WriteLn('Fehler beim Dateizugriff');
    stInitError : WriteLn('Fehler bei der Stream-Initialisierung');
    stReadError : WriteLn('Versuch, Åber das Stream-Ende hinaus zu lesen');
    stWriteError : WriteLn('Fehler beim Schreiben in den Stream');
    stGetError : WriteLn('Get mit nicht registriertem Objekttyp aufgerufen');
    stPutError : WriteLn('Put mit nicht registriertem Objekttyp aufgerufen');
  end;
end;

const
  RFilmObj : TStreamRec = (
    ObjType : 150;
    VmtLink : Ofs(TypeOf(TFilmObj)^);
    Load: @TFilmObj.Load;
    Store: @TFilmObj.Store);

  RListe : TStreamRec = (
    ObjType : 151;
    VmtLink : Ofs(TypeOf(TMeineCollection)^);
    Load: @TMeineCollection.Load;
    Store: @TMeineCollection.Store);

procedure Registriere;
begin
  RegisterType(RFilmObj);
  RegisterType(RListe);
  RegisterObjects;
end;

begin
  Registriere;
end.