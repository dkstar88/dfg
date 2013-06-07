unit B9Panel;

interface

uses
  SysUtils, Classes, Windows, Controls, ExtCtrls, Graphics;

type
  TB9Images = class(TPersistent)
  private
    FRight: TPicture;
    FBottomLeft: TPicture;
    FBottom: TPicture;
    FBottomRight: TPicture;
    FTopLeft: TPicture;
    FTop: TPicture;
    FLeft: TPicture;
    FTopRight: TPicture;
    procedure SetBottom(const Value: TPicture);
    procedure SetBottomLeft(const Value: TPicture);
    procedure SetBottomRight(const Value: TPicture);
    procedure SetLeft(const Value: TPicture);
    procedure SetRight(const Value: TPicture);
    procedure SetTop(const Value: TPicture);
    procedure SetTopLeft(const Value: TPicture);
    procedure SetTopRight(const Value: TPicture);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property TopLeft: TPicture read FTopLeft write SetTopLeft;
    property Top: TPicture read FTop write SetTop;
    property TopRight: TPicture read FTopRight write SetTopRight;
    property Left: TPicture read FLeft write SetLeft;
    property Right: TPicture read FRight write SetRight;
    property BottomLeft: TPicture read FBottomLeft write SetBottomLeft;
    property Bottom: TPicture read FBottom write SetBottom;
    property BottomRight: TPicture read FBottomRight write SetBottomRight;
  end;

  TB9Panel = class(TCustomPanel)
  private
    FImages: TB9Images;
    fBuffer: TBitmap;
    FTransparent: Boolean;
    FClientPadding: TRect;
    procedure SetImages(const Value: TB9Images);
    procedure SetTransparent(const Value: Boolean);
    procedure SetClientPadding(const Value: TRect);
    { Private declarations }
  protected
    { Protected declarations }
    function GetClientRect: TRect; override;    
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Images: TB9Images read FImages write SetImages;
    property Color;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property ClientPadding: TRect read FClientPadding write SetClientPadding;
  end;

procedure Register;

implementation

procedure TB9Images.AssignTo(Dest: TPersistent);
var
  d: TB9Images;
begin
  inherited;
  if Dest is TB9Images then
  begin
    d := TB9Images(Dest);
    d.Top := fTop;
    d.TopLeft := fTopLeft;
    d.TopRight := fTopRight;
    d.Left := fTop;
    d.Right := fRight;
    d.Bottom := fBottom;
    d.BottomLeft := fBottomLeft;
    d.BottomRight := fBottomRight;

  end;
end;

constructor TB9Images.Create;
var
  fEmptyBitmap: TBitmap;
begin
  inherited Create;
  FTopLeft := TPicture.Create;
  FTop := TPicture.Create;
  FTopRight := TPicture.Create;
  FLeft := TPicture.Create;
  FRight := TPicture.Create;
  FBottomLeft := TPicture.Create;
  FBottom := TPicture.Create;
  FBottomRight := TPicture.Create;
  fEmptyBitmap := TBitmap.Create;
  fEmptyBitmap.Width := 4;
  fEmptyBitmap.Height := 4;
  FTopLeft.Assign(fEmptyBitmap);
  FTop.Assign(fEmptyBitmap);
  FTopRight.Assign(fEmptyBitmap);
  FLeft.Assign(fEmptyBitmap);
  FRight.Assign(fEmptyBitmap);
  FBottomLeft.Assign(fEmptyBitmap);
  FBottom.Assign(fEmptyBitmap);
  FBottomRight.Assign(fEmptyBitmap);
  fEmptyBitmap.Free;
end;

destructor TB9Images.Destroy;
begin
  FTopLeft.Free;
  FTop.Free;
  FTopRight.Free;
  FLeft.Free;
  FRight.Free;
  FBottom.Free;
  FBottomLeft.Free;
  FBottomRight.Free;
  inherited;
end;

procedure TB9Images.SetBottom(const Value: TPicture);
begin
  FBottom.Assign(Value);
