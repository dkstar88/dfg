unit Fileman;

{.$define _DELPHI_LOWVER_}

interface

{$IFDEF KOL}
uses Kol, Registry, StrMan, ShellApi, winshell;
{$ELSE}
uses Windows, SysUtils, Classes, Registry, StrMan, ShellApi, winshell;
{$ENDIF}

//Get windows directory
function GetWinDir : String;
function GetSysDir : String;
//Create directories with 1 or more non-exists directories.
function CreateDirs(const Dirs: String) : Boolean;
//check if directory exists or not
function DirExists(const Dir: String): Boolean;
//return application path
function AppPath: String; overload;
function AppPath(AFilename: String): String; overload;
//Return application exename
function AppExe: String;
//Return the last dir in the Dir string.
function LastDir(Dir: String): String;
//Get the Temp dir.
function TmpDir: String;
//Noticed this function will not return '\' at all.
//unlike delphi's function, it will return '\' when the file
//contain no dir only a drive. ('a:\test.txt'->'a:\')
function ExtractFilepath(const Filename: TFilename): String;
//this function ('a:\test.txt'->'a:')

//Just like windows explorer go to the parent directory.
function DirUp(Directory: String): String;
//Test write the directory if it is readonly.
function TestWrite(const Dir: String): Boolean;
//Form a full path filename avoid '\' error.
function formFilename(const Dir, Filename: String): String;
function FilenameOnly(const Filename: String): String;

//Search file with the exxtention in a directory
procedure SearchFileExt(const Dir, Ext: String; Files: TStrings; SubDir: Boolean);
//Find the file's correct path
function SearchFind(const Dir, Filename: String): String;

function FileDateTime(const Filename: String): TDateTime;
function FileLastWrite(const Filename: String): TFileTime;
function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
function FileSize(Filename: TFilename): LongInt;
function RelativeDir(Dir, APath: String): String;
function EngFileSize(ASize: Int64): String;
function EngFileSizeF(ASize: Real): String;

function FormattedVersion(AVersion: TVSFixedFileInfo): String;
function GetVersionInfo ({$IFDEF WIN32}const{$ENDIF} Filename: String;
	var VersionInfo: {$IFDEF WIN32} TVSFixedFileInfo {$ELSE} tvs_FixedFileInfo {$ENDIF}): Boolean; overload;
function GetVersionInfo (Filename: String): TVSFixedFileInfo; overload;

function DriveFree(C: Char): Int64;
function FileUpdateTime(const Filename: String): TDateTime;

function NewTempFilename: String;
procedure CleanupTemp;

function NewTempFile(AtDir, AExt: String): String;
procedure FilterStringToStrings(AFilter: String; AStrings, AMasks: TStrings);
function GetFilterFileMask(AFilter: String): String;
function ChangeFilename(AOriginal, AFilename: String): String;
function DuplicateFile(AOriginal: String): Boolean;
//function ShortPathName(AFilename: String): String;
function CreateEmptyFile(AFilename: String): Boolean;
function WaitForFileLock(AFilename: String; const ATimeoutSec: Integer = 1000): Boolean;
function fileExec(const aCmdLine: String; aHide, aWait: Boolean): Boolean;
function GetFmtFileVersion(const FileName: String = '';
  const Fmt: String = '%d.%d.%d.%d'): String;

function LocalSettings(AFilename: String): string;
procedure RemoveEmptyDirs(ADirectory: String);
function IsWindowsVista: Boolean;

function ShlExec(AFilename, AParam: String; const AWaitTime: Integer;
	AWorkDir: String = ''): Boolean; overload;
  
function ShlExec(AFilename, AParam: String; AWait: Boolean;
	pExecProcHandle: PCardinal; AWorkDir: String = ''): Boolean; overload;

function ShlExec(AFilename, AParam: String; AWait: Boolean;
	AWorkDir: String = ''): Boolean; overload;

function ShlExec(AFilename, AParam: String): Boolean; overload;

function ShlExec(AFilename: String): Boolean; overload;

function RunAs(AFilename, AParam: String): Boolean;

function GetLongPathName(const ShortName : string) : string;

function GetLongPathNameA (ShortPathName: PChar; LongPathName: PChar;
                             cchBuffer: Integer): Integer; stdcall;

function GetWinVersion: String;

