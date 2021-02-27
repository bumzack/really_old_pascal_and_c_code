unit UDatendi;

interface

uses App, Dialogs, Drivers, Konst, Strukt, Objects,
     U_Liste, UFilter, Vars, Versch, Views;

type
  PDatenDialog = ^TDatenDialog;
  TDatenDialog = object(TDialog)
                   Naechster  : PButton;
                   Vorheriger : PButton;
                   Minus25    : PButton;
                   Plus25     : PButton;
                   Erster     : PButton;
                   Letzter    : PButton;
                   Neu        : PButton;
                   Speichern  : PButton;
                   Loeschen   : PButton;
                   FilterBut  : PButton;
                   Ende       : PButton;

                   Kassettennr    : PZahlInputLine;
                   TKassettennr   : PLabel;
                   Titel          : PInputLine;
                   TTitel         : PLabel;
                   Darsteller     : PInputLine;
                   TDarsteller    : PLabel;
                   Datum          : PInputLine;
                   TDatum         : PLabel;
                   Filmlaenge     : PZahlInputLine;
                   TFilmlaenge    : PLabel;
                   Zaehlwerk_von  : PZahlInputLine;
                   TZaehlwerk_von : PLabel;
                   Zaehlwerk_bis  : PZahlInputLine;
                   TZaehlwerk_bis : PLabel;
                   Sender         : PRadioButtons;
                   Gattung        : PRadioButtons;
                   Gesamtlaenge   : PInputLine;
                   TGesamtlaenge  : PLabel;
                   Frei           : PInputLine;
                   TFrei          : PLabel;
                   FilmLoeschen   : PRadioButtons;
                   TFilmLoeschen  : PLabel;

                   Wievielter_Film  : PInputLine;
                   TWievielter_Film : PLabel;

                   TransferRecord   : TTransferRecordDOS;

                   FilterDialog     : PFilterDialog;

                   constructor Init(var Bounds : TRect; ATitle : TTitleStr);
                   procedure HandleEvent(var Event : TEvent); virtual;
                 end;

implementation

constructor TDatenDialog.Init;
var
  R : TRect;
  i : Byte;
  s : String;