end;

procedure TB9Images.SetBottomLeft(const Value: TPicture);
begin
  FBottomLeft.Assign(Value);
end;

procedure TB9Images.SetBottomRight(const Value: TPicture);
begin
  FBottomRight.Assign(Value);
end;

procedure TB9Images.SetLeft(const Value: TPicture);
begin
  FLeft.Assign(Value);
end;

procedure TB9Images.SetRight(const Value: TPicture);
begin
  FRight.Assign(Value);
end;

procedure TB9Images.SetTop(const Value: TPicture);
begin
  FTop := Value;
end;

procedure TB9Images.SetTopLeft(const Value: TPicture);
begin
  FTopLeft.Assign(Value);
end;

procedure TB9Images.SetTopRight(const Value: TPicture);
begin
  FTopRight.Assign(Value);
end;


procedure Register;
begin
  RegisterComponents('Samples', [TB9Panel]);
end;

{ TB9Panel }

constructor TB9Panel.Create(AOwner: TComponent);
begin
  inherited;
  fImages := TB9Images.Create;
  fBuffer := TBitmap.Create;
  DoubleBuffered := True;
end;

destructor TB9Panel.Destroy;
begin
  fBuffer.Free;
  fImages.Free;
  inherited;
end;

function TB9Panel.GetClientRect: TRect;
begin
  Result := Rect(ClientPadding.Left, ClientPadding.Top, Width-ClientPadding.Right, Height-ClientPadding.Bottom);
end;

procedure TB9Panel.Paint;
var
  fCanvas: TCanvas;
  x, y: Integer;
  fRect: TRect;
begin
  if (fBuffer.Width<>Width) or (fBuffer.Height<>Height) then
  begin
    fBuffer.Width := Width;
    fBuffer.Height := Height;
  end;

  fCanvas := fBuffer.Canvas;
  if fTransparent then
  begin
    fCanvas.Brush.Style := bsClear;
  end else
  begin
    fCanvas.Brush.Style := bsSolid;
    fCanvas.Brush.Color := Color;
  end;
  fCanvas.FillRect(ClientRect);
  // Draw Top
  x := 0; y := 0;
  fCanvas.Draw(x, y, fImages.TopLeft.Graphic);

  fCanvas.Draw(Width-fImages.TopRight.Width, y, fImages.TopRight.Graphic);

  fRect := Rect(fImages.TopLeft.Width, 0, Width-fImages.TopRight.Width, fImages.Top.Height);
  fCanvas.StretchDraw(fRect, fImages.Top.Graphic);

  // Draw Sides
  fRect := Rect(0, fImages.TopLeft.Height,
    fImages.Left.Width, Height-fImages.BottomLeft.Height);
  fCanvas.StretchDraw(fRect, fImages.Left.Graphic);
  fRect := Rect(Width-fImages.Right.Width, fImages.TopRight.Height,
    Width, Height-fImages.BottomRight.Height);
  fCanvas.StretchDraw(fRect, fImages.Right.Graphic);

  // Draw Bottom
  y := Height-fImages.BottomLeft.Height;
  fCanvas.Draw(0, y, fImages.BottomLeft.Graphic);
  fCanvas.Draw(Width-fImages.BottomRight.Width, y, fImages.BottomRight.Graphic);
  fRect := Rect(fImages.BottomLeft.Width, Height-fImages.Bottom.Height,
    Width-fImages.BottomRight.Width, Height);
  fCanvas.StretchDraw(fRect, fImages.Bottom.Graphic);


  Canvas.CopyRect(Canvas.ClipRect, fCanvas, Canvas.ClipRect);

end;

procedure TB9Panel.SetClientPadding(const Value: TRect);
begin
  FClientPadding := Value;
end;

procedure TB9Panel.SetImages(const Value: TB9Images);
begin
  FImages.Assign(Value);
end;

procedure TB9Panel.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  Repaint;
end;

end.
