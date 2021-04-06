unit ProductCategoryForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ActnList, DBGrids,
  ComCtrls, Menus, StdCtrls, EditBtn;

type

  { TfrmProductCategory }

  TfrmProductCategory = class(TForm)
    actAdd: TAction;
    actClose: TAction;
    actDelete: TAction;
    actEdit: TAction;
    actImport: TAction;
    actExport: TAction;
    actCheckAll: TAction;
    actClearFilter: TAction;
    actUncheckAll: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    edtFilter: TEditButton;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    DropDownMenu1: TPopupMenu;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure actAddExecute(Sender: TObject);
    procedure actCheckAllExecute(Sender: TObject);
    procedure actClearFilterExecute(Sender: TObject);
    procedure actClearFilterUpdate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actUncheckAllExecute(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1UserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure edtFilterChange(Sender: TObject);
    procedure edtFilterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    CheckList: TBookmarkList;         
    temp_id: integer;
    procedure SetChecked( AChecked: Boolean);
  public

  end;

  const
    CONST_CANNOT_EDIT = 'Editing/Deleting not allowed for this record.';

var
  frmProductCategory: TfrmProductCategory;

implementation

uses inventoryDM, importForm, Grids;

{$R *.lfm}

{ TfrmProductCategory }

procedure TfrmProductCategory.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmProductCategory.actAddExecute(Sender: TObject);
var
  sInput, msg: string;
  table : TDataSet;
begin
  sInput := '';
  msg := '';
  table :=  DBGrid1.DataSource.DataSet;
  if InputQuery('Add product category','Category name:',sInput) and (sInput<>'') then
    begin
      table.Append;
      //table.FieldByName('PRODUCT_CATEGORY_ID').AsInteger:= dmInventory.temp_id;
      //Dec(dmInventory.temp_id);   
      table.FieldByName('PRODUCT_CATEGORY_NAME').AsString:= sInput;
      dminventory.EditAndCommit(table, 'PRODUCT_CATEGORY_ID', msg, True);
      if msg <> '' then showmessage(msg);
    end;
end;

procedure TfrmProductCategory.actCheckAllExecute(Sender: TObject);
begin
  SetChecked(True);
end;

procedure TfrmProductCategory.actClearFilterExecute(Sender: TObject);
begin
  edtFilter.Clear;
end;

procedure TfrmProductCategory.actClearFilterUpdate(Sender: TObject);
begin
  (sender as taction).Enabled:= (edtFilter.Text<>'');
end;

procedure TfrmProductCategory.actDeleteExecute(Sender: TObject);
var
  table: TDataSet;
  msg: string;
  skipped: integer;

  procedure _deletemarked;
  var
    i : integer;
  begin
    for i := CheckList.count-1 downto 0 do
      begin
        table.GotoBookmark(CheckList[i]);
        if dmInventory.CanModifyRecord(table) then
          begin
            CheckList.CurrentRowSelected:= false;
            table.Delete;
          end
        else
          skipped := skipped + 1;
      end;
    dmInventory.ApplyAndCommit(table);
    if skipped > 0 then
      showmessage(format('%d record(s) not deleted.',[skipped]));
  end;

begin
  msg := '';
  skipped := 0;
  table := dbgrid1.datasource.dataset;  
  if CheckList.Count > 0 then
    begin
      if QuestionDlg('Confirm delete', Format('Delete %d record(s) selected?',
          [CheckList.Count]),mtConfirmation,[mrYes,mrNO],'')=mrYes then
        _deletemarked;
    end
  else
    begin
      dmInventory.DeleteAndCommit(table,msg);
      if msg <> '' then showmessage(msg);
    end;

  //msg := '';
  //table := dbgrid1.DataSource.dataset;
  //dmInventory.DeleteAndCommit(table, msg, CheckList);
  //if msg <> '' then showmessage(msg);
  //exit;

  //if dbgrid1.DataSource.dataset.fieldbyname('IS_SYSTEM').asinteger = 1 then
  //  begin
  //    showmessage(CONST_CANNOT_EDIT);
  //    exit;
  //  end;
  //
  //if CheckList.Count > 0 then
  //  begin
  //    if QuestionDlg('Confirm delete', Format('Delete %d record(s) selected?',
  //        [CheckList.Count]),mtConfirmation,[mrYes,mrNO],'')=mrYes then
  //      CheckList.Delete;
  //  end
  //else
  //  DataSource1.DataSet.Delete;
end;

procedure TfrmProductCategory.actEditExecute(Sender: TObject);
var
  s, msg: String;
  table: TDataSet;
begin
  table := dbgrid1.DataSource.DataSet;
  if not dmInventory.CanModifyRecord(table) then
    begin
      showmessage(CONST_CANNOT_EDIT);
      exit;
    end;

  s := table.fieldbyname('PRODUCT_CATEGORY_NAME').asstring;
  if InputQuery('Edit product category','Category name:',s) and (s<>'') then
    begin
      table.Edit;
      table.fieldbyname('PRODUCT_CATEGORY_NAME').asstring := s;
      dminventory.EditAndCommit(table, 'PRODUCT_CATEGORY_ID', msg);
      if msg <> '' then showmessage(msg);
    end;
end;

procedure TfrmProductCategory.actImportExecute(Sender: TObject);
begin
  TfrmImport.OpenForm;
  //OpenDialog1.Filter:= 'Excel files|*.xlsx;*.xls';
  //OpenDialog1.Execute;
end;

procedure TfrmProductCategory.actUncheckAllExecute(Sender: TObject);
begin
  CheckList.Clear;
end;

procedure TfrmProductCategory.DBGrid1CellClick(Column: TColumn);
begin
  if Column.Index =0 then
    CheckList.CurrentRowSelected:= not CheckList.CurrentRowSelected;
end;

procedure TfrmProductCategory.DBGrid1DblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure TfrmProductCategory.DBGrid1UserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
  if CheckList.CurrentRowSelected then
    AState:= cbChecked
  else
    AState:= cbUnchecked;
end;

procedure TfrmProductCategory.edtFilterChange(Sender: TObject);
begin
  if edtFilter.Text <> '' then
    begin
      //run query with filter
      //Add condition to TWhereClauses
      //  whereclauses1.Containing('PRODUCT_CATEGORY_NAME', edtFilter.Text)
      //      = where PRODUCT_CATEGORY_NAME containing :PRODUCT_CATEGORY_NAME
      //  whereclauses1.Equals('PRODUCT_CATEGORY_NAME', edtFilter.Text)
      //      = where PRODUCT_CATEGORY_NAME = :PRODUCT_CATEGORY_NAME
    end;
end;

procedure TfrmProductCategory.edtFilterClick(Sender: TObject);
begin
  ShowMessage(dmInventory.qryProductCategory.SQL.Text);
end;

procedure TfrmProductCategory.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DataSource1.DataSet.CheckBrowseMode;
  CheckList.Free;
  CloseAction:= caFree;
  frmProductCategory := nil;
end;

procedure TfrmProductCategory.FormCreate(Sender: TObject);
begin
  dmInventory.OpenProductsCategory;
  DataSource1.dataset := dmInventory.qryProductCategory;  
  //DataSource1.OnStateChange:= @dmInventory.DataSource1StateChange;
                                                              
  CheckList := TBookmarkList.Create(DBGrid1);
  TColumn(DBGrid1.Columns.Insert(0)).Title.Caption:= 'Select';
  DBGrid1.Columns[0].ButtonStyle:=cbsCheckboxColumn;
  DBGrid1.OnCellClick:= @DBGrid1CellClick;
  DBGrid1.OnUserCheckboxState:= @DBGrid1UserCheckboxState;
  DBGrid1.AutoAdjustColumns;

  edtFilter.button.Action := actClearFilter;
  temp_id := -1;
end;

procedure TfrmProductCategory.SetChecked(AChecked: Boolean);
var
  bm: TBookMark;
begin
  with DBGrid1.DataSource.DataSet do
    begin
      DisableControls;
      bm := Bookmark;
      First;
      while not eof do
        begin
          CheckList.CurrentRowSelected:= AChecked;
          Next;
        end;
        GotoBookmark(bm);
      EnableControls;
    end;
end;

end.