begin
  inherited Init(Bounds, ATitle);

  Options := Options OR ofCentered;
  Flags := Flags AND NOT (wfMove + wfClose);

  R.Assign(14, 1, 20, 2);
  Kassettennr := New(PZahlInputLine, Init(R, 5));
  R.Assign(1, 1, 11, 2);
  TKassettennr := New(PLabel, Init(R, 'Kass.nr.:', Kassettennr));

  R.Assign(14, 2, 78, 3);
  Titel := New(PInputLine, Init(R, 250));
  R.Assign(1, 2, 8, 3);
  TTitel := New(PLabel, Init(R, 'Titel:', Titel));

  R.Assign(14, 3, 78, 4);
  Darsteller := New(PInputLine, Init(R, 250));
  R.Assign(1, 3, 13, 4);
  TDarsteller := New(PLabel, Init(R, 'Darsteller:', Darsteller));

  R.Assign(18, 5, 28, 6);
  Datum := New(PInputLine, Init(R, 8));
  R.Assign(1, 5, 17, 6);
  TDatum := New(PLabel, Init(R, 'Aufgenommen am:', Datum));

  R.Assign(37, 5, 43, 6);
  Filmlaenge := New(PZahlInputLine, Init(R, 5));
  R.Assign(29, 5, 36, 6);
  TFilmlaenge := New(PLabel, Init(R, 'Dauer:', Filmlaenge));

  R.Assign(50, 5, 55, 6);
  Frei := New(PInputLine, Init(R, 5));
  Frei^.Options := Frei^.Options AND NOT ofSelectable;
  R.Assign(43, 5, 49, 6);
  TFrei := New(PLabel, Init(R, 'Frei:', Frei));
  TFrei^.Options := TFrei^.Options AND NOT ofSelectable;

  R.Assign(72, 5, 78, 6);
  Gesamtlaenge := New(PInputLine, Init(R, 5));
  R.Assign(55, 5, 71, 6);
  TGesamtlaenge := New(PLabel, Init(R, 'Kassettenl„nge:', Gesamtlaenge));

  R.Assign(9, 7, 16, 8);
  Zaehlwerk_von := New(PZahlInputLine, Init(R, 5));
  R.Assign(1, 7, 8, 8);
  TZaehlwerk_von := New(PLabel, Init(R, 'Start:', Zaehlwerk_von));

  R.Assign(24, 7, 30, 8);
  Zaehlwerk_bis := New(PZahlInputLine, Init(R, 5));
  R.Assign(17, 7, 23, 8);
  TZaehlwerk_bis := New(PLabel, Init(R, 'Ende:', Zaehlwerk_bis));

  R.Assign(43, 7, 61, 8);
  FilmLoeschen := New(PRadioButtons, Init(R,
    NewSItem('Ja',
    NewSItem('Nein',
    NIL))));
  R.Assign(32, 7, 41, 8);
  TFilmLoeschen := New(PLabel, Init(R, 'L”schen:', FilmLoeschen));

  R.Assign(68, 7, 75, 8);
  Wievielter_Film := New(PInputLine, Init(R, 5));
  Wievielter_Film^.Options := Wievielter_Film^.Options AND NOT ofSelectable;
  R.Assign(62, 7, 67, 8);
  TWievielter_Film := New(PLabel, Init(R, 'Film', Wievielter_Film));
  TWievielter_Film^.Options := TWievielter_Film^.Options AND NOT ofSelectable;

  R.Assign(2, 9, 74, 13);
  Gattung := New(PRadioButtons, Init(R,
    NewSItem('Thriller',
    NewSItem('Action',
    NewSItem('Horror',
    NewSItem('SF',
    NewSItem('Kom”die',
    NewSItem('Theater',
    NewSItem('Kabarett',
    NewSItem('Show',
    NewSItem('Western',
    NewSItem('Kriegsfilm',
    NewSItem('Spielfilm',
    NewSItem('Drama',
    NewSItem('Interview',
    NewSItem('Doku',
    NewSItem('Sport',
    NewSItem('Serie',
    NewSItem('Musik',
    NewSItem('Anderes',
    NIL))))))))))))))))))));

  R.Assign(2, 14, 71, 17);
  Sender := New(PRadioButtons, Init(R,
    NewSItem('ORF',
    NewSItem('RTL',
    NewSItem('RTL 2',
    NewSItem('SAT 1',
    NewSItem('PRO 7',
    NewSItem('VOX',
    NewSItem('ARD',
    NewSItem('ZDF',
    NewSItem('3 SAT',
    NewSItem('Nachrichtensender',
    NewSItem('3. Programme',
    NewSItem('MTV + Sport',
    NewSItem('TNT',
    NewSItem('Anderer',
    NIL))))))))))))))));

  R.Assign(1, 18, 8, 20);
  Vorheriger := New(PButton, Init(R, '<-', cmVorheriger, bfNormal));

  R.Assign(8, 18, 15, 20);
  Naechster := New(PButton, Init(R, '->', cmNaechster, bfNormal));

  R.Assign(15, 18, 22, 20);
  Minus25 := New(PButton, Init(R, '-25', cmMinus25, bfNormal));

  R.Assign(22, 18, 29, 20);
  Plus25 := New(PButton, Init(R, '+25', cmPlus25, bfNormal));

  R.Assign(29, 18, 36, 20);
  Erster := New(PButton, Init(R, '<--', cmErster, bfNormal));

  R.Assign(36, 18, 43, 20);
  Letzter := New(PButton, Init(R, '-->', cmLetzter, bfNormal));

  R.Assign(1, 20, 15, 22);
  Neu := New(PButton, Init(R, '~N~eu', cmNeu, bfNormal));

  R.Assign(15, 20, 29, 22);
  Loeschen := New(PButton, Init(R, 'L”schen', cmLoeschen, bfNormal));

  R.Assign(29, 20, 44, 22);
  Speichern := New(PButton, Init(R, '~S~peichern', cmSpeichern, bfNormal));

  R.Assign(44, 20, 59, 22);
  FilterBut := New(PButton, Init(R, 'Filter', cmFilter, bfNormal));

  R.Assign(59, 20, 74, 22);
  Ende := New(PButton, Init(R, '~E~nde', cmEnde, bfNormal));

  Insert(Kassettennr);
  Insert(TKassettennr);
  Insert(Titel);
  Insert(TTitel);
  Insert(Darsteller);
  Insert(TDarsteller);
  Insert(Datum);
  Insert(TDatum);
  Insert(Filmlaenge);
  Insert(TFilmlaenge);
  Insert(Gesamtlaenge);
  Insert(TGesamtlaenge);
  Insert(Zaehlwerk_von);
  Insert(TZaehlwerk_von);
  Insert(Zaehlwerk_bis);
  Insert(TZaehlwerk_bis);
  Insert(FilmLoeschen);
  Insert(TFilmLoeschen);
  Insert(Gattung);
  Insert(Sender);
  Insert(Frei);
  Insert(TFrei);
  Insert(Wievielter_Film);
  Insert(TWievielter_Film);

  Insert(Vorheriger);
  Insert(Naechster);
  Insert(Minus25);
  Insert(Plus25);
  Insert(Erster);
  Insert(Letzter);
  Insert(Neu);
  Insert(Loeschen);
  Insert(Speichern);
  Insert(FilterBut);
  Insert(Ende);

  Kassettennr^.Select;

  if NOT NeuerDatenSatz then
  begin
    GibAktuelles(Liste, TransferRecord);
    SetData(TransferRecord);
  end
  else
  begin
    FillChar(TransferRecord, SizeOf(TTransferRecordDOS), 0);
    SetData(TransferRecord);
  end;
