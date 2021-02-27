uses Strukt, U_Liste;

var
  Liste : PListe;
  f     : Text;
  a     : TFilm;
  s     : String;
  i     : Integer;
begin
  Liste := New(PListe, Init('DISK.STM'));
  Assign(f, 'DISK.TXT');
  Rewrite(f);
  Liste^.GeheZuAnfang;
  while NOT Liste^.IstLetztes do
  begin
    Liste^.GibAktuelles(a);
    Write(f, a.Kassettennr : 4);
    s := '';
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
    Liste^.GeheVor;
  end;
  Close(f);
  Dispose(Liste, Done);
end.