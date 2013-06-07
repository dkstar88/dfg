unit WinShell;

interface

uses SysUtils, Classes, Windows, Registry, ActiveX, ShlObj;

type
 EShellOleError = class(Exception);

 TShellLinkInfo = record
  PathName: string;
  Arguments: string;
  Description: string;
  WorkingDirectory: string;
  IconLocation: string;
  IconIndex: integer;
  ShowCmd: integer;
  HotKey: word;
 end;

 TSpecialFolderInfo = record
  Name: string;
  ID: Integer;
 end;

const
 SpecialFolders: array[0..29] of TSpecialFolderInfo = (
  (Name: 'Alt Startup'; ID: CSIDL_ALTSTARTUP),
  (Name: 'Application Data'; ID: CSIDL_APPDATA),
  (Name: 'Recycle Bin'; ID: CSIDL_BITBUCKET),
  (Name: 'Common Alt Startup'; ID: CSIDL_COMMON_ALTSTARTUP),
  (Name: 'Common Desktop'; ID: CSIDL_COMMON_DESKTOPDIRECTORY),
  (Name: 'Common Favorites'; ID: CSIDL_COMMON_FAVORITES),
  (Name: 'Common Programs'; ID: CSIDL_COMMON_PROGRAMS),
  (Name: 'Common Start Menu'; ID: CSIDL_COMMON_STARTMENU),
  (Name: 'Common Startup'; ID: CSIDL_COMMON_STARTUP),
  (Name: 'Controls'; ID: CSIDL_CONTROLS),
  (Name: 'Cookies'; ID: CSIDL_COOKIES),
  (Name: 'Desktop'; ID: CSIDL_DESKTOP),
  (Name: 'Desktop Directory'; ID: CSIDL_DESKTOPDIRECTORY),
  (Name: 'Drives'; ID: CSIDL_DRIVES),
  (Name: 'Favorites'; ID: CSIDL_FAVORITES),
  (Name: 'Fonts'; ID: CSIDL_FONTS),
  (Name: 'History'; ID: CSIDL_HISTORY),
  (Name: 'Internet'; ID: CSIDL_INTERNET),
  (Name: 'Internet Cache'; ID: CSIDL_INTERNET_CACHE),
  (Name: 'Network Neighborhood'; ID: CSIDL_NETHOOD),
  (Name: 'Network Top'; ID: CSIDL_NETWORK),
  (Name: 'Personal'; ID: CSIDL_PERSONAL),
  (Name: 'Printers'; ID: CSIDL_PRINTERS),
  (Name: 'Printer Links'; ID: CSIDL_PRINTHOOD),
  (Name: 'Programs'; ID: CSIDL_PROGRAMS),
  (Name: 'Recent Documents'; ID: CSIDL_RECENT),
  (Name: 'Send To'; ID: CSIDL_SENDTO),
  (Name: 'Start Menu'; ID: CSIDL_STARTMENU),
  (Name: 'Startup'; ID: CSIDL_STARTUP),
  (Name: 'Templates'; ID: CSIDL_TEMPLATES));

type
  TGetShellLinkOption = (slPathname, slArguments,
    slDescription, slWorkingDirectory, slIconLocation, slShowCmd, slHotKey);
  TGetShellLinkOptions = set of TGetShellLinkOption;

const
  GetShellLinkOptions_All = [slPathname, slArguments,
    slDescription, slWorkingDirectory, slIconLocation, slShowCmd, slHotKey];

function CreateShellLink(const AppName, Desc: string; Dest: Integer): string; overload;
function CreateShellLink(const AppName, Desc: string; Dest: String): string; overload;
function GetShellLink(const AppName, Desc: string; Dest: Integer): string; overload;
function GetShellLink(const AppName, Desc: string; Dest: String): string; overload;

function GetSpecialFolderPath(Folder: Integer; CanCreate: Boolean = False): string;
procedure GetShellLinkInfo(const LinkFile: WideString;
 var SLI: TShellLinkInfo; AOptions: TGetShellLinkOptions = GetShellLinkOptions_All);
