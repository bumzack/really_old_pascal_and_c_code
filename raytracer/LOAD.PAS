unit load;

interface

uses defs, calc;

function saveworld(w : PWorld; name : String) : Integer;
function loadworld(w : PWorld; name : String) : Integer;

implementation

{
  speichert eine Welt mit Objekten und Lampen unter Namen ab
  Output 0 : Kein Fehler
         1 : Fehler beim Speichern
}

function saveworld(w : PWorld; name : String) : Integer;
var
  fp : File;
  l  : PLamp;
  o  : PObject;
  i  : Integer;
begin
  l := w^.lamp;
  o := w^.objects;
  Assign(fp, name);
  {$I-}
  Rewrite(fp);
  {$I+}
  if IOResult = 0 then
  begin
    BlockWrite(fp, w^, SizeOf(TWorld));
    i := 0;
    while l <> NIL do
    begin
      Inc(i);
      l := l^.next;
    end;
    { Anzahl der Lampen }
    BlockWrite(fp, i, SizeOf(i));
    l := w^.lamp;
    while l <> NIL do
    begin
      BlockWrite(fp, l^, SizeOf(TLamp));
      l := l^.next;
    end;
    i := 0;
    while o <> NIL do
    begin
      Inc(i);
      o := o^.next;
    end;
    { Anzahl der Objekte }
    BlockWrite(fp, i, SizeOf(i));
    o := w^.objects;
    while o <> NIL do
    begin
      BlockWrite(fp, o^, SizeOf(TObject));

      { Texture vorhanden ? }
      if o^.text.map^ <> 0 then
        BlockWrite(fp, o^.text.map^, o^.text.x * o^.text.y * SizeOf(Byte));
      o := o^.next;
    end;
    { Und uns selbst }
    BlockWrite(fp, w^.observer, SizeOf(TObserver));

    { Noch ein paar Variablen }
    BlockWrite(fp, BackGround, SizeOf(TColor));
    BlockWrite(fp, Black, SizeOf(TColor));
    BlockWrite(fp, Ambient, SizeOf(TColor));
    BlockWrite(fp, MaxDepth, SizeOf(Word));
    BlockWrite(fp, amb, SizeOf(Real));

    Close(fp);
    saveworld := 0;
    Exit;
  end;
  saveworld := 1;
end;

function loadworld(w : PWorld; name : String) : Integer;
var
  fp : File;
  l, l1 : PLamp;
  o, o1 : PObject;
  i     : Integer;
begin
  l := w^.lamp;
  o := w^.objects;
  while l <> NIL do
  begin
    l1 := l;
    l := l^.next;
    FreeMem(l1, SizeOf(TLamp));
  end;
  while o <> NIL do
  begin
    o1 := o;
    if (o^.text.map <> NIL) AND (o^.text.x <> 0) AND
       (o^.text.y <> 0) then
      FreeMem(o^.text.map, o^.text.x * o^.text.y);
    o := o^.next;
    FreeMem(o1, SizeOf(TObject));
  end;

  if w^.observer <> NIL then
    FreeMem(w^.observer, SizeOf(TObserver));
  w^.lamp := NIL;
  w^.objects := NIL;
  w^.observer := NIL;

  { Datei ”ffnen }
  Assign(fp, name);
  {$I-}
  Reset(fp);
  {$I+}
  if IOResult = 0 then
  begin
    BlockRead(fp, w^, SizeOf(TWorld));
    { Anzahl der Lampen }
    BlockRead(fp, i, SizeOf(i));
    l1 := NIL;
    while i <> 0 do
    begin
      Dec(i);
      GetMem(l, SizeOf(TLamp));
      if l = NIL then
      begin
        Close(fp);
        loadworld := 2;
        Exit;
      end;
      if l1 <> NIL then
        l1^.next := l
      else
        w^.lamp := l;
      BlockRead(fp, l, SizeOf(TLamp));
      l1 := l;
    end;
    { Anzahl der Objekte }
    BlockRead(fp, i, SizeOf(i));
    o1 := o;
    while i <> 0 do
    begin
      Dec(i);
      GetMem(o, SizeOf(TObject));
      if o = NIL then
      begin
        Close(fp);
        loadworld := 2;
        Exit;
      end;
      if o1 <> NIL then
        o1^.next := o
      else
        w^.objects := o;

      BlockRead(fp, o^, SizeOf(TObject));
      if (o^.text.map <> NIL) AND (o^.text.x <> 0) AND (o^.text.y <> 0) then
      begin
        GetMem(o^.text.map, SizeOf(Byte) * o^.text.x * o^.text.y);
        if o^.text.map = NIL then
        begin
          o^.text.x := 0;
          o^.text.y := 0;
          o^.text.map := NIL;
          GetMem(w^.observer, SizeOf(TObserver));
          Close(fp);
          loadworld := 2;
          Exit;
        end;
        BlockRead(fp, o^.text.map^, SizeOf(Byte) * o^.text.x * o^.text.y);
      end;
      o1 := o;
    end;
    { und uns selbst }
    GetMem(w^.observer, SizeOf(TObserver));
    if w^.observer = NIL then
    begin
      Close(fp);
      loadworld := 2;
      Exit;
    end;
    BlockRead(fp, w^.observer, SizeOf(TObserver));
    { Noch ein paar Variablen }
    BlockRead(fp, BackGround, SizeOf(TColor));
    BlockRead(fp, Black, SizeOf(TColor));
    BlockRead(fp, Ambient, SizeOf(TColor));
    BlockRead(fp, MaxDepth, SizeOf(Word));
    BlockRead(fp, amb, SizeOf(Real));
    Close(fp);
    loadworld := 0;                    { Kein Fehler }
    Exit;
  end;
  GetMem(w^.observer, SizeOf(TObserver));
  loadworld := -1;                     { Fehler }
end;
end.