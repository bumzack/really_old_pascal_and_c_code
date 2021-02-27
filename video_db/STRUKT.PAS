unit Strukt;

interface

type
  PFilm = ^TFilm;
  TFilm = record
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
          end;

  TTransferRecordDOS = record
                         Kassettennr : String[5];
                         Titel       : String[250];
                         Darsteller  : String[250];
                         Datum       : String[8];
                         Filmlaenge  : String[5];
                         Gesamtlaenge  : String[5];
                         Zaehlwerk_von : String[5];
                         Zaehlwerk_bis : String[5];
                         Loeschen      : Word;
                         Gattung       : Word;
                         Sender        : Word;
                         Frei          : String[5];
                         Wievielter_Film : String[5];
                       end;

  PTransferRecordWIN = ^TTransferRecordWIN;
  TTransferRecordWIN = record
                         Kassettennr     : array[0..6] of Char;
                         Titel           : array[0..251] of Char;
                         Darsteller      : array[0..251] of Char;
                         Datum           : array[0..9] of Char;
                         Filmlaenge      : array[0..6] of Char;
                         Gesamtlaenge    : array[0..6] of Char;
                         Zaehlwerk_von   : array[0..6] of Char;
                         Zaehlwerk_bis   : array[0..6] of Char;
                         Loeschen        : array[0..2] of Word;
                         Gattung         : array[0..18] of Word;
                         Sender          : array[0..14] of Word;
                       end;

type
  SortTyp = (SortKassettennr);

type
  SuchTyp = (SuchNichts, SuchFrei, SuchDarsteller, SuchLoeschen, SuchTitel, SuchKassettennr);

type
  FilterTyp = (FilterNichts, FilterFrei, FilterDarsteller, FilterLoeschen, FilterTitel, FilterKassettennr);

implementation

end.