procedure GetLogicalDriveList (List : TStrings);
function IsDriveExists(AFilename: String): Boolean;
function EnoughDiskSpace(AFolder: String; ASpaceRequired: Int64; const AMinimum: Int64 = 0): Boolean;

function RemoveTailingSlash(APath: String): String;

function DirIsEmpty(path: String): Boolean;

function DirIsHasEx(path: string; Ex: string) : boolean;

function SetFileLastWrite(const Filename: String; ADatetime: TDatetime): Boolean;

function RemoveInvalidPathChar(APath: String): String;


var
	StopSearch: Boolean;

implementation

uses ShlObj;


{$ifdef _DELPHI_LOWVER_}
const
	CSIDL_LOCAL_APPDATA                 = $001c; { <user name>\Local Settings\Application Data (non roaming) }
	
{$endif}




var
	fLogicalDrive: TStrings;


function RemoveInvalidPathChar(APath: String): String;
const
	INVALID_PATH_CHARS = ['/', ':', '*', '?', '<', '>', '|', #13, #10];
begin
	// '[/:"*?<>|\r\n]+';
  if (Length(APath) > 3) then
  begin
    if (APath[2]=':') then Result := Copy(APath, 2, Length(APath))
    else Result := APath;
    Result := RemoveChars(Result, INVALID_PATH_CHARS);
    if (APath[2]=':') then Result := Copy(APath, 1, 2) + Result;
  end else
  	Result := APath;
end;

function RemoveTailingSlash(APath: String): String;
var
	lastChar: String;
begin
	lastChar := Copy(APath, Length(APath), 1);
  if (lastChar = '\') or (lastChar='/') then
  begin
    Result := Copy(APath, 1, Length(APath)-1);
  end else
  	Result := APath;
end;

function EnoughDiskSpace(AFolder: String; ASpaceRequired: Int64; const AMinimum: Int64 = 0): Boolean;
var
	drive: String;
begin
	drive := ExtractFileDrive(AFolder);
  if drive <> '' then
	  Result := (DiskFree(Ord(UpCase(drive[1]))-$40) - ASpaceRequired) > AMinimum
  else
  	Result := False;
end;

{判断文件夹是否为空}
function DirIsEmpty(path: String): Boolean;
var
  f: TSearchRec;
  hasNext: Boolean;
begin
  Result := True;
  path := IncludeTrailingPathDelimiter(path);
  hasNext := FindFirst(path + '*.*', faAnyFile, f) = 0;
  while hasNext do
  begin
    if (f.Name <> '.') and (f.Name <> '..') then
    begin
      Result := False;
      Break;
    end;
    hasNext := FindNext(f) = 0;
  end;
  FindClose(f);
end;

function DirIsHasEx(path: string; Ex: string) : boolean;
var
  f: TSearchRec;
  hasNext: Boolean;
begin
  Result := false;
  path := IncludeTrailingPathDelimiter(path);
  hasNext := FindFirst(path + '*.*', faAnyFile, f) = 0;
  while hasNext do
  begin
    if (f.Name <> '.') and (f.Name <> '..') then
    begin
      if Ex = ExtractFileExt(f.Name) then begin
        Result := true;
        Break;
      end;
    end;
    hasNext := FindNext(f) = 0;
  end;
  FindClose(f);
end;


function IsDriveExists(AFilename: String): Boolean;
begin
  Result := False;
  if Length(AFilename) < 1  then Exit;

  if fLogicalDrive = nil then
  begin
  	fLogicalDrive := TStringList.Create;
    GetLogicalDriveList(fLogicalDrive);
  end;

  Result := fLogicalDrive.IndexOf(Uppercase(AFilename[1])) >= 0;


end;

procedure GetLogicalDriveList (List : TStrings);
 var
   Num  : integer;
   Bits : set of 0..25;
 begin
   List.Clear;
   integer (Bits) := Windows.GetLogicalDrives;
   for Num := 0 to 25 do
     if Num in Bits then
	     List.Add (Char (Num + Ord('A')))
end;

{
function GetLongPathName(const ShortName : string) : string;
var
  aInfo: TSHFileInfo;
begin
  if SHGetFileInfo(PChar(ShortName),0,aInfo,Sizeof(aInfo),SHGFI_DISPLAYNAME)<>0 then
     Result:= String(aInfo.szDisplayName)
  else
     Result:= ShortName;
end;
}

function GetLongPathName(const ShortName : string) : string;
var
  pcBuffer: PChar;
  iLen : Integer;
begin
  Result := ShortName;
  pcBuffer := StrAlloc(MAX_PATH + 1);
  try
    iLen := GetLongPathNameA(PChar(ShortName), pcBuffer, MAX_PATH);
    // if result = 0 : conversion failed
    // if result > MAX_PATH ==> conversion failed, buffer not large enough
    if (iLen > 0) and (iLen <= MAX_PATH) then begin
      Result := StrPas(pcBuffer);
    end;  // if (iLen <= MAX_PATH) then
  finally
    StrDispose(pcBuffer);
  end;
end;

function GetWinVersion: String;
var
  osVerInfo: TOSVersionInfo;
  majorVersion, minorVersion: Integer;
begin
  Result := '';
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo) ;
  if GetVersionEx(osVerInfo) then
  begin
    minorVersion := osVerInfo.dwMinorVersion;
    majorVersion := osVerInfo.dwMajorVersion;
    case osVerInfo.dwPlatformId of
      VER_PLATFORM_WIN32_NT:
      begin
        if majorVersion <= 4 then
          Result := 'WinNT'
        else if (majorVersion = 5) and (minorVersion = 0) then
          Result := 'Win2000'
        else if (majorVersion = 5) and (minorVersion = 1) then
          Result := 'WinXP'
        else if (majorVersion = 6) then
          Result := 'Vista'
        else if (majorVersion = 7) then
          Result := 'Win7';
      end;
      VER_PLATFORM_WIN32_WINDOWS:
      begin
        if (majorVersion = 4) and (minorVersion = 0) then
          Result := 'Win95'
        else if (majorVersion = 4) and (minorVersion = 10) then
        begin
          if osVerInfo.szCSDVersion[1] = 'A' then
            Result := 'Win98se'
          else
            Result := 'Win98';
        end
        else if (majorVersion = 4) and (minorVersion = 90) then
          Result := 'WinME'
        else
          Result := '';
      end;
    end;
  end;
end;

function IsWindowsVista: Boolean;   
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);        
  Result := VerInfo.dwMajorVersion >= 6;
