uses VGAfx;

var x, y : Word;

begin
  VGA.Init(320);
  for x := 0 to 200 do
    VGA.SetPix(x, x, 215);
  ReadLn;
  VGA.SetView(100, 0);
  ReadLn;
  VGA.Done;
end.
