unit HTMLMan;

interface

uses SysUtils, Graphics;

//Functions about HTML
function hmRatio(Group, Name : String; Checked: Boolean): String;
function hmCheckbox(Group, Name : String; Checked: Boolean): String;
function hmTextbox(Name, Value : String): String;
function hmButton(ButtonType: Integer; Name, Caption: String): String;
function hmFont(Face, Size: String; Color: TColor): String;
function FontToHTML(AFont: TFont): String;

implementation

function FontToHTML(AFont: TFont): String;
var
	Sz: String;
begin
	case AFont.Size of
  0..6: Sz:= '1';
  7..11: Sz := '2';
  12..16: Sz := '3';
  17..24: Sz := '4';
  25..30: Sz := '5';
  31..35: Sz := '6';
  else Sz := '7';
  end;
	Result := '<Font Face=' + AFont.Name + ' Size='
  	+ Sz + ' Color=#'+ IntToHex(ColorToRGB(AFont.Color), 6) + ' >'
end;

function hmFont(Face, Size: String; Color: TColor): String;
begin
	Result := '<Font Face=' + Face + ' Size='
  	+ Size + ' Color=#'+ IntToHex(ColorToRGB(Color), 6) + ' >'
end;

function hmButton(ButtonType: Integer; Name, Caption: String): String;
begin
	case ButtonType of
  0: Result := '<INPUT TYPE="Submit" Value='+Caption+' NAME='+NAME+' >';
  1: Result := '<INPUT TYPE="Reset" Value='+Caption+' NAME='+NAME+' >';
  2: Result := '<INPUT TYPE="Button" Value='+Caption+' NAME='+NAME+' >';
  end;
end;

function hmTextbox(Name, Value : String): String;
begin
	Result := '<INPUT TYPE="Text" Value='+Value+' NAME='+NAME+' >'
end;

function hmCheckbox(Group, Name : String; Checked: Boolean): String;
begin
	if Checked then
		Result := '<INPUT TYPE="CHECK" GROUP='+GROUP+' NAME='+NAME+' CHECKED >'
  else
		Result := '<INPUT TYPE="CHECK" GROUP='+GROUP+' NAME='+NAME+'>';
end;

function hmRatio(Group, Name : String; Checked: Boolean): String;
begin
	if Checked then
		Result := '<INPUT TYPE="Ratio" GROUP='+GROUP+' NAME='+NAME+' CHECKED >'
  else
		Result := '<INPUT TYPE="Ratio" GROUP='+GROUP+' NAME='+NAME+'>';
end;

end.