end;

function FormattedVersion(AVersion: TVSFixedFileInfo): String;
begin
  Result := Format('%d.%d.%d.%d', [AVersion.dwFileVersionMS,
    AVersion.dwFileVersionLS, AVersion.dwFileVersionMS, AVersion.dwProductVersionLS]);    
end;

procedure ListDirs(ADir: WideString; ADirectories: TStrings);
var
	Found: TSearchRec;
  i : Integer;
  Dirs: TStrings; //Store sub-directories
  Finished : Integer; //Result of Finding
  fPath: WideString;
begin
  if not DirExists(ADir) then Exit;
	StopSearch := False;
	Dirs := TStringList.Create;
  fPath := formFilename(ADir, '*');
	Finished := FindFirst(fPath, faDirectory, Found);
  while (Finished = 0) and not (StopSearch) do
  begin
  	//Check if the name is valid.
  	if (Found.Name[1] <> '.') then
 		begin
    //Check if file is a directory
    	if (Found.Attr and faDirectory = faDirectory) then
      begin
      	Dirs.Add(formFilename(ADir, Found.Name))  //Add to the directories list.

      end;
    end;
		Finished := FindNext(Found);
  end;
  //end the search process.
  // Windows.FindClose(Found.FindHandle);  
  FindClose(Found);
  //Check if any sub-directories found
 	for i := 0 to Dirs.Count - 1 do
   	//If sub-dirs then search agian ~>~>~> on and on, until it is done.
		ListDirs(Dirs[i], ADirectories);
  ADirectories.AddStrings(Dirs);
  //Clear the memories.
  Dirs.Free;
end;

procedure DeleteDir(ADir: String);
begin
//  fileExec('rmdir ' + ADir + '\', False, False);
  RemoveDirectoryW(PWideChar(ADir));
end;

{$ifdef _DELPHI_LOWVER_}
procedure RemoveEmptyDirs(ADirectory: String);
var
  dirs: TStrings;
  fdir: String;
  I: Integer;
begin
  dirs := TStringList.Create;
  ListDirs(ADirectory, dirs);
  for I := 0 to Dirs.Count-1 do
  begin
  	fdir := Dirs[I];
