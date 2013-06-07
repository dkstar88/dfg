unit WYWebImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TWYWebImage = class(TGraphicControl)
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
    FBackground: TBitmap;
    FUseBackground: Boolean;
    FCaption: String;
    FFont: TFont;
    FOverFont: TFont;
    FDownFont: TFont;
    procedure SetDownImage(const Value: TPicture);
    procedure SetImage(const Value: TPicture);
    procedure SetOverImage(const Value: TPicture);
    procedure SetAutosize(const Value: Boolean);
    procedure SetDisableImage(const Value: TPicture);
    procedure SetChecked(const Value: Boolean);
    procedure CMButtonPressed(var Message: TMessage); message CM_ButtonPressed;
    procedure UpdateExclusive;
    procedure SetBackground(const Value: TBitmap);
    procedure SetUseBackground(const Value: Boolean);
    procedure SetCaption(const Value: String);
    procedure SetDownFont(const Value: TFont);
    procedure SetFont(const Value: TFont);
    procedure SetOverFont(const Value: TFont);
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

  published
    { Published declarations }
    property Caption: String read FCaption write SetCaption;
    property Image: TPicture read FImage write SetImage;
    property DownImage: TPicture read FDownImage write SetDownImage;
    property OverImage: TPicture read FOverImage write SetOverImage;
    property Checked: Boolean read fChecked write SetChecked;
    property CheckGroup: Integer read fCheckGroup write fCheckGroup;
    property DisableImage: TPicture read fDisableImage write SetDisableImage;
    property Transparent: Boolean read fTransparent write fTransparent;
    property AllowAllUp: Boolean read fAllowAllUp write fAllowAllUp;
    property PushOffset: Integer read fPushOffset write fPushOffset;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Background: TBitmap read FBackground write SetBackground;
    property UseBackground: Boolean read FUseBackground write SetUseBackground;

    property Font: TFont read FFont write SetFont;
    property OverFont: TFont read FOverFont write SetOverFont;
    property DownFont: TFont read FDownFont write SetDownFont;
    
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

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Grafix', [TWYWebImage]);
end;

{ TWYWebImage }

constructor TWYWebImage.Create(Aowner: TComponent);
begin
	inherited Create(AOwner);
  // DoubleBuffer := True;
  fOverImage := TPicture.Create;
  fDownImage := TPicture.Create;
  fDisableImage := TPicture.Create;
  FBackground := TBitmap.Create;
  FFont := TFont.Create;
  FOverFont := TFont.Create;
  FDownFont := TFont.Create;
  fImage := TPicture.Create;
  fStatus := 0;
  fAutoSize := True;
end;

destructor TWYWebImage.Destroy;
begin
  FBackground.Free;
	fDownImage.Free;
	fOverImage.Free;
  FFOnt.Free;
  FDownFont.Free;
  FOverFont.Free;
	fImage.Free;
  fDisableImage.Free;
	inherited Destroy;
end;

