unit Schalter;

interface

uses Crt, Dos, UGraph, Vid, Maus;

type str80 = String[80];

type PSchalter = ^TSchalter;
     TSchalter = record
                   next : PSchalter;
                   left : Integer;
                   top : Integer;
                   right : Integer;
                   bottom : Integer;
                   framecol, col, ilucol : Word;
                   backcol               : Word;
                   msg    : String;
                 end;

function TestSch(x, y : Word; sch : PSchalter; sha : PSchalter) : Word;
procedure print(str : String; co : Word);
procedure printnum(nr : Word);
procedure getstr(var str : str80);
procedure showsch(sch : PSchalter);

implementation

{
  ÅberprÅft ob an STelle x, y ein Schalter ist und gibt ihn gegebenfalls
  in sha zurÅck
}

function TestSch(x, y : Word; sch : PSchalter; sha : PSchalter) : Word;
var
  i : Integer;
  s : PSchalter;
begin
  s := sch;
  i := 1;
  while s <> NIL do
  begin
    if (x >= s^.left) AND
       (x <= s^.right) AND
       (y >= s^.top) AND
       (y <= s^.bottom) then
    begin
      if (s^.backcol <> 0) then
      begin
        mouse_hide;
        drawtangle(s^.left, s^.top, s^.right, s^.bottom, s^.ilucol);
        if s^.backcol = 1 then
        begin
          Delay(100);
          drawtangle(s^.left, s^.top, s^.right, s^.bottom, s^.framecol);
        end;
        mouse_show;
      end;
      sha := s;
      TestSch := i;
      Exit;
    end;
    Inc(i);
    s := s^.next;
  end;
  TestSch := 0;
end;

{
  gibt String im Grafikmodus in der Farbe co aus
}

procedure print(str : String; co : Word);
var
  Regs : Registers;
  i    : Integer;
begin
  for i := 1 to Length(str) do
  begin
    Regs.ah := $09;
    Regs.al := Ord(str[i]);
    Regs.bl := co;
    Regs.cx := 1;
    Intr($10, Regs);
    GotoXY(WhereX + 1, WhereY);
  end;
end;

{
  holt String vom Benutzer im Grafikmodus
}

procedure getstr(var str : str80);
var
  ch : String[2];
begin
  ch[2] := #0;
  repeat
    ch[1] := ReadKey;
    case ch[1] of
      #13: break;
      #10: break;
      #8 : begin
             Dec(str[0]);
             GotoXY(WhereX - 1, WhereY);
             print(' ', 215);
             GotoXY(WhereX - 1, WhereY);
           end;
    else
    begin
      print(ch, 215);
      Inc(str[0]);
      str[Ord(str[0])] := ch[1];
    end;
    end;
  until ch[1] = #13;
end;

procedure printnum(nr : Word);
var
  st : String[10];
begin
  Str(nr, st);
  print(st, 215);
end;

procedure showsch(sch : PSchalter);
var
  s : PSchalter;
begin
  s := sch;
  while s <> NIL do
  begin
    drawtangle(s^.left, s^.top, s^.right, s^.bottom, s^.framecol);
    fill(s^.left + 1, s^.top + 1, s^.col);
    if s^.msg <> '' then
    begin
      GotoXY(s^.left DIV 8 + 2, s^.top DIV 8 + 2);
      print(s^.msg, 215);
    end;
    s := s^.next;
  end;
end;
end.