//    Log('RemoveEmptyDirs', fDir);
    DeleteDir(fdir);
  end;
  DeleteDir(ADirectory);
  dirs.Free;
end;
{$else}
procedure RemoveEmptyDirs(ADirectory: String);
var
  dirs: TStrings;
  fdir: String;
begin
  dirs := TStringList.Create;
  ListDirs(ADirectory, dirs);
  for fdir in Dirs do
  begin
//    Log('RemoveEmptyDirs', fDir);
    DeleteDir(fdir);
  end;
  DeleteDir(ADirectory);
  dirs.Free;
end;
{$endif}

function LocalSettings(AFilename: String): string;
begin
  Result := winshell.GetSpecialFolderPath(CSIDL_LOCAL_APPDATA, False);
  if Result <> '' then
  begin
    Result := formFilename(Result, AFilename);
  end else
  begin
    raise Exception.Create('Local Setting does not exist.');
  end;
end;

function ShlExec(AFilename: String): Boolean;
begin
  Result := ShlExec(AFilename, '');
end;

function ShlExec(AFilename, AParam: String): Boolean;
begin
  Result := ShlExec(AFilename, AParam, False);
end;

function RunAs(AFilename, AParam: String): Boolean;
var
  shExecInfo: TShellExecuteInfo;
begin
  FillChar(shExecInfo, SizeOf(shExecInfo), 0);
  shExecInfo.cbSize := sizeof(TShellExecuteInfo);
  shExecInfo.lpVerb := 'runas';
  shExecInfo.lpFile := PChar(AFilename);
  shExecInfo.lpParameters := PChar(AParam);
  shExecInfo.nShow := SW_SHOW;
  Result := ShellExecuteEx(@shExecInfo);
end;

function ShlExec(AFilename, AParam: String; AWait: Boolean;
	pExecProcHandle: PCardinal; AWorkDir: String = ''): Boolean;
var
  shExecInfo: TShellExecuteInfo;
  ExitCode: Cardinal;
begin
  FillChar(shExecInfo, SizeOf(shExecInfo), 0);
  shExecInfo.cbSize := sizeof(TShellExecuteInfo);
  if IsWindowsVista then
    shExecInfo.lpVerb := 'runas'
  else
    shExecInfo.lpVerb := 'open';
  shExecInfo.lpFile := PChar(AFilename);
  shExecInfo.lpParameters := PChar(AParam);
  shExecInfo.lpDirectory := PChar(AWorkDir);
  shExecInfo.nShow := SW_SHOW;
  shExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  Result := ShellExecuteEx(@shExecInfo);

  if Result and AWait then
  begin
  	// Added by wangyong.wesley 2010-9-17 10:08:16
    // Add execute wait time out in sddown, return process
    if pExecProcHandle <> nil then
			pExecProcHandle^ := shExecInfo.hProcess;
    
  end;
end;

function ShlExec(AFilename, AParam: String; const AWaitTime: Integer;
	AWorkDir: String = ''): Boolean;
var
  shExecInfo: TShellExecuteInfo;
  ExitCode: Cardinal;
  ProcessHandle: Cardinal;
  WaitedTime: Cardinal;
begin

	Result := ShlExec(AFilename, AParam, True, @ProcessHandle, AWorkDir);
  if Result and (AWaitTime > 0) then
  begin
  	WaitedTime := 0;
    repeat
      Sleep(50);
      Inc(WaitedTime, 50);
      if WaitedTime > AWaitTime then Break;      
    	GetExitCodeProcess(ProcessHandle, ExitCode) ;
    until (ExitCode <> STILL_ACTIVE);
  end;
  Result := ExitCode <> 0;
end;


function ShlExec(AFilename, AParam: String; AWait: Boolean;
	AWorkDir: String = ''): Boolean;
begin
	if AWait then
		Result := ShlExec(AFilename, AParam, MAXINT, AWorkDir)
  else
		Result := ShlExec(AFilename, AParam, 0, AWorkDir);
end;