procedure SetShellLinkInfo(const LinkFile: WideString;
 const SLI: TShellLinkInfo);


function ShExecute(const FileName, Parameters: String): Boolean; overload;

function ShExecute(const FileName, Parameters: String;
  var ExitCode: DWORD; const Wait: DWORD = 0;
  const Hide: Boolean = False): Boolean; overload;

function ShellRedirectedExecute(const CmdLine: String;
  var Output, Error: String; const Wait: DWORD = 3600000): Boolean;

function EnabledDebugPrivilege(const bEnabled: Boolean): Boolean;



implementation

uses ComObj, ShellAPI;



function EnabledDebugPrivilege(const bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  tp: TOKEN_PRIVILEGES;
  a: DWORD;
const
	SE_DEBUG_NAME = 'SeDebugPrivilege';
begin
	Result := False;
  if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken)) then
  begin
    tp.PrivilegeCount := 1;
    LookupPrivilegeValue(nil, SE_DEBUG_NAME, tp.Privileges[0].Luid);
    if bEnabled then
      tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      tp.Privileges[0].Attributes := 0;
    a := 0;
    AdjustTokenPrivileges(hToken, False, tp, SizeOf(tp), nil, a);
    //ShowMessage( IntToStr( GetLastError ));
    Result := GetLastError = ERROR_SUCCESS;


    CloseHandle(hToken);
  end;
end;



function ShExecute(const FileName, Parameters: String): Boolean;
var
  tmp: DWord;
begin
  Result := ShExecute(Filename, Parameters, tmp);
end;

function ShExecute(const FileName, Parameters: String;
  var ExitCode: DWORD; const Wait: DWORD = 0;
  const Hide: Boolean = False): Boolean;
var
  myInfo: SHELLEXECUTEINFO;
  iWaitRes: DWORD;
begin
  // prepare SHELLEXECUTEINFO structure
  ZeroMemory(@myInfo, SizeOf(SHELLEXECUTEINFO));
  myInfo.cbSize := SizeOf(SHELLEXECUTEINFO);
  myInfo.lpDirectory := PChar(ExtractFilepath(FileName));
  myInfo.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI;
  myInfo.lpFile := PChar(FileName);
  myInfo.lpParameters := PChar(Parameters);
  if Hide then
    myInfo.nShow := SW_HIDE
  else
    myInfo.nShow := SW_SHOWNORMAL;
  // start file
  ExitCode := 0;
  Result := ShellExecuteEx(@myInfo);
  // if process could be started
  if Result then
  begin
    // wait on process ?
    if (Wait > 0) then
    begin
      iWaitRes := WaitForSingleObject(myInfo.hProcess, Wait);
      // timeout reached ?
      if (iWaitRes = WAIT_TIMEOUT) then
      begin
        Result := False;
//        Log('ShExecute', Format('Wait timeout', []));
        // TerminateProcess(myInfo.hProcess, 0);
      end;
      // get the exitcode
      GetExitCodeProcess(myInfo.hProcess, ExitCode);
    end;
    // close handle, because SEE_MASK_NOCLOSEPROCESS was set
    CloseHandle(myInfo.hProcess);
  end;
end;

function GetSpecialFolderPath(Folder: Integer; CanCreate: Boolean = False): string;
var
 FilePath: array[0..MAX_PATH] of widechar;
begin
 { Get path of selected location }
 SHGetSpecialFolderPathW(0, FilePath, Folder, CanCreate);
 Result := FilePath;
end;

function GetShellLink(const AppName, Desc: string; Dest: String): string;
{ Creates a shell link for application or document specified in }
{ AppName with description Desc. Link will be located in folder }
{ specified by Dest, which is one of the string constants shown }
{ at the top of this unit. Returns the full path name of the  }
{ link file. }
var
 LnkName: WideString;