end;

procedure TDatenDialog.HandleEvent;
  function Filtere : Boolean;
  var
    Zahl  : Word;
    Error : Word;
    s     : String;
    s1    : String;
  begin
    Filtere := False;
    case Filter of
      FilterNichts : Filtere := True;
      FilterKassettennr : begin
                            Val(FilterString, Zahl, Error);
                            if Error <> 0 then
                            begin
                              Filter := FilterNichts;
                              Exit;
                            end;
                            with Liste^ do
                              if Zahl = PFilmObj(Collection^.At(Aktuelles))^.Kassettennr then
                                Filtere := True;
                          end;
      FilterTitel : begin
                      s := '';
                      for Zahl := 1 to Length(FilterString) do
                        s := s + UpCase(FilterString[zahl]);
                      with Liste^ do
                        s1 := PFilmObj(Collection^.At(Aktuelles))^.Titel;
                      for Zahl := 1 to Length(s1) do
                        s1[Zahl] := UpCase(s1[Zahl]);
                      if Pos(s, s1) > 0 then
                        Filtere := True;
                    end;
      FilterDarsteller : begin
                           s := '';
                           for Zahl := 1 to Length(FilterString) do
                             s := s + UpCase(FilterString[Zahl]);
                           with Liste^ do
                             s1 := PFilmObj(Collection^.At(Aktuelles))^.Darsteller;
                           for Zahl := 1 to Length(s1) do
                             s1[Zahl] := UpCase(s1[Zahl]);
                           if Pos(s, s1) > 0 then
                             Filtere := True;
                         end;
      FilterFrei : begin
                     Val(FilterString, Zahl, Error);
                     if Error <> 0 then
                     begin
                       Filter := FilterNichts;
                       Exit;
                     end;
                     with Liste^ do
                       if Zahl <= PFilmObj(Collection^.At(Aktuelles))^.Frei then
                         Filtere := True;
                   end;
      FilterLoeschen : begin
                         with Liste^ do
                           if PFilmObj(Collection^.At(Aktuelles))^.Loeschen then
                             Filtere := True;
                       end;
    end;
  end;

  procedure HoleDatensatz;
  begin
    GetData(TransferRecord);
    if NeuerDatensatz then
    begin
      SortiereEin(Liste, TransferRecord);
      NeuerDatensatz := False;
    end
    else
      SchreibeAktuelles(Liste, TransferRecord);
  end;

  procedure TesteCommands;
  begin
    if Liste^.GeheVorMoeglich then
      EnableCommands([cmNaechster, cmPlus25])
    else
      DisableCommands([cmNaechster, cmPlus25]);
    if Liste^.GeheZurueckMoeglich then
      EnableCommands([cmVorheriger, cmMinus25])
    else
      DisableCommands([cmVorheriger, cmMinus25]);
    if Liste^.IstErstes then
      DisableCommands([cmErster, cmMinus25])
    else
      EnableCommands([cmErster, cmMinus25]);
    if Liste^.IstLetztes then
      DisableCommands([cmLetzter, cmPlus25])
    else
      EnableCommands([cmLetzter, cmPlus25]);
  end;

var
  Zaehler : Byte;
  R       : TRect;
