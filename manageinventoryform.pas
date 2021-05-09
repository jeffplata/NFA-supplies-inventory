unit ManageInventoryForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Forms, Controls, Graphics, Dialogs, ComCtrls,
  DBGrids, ActnList, Menus, StdCtrls, TableManagement_u, MyDBGridExt, UITypes;

type

  { TfrmManageInventory }

  TfrmManageInventory = class(TForm)
    actAdd: TAction;
    actDelete: TAction;
    actEdit: TAction;
    actClose: TAction;
    actCheckall: TAction;
    actChangeCategory: TAction;
    actUncheckall: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    dsCategoriesLku: TDataSource;
    DBGrid1: TMyDBGridExt;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    N1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    procedure actAddExecute(Sender: TObject);
    procedure actChangeCategoryExecute(Sender: TObject);
    procedure actCheckallExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actUncheckallExecute(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
  public

  end;

var
  frmManageInventory: TfrmManageInventory;

implementation

uses inventoryDM, selectProdCategory_u;

{$R *.lfm}

{ TfrmManageInventory }

procedure TfrmManageInventory.actAddExecute(Sender: TObject);
var
  sInput, msg: string;
  table : TSQLQuery;
begin
  sInput := '';
  msg := '';
  table :=  TSQLQuery(dbgrid1.DataSource.DataSet);
  if InputQuery('Add product','Product name:',sInput) and (sInput<>'') then
    begin
      table.Append;
      //TODO: product edit form
      table.FieldByName('PRODUCT_NAME').asstring := sInput;
      table.fieldbyname('PRODUCT_CATEGORY_ID').asinteger := 0; //default
      EditAndCommit(table, 'PRODUCT_ID', msg, True);
      if msg <> '' then showmessage(msg);
    end;
end;

procedure TfrmManageInventory.actChangeCategoryExecute(Sender: TObject);
var
  s: String;  
  table: TDataSet;
  msg: string;
  skipped: integer;
  ADBGrid: TMyDBGridExt;

  procedure _changemarked;
  var
    i : integer;
  begin
    for i := ADBGrid.CheckList.count-1 downto 0 do
      begin
        table.GotoBookmark(ADBGrid.CheckList[i]);
        if CanModifyRecord(table) then
          begin
            ADBGrid.CheckList.CurrentRowSelected:= false;
            table.Edit;
            table.fieldbyname('PRODUCT_CATEGORY_ID').asinteger := strtoint(s);
            table.Post;
          end
        else
          skipped := skipped + 1;
      end;
    ApplyAndCommit(table);
    if skipped > 0 then
      showmessage(format('%d record(s) not modified.',[skipped]));
  end;

begin

  msg := '';
  skipped := 0;
  ADBGrid := DBGrid1;
  table := ADBGrid.datasource.dataset;
  s := TfrmSelectProdCategory.SelectedItem;
  if s = '' then exit; //<===

  if ADBGrid.CheckList.Count > 0 then
    begin
      if QuestionDlg('Confirm change', Format('Change %d record(s) selected?',
          [ADBGrid.CheckList.Count]),mtConfirmation,[mrYes,mrNO],'')=mrYes then
        _changemarked;
    end
  else
    begin
 
      if not CanModifyRecord(table) then
        begin
          showmessage(C_CANNOT_EDIT);
          exit;
        end;

      table.Edit;
      table.fieldbyname('PRODUCT_CATEGORY_ID').asinteger := strtoint(s);
      EditAndCommit(table, 'PRODUCT_ID', msg);
      if msg <> '' then showmessage(msg);

    end;

end;

procedure TfrmManageInventory.actCheckallExecute(Sender: TObject);
begin
  DBGrid1.CheckAll(True);
end;

procedure TfrmManageInventory.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmManageInventory.actDeleteExecute(Sender: TObject);
begin
  Delete( DBGrid1 );
end;

procedure TfrmManageInventory.actEditExecute(Sender: TObject);
var
  s, msg: String;
  table: TDataSet;
begin
  table := TSQLQuery( dbgrid1.DataSource.DataSet );
  if not CanModifyRecord(table) then
    begin
      showmessage(C_CANNOT_EDIT);
      exit;
    end;

  s := table.fieldbyname('PRODUCT_NAME').asstring;
  if InputQuery('Edit product','Product name:',s) and (s<>'') then
    begin
      table.Edit;
      table.fieldbyname('PRODUCT_NAME').asstring := s;
      EditAndCommit(table, 'PRODUCT_ID', msg);
      if msg <> '' then showmessage(msg);
    end;
end;

procedure TfrmManageInventory.actUncheckallExecute(Sender: TObject);
begin
  dbgrid1.checklist.clear;
end;

procedure TfrmManageInventory.DBGrid1DblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure TfrmManageInventory.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DBGrid1.CheckList.Clear;   //IMPORTANT
  CloseAction:= caFree;
  frmManageInventory := nil;
  dmInventory.qryProduct.Close;
  dmInventory.qryProdCategoryLku.close;
end;

procedure TfrmManageInventory.FormCreate(Sender: TObject);
var
  c: TColumn;
  m: TMenuItem;
begin
  //prepare grid
  c := DBGrid1.Columns.Add;
  c.FieldName:= 'PRODUCT_ID';
  c := DBGrid1.Columns.Add;
  c.FieldName:= 'PRODUCT_NAME';
  c := DBGrid1.Columns.Add;
  c.FieldName:= 'UNIT_MEASURE';
  c := DBGrid1.Columns.Add;
  c.FieldName:= 'PRODUCT_CATEGORY_NAME';

  dmInventory.qryProdCategoryLku.Open;
  dsCategoriesLku.dataset := dmInventory.qryProdCategoryLku;
  with dmInventory.qryProdCategoryLku do
    while not eof do
    begin
      m := TMenuItem.Create(PopupMenu1);
      m.Caption:= fieldbyname('PRODUCT_CATEGORY_NAME').AsString;
      PopupMenu1.Items.Add(m);
      next;
    end;

  dmInventory.OpenProducts([]);
  DataSource1.DataSet := dmInventory.qryProduct;
  //TODO: implement change category feature

  DBGrid1.AutoAdjustColumns;
end;

end.

