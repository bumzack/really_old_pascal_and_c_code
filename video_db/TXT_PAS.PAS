uses Strukt, U_Liste;

procedure aa(var s : String);
var
  i : Byte;
begin
  if s[1] = #32 then
    while (s[1] = #32) AND (Length(s) > 0) do
      Delete(s, 1, 1);
  i := Length(s);
  if s[i] = #32 then
    while (s[i] = #32) AND (Length(s) > 0) do
    begin
      Delete(s, i, 1);
      Dec(i);
    end;
end;

var
  Liste : PListe;
  f     : Text;
  a     : TFilm;
  s     : String;
  s1    : String;
  i     : Integer;
  j     : Integer;
begin
  Liste := New(PListe, Init(''));
  Assign(f, 'DISK2.TXT');
  Reset(f);
  while NOT EoF(f) do
  begin
    Read(f, s);
    s1 := Copy(s, 1, 4);
    Val(s1, a.Kassettennr, i);
    Delete(s, 1, 4);

    a.Titel := Copy(s, 1, 250);
    {Copy(s, 1, 251);
    Delete(s, 1, 251);
    }
    s1 := a.Titel;
    aa(s1);
    a.Titel := s1;

    Read(f, s);
    Delete(s, 1, 3);

    a.Darsteller := Copy(s, 1, 250);
    Delete(s, 1, 250);
    s1 := a.Darsteller;
    aa(s1);
    a.Darsteller := s1;

    ReadLn(f, s);
    Delete(s, 1, 4);
    a.Datum := Copy(s, 1, 10);

    Delete(s, 1, 10);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Filmlaenge, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Zaehlwerk_von, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Zaehlwerk_bis, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Sender, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Gattung, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Gesamtlaenge, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Frei, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    if s1 = 'TRUE' then
      a.Loeschen := True
    else
      a.Loeschen := False;
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Gesamtfilme, i);
    Delete(s, 1, 7);

    s1 := Copy(s, 1, 7);
    aa(s1);
    Val(s1, a.Wievielter_Film, i);
    Delete(s, 1, 7);
    {

    for i := 1 to 250 - Length(a.Titel) do
      s := s + ' ';
    Write(f, a.Titel + s + '    ');
    s := '';
    for i := 1 to 250 - Length(a.Darsteller) do
      s := s + ' ';
    Write(f, a.Darsteller + s + '    ');
    WriteLn(f, a.Datum : 10, '   ',
               a.Filmlaenge : 4, '   ',
               a.Zaehlwerk_von : 4, '   ',
               a.Zaehlwerk_bis : 4, '   ',
               a.Sender : 4, '   ',
               a.Gattung : 4, '   ',
               a.Gesamtlaenge : 4, '   ',
               a.Frei : 4, '   ',
               a.loeschen : 4, '   ',
               a.Gesamtfilme : 4, '   ',
               a.Wievielter_Film: 4, '   ');
    }
    Liste^.SortiereEin(a);
  end;
  Liste^.SpeichereListe('DISK.STM');
  Close(f);
  Dispose(Liste, Done);
end.