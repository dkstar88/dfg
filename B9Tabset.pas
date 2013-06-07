unit B9Tabset;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, B9Panel,
  	myWebImage, ImageCacheLoader;

type
  TB9Tabset = class(TB9Panel)
  private
    FTabs: TStrings;
    FLeftPadding: Integer;
    FFont: TFont;
    FRightPadding: Integer;
    FOverFont: TFont;
    FDownFont: TFont;
    FTabIndex: Integer;
    FCaptionOffsetY: Integer;
    FOnChange: TNotifyEvent;
    FTabDownImage: TPicture;
    FTabImage: TPicture;
    FTabOverImage: TPicture;
    fTabControls: TList;
    FMargin: Integer;
    FCheckedFont: TFont;

    procedure SetDownFont(const Value: TFont);
    procedure SetFont(const Value: TFont);
    procedure SetLeftPadding(const Value: Integer);
    procedure SetOverFont(const Value: TFont);
    procedure SetRightPadding(const Value: Integer);
    procedure SetTabIndex(const Value: Integer);
    procedure SetTabs(const Value: TStrings);

    procedure RecreateTabs;
    procedure SetCaptionOffsetY(const Value: Integer);
    procedure TabClicked(Sender: TObject);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetTabDownImage(const Value: TPicture);
    procedure SetTabImage(const Value: TPicture);
    procedure SetTabOverImage(const Value: TPicture);

    procedure TabsChanged(Sender: TObject);
    procedure SetMargin(const Value: Integer);
    procedure SetCheckedFont(const Value: TFont);

    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadImages(APath, ANormal, AOver, ADown: string); overload;
    procedure LoadImages(APath, ANormal: String); overload;

    procedure LoadImagesFromRes(ANormal: String; ResType: PChar); overload;
    procedure LoadImagesFromRes(ANormal: String); overload;
    
  published
    { Published declarations }
    property Tabs: TStrings read FTabs write SetTabs;

    property TabImage: TPicture read FTabImage write SetTabImage;
    property TabDownImage: TPicture read FTabDownImage write SetTabDownImage;
    property TabOverImage: TPicture read FTabOverImage write SetTabOverImage;

    property LeftPadding: Integer read FLeftPadding write SetLeftPadding;
    property RightPadding: Integer read FRightPadding write SetRightPadding;
    property TabIndex: Integer read FTabIndex write SetTabIndex;
    property Font: TFont read FFont write SetFont;
    property OverFont: TFont read FOverFont write SetOverFont;
    property DownFont: TFont read FDownFont write SetDownFont;
    property CheckedFont: TFont read FCheckedFont write SetCheckedFont;
    property CaptionOffsetY: Integer read FCaptionOffsetY write SetCaptionOffsetY;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property Margin: Integer read FMargin write SetMargin;
  end;

procedure Register;

implementation

uses Fileman;

procedure Register;
begin
  RegisterComponents('Samples', [TB9Tabset]);
end;

{ TB9Tabset }

constructor TB9Tabset.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  FTabs := TStringList.Create;
  TStringList(FTabs).OnChange := TabsChanged;
  FFont := TFont.Create;
  FDownFont := TFont.Create;
  FOverFont := TFont.Create;
  FCheckedFont := TFont.Create;
  fTabControls := TList.Create;
  fTabImage := TPicture.Create;
  fTabOverImage := TPicture.Create;
  FTabDownImage := TPicture.Create;
  FMargin := 3;
end;

destructor TB9Tabset.Destroy;
begin
  FTabImage.Free;
  FTabOverImage.Free;
  FTabDownImage.Free;
  fTabControls.Free;
  fTabs.Free;
  FFont.Free;
  FDownFont.Free;
  FOverFont.Free;
  FreeAndNil( FCheckedFont );
  
  inherited;
end;

procedure TB9Tabset.LoadImages(APath, ANormal, AOver, ADown: string);
begin
	LoadGraphicCached(APath + ANormal, fTabImage);
//  fTabImage.LoadFromFile(APath + ANormal);
  if FileExists(APath + AOver) then
    LoadGraphicCached(APath + AOver, FTabOverImage);
  if FileExists(APath + ADown) then
    LoadGraphicCached(APath + ADown, fTabDownImage);

  if FTabs.Count > 0 then
    ClientPadding := Rect(fMargin, fTabImage.Height, fMargin, fMargin);
end;

procedure TB9Tabset.LoadImages(APath, ANormal: String);
var
  ext: String;
