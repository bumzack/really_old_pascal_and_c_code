unit UFilter;

interface

uses Dialogs, Drivers, Konst, Strukt,
     Objects, Vars, Views;

type
  PFilterDialog = ^TFilterDialog;
  TFilterDialog = object(TDialog)
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

constructor TFilterDialog.Init;
var
  R : Trect;
begin
  inherited Init(Bounds, ATitle);

  Options := Options OR ofCentered;

  R.Assign(3, 2, 40, 3);
  Eingabe := New(PInputLine, Init(R, 50));

  R.Assign(2, 1, 15, 2);
  TEingabe := New(PLabel, Init(R, 'Filter:', Eingabe));

  R.Assign(41, 2, 44, 3);
  Aufzeichnungen := New(PHistory, Init(R, Eingabe, 100));

  R.Assign(2, 4, 21, 6);
  Kassettennr := New(PButton, Init(R, 'Kassettennummer', cmFilterKassettennr, bfNormal));

  R.Assign(21, 4, 30, 6);
  Titel := New(PButton, Init(R, 'Titel', cmFilterTitel, bfNormal));

  R.Assign(30, 4, 44, 6);
  Darsteller := New(PButton, Init(R, 'Darsteller', cmFilterDarsteller, bfNormal));

  R.Assign(44, 4, 52, 6);
  Frei := New(PButton, Init(R, 'Frei', cmFilterFrei, bfNormal));

  R.Assign(52, 4, 64, 6);
  Loeschen := New(PButton, Init(R, 'Loeschen', cmFilterLoeschen, bfNormal));

  R.Assign(64, 4, 74, 6);
  Zurueck := New(PButton, Init(R, 'ZurÅck', cmFilterZurueck, bfNormal));

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

procedure TFilterDialog.HandleEvent;
begin
  { Esc-Taste abfangen }
  if (Event.What = evKeyDown) AND (Event.KeyCode = kbEsc) then
    ClearEvent(Event);
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmFilterKassettennr : begin
                              Eingabe^.GetData(FilterString);
                              if FilterString <> '' then
                                Filter := FilterKassettennr;
                            end;
      cmFilterTitel : begin
                        Eingabe^.GetData(FilterString);
                        if FilterString <> '' then
                          Filter := FilterTitel;
                      end;
      cmFilterDarsteller : begin
                             Eingabe^.GetData(FilterString);
                             if FilterString <> '' then
                               Filter := FilterDarsteller;
                           end;
      cmFilterFrei : begin
                       Eingabe^.GetData(FilterString);
                       if FilterString <> '' then
                         Filter := FilterFrei;
                     end;
      cmFilterLoeschen : Filter := FilterLoeschen;
      cmFilterZurueck  : Filter := FilterNichts;
    end;
    EndModal(cmOk);
    ClearEvent(Event);
  end;
end;
end.