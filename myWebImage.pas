unit myWebImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  {$ifdef _csdbg_}
  CodeSiteLogging,
  {$endif}
    Forms, GifImg, PngImage, ImageCacheLoader;

type
  TMyWebImageChecked = procedure (ASender: TObject; var AChecked: Boolean) of object;
  TmyWebImage = class(TGraphicControl)
  private
    FOverImage: TPicture;
    FDownImage: TPicture;
    FImage: TPicture;
    fStatus: Integer;
    fAutosize: Boolean;
    fChecked: Boolean;
    fCheckGroup: Integer;
    fDisableImage: TPicture;
    fTransparent: Boolean;
    fAllowAllUp: Boolean;
    fPushOffset: Integer;
    fOnChecked: TMyWebImageChecked;
    FCaption: String;
    FOverFont: TFont;
    FDownFont: TFont;
    FColor: TColor;
    FCaptionOffset: TPoint;
    FCaptionOffsetY: Integer;
    FCaptionOffsetX: Integer;
    FCheckedImage: TPicture;
    FCheckedFont: TFont;
    FGlyphAlignment: TAlign;
    FGlyph: TPicture;
    FSpace: Integer;
    FDisabledFont: TFont;
    procedure SetDownImage(const Value: TPicture);
    procedure SetImage(const Value: TPicture);
    procedure SetOverImage(const Value: TPicture);
    procedure SetAutosize(const Value: Boolean);
    procedure SetDisableImage(const Value: TPicture);
    procedure SetChecked(const Value: Boolean);
    procedure CMButtonPressed(var Message: TMessage); message CM_ButtonPressed;
    procedure UpdateExclusive;
    procedure SetOnChecked(const Value: TMyWebImageChecked);
    procedure SetCaption(const Value: String);
    procedure SetDownFont(const Value: TFont);
    procedure SetOverFont(const Value: TFont);
    procedure SetColor(const Value: TColor);
    procedure SetCaptionOffsetX(const Value: Integer);
    procedure SetCaptionOffsetY(const Value: Integer);
    procedure LoadImages(APath, ANormal, AOver, ADown, ADisabled: string); overload;
    procedure SetCheckedImage(const Value: TPicture);
    procedure SetCheckedFont(const Value: TFont);
    procedure SetGlyph(const Value: TPicture);
    procedure SetGlyphAlignment(const Value: TAlign);
    procedure SetSpace(const Value: Integer);
    procedure SetDisabledFont(const Value: TFont);

//    procedure SetCheckGroup(const Value: Integer);
    { Private declarations }
  protected
    { Protected declarations }
    procedure EraseBackground(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND; 

    procedure MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer); override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MsgMouseEnter(var Message: TMessage); message CM_MouseEnter;
    procedure MsgMouseLeave(var Message: TMessage); message CM_MouseLeave;

    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(Aowner: TComponent); override;
    destructor Destroy; override;

    procedure LoadImages(APath, ANormal, AOver, ADown: string); overload;
    procedure LoadImages(APath, ANormal: String); overload;

    procedure LoadImagesFromRes(ANormal: String; ResType: PChar); overload;
    procedure LoadImagesFromRes(ANormal: String); overload;

  published
    { Published declarations }