begin
  ext := ExtractFileExt(ANormal);
  LoadImages(APath, ANormal, ChangeFileExt(ANormal, '-Over' + Ext), ChangeFileExt(ANormal, '-Down' + Ext));
end;


procedure TB9Tabset.LoadImagesFromRes(ANormal: String; ResType: PChar);
begin
  GraphicLoadRC(fTabImage, ANormal, ResType);
  GraphicLoadRC(FTabOverImage, ANormal+'_OVER', ResType);
  GraphicLoadRC(fTabDownImage, ANormal+'_DOWN', ResType);
  if FTabs.Count > 0 then
    ClientPadding := Rect(fMargin, fTabImage.Height, fMargin, fMargin);
end;

procedure TB9Tabset.LoadImagesFromRes(ANormal: String);
begin
  LoadImagesFromRes(ANormal, RT_RCDATA);
end;

procedure TB9Tabset.RecreateTabs;

  function CreateTab(ACaption: String; Aindex: Integer): TMyWebImage;
  begin
    Result := TMyWebImage.Create(Self);
    with Result do
    begin
      Parent := Self;
      Caption := ACaption;
      Image.Assign(Self.TabImage);
      OverImage.Assign(Self.TabOverImage);
      DownImage.Assign(Self.TabDownImage);      
      Cursor := crHandPoint;
      Font.Assign(Self.Font);
      OverFont.Assign(Self.OverFont);
      DownFont.Assign(Self.DownFont);
      CheckedFont.Assign(Self.CheckedFont);
      CaptionOffsetY := Self.CaptionOffsetY;
      OnClick := TabClicked;
      CheckGroup := 9;
      Top := 0;
      Left := Aindex*(Image.Width+5)+10;
      AutoSize := True;
      BringToFront;
      Visible := True;
    end;
  end;

var
  i: Integer;
begin

  Visible := False;
  DestroyHandle;

  // Clear tabs
  for i := 0 to fTabControls.Count-1 do
  begin
    TObject(fTabControls[i]).Free;
  end;
  fTabControls.Clear;
  
  for i := 0 to FTabs.Count - 1 do
  begin
    fTabControls.Add(CreateTab(FTabs[i], i));
  end;

  if FTabIndex >= fTabControls.Count then
  begin
    TabIndex := fTabControls.Count-1;
  end;

  if FTabs.Count > 0 then
    ClientPadding := Rect(FMargin, fTabImage.Height, FMargin, FMargin)
  else
    ClientPadding := Rect(FMargin, FMargin, FMargin, FMargin);

  Visible := True;

end;

procedure TB9Tabset.SetCaptionOffsetY(const Value: Integer);
begin
  FCaptionOffsetY := Value;
end;

procedure TB9Tabset.SetCheckedFont(const Value: TFont);
begin
  FCheckedFont.Assign(Value);
end;

procedure TB9Tabset.SetDownFont(const Value: TFont);
begin
  FDownFont.Assign(Value);
end;

procedure TB9Tabset.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TB9Tabset.SetLeftPadding(const Value: Integer);
begin
  FLeftPadding := Value;
end;

procedure TB9Tabset.SetMargin(const Value: Integer);
begin
  FMargin := Value;
end;

procedure TB9Tabset.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TB9Tabset.SetOverFont(const Value: TFont);
begin
  FOverFont.Assign(Value);
end;

procedure TB9Tabset.SetRightPadding(const Value: Integer);
begin
  FRightPadding := Value;
end;

procedure TB9Tabset.SetTabDownImage(const Value: TPicture);
begin
  FTabDownImage.Assign(Value);
end;

procedure TB9Tabset.SetTabImage(const Value: TPicture);
begin
  FTabImage.Assign(Value);
end;

procedure TB9Tabset.SetTabIndex(const Value: Integer);
begin
  FTabIndex := Value;
  if FTabIndex < 0 then FTabIndex := 0;
  if FTabIndex > fTabControls.Count then FTabIndex := fTabControls.Count;
  if fTabControls.Count>0 then
    TmyWebImage(fTabControls[FTabIndex]).Checked := True;
end;

procedure TB9Tabset.SetTabOverImage(const Value: TPicture);
begin
  FTabOverImage.Assign(Value);
end;

procedure TB9Tabset.SetTabs(const Value: TStrings);
begin
  FTabs.Assign(Value);
end;

procedure TB9Tabset.TabClicked(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Sender);
  
end;

procedure TB9Tabset.TabsChanged(Sender: TObject);
begin
  RecreateTabs;
end;

end.
