unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Forms, Menus, ActnList,
  ComCtrls, ExtCtrls, Controls, TDIClass, SQLDB, Classes;

type

  { TfmMain }

  TfmMain = class(TForm)
    actExit: TAction;
    actAbout: TAction;
    actChangePass: TAction;
    actInventoryManager: TAction;
    actProductCategory: TAction;
    actReceipts: TAction;
    actIssuances: TAction;
    actUserManager: TAction;
    actLogout: TAction;
    actSetdatabase: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Setdatabase1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem3: TMenuItem;
    StatusBar1: TStatusBar;
    TDINoteBook1: TTDINoteBook;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure actChangePassExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actInventoryManagerExecute(Sender: TObject);
    procedure actIssuancesExecute(Sender: TObject);
    procedure actLogoutExecute(Sender: TObject);
    procedure actLogoutUpdate(Sender: TObject);
    procedure actProductCategoryExecute(Sender: TObject);
    procedure actReceiptsExecute(Sender: TObject);
    procedure actSetdatabaseExecute(Sender: TObject);
    procedure actUserManagerExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure UpdateConnectedIndicator;
    procedure UpdateFormUI;
  public

  end;

var
  fmMain: TfmMain;

implementation

uses
  mainDM, IssuanceForm, ReceiptsForm, ManageInventoryForm, inventoryDM,
  ProductCategoryForm;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.actExitExecute(Sender: TObject);
begin
  close;
end;

procedure TfmMain.actInventoryManagerExecute(Sender: TObject);
begin
  if not assigned(frmManageInventory) then

    frmManageInventory := TfrmManageInventory.Create(self);
  TDINoteBook1.ShowFormInPage(frmManageInventory, 0);
end;

procedure TfmMain.actIssuancesExecute(Sender: TObject);
begin
  if not assigned(frmIssuance) then
    frmIssuance := TfrmIssuance.Create(self);
  TDINoteBook1.ShowFormInPage(frmIssuance, 2);
end;

procedure TfmMain.actChangePassExecute(Sender: TObject);
begin
  //action change password
  if dmMain.User.Loggedin then
    dmMain.User.ChangePassDialog;
end;

procedure TfmMain.actLogoutExecute(Sender: TObject);
begin
  dmMain.User.Logout(True);
  UpdateConnectedIndicator;
  if dmMain.User.LoginDialog then
  begin
    UpdateConnectedIndicator;
    UpdateFormUI;
  end
  else
    actExit.Execute;
end;

procedure TfmMain.actLogoutUpdate(Sender: TObject);
begin
  (Sender as TAction).enabled := dmMain.User.Loggedin;
end;

procedure TfmMain.actProductCategoryExecute(Sender: TObject);
begin
  //product category
  if not assigned(frmProductCategory) then
    frmProductCategory := TfrmProductCategory.create(self);
  TDINoteBook1.ShowFormInPage(frmProductCategory);
end;

procedure TfmMain.actReceiptsExecute(Sender: TObject);
begin
  if not assigned(frmReceipts) then
    frmReceipts := TfrmReceipts.create(self);
  TDINoteBook1.ShowFormInPage(frmReceipts, 1);
end;

procedure TfmMain.actSetdatabaseExecute(Sender: TObject);
begin
  dmMain.SetDatabase;
  UpdateConnectedIndicator;
  UpdateFormUI;
end;

procedure TfmMain.actUserManagerExecute(Sender: TObject);
begin
  dmMain.UserManager.OpenForm;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  UpdateConnectedIndicator;
  UpdateFormUI;
end;

procedure TfmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: Integer;
begin
  // ensure that form.close methods are called
  for i := 0 to Screen.FormCount-1 do
    if Screen.Forms[i] <> fmMain then
      Screen.Forms[i].Close;
end;

procedure TfmMain.UpdateConnectedIndicator;
var
  st_text : String;
begin  
  if dmMain.isConnected then
    st_text := 'Connected'
  else
    st_text := 'Not connected';

  if dmMain.User.Loggedin then
    st_text := st_text + ' | Logged in'
  else
    st_text := st_text + ' | Not logged in';

  StatusBar1.SimpleText := st_text;
end;

procedure TfmMain.UpdateFormUI;
begin
  // set action/memu visibility/accessibility here
  actUserManager.Visible:= dmMain.User.Username = 'admin';
end;

end.