begin
  { Esc-Taste abfangen }
  if (Event.What = evKeyDown) AND (Event.KeyCode = kbEsc) then
    ClearEvent(Event);
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNaechster : begin
                      HoleDatensatz;
                      if Liste^.GeheVorMoeglich then
                      begin
                        Liste^.SpeichereAktuelles;
                        Liste^.GeheVor;
                        while NOT Filtere do
                        begin
                          if Liste^.GeheVorMoeglich then
                            Liste^.GeheVor
                          else
                          begin
                            Liste^.RestauriereAktuelles;
                            break;
                          end;
                        end;
                        GibAktuelles(Liste, TransferRecord);
                        SetData(TransferRecord);
                      end;
                    end;
      cmVorheriger: begin
                      HoleDatensatz;
                      if Liste^.GeheZurueckMoeglich then
                      begin
                        Liste^.SpeichereAktuelles;
                        Liste^.GeheZurueck;
                        while NOT Filtere do
                          if Liste^.GeheZurueckMoeglich then
                            Liste^.GeheZurueck
                          else
                          begin
                            Liste^.RestauriereAktuelles;
                            break;
                          end;
                        GibAktuelles(Liste, TransferRecord);
                        SetData(TransferRecord);
                      end;
                    end;
      cmMinus25 : begin
                    HoleDatensatz;
                    Liste^.SpeichereAktuelles;
                    for Zaehler := 1 to 25 do
                      if Liste^.GeheZurueckMoeglich then
                        Liste^.GeheZurueck;
                    while NOT Filtere do
                      if Liste^.GeheZurueckMoeglich then
                        Liste^.GeheZurueck
                      else
                      begin
                        Liste^.RestauriereAktuelles;
                        break;
                      end;
                    GibAktuelles(Liste, TransferRecord);
                    SetData(TransferRecord);
                  end;
      cmPlus25 : begin
                   HoleDatensatz;
                   Liste^.SpeichereAktuelles;
                   for Zaehler := 1 to 25 do
                      if Liste^.GeheVorMoeglich then
                        Liste^.GeheVor;
                   while NOT Filtere do
                     if Liste^.GeheVorMoeglich then
                       Liste^.GeheVor
                     else
                     begin
                       Liste^.RestauriereAktuelles;
                       break;
                     end;
                   GibAktuelles(Liste, TransferRecord);
                   SetData(TransferRecord);
                 end;
      cmNeu : begin
                HoleDatensatz;
                FillChar(TransferRecord, SizeOf(TTransferRecordDOS), 0);
                SetData(TransferRecord);
                Kassettennr^.Select;
                NeuerDatensatz := True;
              end;
      cmSpeichern : begin
                      HoleDatensatz;
                      Liste^.SpeichereListe(Dateiname);
                    end;
      cmLoeschen : begin
                     Liste^.LoescheAktuelles;
                     Liste^.SpeichereAktuelles;
                     while NOT Filtere do
                       if Liste^.GeheZurueckMoeglich then
                         Liste^.GeheZurueck
                       else
                       begin
                         Liste^.RestauriereAktuelles;
                         break;
                       end;
                     GibAktuelles(Liste, TransferRecord);
                     SetData(TransferRecord);
                   end;
      cmErster : begin
                   HoleDatensatz;
                   Liste^.GeheZuAnfang;
                   Liste^.SpeichereAktuelles;
                   while NOT Filtere do
                     if Liste^.GeheVorMoeglich then
                       Liste^.GeheVor
                     else
                     begin
                       Liste^.RestauriereAktuelles;
                       break;
                     end;
                   GibAktuelles(Liste, TransferRecord);
                   SetData(TransferRecord);
                 end;
      cmLetzter : begin
                    HoleDatensatz;
                    Liste^.GeheZuEnde;
                    Liste^.SpeichereAktuelles;
                    while NOT Filtere do
                      if Liste^.GeheZurueckMoeglich then
                        Liste^.GeheZurueck
                      else
                      begin
                        Liste^.RestauriereAktuelles;
                        break;
                      end;
                    GibAktuelles(Liste, TransferRecord);
                    SetData(TransferRecord);
                  end;
      cmFilter : begin
                   Hide;
                   R.Assign(0, 0, 76, 8);
                   FilterDialog := New(PFilterDialog, Init(R, 'Filter eingeben'));
                   FilterDialog^.Options := FilterDialog^.Options OR ofCentered;
                   Application^.ExecuteDialog(FilterDialog, NIL);
                   Event.What := evCommand;
                   Event.Command := cmErster;
                   Event.InfoPtr := @SELF;
                   PutEvent(Event);
                   Show;
                   Exit;
                 end;
      cmEnde : begin
                 HoleDatensatz;
                 EndModal(cmOk);
               end;
    end;
    TesteCommands;
    ClearEvent(Event);
  end;
  if Event.What = evKeyDown then
  begin
    case Event.KeyCode of
      kbPgDn : begin
                 ClearEvent(Event);
                 Event.What := evCommand;
                 Event.Command := cmVorheriger;
                 Event.InfoPtr := @SELF;
                 PutEvent(Event);
               end;
      kbPgUp : begin
                 ClearEvent(Event);
                 Event.What := evCommand;
                 Event.Command := cmNaechster;
                 Event.InfoPtr := @SELF;
                 PutEvent(Event);
               end;
    end;
    ClearEvent(Event);
  end;
end;
end.