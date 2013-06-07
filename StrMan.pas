
{ ---------------------------------------------------
		String Manager   Copyright (r) by DreamFactory
    Version : 1.75   Author : William Yang
		Last Update 25 - Aug - 97
  --------------------------------------------------- }


unit StrMan; {String Manager}

interface
{-- Declaretion Part --}

uses Windows, SysUtils, Math, Classes;

type

	TCharSet = set of Char;
const

  Decimals = ['0'..'9'];
  FloatNums = ['0'..'9', '.'];
  Operators = ['+', '-', '*', '/'];
  HexDecimals = ['0'..'9', 'A'..'F'];
  Letters = ['a'..'z', 'A'..'Z'];
  Symbols = ['"', '''', '<', '>', '{', '}', '[', ']', '(', ',', ')'];
  Masks : array[1..3] of Char  = ('*', '?', '#');

function ReplaceOne(Src, Ch : String; iStart, iCount : Integer ) : String;
function FillStr(Amount : Byte; C : Char) : String;
function TitleCase(SourceStr : String) : String;
function ReplaceAll(Source , Target, ChangeTo : String) : String ;
function Instr(iStart : Integer; Src, Find: String) : Integer;
function CompareStrAry(Source : String; CmpTo : Array of string) : Integer;
function LowCaseStr(S : String) : String;
function LoCase(C : Char) : Char;
procedure StrSplit(SrcStr : String; BreakDownPos : Integer;
	var S1, S2 : String);
function LeftStr(S : String; ToPos : Integer) : String;
function RightStr(S : String; ToPos : Integer) : String;
function CharCount(S : String; C : Char) : Integer;

function RemoveChars(S : String; C : TCharSet) : String;
function StrBrief(AString: String; AMaxChar: Integer): String;
function EStrToInt(S : String) : Integer;
function EStrToFloat(S : String) : Real;

function LastDir(Dir: String): String;

function RPos(C: String; Src : String) : Integer; overload;
function RPos(C: String; Src : String; nStart: Integer) : Integer; overload;

function ReturnLine(SList: TStringList; Find: String) : String;
procedure SplitStrC (S:string; C : char; var head, queue : string);
procedure Split(StringList: TStringList; S : string; C : char);

function ReadBetween(Src, Mark1, Mark2: WideString): WideString;
procedure RemoveQuate(var Src: String);

function strFileLoad(const aFile: String): String;
procedure strFileSave(const aFile,aString: String);
function JoinStrings(AStrings: TStrings): String; overload;
function JoinStrings(strings: TStrings; delimiter: String): String; overload;
function AddSlashes(AString: String): String;
function StripSlashes(AString: String): String;
function AddSlashesExt(AString: String; Targets:array of char): String;
procedure ChopStrings(AStr: String; AChunkSize: Integer; AOut: TStrings);overload;
procedure ChopStrings(AStr: WideString; AChunkSize: Integer; AOut: TStrings); overload;

function strAddSlash(const S: String): String;
function strDelSlash(const S: String): String;

implementation

const
  SLASH = '\';
function  strLastCh(const S: String): Char;
begin
  Result:=S[Length(S)];
end;

function strAddSlash(const S: String): String;
begin
	if Length(S)>0 then
  begin
    Result:=S;
    if strLastCh(Result)<>SLASH then Result:=Result+SLASH;
  end
end;

function strDelSlash(const S: String): String;
begin
	if Length(S)>0 then
  begin
  	Result:=S;
	  if strLastCh(Result)=SLASH then Delete(Result,Length(Result),1);
  end else
  	Result := S;
end;

procedure ChopStrings(AStr: String; AChunkSize: Integer; AOut: TStrings);overload;
var
  s: String;
  i: Integer;
begin
  s := AStr;
  while s <> '' do
  begin
    i := Min(80, Length(s));
    AOut.Add(Copy(s, 1, i));
    Delete(s, 1, i);
  end;
end;

procedure ChopStrings(AStr: WideString; AChunkSize: Integer; AOut: TStrings); overload;
var
  s: WideString;
  i: Integer;
begin
  s := AStr;
  while s <> '' do
  begin
    i := Min(80, Length(s));
    AOut.Add(Copy(s, 1, i));
    Delete(s, 1, i);
  end;
end;

function StrBrief(AString: String; AMaxChar: Integer): String;
begin
  if Length(AString)<=AMaxChar then
    Result := AString
  else
  begin
    Result := Copy(AString, 0, AMaxChar-3) + '...';
  end;
end;

function AddSlashes(AString: String): String;
begin
  Result := AString;
  Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);

//  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
//  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
//  Result := StringReplace(Result, #9, '\t', [rfReplaceAll]);

  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll]);
  Result := StringReplace(Result, #9, '', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
end;

function AddSlashesExt(AString: String; Targets:array of char): String;
var
  i: Integer;
begin
  Result := AString;
  for i := Low(Targets) to High(Targets) do
  begin
    Result := StringReplace(Result, Targets[i], '\' + Targets[i], [rfReplaceAll]);
  end;
//  Result := ReplaceAll(AString, '''', '\''');
//  Result := ReplaceAll(Result, '"', '\"');
end;

function StripSlashes(AString: String): String;
begin
  Result := ReplaceAll(AString, '\''', '''');
  Result := ReplaceAll(Result, '\"', '"');
end;

function JoinStrings(AStrings: TStrings): String;
var
  i: Integer;
begin
  result := '';
  for i := 0 to AStrings.Count-2 do
  begin
    result := result + AStrings[i] + '\';
  end;
  result := result + AStrings[AStrings.Count-1];
end;

function JoinStrings(strings: TStrings; delimiter: String): String;
var
	i: Integer;
begin
	if strings.Count=0 then Exit;
	Result := strings[0];
  if strings.Count>0 then
  	for i := 1 to strings.Count-1 do
  	begin
  		Result := Result + delimiter + strings[i]
  	end;
end;


function strFileLoad(const aFile: String): String;
var
  aStr : TStrings;
begin
  Result:='';
  aStr:=TStringList.Create;
  try
    aStr.LoadFromFile(aFile);
    Result:=aStr.Text;
  finally
    aStr.Free;
  end;
end;

procedure strFileSave(const aFile,aString: String);
var
  Stream: TStream;
begin
	if FileExists(aFile) then begin
    SetFileAttributes( PChar(aFile),FILE_ATTRIBUTE_NORMAL );
    DeleteFile(aFile);
  end;
  Stream := TFileStream.Create(aFile, fmCreate);
  try
    Stream.WriteBuffer(Pointer(aString)^,Length(aString));
  finally
    Stream.Free;
  end;
end;

procedure RemoveQuate(var Src: String);
begin
	if Src='' then Exit;
	if Src[1]='"' then Delete(Src, 1, 1);
  if Src[Length(Src)]='"' then Delete(Src, Length(Src), 1);
  if Src[1]='''' then Delete(Src, 1, 1);
  if Src[Length(Src)]='''' then Delete(Src, Length(Src), 1);
end;

function ReadBetween(Src, Mark1, Mark2: WideString): WideString;
var
	i,j : Integer;
begin
  Result := '';
  if (Mark1='') and (Mark2='') then
  begin
    Result := '';
    Exit;
  end else if Mark1 = '' then
  begin
    j := Pos(Mark2, Src);
    if (j > 0) then
      Result := Copy(Src, 1, j-1);
  end else if Mark2='' then
  begin
    i := Pos(Mark1, Src);
    if (i > 0) then
      Result := Copy(Src, i+Length(Mark1), Length(Src));
  end else
  begin
    i := Pos(Mark1, Src);
    j := InStr(i + Length(Mark1), Src, Mark2);
    if (i >0) and (j > 0) then
    	Result := Copy(Src, i + Length(Mark1), j-i-Length(Mark1));
  end;
end;

function LastDir(Dir: String): String;
begin
	if Dir[Length(Dir)]='\' then
  	Delete(Dir, Length(Dir), 1);
  Result := RightStr(Dir, RPos('\', Dir)+1);
end;

procedure SplitStrC (S:string; C : char; var head, queue : string);
var
    I : integer;
    Quated: Boolean;
begin
   head:=''; queue:='';
   Quated := False;
   for i := 1 to Length(S) do    // Iterate
   begin
		if S[i]='"' then
		begin
    	if Quated then
			begin
				if head<>'' then Break;
				Quated := False;
			end
      else
      begin
      	if i=1 then Quated := True
      end;
    end
    else if S[i]=C then
    	begin Break end
    else
    	Head := Head + S[i];
   end;    // for
   delete(S,1,i);
   queue := S;
end;

procedure Split(StringList: TStringList; S : string; C : char);
var
	Line: String;
begin
	StringList.Clear;
  while S <> '' do
  begin
   SplitStrC(S, C, Line, S);
   StringList.Add(Trim(Line));
  end;
end;

function ReturnLine(SList: TStringList; Find: String) : String;
var
	i :Integer;
  s: String;
begin
	Result := '';
	for i := 0 to SList.Count - 1 do
  begin
    s := SList[i];
  	if Pos(Find, s) > 0 then
    begin
    	Result := SList[i];
      Exit;
    end;
  end;
end;

function EStrToFloat(S : String) : Real;
var
	i : Integer;
  r : String;
begin
	r := '';
	for i := 1 to Length(S) do
  	if s[i] in FloatNums then
    	r := r + s[i];
  if r = '' then
  	Result := 0
  else
  	Result := StrToFloat(r);
end;

function EStrToInt(S: String) : Integer;
var
	i : Integer;
  r : String;
begin
	r := '';
	for i := 1 to Length(S) do
  	if s[i] in Decimals then
    	r := r + s[i];
  if r = '' then
  	Result := 0
  else
  	Result := StrToInt(r);
end;

function RemoveChars(S : String; C : TCharSet) : String;
var
  j : Integer;
begin
//  Result := S;
	j := 1;
  Result := '';
  while j <= Length(S) do
	begin
    if not (S[j] in C) then
      Result := Result + S[j];
    Inc(j);
  end;
end;

function ReplaceOne(Src, Ch : String; iStart, iCount : Integer) : String;
var mResult : String;
begin
	mResult := Src;
	Delete(mResult, iStart, iCount);
	Insert(Ch, mResult, iStart);
	ReplaceOne := mResult;
end;

function Instr(iStart : Integer; Src, Find: String) : Integer;
var
  CS : String;
begin
		CS := Copy(Src, iStart, Length(Src)-iStart+1);
		if Pos(Find, CS) <> 0 then
			Result := Pos(Find, CS) + iStart - 1
		else
			Result := 0;
end;

function LeftStr(S : String; ToPos : Integer) : String;
begin
	Result := Copy(S, 1, ToPos);
end;

function RightStr(S : String; ToPos : Integer) : String;
begin
	Result := Copy(S, ToPos, Length(S) - ToPos + 1);
end;

procedure StrSplit(SrcStr : String; BreakDownPos : Integer;
	var S1, S2 : String);
begin
	S1 := LeftStr(SrcStr, BreakDownPos - 1);
	S2 := RightStr(SrcStr, BreakDownPos - 1);
end;

function ReplaceAll(Source , Target, ChangeTo : String) : String ;
var
Index: Integer;
Src, Tgt, Cht : String;
begin
	Src := Source;
  Tgt := Target;
  Cht := ChangeTo;
	Index := Pos(Tgt, Src);
	while Index > 0 do
	begin
		Src := ReplaceOne(Src, Cht, Index, Length(Tgt));
		Index := Index + Length(Cht);
		Index := Instr(Index, Src, Tgt);
	end;
  Result := Src;
end;

function LoCase(C : Char) : Char;
begin
	if (Ord(C) >= Ord('A')) and (Ord(C) <= Ord('Z')) then
		Result := Chr(Ord(C) - (Ord('A') - Ord('a')))
	else LoCase := C;
end;

function LowCaseStr(S : String) : String;
var i : Integer;
begin
	for i := 1 to Length(S) do
  	S[i] := LoCase(S[i]);
end;

{Make The First Letter Of Each Word To Upper Case}
function TitleCase(SourceStr : String) : String;

var
  I : Integer;
  First : boolean;
begin
  Result := SourceStr;
  First := True;
  for I := 1 to Length(SourceStr) do
  begin
		if First then
			Result[I] := UpCase(Result[I])
		else
			Result[I] := LoCase(Result[I]);
		First := False;
  	if Result[I] in [' ', '=', '"', '''', ',', ';', '.'] then First := True;
  end;
  TitleCase := Result;
end;

{Fill The String With Parameter 'C'}
function FillStr(Amount : Byte; C : Char) : String;
var R : String;
	i : byte;
begin
	for i :=1 to Amount do
		R := R + C;
	Result := R;

end;

function CompareStrAry(Source : String; CmpTo : Array of string) : integer;
var i : Integer;
begin
	Result := -1;
	for i := Low(CmpTo) to High(CmpTo) do
  begin
  	if LowCaseStr(Source) = LowCaseStr(CmpTo[i]) then
    begin
    	Result := i;
      Exit;
    end;
  end;
end;

function RPos(C: String; Src : String) : Integer;
begin
  result := RPos(C, Src, 1);
end;

function RPos(C: String; Src : String; nStart: Integer) : Integer;
var
	i : integer;
begin
  Result := 0;
	for i := Length(Src) downto nStart do
  	if Src[i] = C then
    begin
      Result := i;
     	Break;
    end;
end;

function CharCount(S : String; C : Char) : Integer;
var i : Integer;
begin
	Result := 0;
	for i := 1 to Length(S) do
  	if S[i] = C then Result := Result + 1;
end;

end.






