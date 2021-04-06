unit ManageInventoryForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids,
  ActnList;

type

  { TfrmManageInventory }

  TfrmManageInventory = class(TForm)
    actAdd: TAction;
    actDelete: TAction;
    actEdit: TAction;
    actClose: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
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
begin
  //add
end;

procedure TfrmManageInventory.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmManageInventory.actDeleteExecute(Sender: TObject);
begin
  //delete

end;

procedure TfrmManageInventory.actEditExecute(Sender: TObject);
begin
  //edit
end;

procedure TfrmManageInventory.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
  frmManageInventory := nil;
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

  dmInventory.OpenProducts;
  DataSource1.DataSet := dmInventory.qryProduct;
  DBGrid1.AutoAdjustColumns;
end;

end.