begin
	Result := '';

	{ create a path location and filename for link file }
  LnkName := Dest + '\' + ChangeFileExt(Desc, '.lnk');

 	if LnkName <> '' then
  	//if FileExists(LnkName) then
 			Result := LnkName;
end;

function CreateShellLink(const AppName, Desc: string; Dest: String): string;
{ Creates a shell link for application or document specified in }
{ AppName with description Desc. Link will be located in folder }
{ specified by Dest, which is one of the string constants shown }
{ at the top of this unit. Returns the full path name of the  }
{ link file. }
var
 SL: IShellLink;
 PF: IPersistFile;
 LnkName: WideString;
begin

	Result := '';
  OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, SL));
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  PF := SL as IPersistFile;
  OleCheck(SL.SetPath(PChar(AppName))); // set link path to proper file
  if Desc <> '' then OleCheck(SL.SetDescription(PChar(Desc))); // set description
  { create a path location and filename for link file }
  LnkName := Dest + '\' + ChangeFileExt(Desc, '.lnk');
 	if LnkName <> '' then begin
 		Result := LnkName;

    ForceDirectories(ExtractFilePath(LnkName));
    PF.Save(PWideChar(LnkName), True);     // save link file
  end;
end;


function GetShellLink(const AppName, Desc: string; Dest: Integer): string;
{ Creates a shell link for application or document specified in }
{ AppName with description Desc. Link will be located in folder }
{ specified by Dest, which is one of the string constants shown }
{ at the top of this unit. Returns the full path name of the  }
{ link file. }
var
// SL: IShellLink;
// PF: IPersistFile;
 LnkName: WideString;
begin
	Result := '';
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  { create a path location and filename for link file }
  LnkName := GetSpecialFolderPath(Dest, True) + '\' + ChangeFileExt(Desc, '.lnk');
 	if LnkName <> '' then begin
  	//if FileExists(LnkName) then
 			Result := LnkName;
  end;
end;

function CreateShellLink(const AppName, Desc: string; Dest: Integer): string;
{ Creates a shell link for application or document specified in }
{ AppName with description Desc. Link will be located in folder }
{ specified by Dest, which is one of the string constants shown }
{ at the top of this unit. Returns the full path name of the  }
{ link file. }
var
 SL: IShellLink;
 PF: IPersistFile;
 LnkName: WideString;
begin

	Result := '';
  OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
  IShellLink, SL));
  { The IShellLink implementer must also support the IPersistFile }
  { interface. Get an interface pointer to it. }
  PF := SL as IPersistFile;
  OleCheck(SL.SetPath(PChar(AppName))); // set link path to proper file
  if Desc <> '' then
  OleCheck(SL.SetDescription(PChar(Desc))); // set description
  { create a path location and filename for link file }
  LnkName := GetSpecialFolderPath(Dest, True) + '\' + ChangeFileExt(Desc, '.lnk');
 	if LnkName <> '' then begin
 		Result := LnkName;
	 	PF.Save(PWideChar(LnkName), True);     // save link file
  end;
  
end;


procedure GetShellLinkInfo(const LinkFile: WideString;
 var SLI: TShellLinkInfo; AOptions: TGetShellLinkOptions = GetShellLinkOptions_All);
{ Retrieves information on an existing shell link }
var
 SL: IShellLink;
 PF: IPersistFile;
 FindData: TWin32FindData;
 AStr: array[0..MAX_PATH] of char;
begin
  FillChar(SLI, SizeOf(SLI), 0);
