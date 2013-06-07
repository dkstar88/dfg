unit ImageCacheLoader;

interface

uses Windows, Contnrs, SysUtils, Classes, GifImg, PngImage, Jpeg,
	Graphics,
  {$IFDEF USE_GR32}
  GR32, GR32_Resamplers,
  {$ELSE}
  Resample,  // Simple image resample offering
	{$ENDIF}
  ImgList;


procedure LoadGraphicCached(AFilename: String; const APicture: TPicture;
	const AWidth: Integer = 0; const AHeight: Integer = 0; const AResize: Boolean = false); overload;

procedure LoadGraphicCached(const AFilenames: array of string; AImageList: TCustomImageList;
	const AFolder: String = ''); overload;


implementation

uses Math, ThreadObjectList;

var
	fMemCache: TNamedThreadObjectList;

{$IFDEF USE_GR32}
function ResizeImage(APicture: TPicture; AMaxWidth, AMaxHeight: Integer): Boolean;
var
	oldImage, newImage: TBitmap32;
  r: TKernelResampler;
  newRect: TRect;
  newWidth, newHeight: Integer;
  bmp: TBitmap;

begin
  Result := False;
	if (APicture.Width < AMaxWidth) and (APicture.Height < AMaxHeight) then
  begin
    Exit;
  end;

	newImage := TBitmap32.Create;
  oldImage := TBitmap32.Create;
  try
    oldImage.OuterColor := $00FFFFFF;
  	oldImage.Width := APicture.Width;
    oldImage.Height := APicture.Height;
    oldImage.FillRect(0, 0, oldImage.Width, oldImage.Height, $FFFFFF);
//	  bmp := TBitmap.Create;
//    bmp.Assign(APicture.Graphic);
//    newImage.Canvas.Draw(0, 0, bmp);
//    bmp.Free;
//    CodeSite.Send('Before resize ', newImage);
//  	oldImage.Canvas.Draw(0, 0, APicture.Graphic);
//    newImage.
    try

  		oldImage.Assign(APicture);
    except

    end;
  	if oldImage.Width > oldImage.Height then
    begin
    	newWidth := Min(APicture.Width, AmaxWidth);
      newHeight := MulDiv(newWidth, oldImage.Height, oldImage.Width);
    end else
    begin
    	newWidth := Min(APicture.Height, AMaxHeight);;
      newHeight := MulDiv(newWidth, oldImage.Width, oldImage.Height);
    end;
////    newImage.BeginUpdate;
//		TKernelResampler(oldImage.Resampler).Kernel := TLanczosKernel.Create;
////    r := TLinearResampler.Create(newImage);
////    newImage.CombineMode :=
//    newImage.Draw(Rect(0, 0, newImage.Width, newImage.Height),
//    	Rect(0, 0, oldImage.Width, oldImage.Height),
//      oldImage);
////    newImage.EndUpdate;
////    newImage.Changed;
//
//
////    CodeSite.Send('Resized buffer ', newImage);
////    APicture.Graphic := nil;
////    APicture.Bitmap.Assign(newImage);


    r := TKernelResampler.Create;
    try
      r.Kernel := TLanczosKernel.Create;
	    newImage.SetSize(newWidth, newHeight);      
      StretchTransfer(newImage, Rect(0, 0, newImage.Width, newImage.Height),
        Rect(0, 0, newImage.Width, newImage.Height),
        OldImage,  Rect(0, 0, oldImage.Width, oldImage.Height),
        r, dmOpaque, nil);
    finally
      r.Free;
    end;

  	APicture.Assign(newImage);
//    CodeSite.Send('After resize ', APicture);
    Result := True;
  finally
  	oldImage.Free;
    newImage.Free;
  end;
end;
{$ELSE}
function ResizeImage(APicture: TPicture; AMaxWidth, AMaxHeight: Integer): Boolean;
var
	OldPic, NewPic: TBitmap;
	newWidth, newHeight: Integer;  
begin
	Result := False;
	NewPic := TBitmap.Create;
  OldPic := TBitmap.Create;
  try
    OldPic.Assign(APicture.Graphic);
    OldPic.PixelFormat := pf24bit;
  	if APicture.Width > APicture.Height then
    begin
    	newWidth := Min(APicture.Width, AmaxWidth);
      newHeight := MulDiv(newWidth, APicture.Height, APicture.Width);
    end else
    begin
    	newWidth := Min(APicture.Height, AMaxHeight);;
      newHeight := MulDiv(newWidth, APicture.Width, APicture.Height);
    end;
    NewPic.SetSize(newWidth, newHeight);
	  stretch(OldPic, NewPic, @Lanczos3Filter, 3);
  	APicture.Assign(NewPic);    
    Result := True;
  finally
    NewPic.Free;
    OldPic.Free;
  end;
end;
{$ENDIF}
procedure LoadGraphicCached(AFilename: String; const APicture: TPicture;
	const AWidth: Integer = 0; const AHeight: Integer = 0; const AResize: Boolean = false);
var
  fKey: String;
  fMem: TMemoryStream;
  fPicture: TPicture;
//  fGraphic: TGraphic;
//  fGraphicClass: TGraphicClass;
begin
	if fMemCache = nil then
  begin
    fMemCache := TNamedThreadObjectList.Create;
  end;
  fMemCache.Lock;
  try
    fKey := Format('%s-%d-%d', [Lowercase(AFilename), AWidth, AHeight]);
    if fMemCache.IndexOf(fKey)<0 then
    begin
//      fMem := TMemoryStream.Create;
//      fMem.LoadFromFile(AFilename);
      fPicture := TPicture.Create;
      fPicture.LoadFromFile(AFilename);

      if (fPicture.Graphic <> nil) then
      begin
        if AResize then
        begin
          ResizeImage(fPicture, AWidth, AHeight);
        end;
      end;
      APicture.Assign(fPicture);      
      fMemCache[fKey] := fPicture;
//      fGraphicClass := GetFileFormats.FindExt(fMem);
//      if Assigned(fGraphicClass) then
//     	begin
//        fGraphic := fGraphicClass.Create;
//        fGraphic.LoadFromStream(fMem);
//        fMemCache.Insert(fKey, fGraphic);
//      end;
    end else
    begin
//      CodeSite.Send(fKey + ' loaded from cache.');
      APicture.Assign(TPicture(fMemCache[fKey]));
    end;
//    APicture.Assign(fGraphic);
  finally
    fMemCache.Unlock;
  end;
end;

procedure LoadGraphicCached(const AFilenames: array of string; AImageList: TCustomImageList;
	const AFolder: String = '');
var
	i: Integer;
  filename: String;
  Pic: TPicture;
  bmp: TBItmap;
begin
	Pic := TPicture.Create;
  bmp := TBitmap.Create;
  try
    for I := Low(AFilenames) to High(AFilenames) do
    begin
      if AFolder <> '' then
        filename := AFolder + AFilenames[i]
      else
        filename := AFilenames[i];
      LoadGraphicCached(filename, Pic);
      bmp.Assign(Pic.Graphic);
      AImageList.Add(bmp, nil);
    end;
  finally
    Pic.Free;
    bmp.Free;
  end;

end;

initialization

finalization
	if fMemCache <> nil then fMemCache.Free;
  


end.
