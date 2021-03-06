unit ClrPanel;

interface

uses
  Windows, Forms, SysUtils, Classes, Graphics, Controls, ExtCtrls;

type
	TClrBevel = class(TBevel)
  protected
    procedure Paint; override;
  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
  published
  	property Align;
    property ParentShowHint;
    property Shape;
    property ShowHint;
    property Style;
    property Visible;
    property Color;
  end;

  TCustomColorPanel = class(TCustomPanel)
  private
    { Private Declarations }
  protected
    { Protected Declarations }
		PaintRect: TRect;
    procedure PaintPanel(var Rect: TRect); virtual;
    procedure Paint; override;
  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
	end;

  TColorPanel = class(TCustomColorPanel)
  private
    { Private Declarations }
  protected
    { Protected Declarations }
  public
    { Public Declarations }
  published
    property Align;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Caption;
    property Color;
    property Ctl3D;
    property Font;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDrag;
  end;

implementation

uses ColorMan, DrawMan;

{ TClrBevel }
constructor TClrBevel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Aowner is TForm then
  	Color := TForm(AOwner).Color
  else if AOwner is TColorPanel then
  	Color := TColorPanel(AOwner).Color;
end;

procedure TClrBevel.Paint;
var
  Color1, Color2: TColor;
  Temp: TColor;

  procedure BevelRect(const R: TRect);
  begin
    with Canvas do
    begin
      Pen.Color := Color1;
      PolyLine([Point(R.Left, R.Bottom), Point(R.Left, R.Top),
        Point(R.Right, R.Top)]);
      Pen.Color := Color2;
      PolyLine([Point(R.Right, R.Top), Point(R.Right, R.Bottom),
        Point(R.Left, R.Bottom)]);
    end;
  end;

  procedure BevelLine(C: TColor; X1, Y1, X2, Y2: Integer);
  begin
    with Canvas do
    begin
      Pen.Color := C;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
  end;

begin
  with Canvas do
  begin
    Pen.Width := 1;

    if Style = bsLowered then
    begin
      Color1 := DarkenColor(Color, 48);
      Color2 := BrightenColor(Color, 48);
    end
    else
    begin
      Color1 := BrightenColor(Color, 48);
      Color2 := DarkenColor(Color, 48);
    end;

    case Shape of
      bsBox: BevelRect(Rect(0, 0, Width - 1, Height - 1));
      bsFrame:
        begin
          Temp := Color1;
          Color1 := Color2;
          BevelRect(Rect(1, 1, Width - 1, Height - 1));
          Color2 := Temp;
          Color1 := Temp;
          BevelRect(Rect(0, 0, Width - 2, Height - 2));
        end;
      bsTopLine:
        begin
          BevelLine(Color1, 0, 0, Width, 0);
          BevelLine(Color2, 0, 1, Width, 1);
        end;
      bsBottomLine:
        begin
          BevelLine(Color1, 0, Height - 2, Width, Height - 2);
          BevelLine(Color2, 0, Height - 1, Width, Height - 1);
        end;
      bsLeftLine:
        begin
          BevelLine(Color1, 0, 0, 0, Height);
          BevelLine(Color2, 1, 0, 1, Height);
        end;
      bsRightLine:
        begin
          BevelLine(Color1, Width - 2, 0, Width - 2, Height);
          BevelLine(Color2, Width - 1, 0, Width - 1, Height);
        end;
    end;
  end;
end;

constructor TCustomColorPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Aowner is TForm then
  	Color := TForm(AOwner).Color
  else if AOwner is TColorPanel then
  	Color := TColorPanel(AOwner).Color;
  Caption := '';
end;

destructor TCustomColorPanel.Destroy;
begin
  inherited Destroy;
end;

procedure TCustomColorPanel.Paint;
var
  FontHeight: Integer;
  R2: Trect;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
begin
	PaintRect := ClientRect;
	PaintPanel(PaintRect);
  with Canvas do
  begin
  	R2 := PaintRect;
   	Brush.Color := Color;
   	FillRect(PaintRect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with R2 do
    begin
      Top := ((Bottom + Top) - FontHeight) div 2;
      Bottom := Top + FontHeight;
    end;
    DrawText(Handle, PChar(Caption), -1, R2, (DT_EXPANDTABS or
      DT_VCENTER) or Alignments[Alignment]);
  end;
end;

procedure TCustomColorPanel.PaintPanel(var Rect: TRect);
var
  TopColor, BottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    if Bevel = bvLowered then TopColor := BrightenColor(Color, -64) else
    	TopColor := BrightenColor(Color, 64);
    if Bevel = bvLowered then BottomColor := DarkenColor(Color, -64) else
    	BottomColor := DarkenColor(Color, 64)
  end;

begin
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;

  Frame3D(Canvas, Rect, Color, Color, BorderWidth);

  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;

end;

end.
