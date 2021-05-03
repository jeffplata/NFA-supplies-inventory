unit ManageInventoryForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Forms, Controls, Graphics, Dialogs, ComCtrls,
  DBGrids, ActnList, TableManagement_u, MyDBGridExt;

type

  { TfrmManageInventory }

  TfrmManageInventory = class(TForm)
    actAdd: TAction;
    actDelete: TAction;
    actEdit: TAction;
    actClose: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DBGrid1: TMyDBGridExt;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure actAddExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
  public

  end;

var
  frmManageInventory: TfrmManageInventory;

implementation

uses inventoryDM;

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

procedure TfrmManageInventory.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmManageInventory.actDeleteExecute(Sender: TObject);
//var
//  table: TDataSet;
//  msg: string;
//  skipped: integer;
//
//  procedure _deletemarked;
//  var
//    i : integer;
//  begin
//    for i := DBGrid1.CheckList.count-1 downto 0 do
//      begin
//        table.GotoBookmark(DBGrid1.CheckList[i]);
//        if CanModifyRecord(table) then
//          begin
//            DBGrid1.CheckList.CurrentRowSelected:= false;
//            table.Delete;
//          end
//        else
//          skipped := skipped + 1;
//      end;
//    ApplyAndCommit(table);
//    if skipped > 0 then
//      showmessage(format('%d record(s) not deleted.',[skipped]));
//  end;

begin
  Delete( DBGrid1 );
  //msg := '';
  //skipped := 0;
  //table := dbgrid1.datasource.dataset;
  //if DBGrid1.CheckList.Count > 0 then
  //  begin
  //    if QuestionDlg('Confirm delete', Format('Delete %d record(s) selected?',
  //        [DBGrid1.CheckList.Count]),mtConfirmation,[mrYes,mrNO],'')=mrYes then
  //      _deletemarked;
  //  end
  //else
  //  begin
  //    DeleteAndCommit(table,msg);
  //    if msg <> '' then showmessage(msg);
  //  end;
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

procedure TfrmManageInventory.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DBGrid1.CheckList.Clear;   //IMPORTANT
  CloseAction:= caFree;
  frmManageInventory := nil;
  dmInventory.qryProduct.Close;
end;

procedure TfrmManageInventory.FormCreate(Sender: TObject);
var
  c: TColumn;
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

  dmInventory.OpenProducts([]);
  DataSource1.DataSet := dmInventory.qryProduct;

  DBGrid1.AutoAdjustColumns;
end;

end.

