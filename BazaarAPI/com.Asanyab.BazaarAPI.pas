unit com.Asanyab.BazaarAPI;
//{$Define UseLogger}

interface
uses
  com.Asanyab.BazaarAPI.LoginCheckServiceConnection, com.Asanyab.BazaarAPI.UpdateCheckService;

const
  BazzarPackageName = 'com.farsitel.bazaar'; { do not localize }

type

  TBazaarAPI = class(TObject)
  private
  {$IFDEF UseLogger}
    FCategory: string;
  {$ENDIF}
    FPackageName: string;
    FDeveloperID: string;
    {$IFDEF Android}
    FLoginCheckServiceConnection: TLoginCheckServiceConnection;
    FUpdateCheckServiceConnection: TUpdateCheckServiceConnection;
    {$ENDIF}
  public
    constructor Create(aPackageName: string; aDeveloperID: string);
    destructor Destroy; override;

    procedure VoteApp;
    procedure GoDeveloperPage;
    procedure GoToLoginPage;
    //Check user login status
    procedure InitUserIsLogin;
    function UserIsLogin: Boolean;
    procedure ReleaseUserLoginService;
    //Check app version
    procedure InitCheckUpdate;
    function GetAppVersion: Integer;
    procedure ReleaseCheckUpdateService;

    property PackageName: string read FPackageName;
    property DeveloperID: string read FDeveloperID;
  end;

var
  BazaarAPI: TBazaarAPI = nil;

implementation

{ TBazaarAPI }

uses System.SysUtils
  {$IFDEF UseLogger},LoggerManager{$ENDIF}
  {$IFDEF Android}
  , Androidapi.JNI.GraphicsContentViewText
  ,Androidapi.JNI.Net, Androidapi.Helpers
  {$ENDIF};

constructor TBazaarAPI.Create(aPackageName: string; aDeveloperID: string);
begin
  {$IFDEF UseLogger}
  FCategory := ClassName;
  Logger.AddCategory(FCategory);
  {$ENDIF}
  FPackageName := aPackageName;
  FDeveloperID := aDeveloperID;
  {$IFDEF Android}
  FLoginCheckServiceConnection := TLoginCheckServiceConnection.Create;
  FUpdateCheckServiceConnection := TUpdateCheckServiceConnection.Create(FPackageName);
  {$ENDIF}
end;

destructor TBazaarAPI.Destroy;
begin
  {$IFDEF Android}
  FreeAndNil(FUpdateCheckServiceConnection);
  FreeAndNil(FLoginCheckServiceConnection);
  {$ENDIF}
  inherited;
end;


function TBazaarAPI.GetAppVersion: Integer;
begin
  {$IFDEF MSWindows}
  Result := -1001;
  {$ENDIF}
  {$IFDEF Android}
  if FUpdateCheckServiceConnection.IsConnected then
  begin
    Result := FUpdateCheckServiceConnection.GetVersion;
  end;
  {$ENDIF}
end;

procedure TBazaarAPI.GoDeveloperPage;
const
  MethodName = 'GoDeveloperPage';
{$IFDEF Android}
var
  Intent: JIntent;
  Command: string;
{$ENDIF}
begin
{$IFDEF Android}
  try
    Command := 'bazaar://collection?slug=by_author&aid=' + DeveloperID;
    Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW,
      TJnet_Uri.JavaClass.parse(StringToJString(Command)));
    Intent.setPackage(StringToJString(BazzarPackageName));
    SharedActivity.startActivity(Intent);
  except
    on E: Exception do
    begin
      {$IFDEF UseLogger}
      Logger.DoLog(ltError, ClassName + '.' + MethodName, FCategory, [E.Message]);
      {$ENDIF}
      raise Exception.Create(E.Message);
    end;
  end;
{$ENDIF}
end;

procedure TBazaarAPI.GoToLoginPage;
const
  MethodName = 'GoToLoginPage';
{$IFDEF Android}
var
  Intent: JIntent;
  Command: string;
{$ENDIF}
begin
{$IFDEF Android}
  try
    Command := 'bazaar://login';
    Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW,
      TJnet_Uri.JavaClass.parse(StringToJString(Command)));
    Intent.setPackage(StringToJString(BazzarPackageName));
    SharedActivity.startActivity(Intent);
  except
    on E: Exception do
    begin
      {$IFDEF UseLogger}
      Logger.DoLog(ltError, ClassName + '.' + MethodName, FCategory, [E.Message]);
      {$ENDIF}
      raise Exception.Create(E.Message);
    end;
  end;
{$ENDIF}
end;

procedure TBazaarAPI.InitCheckUpdate;
begin
  {$IFDEF Android}
  FUpdateCheckServiceConnection.StartSetup;
  {$ENDIF}
end;

procedure TBazaarAPI.InitUserIsLogin;
begin
  {$IFDEF Android}
  FLoginCheckServiceConnection.StartSetup;
  {$ENDIF}
end;

procedure TBazaarAPI.ReleaseCheckUpdateService;
begin
  {$IFDEF Android}
  FUpdateCheckServiceConnection.Dispose;
  {$ENDIF}
end;

procedure TBazaarAPI.ReleaseUserLoginService;
begin
  {$IFDEF Android}
  FLoginCheckServiceConnection.Dispose;
  {$ENDIF}
end;

function TBazaarAPI.UserIsLogin: Boolean;
begin
  {$IFDEF Android}
  if FLoginCheckServiceConnection.IsConnected then
  begin
    Result := FLoginCheckServiceConnection.IsLogin;
  end
  else
  begin
    Result := False;
  end;
  {$ENDIF}
end;

procedure TBazaarAPI.VoteApp;
const
  MethodName = 'VoteApp';
{$IFDEF Android}
var
  Intent: JIntent;
  Command: string;
{$ENDIF}
begin
{$IFDEF Android}
  try
    Command := 'bazaar://details?id=' + PackageName;
    Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW,
      TJnet_Uri.JavaClass.parse(StringToJString(Command)));
    Intent.setPackage(StringToJString(BazzarPackageName));
    SharedActivity.startActivity(Intent);
  except
    on E: Exception do
    begin
      {$IFDEF UseLogger}
      Logger.DoLog(ltError, ClassName + '.' + MethodName, FCategory, [E.Message]);
      {$ENDIF}
      raise Exception.Create(E.Message);
    end;
  end;
{$ENDIF}
end;

end.
