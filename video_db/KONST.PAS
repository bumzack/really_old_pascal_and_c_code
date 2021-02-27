unit Konst;

interface

uses Objects;

const
  cmNeu        = 100;
  cmSpeichern  = 101;
  cmSuchen     = 102;
  cmEnde       = 103;
  cmNaechster  = 104;
  cmVorheriger = 105;
  cmLoeschen   = 106;
  cmFilter     = 107;
  cmZurueck       = 111;
  cmDatenEingeben = 112;
  cmErster        = 113;
  cmLetzter       = 114;
  cmMinus25       = 115;
  cmPlus25        = 116;
  cmSuchKassettennr = 108;
  cmSuchTitel       = 109;
  cmSuchDarsteller  = 110;
  cmSuchFrei        = 117;
  cmSuchLoeschen    = 118;
  cmFilterKassettennr = 119;
  cmFilterTitel       = 120;
  cmFilterDarsteller  = 121;
  cmFilterFrei        = 122;
  cmFilterLoeschen    = 123;
  cmFilterZurueck     = 124;

{$IFDEF WINDOWS}

  Dateiname           : FNameStr = 'WIN_VID.STM';

{$ELSE}

  Dateiname           : String   = 'DISK.STM';

{$ENDIF}

  cm_MacheDialog = 101;

  id_Kassnr = 101;
  id_Titel  = 102;
  id_Darsteller = 103;
  id_Datum = 104;
  id_Dauer = 105;
  id_Kasslaenge = 106;
  id_Frei = 107;
  id_Zaehlw_Start = 108;
  id_Zaehlw_Ende = 109;
  id_Film = 110;
  id_Loesche : array[0..1] of Word = (111, 112);
  id_Gattung : array[0..17] of Word = (113, 114, 115, 116, 117, 118, 119, 120, 121,
				       122, 123, 124, 125, 126, 127, 128, 129, 130);
  id_Sender : array[0..13] of Word = (131, 132, 133, 134, 155, 135, 136,
                                      137, 138, 139, 140, 141, 142, 143);
  id_Vorheriger = 144;
  id_Naechster = 145;
  id_Erster = 146;
  id_Letzter = 147;
  id_Plus25  = 153;
  id_Minus25 = 154;
  id_Neu = 148;
  id_Loeschen = 149;
  id_Speichern = 150;
  id_Filter = 151;
  id_Ende = 152;

  MaxLen = 10;


implementation

end.