try
 OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
  IShellLink, SL));
 { The IShellLink implementer must also support the IPersistFile }
 { interface. Get an interface pointer to it. }
 PF := SL as IPersistFile;
 { Load file into IPersistFile object }
 OleCheck(PF.Load(PWideChar(LinkFile), STGM_READ));
 { Resolve the link by calling the Resolve interface function. }
 OleCheck(SL.Resolve(0, SLR_ANY_MATCH or SLR_NO_UI));
 { Get all the info! }
 with SLI do
 begin
  if (slPathName in AOptions) then
  begin
    OleCheck(SL.GetPath(AStr, MAX_PATH, FindData, SLGP_SHORTPATH));
    PathName := AStr;
  end;
  if slArguments in AOptions then
  begin
    OleCheck(SL.GetArguments(AStr, MAX_PATH));
    Arguments := AStr;
  end;
  if slDescription in AOptions then
  begin
    OleCheck(SL.GetDescription(AStr, MAX_PATH));
    Description := AStr;
  end;
  if slWorkingDirectory in AOptions then
  begin
    OleCheck(SL.GetWorkingDirectory(AStr, MAX_PATH));
    WorkingDirectory := AStr;
  end;
  if slIconLocation in AOptions then
  begin
    OleCheck(SL.GetIconLocation(AStr, MAX_PATH, IconIndex));
    IconLocation := AStr;
  end;
  if slShowCmd in AOptions then OleCheck(SL.GetShowCmd(ShowCmd));
  if slHotKey in AOptions then OleCheck(SL.GetHotKey(HotKey));
 end;
except
	on E: Exception do
  begin
    Raise Exception.Create(LinkFile);
  end;
end;
end;

procedure SetShellLinkInfo(const LinkFile: WideString;
 const SLI: TShellLinkInfo);
{ Sets information for an existing shell link }
var
 SL: IShellLink;
 PF: IPersistFile;
begin
 OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
  IShellLink, SL));
 { The IShellLink implementer must also support the IPersistFile }
 { interface. Get an interface pointer to it. }
 PF := SL as IPersistFile;
 { Load file into IPersistFile object }
 OleCheck(PF.Load(PWideChar(LinkFile), STGM_SHARE_DENY_WRITE));
 { Resolve the link by calling the Resolve interface function. }
 OleCheck(SL.Resolve(0, SLR_ANY_MATCH or SLR_UPDATE or SLR_NO_UI));
 { Set all the info! }
 with SLI, SL do
 begin
  OleCheck(SetPath(PChar(PathName)));
  OleCheck(SetArguments(PChar(Arguments)));
  OleCheck(SetDescription(PChar(Description)));
  OleCheck(SetWorkingDirectory(PChar(WorkingDirectory)));
  OleCheck(SetIconLocation(PChar(IconLocation), IconIndex));
  OleCheck(SetShowCmd(ShowCmd));
  OleCheck(SetHotKey(HotKey));
 end;
 PF.Save(PWideChar(LinkFile), True);  // save file
end;


type
  TStoReadPipeThread = class(TThread)
  protected
    FPipe: THandle;
    FContent: TStringStream;
    function Get_Content: String;
    procedure Execute; override;
  public
    constructor Create(const Pipe: THandle);
    destructor Destroy; override;
    property Content: String read Get_Content;
  end;

constructor TStoReadPipeThread.Create(const Pipe: THandle);
begin
  FPipe := Pipe;
  FContent := TStringStream.Create('');
  inherited Create(True);
end;

destructor TStoReadPipeThread.Destroy;
begin
  FContent.Free;
  inherited Destroy;
end;

procedure TStoReadPipeThread.Execute;
const
  BLOCK_SIZE = 4096;
var
  iBytesRead: DWORD;
  myBuffer: array[0..BLOCK_SIZE-1] of Byte;
begin
  repeat
    // try to read from pipe
    if ReadFile(FPipe, myBuffer, BLOCK_SIZE, iBytesRead, nil) then
      FContent.Write(myBuffer, iBytesRead);
  // a process may write less than BLOCK_SIZE, even if not at the end
  // of the output, so checking for < BLOCK_SIZE would block the pipe.
  until (iBytesRead = 0);
end;

function TStoReadPipeThread.Get_Content: String;
begin
  Result := FContent.DataString;
end;