function fileExec(const aCmdLine: String; aHide, aWait: Boolean): Boolean;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
begin

  if IsWindowsVista then
  begin
    Result := ShlExec(aCmdLine, '');
    Exit;
  end;

  {setup the startup information for the application }
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do
  begin
    cb:= SizeOf(TStartupInfo);
    dwFlags:= STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    if aHide then wShowWindow:= SW_HIDE
             else wShowWindow:= SW_SHOWNORMAL;
  end;

  Result := CreateProcess(nil, PChar(aCmdLine), nil, nil, False,
               NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);

  if not Result then
  begin
    OutputDebugString(PChar(Format('Failed CreateProcess: %d', [GetLastError])));
  end;
  
  if aWait then
     if Result then
     begin
       WaitForInputIdle(ProcessInfo.hProcess, INFINITE);
       WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
     end;
end;


function WaitForFileLock(AFilename: String; const ATimeoutSec: Integer = 1000): Boolean;
var
  fh: Integer;
  stop: Integer;
begin

  Result := False;
  stop := GetTickCount + ATimeoutSec*1000;
  repeat
    fh := FileOpen(AFileName, fmOpenRead);
    if fh < 0 then
    begin
      raise Exception.Create('Cannot open file for read');
    end;
    if GetTickCount > stop then
    begin
      Break;
    end;
  until fh >= 0;

  Result := fh >= 0;

  if Result then FileClose(fh);


end;

function CreateEmptyFile(AFilename: String): Boolean;
var
  filestream: TFileStream;
begin
  Result := False;
  filestream := TFileStream.Create(AFilename, fmCreate);  
  try
    Result := True;
  finally
    filestream.Free;
  end;
end;

//function ShortPathName(AFilename: String): String;
//begin
//	SetLength(Result, 200);
//  GetShortPathName(PChar(AFilename), @Result[1], 200);
//	Result := StrPas(@Result[1]);
//end;

function GetFilterFileMask(AFilter: String): String;
var
	i: Integer;
begin
	i := Pos('|', AFilter);
	if i > 0 then Result := Copy(AFilter, i+1, Length(AFilter)) else Result := AFilter;
end;

procedure FilterStringToStrings(AFilter: String; AStrings, AMasks: TStrings);
var
	j: Integer;
  s, cap, mask: String;
begin
  s := AFilter;
  AStrings.Clear;
  AMasks.Clear;
  while (s<>'') do
  begin
  	j := Pos('|', s);
    if j>0 then
    begin
			cap := Copy(s, 1, j-1);
      Delete(s, 1, j);
    end else Cap := '';
  	j := Pos('|', s);
    if j>0 then
    begin
			mask := Copy(s, 1, j-1);
      Delete(s, 1, j);
    end else
    begin
	    mask := s;
    end;
    if Cap<>'' then
	    AStrings.Add(Cap)
    else
	    AStrings.Add(mask);
    AMasks.Add(mask);
    if Mask=s then Break;
  end;    // while
end;

var
	TempFiles: TStrings;

function NewTempFilename: String;
var
	i: Integer;
begin
	i := $8;
	repeat
		Result := formFilename(TmpDir, IntToStr(i)+'.tmp');
		inc(i);
	until (not FileExists(result));
	TempFiles.Add(Result);
end;

function NewTempFile(AtDir,AExt: String): String;
var
	i: Integer;
begin
	i := Random($1000);
	repeat
		Result := formFilename(AtDir, IntToStr(i)+AExt);
		i := Random($1000);
	until (not FileExists(result));
	TempFiles.Add(Result);
end;

procedure CleanupTemp;
var
	i: INteger;
begin
	for i := 0 to tempFiles.Count-1 do
	begin
		try
			DeleteFile(tempFiles[i]);
		except
		end;
	end;
	tempFiles.Clear;
end;

function DriveFree(C: Char): Int64;
var
	Root: array[0..3] of Char;
  d1,d2: Int64;
begin
  Root := 'C:\';
	Root[0] := C;
  Root[3] := #0;
  if not GetDiskFreeSpaceEx(@Root[0], d1,d2, @Result) then
    Result := -1;
end;

const
  KB = 1024;
  MB = KB*1024;
  GB = MB*1024;

function EngFileSize(ASize: Int64): String;
begin
  if ASize < MB then
    Result := FormatFloat('0.## KB', ASize/KB)
  else if ASize < GB then
    Result := FormatFloat('0.## MB', ASize/MB)
  else
    Result := FormatFloat('0.## GB', ASize/GB);

end;

