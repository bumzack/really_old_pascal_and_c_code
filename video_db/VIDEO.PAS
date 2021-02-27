{$M 65520,0,655360}

program Datenbankprogramm;

uses App, Drivers, Dialogs, GadGets, Konst,
     Menus, Objects, Strukt, UDatendi, U_Liste, USuchen,
     Vars, Versch, Views;

type
  PDatenbank = ^TDatenbank;
  TDatenbank = object (TApplication)
                 DatenDialog        : PDatenDialog;
                 SuchenDialog       : PSuchenDialog;
                 Zeige_Suchergebnis : PZeige_Suchergebnis;
                 HeapView           : PHeapView;
                 ClockView          : PClockView;

                 constructor Init;
                 procedure Idle; virtual;
                 procedure StarteDialog;
                 procedure StarteSuchen;
                 procedure HandleEvent(var Event : TEvent); virtual;
                 procedure InitStatusLine; virtual;
                 procedure InitMenuBar; virtual;
                 destructor Done; virtual;
               end;

constructor TDatenbank.Init;
var
  R : TRect;
begin
  inherited Init;
  Liste := New(PListe, Init(Dateiname));
  if Liste^.ListeLeer then
  begin
    DisableCommands([cmNaechster, cmVorheriger, cmErster, cmLetzter, cmPlus25, cmMinus25]);
    NeuerDatensatz := True;
  end
  else
  begin
    Liste^.GeheZuAnfang;
    DisableCommands([cmVorheriger, cmErster, cmMinus25]);
    if NOT Liste^.GeheVorMoeglich then
      DisableCommands([cmNaechster, cmPlus25]);
    NeuerDatensatz := False;
  end;

  R.Assign(0, 0, 80, 23);
  Zeige_Suchergebnis := New(PZeige_Suchergebnis, Init(R, 'Suchergebnis', 0));
  Zeige_Suchergebnis^.Hide;
  Application^.InsertWindow(Zeige_Suchergebnis);

  R.Assign(70, 24, 80, 25);
  HeapView := New(PHeapView, Init(R));
  Insert(HeapView);

  R.Assign(72, 0, 80, 1);
  ClockView := New(PClockView, Init(R));
  Insert(ClockView);

  SuchErgebnis := NIL;
  Filter := FilterNichts;
end;

procedure TDatenbank.Idle;
begin
  inherited Idle;
  HeapView^.Update;
  ClockView^.Update;
end;

procedure TDatenbank.InitMenuBar;
var
  R : TRect;
begin
  R.Assign(0, 0, 80, 1);
  MenuBar := New(PMenuBar, Init(R,
               NewMenu(
                 NewItem('~D~aten eingeben', '', kbNoKey, cmDatenEingeben, hcNoContext,
                 NewItem('~S~uchen', '', kbNoKey, cmSuchen, hcNoContext,
                 NewItem('~E~nde', '', kbAltX, cmQuit, hcNoContext,
                 NIL))))));
end;

procedure TDatenbank.InitStatusLine;
var
  R : TRect;
begin
  R.Assign(0, 24, 80, 25);
  StatusLine := New(PStatusLine, Init(R, NIL));
end;

procedure TDatenbank.StarteDialog;
var
  R : TRect;
begin
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y);
  Zeige_Suchergebnis^.Hide;
  Datendialog := New(PDatenDialog, Init(R, 'Datenmaske'));
  ExecuteDialog(DatenDialog, NIL);
end;

procedure TDatenbank.StarteSuchen;
var
  R : TRect;
begin
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y);

  Zeige_Suchergebnis^.Hide;
  R.Assign(0, 0, 76, 8);
  SuchenDialog := New(PSuchenDialog, Init(R, ''));
  SuchenDialog^.Options := SuchenDialog^.Options OR ofCentered;
  Application^.ExecuteDialog(SuchenDialog, NIL);
  if SuchErgebnis <> NIL then
  begin
    Dispose(SuchErgebnis, Done);
    SuchErgebnis := NIL;
  end;
  if Liste^.Suche(SuchString, Suche, SuchErgebnis) then
  begin
    Zeige_Suchergebnis^.Show;
    Zeige_Suchergebnis^.Update;
  end
  else
  begin
    Dispose(SuchErgebnis);
    SuchErgebnis := NIL;
    Zeige_Suchergebnis^.Show;
    Zeige_Suchergebnis^.Update;
  end;
end;

procedure TDatenbank.HandleEvent;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmDateneingeben : StarteDialog;
      cmSuchen        : StarteSuchen;
    end;
    ClearEvent(Event);
  end;
end;

destructor TDatenbank.Done;
begin
  Dispose(Liste, Done);
  inherited Done;
end;

var
  Datenbank : TDatenbank;

begin
  Datenbank.Init;
  Datenbank.Run;
  Datenbank.Done;
end.