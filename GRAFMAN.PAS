
{ ---------------------------------------------------
		Graphics Manager
    Copyright (r) by E-Port Software Team
    Version : 4.0   	Author : William Yang
		Last Update 			1 - Oct - 98
  --------------------------------------------------- }

unit GrafMan;

interface

uses Windows, SysUtils, Graphics, Classes, ColorMan, ExtCtrls, Forms,
	Drawman, NumMan;

{ *************************************************************************
	There is a small bug in this unit.
	Becase I used a internal variable for each function that returns
	a TBitmap object, which means if you are going to add another function
	you must not cross use this variable.
	I mean you cannot use in one of the function and not yet wait until it is finished
	call another function in this unit.
  _________________________________________________________________________ }

type
	EBitmapOperationError = Exception;

procedure ColoriseImage(Bmp : TBitmap; BaseColor : TColor);
procedure MergeBMP(Pic1, Pic2 : TBitmap);
procedure SoftenBMP(Src : TBitmap);
procedure GreyBMP(Src : TBitmap);
procedure BWOnlyBMP(Src : TBitmap);
procedure DarkenBMP(Bmp : TBitmap; Grade : Integer);
procedure BrightenBMP(Bmp : TBitmap; Grade : Integer);
procedure MergeBMPExt(Pic1, Pic2 : TBitmap; Grade: Byte);
function BMPFromRes(ResName: String) : TBitmap;
function ResizeBMP(Src: TBitmap; Width, Height: Integer): TBitmap;
function LoadBMPFile(Filename: String): TBitmap;
function DisabledBmp(Src: TBitmap; DisabledColor, FaceColor: TColor): TBitmap;
function CreatePattern(Color1, Color2: TColor ): TBitmap;
function BmpToLCD(Src: TBitmap; ForeColor, Backcolor: TColor): TBitmap;

implementation

var
	TmpMem : TBitmap;

function CreatePattern(Color1, Color2: TColor ): TBitmap;
var
  X, Y: Integer;
