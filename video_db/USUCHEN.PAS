unit USuchen;

interface

uses Dialogs, Drivers, Konst, Strukt, Objects, Vars, Versch, Views;

const
  MaxZeilen  = 200;
  MaxSpalten = 80;

type
  PZeige_Suchergebnis_Inhalt = ^TZeige_Suchergebnis_Inhalt;
  TZeige_Suchergebnis_Inhalt = object (TScroller)
                                 Daten : array[1..MaxZeilen] of TDrawBuffer;
                                 Zeilen : Word;
                                 constructor Init(var Bounds : TRect;
                                                      HScroller : PScrollBar;
                                                      VScroller : PScrollBar);
                                 procedure Draw; virtual;
                                 procedure Update;
                               end;

type
  PZeige_Suchergebnis = ^TZeige_Suchergebnis;
  TZeige_Suchergebnis = object (TWindow)
                          Inhalt : PZeige_Suchergebnis_Inhalt;
                          constructor Init(var Bounds : TRect; ATitle : TTitleStr; ANumber : Integer);
                          procedure HandleEvent(var Event : TEvent); virtual;
                          procedure Update;
                        end;

type
  PSuchenDialog = ^TSuchenDialog;
  TSuchenDialog = object(TDialog)
                    Kassettennr    : PButton;
                    Titel          : PButton;
                    Darsteller     : PButton;
                    Frei           : PButton;
                    Loeschen       : PButton;
                    Zurueck        : PButton;
                    Eingabe        : PInputLine;
                    TEingabe       : PLabel;
                    Aufzeichnungen : PHistory;

                    constructor Init(var Bounds : TRect; ATitle : TTitleStr);
                    procedure HandleEvent(var Event : TEvent); virtual;
                  end;

implementation


constructor TSuchenDialog.Init;
var
  R : Trect;
begin
  inherited Init(Bounds, ATitle);

  Options := Options OR ofCentered;

  R.Assign(3, 2, 40, 3);
  Eingabe := New(PInputLine, Init(R, 50));

  R.Assign(2, 1, 15, 2);
  TEingabe := New(PLabel, Init(R, 'Suchtext:', Eingabe));

  R.Assign(41, 2, 44, 3);
  Aufzeichnungen := New(PHistory, Init(R, Eingabe, 100));

  R.Assign(2, 4, 21, 6);
  Kassettennr := New(PButton, Init(R, 'Kassettennummer', cmSuchKassettennr, bfNormal));

  R.Assign(21, 4, 30, 6);
  Titel := New(PButton, Init(R, 'Titel', cmSuchTitel, bfNormal));

  R.Assign(30, 4, 44, 6);
  Darsteller := New(PButton, Init(R, 'Darsteller', cmSuchDarsteller, bfNormal));

  R.Assign(44, 4, 52, 6);
  Frei := New(PButton, Init(R, 'Frei', cmSuchFrei, bfNormal));

  R.Assign(52, 4, 64, 6);
  Loeschen := New(PButton, Init(R, 'Loeschen', cmSuchLoeschen, bfNormal));

  R.Assign(64, 4, 74, 6);
  Zurueck := New(PButton, Init(R, 'ZurÅck', cmZurueck, bfNormal));

  Insert(Eingabe);
  Insert(TEingabe);
  Insert(Aufzeichnungen);
  Insert(Kassettennr);
  Insert(Titel);
  Insert(Darsteller);
  Insert(Frei);
  Insert(Loeschen);
  Insert(Zurueck);

  Eingabe^.Select;
end;

procedure TSuchenDialog.HandleEvent;
begin
  { Esc-Taste abfangen }
  if (Event.What = evKeyDown) AND (Event.KeyCode = kbEsc) then
    ClearEvent(Event);
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmSuchKassettennr : begin
                            Eingabe^.GetData(SuchString);
                            if SuchString <> '' then
                              Suche := SuchKassettennr;
                            end;
      cmSuchTitel : begin
                      Eingabe^.GetData(SuchString);
                      if SuchString <> '' then
                        Suche := SuchTitel;
                    end;
      cmSuchDarsteller : begin
                           Eingabe^.GetData(SuchString);
                           if SuchString <> '' then
                             Suche := SuchDarsteller;
                         end;
      cmSuchFrei : begin
                     Eingabe^.GetData(SuchString);
                     if SuchString <> '' then
                       Suche := SuchFrei;
                   end;
      cmSuchLoeschen : Suche := SuchLoeschen;
      cmZurueck : Suche := SuchNichts;
    end;
    EndModal(cmOk);
    ClearEvent(Event);
  end;
end;

constructor TZeige_Suchergebnis_Inhalt.Init;
begin
  inherited Init(Bounds, HScroller, VScroller);
  SetLimit(MaxSpalten, MaxZeilen);
end;

procedure TZeige_Suchergebnis_Inhalt.Draw;
var
  i      : Word;
begin
  inherited Draw;

  i := 1;
  while (i <= Size.Y) AND (i <= MaxZeilen) do
  begin
    WriteLine(0, i - 1, Size.X, 1, Daten[i + Delta.Y]);
    Inc(i);
  end;
end;

procedure TZeige_Suchergebnis_Inhalt.Update;
var
  a      : TFilm;
  Weiter : Boolean;
  i      : Word;
begin
  for i := 1 to MaxZeilen do
    MoveChar(Daten[i], ' ', GetColor(1), MaxSpalten);
  Zeilen := 1;
  if SuchErgebnis <> NIL then
  begin
    SuchErgebnis^.GeheZuAnfang;
    if NOT SuchErgebnis^.ListeLeer then
      repeat
        SuchErgebnis^.GibAktuelles(a);
        MoveStr(Daten[Zeilen], NumToStr(a.Kassettennr) +  ' ' + a.Titel, GetColor(1));
        Inc(Zeilen);
        MoveStr(Daten[Zeilen], a.Darsteller, GetColor(1));
        Inc(Zeilen);
        MoveStr(Daten[Zeilen], 'von: ' + NumToStr(a.Zaehlwerk_von) +
                               ' bis: ' + NumToStr(a.Zaehlwerk_bis) +
                               ' Dauer: ' + NumToStr(a.Filmlaenge),
                               GetColor(1));
        Inc(Zeilen);
        Inc(Zeilen);
        if SuchErgebnis^.GeheVorMoeglich then
        begin
          Weiter := True;
          SuchErgebnis^.GeheVor;
        end
        else
          Weiter := False;
      until (SuchErgebnis^.GeheVorMoeglich = False) AND (Weiter = False);
  end
  else
    MoveStr(Daten[Zeilen], 'Keine EintrÑge gefunden                  ', GetColor(1));
  DrawView;
end;

constructor TZeige_Suchergebnis.Init;
var
  R : TRect;
begin
  inherited Init(Bounds, ATitle, ANumber);
  GetExtent(R);
  R.Grow(-1, -1);
  Flags := Flags OR NOT wfMove;
  Inhalt := New(PZeige_SuchErgebnis_Inhalt,
            Init(R, NIL, StandardScrollBar(sbVertical OR sbHandleKeyBoard)));
  Insert(Inhalt);
end;

procedure TZeige_Suchergebnis.Update;
begin
  Inhalt^.Update;
end;

procedure TZeige_Suchergebnis.HandleEvent;
begin
  if (Event.What = evCommand) AND (Event.Command = cmClose) then
    ClearEvent(Event);
  inherited HandleEvent(Event);
end;
end.