procedure TWYWebImage.EraseBackground(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TWYWebImage.LoadImages(APath, ANormal: String);
var
  ext: String;
begin
  ext := ExtractFileExt(ANormal);
  LoadImages(APath, ANormal, ChangeFileExt(ANormal, '-Over' + Ext), ChangeFileExt(ANormal, '-Down' + Ext));
end;

procedure TWYWebImage.LoadImages(APath, ANormal, AOver, ADown: string);
begin
  fImage.LoadFromFile(APath + ANormal);
  if FileExists(APath + AOver) then
    FOverImage.LoadFromFile(APath + AOver);
  if FileExists(APath + ADown) then
    fDownImage.LoadFromFile(APath + ADown);
  Setbounds(Left, Top, fImage.Width, fImage.Height);
end;

procedure TWYWebImage.UpdateExclusive;
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

procedure TWYWebImage.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
	if Button = mbLeft then
  begin
  	fStatus := 2;
  	if Visible then paint;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TWYWebImage.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
	if fStatus = 2 then
  begin
  	fStatus := 0;
  	if Visible then paint;
		if fCheckGroup <> 0 then Checked := not fChecked;    
  end;
  inherited MouseUp(Button, Shift, X, Y);  
end;

procedure TWYWebImage.MsgMouseEnter(var Message: TMessage);
begin
	if fStatus = 0 then
  begin
  	fStatus := 1;
		paint;
  end;
end;

procedure TWYWebImage.MsgMouseLeave(var Message: TMessage);
begin
	if fStatus = 1 then
  begin
  	fStatus := 0;
  	paint;
  end;
end;

procedure TWYWebImage.Paint;
var
  fCanvas: TCanvas;
  bmp: TBitmap;
  x, y: Integer;
  
	procedure DrawUp;
  var
  	x, y: Integer;
  begin
  	if fImage.Graphic <> nil then
		begin
    	x := 0; y := 0;
			repeat
	      fCanvas.Draw(x, y, fImage.Graphic);
        Inc(x, fImage.Graphic.Width);
        if x > Width+fImage.Graphic.Width then
        begin
          x := 0;
          Inc(y, fImage.Graphic.Height);
        end;
      until (y>=Height)
    end;
  end;

  procedure DrawDown;
  begin
  	if fDownImage.Graphic <> nil then
			fCanvas.Draw(0, 0, fDownImage.Graphic)
    else
		begin
      DrawUp;
    end;
  end;

  procedure DrawOver;
  begin
  	if fOverImage.Graphic <> nil then
			fCanvas.Draw(0, 0, fOverImage.Graphic)
    else
		begin
      DrawUp;
    end;
  end;

  procedure DrawDisabled;
  begin
  	if fDisableImage.Graphic <> nil then
			fCanvas.Draw(0, 0, fDisableImage.Graphic)
    else
		begin
      DrawUp;
    end;
  end;


	procedure DrawChecked;
  begin
		DrawDown;  
  end;  

begin

	if fTransparent then
	begin
  	Canvas.Brush.Style := bsClear;
  	Canvas.FillRect(ClientRect);
  end;

  if fDownImage.Graphic <> nil then
    fDownImage.Graphic.Transparent := fTransparent;
  if fOverImage.Graphic <> nil then
    fOverImage.Graphic.Transparent := fTransparent;
  if fDisableImage.Graphic <> nil then
    fDisableImage.Graphic.Transparent := fTransparent;

  if fImage.Graphic <> nil then
    fImage.Graphic.Transparent := fTransparent;


  if fImage.Graphic <> nil then
  begin

    bmp := TBitmap.Create;
    bmp.Width := Width;
    bmp.Height := Height;
    if FUseBackground then
      bmp.Canvas.Draw(0, 0, fBackground)
    else
      bmp.Canvas.CopyRect(Rect(0, 0, Width, Height), Self.Canvas, Rect(0, 0, Width, Height));
    fCanvas := bmp.Canvas;

    if Enabled then
      case fStatus of
        0: if fChecked then DrawChecked else DrawUp;
        2: DrawDown;
        1: DrawOver;
      end
    else
    begin
      DrawDisabled;
      
    end;
    if FCaption <> '' then
    begin
      x := (Width-bmp.Canvas.TextWidth(fCaption)) div 2;
      y := (Height-bmp.Canvas.TextHeight(fCaption)) div 2;
      bmp.Canvas.Brush.Style := bsClear;
      if (fPushOffset <> 0) and (fStatus=2) then
      begin
        //Inc(x, fPushOffset);
        Inc(y, fPushOffset);
      end;

      case fStatus of
        0: bmp.Canvas.Font.Assign(FFont);
        2: bmp.Canvas.Font.Assign(FDownFont);
        1: bmp.Canvas.Font.Assign(FOverFont);
      end;
      bmp.Canvas.TextOut(x, y, FCaption);
    end;

    Canvas.Draw(0, 0, bmp);
    bmp.Free;
  end
  else
  begin
  	if csDesigning in ComponentState then
    begin
	    Canvas.Pen.Style := psDash;
  	  Canvas.Pen.Color := clWhite;
    	Canvas.Brush.Color := clGray;
    	Canvas.Rectangle(0, 0, Width, Height);
    	Canvas.TextOut(2,2,'(TWYWebImage)');
    end;
  end;
end;

procedure TWYWebImage.SetDisableImage(const Value: TPicture);
begin
  if fDisableImage <> Value then
  begin
  	fDisableImage.Assign(Value);
    if not Enabled then paint;
  end;
end;

procedure TWYWebImage.CMButtonPressed(var Message: TMessage);
var
  Sender: TWYWebImage;
  Comp: TWYWebImage;
  i: Integer;
  OneChecked: Boolean;
begin
	OneChecked := False;
  if Message.WParam = fCheckGroup then
  begin
    Sender := TWYWebImage(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Checked and (fChecked) then
      begin
        fChecked := False;
        paint;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end else if not fAllowAllUp then
    begin
      if Parent <> nil then
	    	for i := 0 to Parent.ControlCount-1 do
    		begin
        	Comp := TWYWebImage(Parent.Controls[i]);
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

procedure TWYWebImage.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TWYWebImage.SetChecked(const Value: Boolean);
begin
	if fChecked <> Value then
  begin
  	fChecked := Value;
    UpdateExclusive;
    paint;
  end;
end;

procedure TWYWebImage.SetAutosize(const Value: Boolean);
begin
  fAutosize := Value;
  if fAutosize then Setbounds(Left, Top, fImage.Width, fImage.Height);
end;

procedure TWYWebImage.SetBackground(const Value: TBitmap);
begin
  FBackground := Value;
end;

procedure TWYWebImage.SetDownFont(const Value: TFont);
begin
  FDownFont.Assign(Value);
end;

procedure TWYWebImage.SetDownImage(const Value: TPicture);
begin
	if fDownImage <> Value then
	begin
    FDownImage.Assign(Value);
    Paint;
  end;
end;

procedure TWYWebImage.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TWYWebImage.SetImage(const Value: TPicture);
begin
  if FImage <> Value then
  begin
  	fImage.Assign(Value);
    if fAutoSize then
		  Setbounds(Left, Top, fImage.Width, fImage.Height);
    paint;
  end;
end;

procedure TWYWebImage.SetOverFont(const Value: TFont);
begin
  FOverFont.Assign(Value);
end;

procedure TWYWebImage.SetOverImage(const Value: TPicture);
begin
	if FOverImage <> Value then
  begin
  	fOverimage.Assign(Value);
  	paint;
  end;
end;

procedure TWYWebImage.SetUseBackground(const Value: Boolean);
begin
  FUseBackground := Value;
end;

procedure TWYWebImage.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
	if fStatus = 0 then
  begin
  	fStatus := 1;
		paint;
  end;
  inherited MouseMove(Shift, X, Y);
end;

end.