//    property AutoSize: Boolean read fAutosize write SetAutosize;
    property Image: TPicture read FImage write SetImage;
    property DownImage: TPicture read FDownImage write SetDownImage;
    property OverImage: TPicture read FOverImage write SetOverImage;
    property CheckedImage: TPicture read FCheckedImage write SetCheckedImage;
    property Checked: Boolean read fChecked write SetChecked;
    property CheckGroup: Integer read fCheckGroup write fCheckGroup;
    property DisableImage: TPicture read fDisableImage write SetDisableImage;
    property Transparent: Boolean read fTransparent write fTransparent;
    property AllowAllUp: Boolean read fAllowAllUp write fAllowAllUp;
    property PushOffset: Integer read fPushOffset write fPushOffset;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;

    property OnChecked: TMyWebImageChecked read fOnChecked write SetOnChecked;

    property Font;
    property OverFont: TFont read FOverFont write SetOverFont;
    property DisabledFont: TFont read FDisabledFont write SetDisabledFont;
    property DownFont: TFont read FDownFont write SetDownFont;
    property CheckedFont: TFont read FCheckedFont write SetCheckedFont;
    property Glyph: TPicture read FGlyph write SetGlyph;
    property GlyphAlignment: TAlign read FGlyphAlignment write SetGlyphAlignment;
    property Space: Integer read FSpace write SetSpace;
    property Caption: String read FCaption write SetCaption;
    property Color: TColor read FColor write SetColor;
    property CaptionOffsetX: Integer read FCaptionOffsetX write SetCaptionOffsetX;
    property CaptionOffsetY: Integer read FCaptionOffsetY write SetCaptionOffsetY;

    property Align;
    property Anchors;

    property Visible;
    property Enabled;
    property PopupMenu;
    property ShowHint;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;


  end;

procedure GraphicLoadRC(fPicture: TPicture; AResName: String; AResType: PChar);  

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Grafix', [TmyWebImage]);
end;

procedure GraphicLoadRC(fPicture: TPicture; AResName: String; AResType: PChar);
var
  resStream: TResourceStream;
  imgGif: TGifImage;
begin
  if FindResource(HInstance, PChar(AResName), AResType)<>0 then
  begin
    resStream := TResourceStream.Create(HInstance, AResName, AResType);
    try
      imgGif := TGifImage.Create;
      imgGif.LoadFromStream(resStream);
      fPicture.Assign(imgGif);
      imgGif.Free;
    finally
      resStream.Free;
    end;
  end;
end;


{ TmyWebImage }
constructor TmyWebImage.Create(Aowner: TComponent);
begin
	inherited Create(AOwner);
  fOverImage := TPicture.Create;
  fDownImage := TPicture.Create;
  fDisableImage := TPicture.Create;
  FCheckedImage := TPicture.Create;
  FCheckedFont := TFont.Create;
  FGlyph := TPicture.Create;
	FGlyphAlignment := alTop;
  FOverFont := TFont.Create;
  FDownFont := TFont.Create;
  FDisabledFont := TFont.Create;  
  fImage := TPicture.Create;
  fStatus := 0;
  fAutoSize := True;
  FCaptionOffsetX := 0;
  FCaptionOffsetY := 0;
  FSpace := 2;
end;

destructor TmyWebImage.Destroy;
begin
	fDownImage.Free;
	fOverImage.Free;
	fImage.Free;
  fDisableImage.Free;
  FOverFont.Free;
  FDisabledFont.Free;
  FDownFont.Free;
	inherited Destroy;
end;

procedure TmyWebImage.EraseBackground(var Msg: TWMEraseBkgnd);
begin
//  Msg.Result := 1;
end;

procedure TmyWebImage.LoadImages(APath, ANormal: String);
var
  ext: String;
begin
  ext := ExtractFileExt(ANormal);
  LoadImages(APath, ANormal,
    ChangeFileExt(ANormal, '-Over' + Ext),
    ChangeFileExt(ANormal, '-Down' + Ext),
    ChangeFileExt(ANormal, '-Disabled' + Ext)
    );
end;

procedure TmyWebImage.LoadImagesFromRes(ANormal: String);
begin
  LoadImagesFromRes(ANormal, RT_RCDATA);
end;

procedure TmyWebImage.LoadImagesFromRes(ANormal: String; ResType: PChar);
begin
  GraphicLoadRC(fImage, ANormal, ResType);
  GraphicLoadRC(FOverImage, ANormal+'_OVER', ResType);
  GraphicLoadRC(fDownImage, ANormal+'_DOWN', ResType);
  GraphicLoadRC(fDisableImage, ANormal+'_DISABLED', ResType);
  Setbounds(Left, Top, fImage.Width, fImage.Height);  
end;