function EngFileSizeF(ASize: Real): String;
begin
	if ASize<KB then Result := FormatFloat('#.## B', ASize)
  else if ASize<MB then Result := FormatFloat('#.## KB', ASize/KB)
	else if ASize<GB then Result := FormatFloat('#.## MB', ASize/MB)
  else Result := FormatFloat('#.## GB', ASize/GB);
end;

function SearchFind(const Dir, Filename: String): String;
var
	Found: TSearchRec;
  i : Integer;
  Dirs: TStrings;
  Finished : Integer;
begin
	Result := '';
	StopSearch := False;
  if FileExists(formFilename(Dir, Filename)) then
  begin
  	Result := formFilename(Dir, Filename);
    Exit;
  end;
	Dirs := TStringList.Create;
	Finished := FindFirst(formFilename(Dir, '*.*'), faDirectory, Found);
  while (Finished = 0) and not (StopSearch) do
  begin
  	//Check if the name is valid.
  	if (Found.Name[1] <> '.') then
 		begin
    //Check if file is a directory
    	if (Found.Attr and faDirectory = faDirectory) then
      	Dirs.Add(formFilename(Dir, Found.Name));
    end;
		Finished := FindNext(Found);
  end;
  //end the search process.
  FindClose(Found);
  //Check if any sub-directories found
	if not StopSearch then
  	for i := 0 to Dirs.Count - 1 do
		begin
    	Result := SearchFind(Dirs[i], Filename);
      if Result <> '' then Exit;
    end;
  Dirs.Free;
end;

function RelativeDir(Dir, APath: String): String;
var
	Up: Boolean;
  s: String;
begin
	Result := Dir;
	s := APath;
  Up := Pos('../', s)=1;
	while Up do
  begin
		DirUp(Result);
    Delete(s, 1, 3);
	  Up := Pos('../', s)=1;
  end;
  Result := formFilename(Result, s);
end;

function FileSize(Filename: TFilename): LongInt;
var
	HFile: Integer;
  OFS: TOFSTRUCT;
begin
	HFile := OpenFile(PAnsiChar(Filename), OFS, 0);
  Result := GetFileSize(HFile, nil);
  CloseHandle(HFile);
end;

function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
	LocalTime: TFileTime;
	SysTime: TSystemTime;
begin
  FileTimeToLocalFileTime(FileTime, LocalTime);
	FileTimeToSystemTime(LocalTime, SysTime);
  Result := SystemTimeToDateTime(SysTime);
end;

function FileLastWrite(const Filename: String): TFileTime;
var
	hf: Integer;
  dum: TFileTime;
  i: Integer;
begin
	hF := FileOpen(Filename, fmOpenRead);
  try
  	i := 0;
		repeat
    	inc(i);
    until	(GetFileTime(hF, @dum, @dum, @Result)) or (i>=10);

  finally
	  FileClose(hF);
  end;
end;

function SetFileLastWrite(const Filename: String; ADatetime: TDatetime): Boolean;
begin
  FileSetDate( Filename, DateTimeToFileDate(ADatetime));
end;

{$WARNINGS OFF}
function FileUpdateTime(const Filename: String): TDateTime;
var
	hf: Integer;
  F1, F2, F3: TFileTime;
  Systime: TSystemTime;
begin
	hF := FileOpen(Filename, fmOpenRead);
	GetFileTime(hF, @F1, @F2, @F3);
  GetSystemTime(Systime);
  SystemTimeToFileTime(Systime, F3);
  SetFileTIme(hF, @F1, @F2, @F3);
  FileClose(hF);
end;
{$WARNINGS OFF}

function GetFmtFileVersion(const FileName: String = '';
  const Fmt: String = '%d.%d.%d.%d'): String;
var
  sFileName: String;
  iBufferSize: DWORD;
  iDummy: DWORD;
  pBuffer: Pointer;
  pFileInfo: Pointer;
  iVer: array[1..4] of Word;