/// <summary>
///   Runs a console application and captures the stdoutput and
///   stderror.</summary>
/// <param name="CmdLine">The commandline contains the full path to
///   the executable and the necessary parameters. Don't forget to
///   quote filenames with "" if the path contains spaces.</param>
/// <param name="Output">Receives the console stdoutput.</param>
/// <param name="Error">Receives the console stderror.</param>
/// <param name="Wait">[milliseconds] Maximum of time to wait,
///   until application has finished. After reaching this timeout,
///   the application will be terminated and False is returned as
///   result.</param>
/// <returns>True if process could be started and did not reach the
///   timeout.</returns>
function ShellRedirectedExecute(const CmdLine: String;
  var Output, Error: String; const Wait: DWORD = 3600000): Boolean;
var
  mySecurityAttributes: SECURITY_ATTRIBUTES;
  myStartupInfo: STARTUPINFO;
  myProcessInfo: PROCESS_INFORMATION;
  hPipeOutputRead, hPipeOutputWrite: THandle;
  hPipeErrorRead, hPipeErrorWrite: THandle;
  myReadOutputThread: TStoReadPipeThread;
  myReadErrorThread: TStoReadPipeThread;
  iWaitRes: Integer;
  sCmdLine: String;
begin
  // prepare security structure
  ZeroMemory(@mySecurityAttributes, SizeOf(SECURITY_ATTRIBUTES));
  mySecurityAttributes.nLength := SizeOf(SECURITY_ATTRIBUTES);
  mySecurityAttributes.bInheritHandle := TRUE;
  // create pipes to get stdoutput and stderror
  CreatePipe(hPipeOutputRead, hPipeOutputWrite, @mySecurityAttributes, 0);
  CreatePipe(hPipeErrorRead, hPipeErrorWrite, @mySecurityAttributes, 0);

  // prepare startupinfo structure
  ZeroMemory(@myStartupInfo, SizeOf(STARTUPINFO));
  myStartupInfo.cb := Sizeof(STARTUPINFO);
  // hide application
  myStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  myStartupInfo.wShowWindow := SW_HIDE;
  // assign pipes
  myStartupInfo.dwFlags := myStartupInfo.dwFlags or STARTF_USESTDHANDLES;
  myStartupInfo.hStdInput := 0;
  myStartupInfo.hStdOutput := hPipeOutputWrite;
  myStartupInfo.hStdError := hPipeErrorWrite;

  // since CreateProcess can map to the unicode version
  // "CreateProcessW" we cannot pass a literal string anymore.
  sCmdLine := CmdLine;
  UniqueString(sCmdLine);
  // start the process
  Result := CreateProcess(nil, PChar(sCmdLine), nil, nil, True,
    CREATE_NEW_CONSOLE, nil, nil, myStartupInfo, myProcessInfo);
  // close the ends of the pipes, now used by the process
  CloseHandle(hPipeOutputWrite);
  CloseHandle(hPipeErrorWrite);

  // could process be started ?
  if Result then
  begin
    myReadOutputThread := TStoReadPipeThread.Create(hPipeOutputRead);
    myReadErrorThread := TStoReadPipeThread.Create(hPipeErrorRead);
    try
    // start threads for reading the output pipes
    myReadOutputThread.Execute;
    myReadErrorThread.Execute;
    // wait unitl there is no more data to receive, or the timeout is reached
    iWaitRes := WaitForSingleObject(myProcessInfo.hProcess, Wait);
    // timeout reached ?
    if (iWaitRes = WAIT_TIMEOUT) then
    begin
      Result := False;
      TerminateProcess(myProcessInfo.hProcess, UINT(ERROR_CANCELLED));
    end;
    // return output
    Output := myReadOutputThread.Content;
    Error := myReadErrorThread.Content;
    finally
      myReadOutputThread.Free;
      myReadErrorThread.Free;
      CloseHandle(myProcessInfo.hThread);
      CloseHandle(myProcessInfo.hProcess);
    end;
  end;
  // close our ends of the pipes
  CloseHandle(hPipeOutputRead);
  CloseHandle(hPipeErrorRead);
end;

end.