procedure TmyWebImage.LoadImages(APath, ANormal, AOver, ADown: string);
begin
  if FileExists(APath + ANormal) then
	  LoadGraphicCached(APath + ANormal, fImage);
  if FileExists(APath + AOver) then
	  LoadGraphicCached(APath + AOver, FOverImage);  
  if FileExists(APath + ADown) then
	  LoadGraphicCached(APath + ADown, fDownImage);  
  Setbounds(Left, Top, fImage.Width, fImage.Height);
end;

procedure TmyWebImage.LoadImages(APath, ANormal, AOver, ADown, ADisabled: string);
begin
	LoadImages( APath, ANormal, AOver, ADown );
//  if FileExists(APath + ANormal) then
//	  LoadGraphicCached(APath + ANormal, fImage);
//  if FileExists(APath + AOver) then
//	  LoadGraphicCached(APath + AOver, FOverImage);  
//  if FileExists(APath + ADown) then
//	  LoadGraphicCached(APath + ADown, fDownImage);  
  if FileExists(APath + ADisabled) then
	  LoadGraphicCached(APath + ADisabled, fDisableImage);  
//  Setbounds(Left, Top, fImage.Width, fImage.Height);
end;


procedure TmyWebImage.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (fCheckGroup <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := fCheckGroup;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

procedure TmyWebImage.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
	if (Enabled) or (not Checked) then
    if Button = mbLeft then
    begin
      fStatus := 2;
      Paint;
    end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TmyWebImage.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
	if (Enabled) or (not Checked) then
    if fStatus = 2 then
    begin
      fStatus := 0;
      if fCheckGroup <> 0 then Checked := not fChecked;
      if fChecked then
      begin
        if Assigned(fOnChecked) then fOnChecked(Self, fChecked);
      end;
      Paint;
    end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TmyWebImage.MsgMouseEnter(var Message: TMessage);
begin
  if (not Enabled) or (Checked) then Exit;
	if fStatus = 0 then
  begin
  	fStatus := 1;
		RePaint;
  end;
end;

procedure TmyWebImage.MsgMouseLeave(var Message: TMessage);
begin
  if (not Enabled) or (Checked) then Exit;
	if fStatus = 1 then
  begin
  	fStatus := 0;
  	RePaint;
  end;
end;

procedure TmyWebImage.Paint;
var
  fbuff: TBitmap;
  fBufCanvas: TCanvas;
  txtWidth, txtHeight,
  gWidth, gHeight: Integer;
  // Content XY
  cx, cy: Integer;
  tx, ty: Integer;
  
  procedure DrawGlyph;
  var
  	gx, gy: Integer;
  begin
  	if fGlyph.Graphic=nil then
    begin
			Exit;
    end;
  	case fGlyphAlignment of
    alTop:
      begin
        gx := (Width - gWidth) div 2;
        gy := cy;
        tx := (Width - txtWidth) div 2;
        ty := cy + Space + gHeight;
      end;
    alLeft:
      begin
        gx := cx; gy := (Height - gHeight) div 2;
        tx := cx + gWidth + Space;
        ty := (Height - txtHeight) div 2;
      end;
    alBottom:
      begin
        gx := (Width - gWidth) div 2; gy := cy+txtHeight+Space;
        tx := (Width - txtWidth) div 2;
        ty := cy;
      end;
    alRight:
      begin
        gx := cx+Space+txtWidth; gy := (Height - gHeight) div 2;
        tx := cx;
        ty := (Height - txtHeight) div 2;
      end;
    end;
    fBufCanvas.Brush.Style := bsClear;
//  	if fGlyph.Graphic is TPNGGraphic then
    
    fBufCanvas.Draw(gx, gy, fGlyph.Graphic);
  end;

	procedure DrawUp;
  var
  	x, y: Integer;
  begin
  	if fImage.Graphic <> nil then
		begin
    	x := 0; y := 0;
	    if Enabled then
        fBufCanvas.Draw(x, y, fImage.Graphic)
	    else
        fBufCanvas.Draw(x, y, fDisableImage.Graphic);
//			repeat
//	      fBufCanvas.Draw(x, y, fImage.Graphic);
//        Inc(x, fImage.Graphic.Width);
//        if x > Width+fImage.Graphic.Width then
//        begin
//          x := 0;
//          Inc(y, fImage.Graphic.Height);
//        end;
//      until (y>=Height)
    end;
  end;

  procedure DrawDown;
  begin
  	if fDownImage.Graphic <> nil then
			fBufCanvas.Draw(0, 0, fDownImage.Graphic)
    else
		begin
      DrawUp;
    end;
  end;

  procedure DrawOver;
  begin
  	if fOverImage.Graphic <> nil then
			fBufCanvas.Draw(0, 0, fOverImage.Graphic)
    else
		begin
      DrawUp;
    end;
  end;


	procedure DrawChecked;
  begin
  	if fCheckedImage.Graphic <> nil then
			fBufCanvas.Draw(0, 0, fCheckedImage.Graphic)
    else
		begin
      DrawOver;
    end;
  end;  

var
  x,y: Integer;  
begin


  if (Width=0) then Exit;
  if (Canvas = nil) then Exit;
  

  if fTransparent then
  begin

    if fDownImage.Graphic <> nil then
      fDownImage.Graphic.Transparent := fTransparent;

    if fOverImage.Graphic <> nil then
      fOverImage.Graphic.Transparent := fTransparent;

    if fImage.Graphic <> nil then
      fImage.Graphic.Transparent := fTransparent;
  end;

  fBuff := TBitmap.Create;
  try
    fBuff.Width := Width;
    fBuff.Height := Height;
    fBuff.Canvas.CopyRect(Rect(0, 0, Width, Height), Self.Canvas, Rect(0, 0, Width, Height));
    fBufCanvas := fBuff.Canvas;

    if fTransparent then
    begin

    end;

    if fImage.Graphic <> nil then
    begin

      case fStatus of
      0: if fChecked then DrawChecked else DrawUp;
      2: DrawDown;
      1: DrawOver;
      end;

      if Enabled then
      begin
      	// test code
        {$ifdef _csdbg_}
      	if Caption = '»»√≈' then
        begin
        	CodeSite.Send( 'ReMen button checked', FChecked );
        	CodeSite.Send( 'ReMen button CheckedFont', FCheckedFont );
        end;
        {$endif}
        case fStatus of
          0: if fChecked then fBufCanvas.Font.Assign(fCheckedFont) else fBufCanvas.Font.Assign(Font);
          2: fBufCanvas.Font.Assign(fDownFont);
          1: fBufCanvas.Font.Assign(fOverFont);
        end;
      end else
      begin
        fBufCanvas.Font.Assign(fDisabledFont);
      end;
      txtHeight := fBufCanvas.TextHeight(fCaption);
      txtWidth := fBufCanvas.TextWidth(fCaption);
      gWidth := Glyph.Width;
      gHeight := Glyph.Height;

    	cx := (Width - gWidth - txtWidth) div 2 + FCaptionOffsetX;
      cy := (Height - gHeight- txtHeight) div 2 + FCaptionOffsetY;

      if Glyph.Graphic <> nil then
      begin
        DrawGlyph;
      end else
      begin
        tx := cx;
        ty := cy;
      end;

      if fCaption <> '' then
      begin
//        y := (Height - fCanvas.TextHeight('Wg')) div 2 + FCaptionOffsetY;
//        x := (Width - fCanvas.TextWidth(fCaption)) div 2 + FCaptionOffsetX;
//        tx := tx + FCaptionOffsetX;
//        ty := ty +  FCaptionOffsetY;
        fBufCanvas.Brush.Style := bsClear;
        fBufCanvas.TextOut(tx, ty, fCaption);
      end;

      if fBuff <> nil then
      begin
        Canvas.Draw(0, 0, fBuff);
      end;
    

    end
    else
    begin
      if csDesigning in ComponentState then
      begin
        Canvas.Pen.Style := psDash;
        Canvas.Pen.Color := clWhite;
        Canvas.Brush.Color := clGray;
        Canvas.Rectangle(0, 0, Width, Height);
        Canvas.TextOut(2,2,'(TmyWebImage)');
      end;
    end;
  finally
    fBuff.Free;
  end;
end;

procedure TmyWebImage.SetDisabledFont(const Value: TFont);
begin
  FDisabledFont.Assign(Value);
end;

procedure TmyWebImage.SetDisableImage(const Value: TPicture);
begin
  if fDisableImage <> Value then
  begin
  	fDisableImage.Assign(Value);
    if not Enabled then Repaint;
  end;
end;

procedure TmyWebImage.CMButtonPressed(var Message: TMessage);
var
  Sender: TmyWebImage;
  Comp: TmyWebImage;
  i: Integer;
  OneChecked: Boolean;
begin
  if not Enabled then Exit;
  
	OneChecked := False;
  if Message.WParam = fCheckGroup then
  begin
    Sender := TmyWebImage(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Checked and (fChecked) then
      begin
        fChecked := False;
        fStatus := 0;
        Repaint;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end else if not fAllowAllUp then
    begin
      if Parent <> nil then
	    	for i := 0 to Parent.ControlCount-1 do
    		begin
        	Comp := TmyWebImage(Parent.Controls[i]);
          if Comp <> nil then
          begin
        		OneChecked := OneChecked and Comp.Checked;
            if OneChecked then Break;
          end;
        end;
      if not OneChecked then Checked := True; 
    end;
  end;
end;

procedure TmyWebImage.SetCaption(const Value: String);
begin
  FCaption := Value;
  Repaint;
end;

procedure TmyWebImage.SetCaptionOffsetX(const Value: Integer);
begin
  FCaptionOffsetX := Value;
end;

procedure TmyWebImage.SetCaptionOffsetY(const Value: Integer);
begin
  FCaptionOffsetY := Value;
end;

procedure TmyWebImage.SetChecked(const Value: Boolean);
begin
	if fChecked <> Value then
  begin
  	fChecked := Value;
    UpdateExclusive;
    Repaint;
  end;
end;

procedure TmyWebImage.SetCheckedFont(const Value: TFont);
begin
  FCheckedFont.Assign(Value);
end;

procedure TmyWebImage.SetCheckedImage(const Value: TPicture);
begin
  FCheckedImage.Assign(Value);
end;

procedure TmyWebImage.SetColor(const Value: TColor);
begin
  FColor := Value;
  Repaint;
end;

procedure TmyWebImage.SetAutosize(const Value: Boolean);
begin
  fAutosize := Value;
  if fAutosize then Setbounds(Left, Top, fImage.Width, fImage.Height);
end;

procedure TmyWebImage.SetDownFont(const Value: TFont);
begin
  FDownFont.Assign(Value);
end;

procedure TmyWebImage.SetDownImage(const Value: TPicture);
begin
	if fDownImage <> Value then
	begin
    FDownImage.Assign(Value);
    Repaint;
  end;
end;

procedure TmyWebImage.SetGlyph(const Value: TPicture);
begin
  FGlyph.Assign(Value);
end;

procedure TmyWebImage.SetGlyphAlignment(const Value: TAlign);
begin
  FGlyphAlignment := Value;
end;

procedure TmyWebImage.SetImage(const Value: TPicture);
begin
  if FImage <> Value then
  begin
  	fImage.Assign(Value);
    if fAutoSize then
		  Setbounds(Left, Top, fImage.Width, fImage.Height);
    Repaint;
  end;
end;

procedure TmyWebImage.SetOnChecked(const Value: TMyWebImageChecked);
begin
  fOnChecked := Value;
end;

procedure TmyWebImage.SetOverFont(const Value: TFont);
begin
  FOverFont.Assign(Value);
end;

procedure TmyWebImage.SetOverImage(const Value: TPicture);
begin
	if FOverImage <> Value then
  begin
  	fOverimage.Assign(Value);
  	Repaint;
  end;
end;

procedure TmyWebImage.SetSpace(const Value: Integer);
begin
  FSpace := Value;
end;

procedure TmyWebImage.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
//	if fStatus = 0 then
//  begin
//  	fStatus := 1;
//		Repaint;
//  end;
//  inherited MouseMove(Shift, X, Y);
end;

end.