begin
  // set default value
  Result := '';
  // get filename of exe/dll if no filename is specified
  sFileName := FileName;
  if (sFileName = '') then
  begin
    // prepare buffer for path and terminating #0
    SetLength(sFileName, MAX_PATH + 1);
    SetLength(sFileName,
      GetModuleFileName(hInstance, PChar(sFileName), MAX_PATH + 1));
  end;
  // get size of version info (0 if no version info exists)
  iBufferSize := GetFileVersionInfoSize(PChar(sFileName), iDummy);
  if (iBufferSize > 0) then
  begin
    GetMem(pBuffer, iBufferSize);
    try
    // get fixed file info (language independent)
    GetFileVersionInfo(PChar(sFileName), 0, iBufferSize, pBuffer);
    VerQueryValue(pBuffer, '\', pFileInfo, iDummy);
    // read version blocks
    iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
    iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
    iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
    iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
    finally
      FreeMem(pBuffer);
    end;
    // format result string
    Result := Format(Fmt, [iVer[1], iVer[2], iVer[3], iVer[4]]);
  end;
end;

function GetVersionInfo (Filename: String): TVSFixedFileInfo;
begin
  GetVersionInfo(Filename, Result);
end;

function GetVersionInfo ({$IFDEF WIN32}const{$ENDIF} Filename: String;
  var VersionInfo: {$IFDEF WIN32} TVSFixedFileInfo {$ELSE} tvs_FixedFileInfo {$ENDIF}): Boolean;
var
  VersionSize: Integer;
  VersionHandle: DWORD;
  VersionBuf: PChar;
  VerInfo: {$IFDEF WIN32} PVSFixedFileInfo {$ELSE} pvs_FixedFileInfo {$ENDIF};
  VerInfoSize: UINT;
begin
  Result := False;

  VersionSize := GetFileVersionInfoSize(PChar(Filename),
    VersionHandle);
  if VersionSize <> 0 then begin
    GetMem (VersionBuf, VersionSize);
    try
      if GetFileVersionInfo(PChar(Filename), VersionHandle, VersionSize, VersionBuf) then begin
        if VerQueryValue(VersionBuf, '\', Pointer(VerInfo), VerInfoSize) then begin
          VersionInfo := VerInfo^;
          Result := True;
        end;
      end;
    finally
      FreeMem (VersionBuf, VersionSize);
    end;
  end;
end;

function FileDateTime(const Filename: String): TDateTime;
var
	hf: Integer;
  F1, F2, F3: TFileTime;
begin
	hF := FileOpen(Filename, fmOpenRead);
	GetFileTime(hF, @F1, @F2, @F3);
  Result := FileTimeToDateTime(F1);
  FileClose(hF);
end;

procedure SearchFileExt(const Dir, Ext: String; Files: TStrings; SubDir: Boolean);
var
	Found: TSearchRec;
  ThisExt: String;
  i : Integer;
  Dirs: TStrings; //Store sub-directories
  Finished : Integer; //Result of Finding
begin
  if not DirExists(Dir) then Exit;
	StopSearch := False;
	Dirs := TStringList.Create;
	Finished := FindFirst(formFilename(Dir, '*.*'), 63, Found);
  while (Finished = 0) and not (StopSearch) do
  begin
  	//Check if the name is valid.
  	if (Found.Name[1] <> '.') then
 		begin
    //Check if file is a directory
    	if (Found.Attr and faDirectory = faDirectory) and SubDir then
      	Dirs.Add(formFilename(Dir, Found.Name))  //Add to the directories list.
    	else
   		begin
      	ThisExt := ExtractFileExt(Found.Name);
        if (Ext <> '*') and (Ext <> '') then
        begin
        	if Pos(UpperCase(ThisExt), UpperCase(Ext))>0 then
        		Files.Add(formFilename(Dir, Found.Name));
        end else
        begin
      		Files.Add(formFilename(Dir, Found.Name));
        end;
      end;
    end;
		Finished := FindNext(Found);
  end;
  //end the search process.
  FindClose(Found);
  //Check if any sub-directories found
	if not StopSearch then
  	for i := 0 to Dirs.Count - 1 do
    	//If sub-dirs then search agian ~>~>~> on and on, until it is done.
			SearchFileExt(Dirs[i], Ext, Files, SubDir);

  //Clear the memories.
  Dirs.Free;
end;

function FilenameOnly(const Filename: String): String;
begin
	Result := ExtractFilename(Filename);
  Result := ChangeFileExt(Filename, '');
end;

function DirUp(Directory: String): String;
begin
	Result := Directory;
	if Result[Length(Result)]='\' then
  	Delete(Result, Length(Result), 1);
	Delete(Result, Length(Result) - Length(LastDir(Result)), Length(Result));
end;

function AppPath: String; overload;
begin
	Result := ExtractFilepath(ParamStr(0));
end;

function AppPath(AFilename: String): String; overload;
begin
	Result := formFilename(ExtractFilepath(ParamStr(0)), AFilename);
end;

function TmpDir: String;
var
	Dir: array[0..255] of Char;
  Size: Integer;
begin
	Size := SizeOf(Dir) - 1;
  GetTempPath(Size, Dir);
  Result := Dir;
end;

function ExtractFilepath(const Filename: TFilename): String;
begin
	Result := SysUtils.ExtractFilepath(Filename);
  //Use the orignal function first, and ...
  if Result = '' then Exit;
  if Result[Length(Result)] = '\' then   //Delete it.
  	Delete(Result, Length(Result), 1);
end;

function LastDir(Dir: String): String;
begin
	if Dir[Length(Dir)]='\' then
  	Delete(Dir, Length(Dir), 1);
  Result := RightStr(Dir, RPos('\', Dir)+1);
end;

function AppExe: String;
begin
	Result := ParamStr(0);
end;

function GetWinDir : String;
var
	Dir: array[0..255] of Char;
	Size: Integer;
begin
	Size := SizeOf(Dir) - 1;
	GetWindowsDirectory(Dir, Size);
	Result := Dir;
end;

function GetSysDir : String;
var
	Dir: array[0..255] of Char;
	Size: Integer;
begin
	Size := SizeOf(Dir) - 1;
	GetSystemDirectory(Dir, Size);
	Result := Dir;
end;

function CreateDirs(const Dirs: String) : Boolean;
//var
//	i : Integer;
//  mD, CurrDir : String;
//begin
//	MD := Dirs;
//	if RightStr(MD, 1) <> '\' then MD := MD + '\';
//	Result := DirExists(Dirs);
//	i := 0;
//  i := Instr(i + 1, MD, '\');
//  if i = 0 then Exit;
//  i := Instr(i + 1, MD, '\');
//  if i = 0 then Exit;
//  CurrDir := Copy(MD, 1, i - 1);
//  while not DirExists(Dirs) do
//	begin
//    if not FileExists(CurrDir) then CreateDir(CurrDir);
//	  i := Instr(i + 1, MD, '\');
//	  if i > 0 then
//    	CurrDir := Copy(MD, 1, i - 1);
//  end;
//  Result := True;
//end;
begin
  Result := ForceDirectories(Dirs);
end;

function formFilename(const Dir, Filename: String): String;
var
	Fl: String;
begin
	Fl := Filename;
	if Fl <> '' then
		if Fl[1] = '\' then Delete(Fl, 1, 1);
	if Dir = '' then
		Result := Dir + Fl
	else if Dir[Length(Dir)] = '\' then
		Result := Dir + Fl
  else
  Result := Dir + '\' + Fl;
end;

function TestWrite(const Dir: String): Boolean;
var
	F: File;
begin
  {$I-}
  AssignFile(F, formFilename(Dir, '~xxy45!j.tmp'));
  ReWrite(F);
  if IOResult <> 0 then
	begin
  	Result := False;
    Exit;
  end
  else
  	Result := True;
  CloseFile(F);
  DeleteFile(formFilename(Dir, '~xxy45!j.tmp'));
  {$I+}
end;

function DirExists(const Dir: String): Boolean;
begin
  Result := DirectoryExists(Dir);
end;

function ChangeFilename(AOriginal, AFilename: String): String;
begin
	Result := formFilename(ExtractFilepath(AOriginal), AFilename);
end;

function DuplicateFile(AOriginal: String): Boolean;
var
	i: Integer;
	nf, Filename, ext: String;
begin
	ext := ExtractFileExt(AOriginal);
  Filename := ExtractFilename(AOriginal);
	nf := formFilename(ExtractFilepath(AOriginal), Filename + ' Copy' + ext);
  i := 1;
	while FileExists(nf) do
  begin
    nf := formFilename(ExtractFilepath(AOriginal), Filename + ' Copy ' + IntToStr(i) + ext);
    Inc(i);
  end;    // while
	Result := CopyFile(PChar(AOriginal), PChar(nf), True);
end;

function GetLongPathNameA; external kernel32 name 'GetLongPathNameA';

initialization
	tempFiles := TStringList.Create;

finalization
	CleanupTemp;
	tempFiles.Free;

end.