begin
  TmpMem.Width := 8;
  TmpMem.Height := 8;
  with TmpMem.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Color1;
    FillRect(Rect(0, 0, TmpMem.Width, TmpMem.Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then  { toggles between even/odd pixles }
          Pixels[X, Y] := Color2;    { on even/odd rows }
  end;
  Result := TmpMem;
end;

function BmpToLCD(Src: TBitmap; ForeColor, Backcolor: TColor): TBitmap;
var
	x, y: Integer;
begin
  TmpMem.Width := Src.Width*4;
  TmpMem.Height := Src.Height*4;
  with TmpMem.Canvas do
  begin
  	Brush.Color := BackColor;
    Brush.Style := bsSolid;
  	FillRect(Rect(0, 0, TmpMem.Width, TmpMem.Height));
    Brush.Color := ForeColor;
    Pen.Color := MergeColor(ForeColor, BackColor);
		for x := 0 to Src.Width do
			for y := 0 to Src.Height do
      begin
      	if not IsLightColor(Src.Canvas.Pixels[x, y]) then
        begin
					Rectangle(x*3+1, y*3+1, x*3+3, y*3+3);
        end
      end;
  end;
  Result := TmpMem;
end;

function LoadBMPFile(Filename: String): TBitmap;
begin
	TmpMem.LoadFromFile(Filename);
	Result := TmpMem;
end;

function DisabledBmp(Src: TBitmap; DisabledColor, FaceColor: TColor): TBitmap;
var
	i, j : Integer;
  Pattern: TBitmap;
	x, y : Integer;
begin
	Pattern := TBitmap.Create;
  Pattern := CreatePattern(DisabledColor, FaceColor);
	TmpMem.Assign(Src);

  if (Src.Width = 0) or (Src.Height=0) then Exit;
	x := 0; y := 0;
	while (y < Src.Height) and (x < Src.Width) do
  begin
    TransparentBlt(TmpMem.Canvas, Pattern, x, y, FaceColor);
    Inc(x, 8);
    if x >= Src.Width then
    begin
      x := 0;
      Inc(y, 8);
    end;
  end;

  Pattern.Free;
end;

function ResizeBMP(Src: TBitmap; Width, Height: Integer): TBitmap;
var
	DR, SR: TRect;
begin
	DR := Rect(0, 0, Width, Height);
  SR := Rect(0, 0, Src.Width, Src.Height);
  TmpMem.Width := Width;
  TmpMem.Height := Height;
  TmpMem.Canvas.CopyRect(DR, Src.Canvas, SR);
  Result := TmpMem;
end;

function BMPFromRes(ResName: String) : TBitmap;
begin
	TmpMem.LoadFromResourceName(HINSTANCE, PChar(UpperCase(ResName)));
	Result := TmpMem;
end;

procedure BrightenBMP(Bmp : TBitmap; Grade : Integer);
var
  i, j : Integer;
  p: PRGBArray;
begin
	if Bmp.PixelFormat <> pf24Bit then
	begin
    EBitmapOperationError.Create('Only 24 bit bitmaps can be operated.');
  end;
  for i := 0 to Bmp.Height-1 do
  begin
    P := Bmp.Scanline[i];
  	for j := 0 to Bmp.Width-1 do
    begin
    	P[j] := IntToRGB(BrightenColor(RGBToInt(P[j]), Grade));
    end;
  end;
end;

procedure DarkenBMP(Bmp : TBitmap; Grade : Integer);
var
  i, j : Integer;
  p: PRGBArray;
begin
	if Bmp.PixelFormat <> pf24Bit then
	begin
    EBitmapOperationError.Create('Only 24 bit bitmaps can be operated.');
  end;
  for i := 0 to Bmp.Height-1 do
  begin
    P := Bmp.Scanline[i];
  	for j := 0 to Bmp.Width-1 do
    begin
    	P[j] := IntToRGB(DarkenColor(RGBToInt(P[j]), Grade));
    end;
  end;
end;

procedure BWOnlyBMP(Src : TBitmap);
begin
  Src.Monochrome := True;
  Src.Monochrome := False;
end;

procedure GreyBMP(Src : TBitmap);
var
  i, j : Integer;
  p: PRGBArray;
begin
	if Src.PixelFormat <> pf24Bit then
	begin
    EBitmapOperationError.Create('Only 24 bit bitmaps can be operated.');
  end;
  for i := 0 to Src.Height-1 do
  begin
    P := Src.Scanline[i];
  	for j := 0 to Src.Width-1 do
    begin
    	P[j] := IntToRGB(ColorToGrey(RGBToInt(P[j])));
    end;
  end;
end;

procedure MergeBMP(Pic1, Pic2 : TBitmap);
begin
	MergeBMPExt(Pic1, Pic2, 50);
end;

procedure MergeBMPExt(Pic1, Pic2 : TBitmap; Grade: Byte);
var
  i, j : Integer;
  p1, p2: PRGBArray;
begin
	if (Pic1.PixelFormat <> pf24Bit) or (Pic2.PixelFormat <> pf24Bit) then
	begin
    EBitmapOperationError.Create('Only 24 bit bitmaps can be operated.');
  end;
  for i := 0 to Pic1.Height-1 do
  begin
    P1 := Pic1.Scanline[i];
    P2 := Pic2.Scanline[i];
  	for j := 0 to Pic1.Width-1 do
    begin
    	P1[j] := IntToRGB(MergeColorExt(RGBToInt(P1[j]), RGBToInt(P2[j]) ,Grade));
    end;
  end;
end;

procedure SoftenBMP(Src : TBitmap);
var
  SumR, SumG, SumB, i, j, k, l : Integer;
  P, G, G1: PRGBArray;
begin
  for i := 1 to Src.Height-2 do
  begin
  	P := Src.Scanline[i];
    G := Src.Scanline[i+1];
    G1 := Src.Scanline[i-1];
  	for j := 1 to Src.Width-2 do
    begin
      SumR := P[j][2] + P[j+1][2] + P[j-1][2] + G[j][2] + G1[j][2];
      SumG := P[j][1] + P[j+1][1] + P[j-1][1] + G[j][1] + G1[j][1];
      SumB := P[j][0] + P[j+1][0] + P[j-1][0] + G[j][0] + G1[j][0];
    	P[j] := IntToRGB(ERGB(SumR/5, SumG/5, SumB/5));
    end;
  end;
end;

procedure ColoriseImage(Bmp : TBitmap; BaseColor : TColor);
var
  i, j : Integer;
  p: PRGBArray;
begin
	if Bmp.PixelFormat <> pf24Bit then
	begin
    EBitmapOperationError.Create('Only 24 bit bitmaps can be operated.');
  end;
  for i := 0 to Bmp.Height-1 do
  begin
    P := Bmp.Scanline[i];
  	for j := 0 to Bmp.Width-1 do
    begin
    	P[j] := IntToRGB(Colorise(RGBToInt(P[j]), BaseColor));
    end;
  end;
end;

initialization
	TmpMem := TBitmap.Create;

finalization
	TmpMem.Free;


end.


