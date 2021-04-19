unit inventoryDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DBGrids, dataset_helper, SQLWhereClause, SQLDB, DB,
  BufDataset;

type

  TVariantArray1 = array of variant;

  { TdmInventory }

  TdmInventory = class(TDataModule)
    qryProduct: TSQLQuery;
    qryProductCategory: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure qryProductCategoryBeforeDelete(DataSet: TDataSet);
    procedure qryProductCategoryUpdateError(Sender: TObject;
      DataSet: TCustomBufDataset; E: EUpdateError; UpdateKind: TUpdateKind;
      var Response: TResolverResponse);
  private
    UpdateErrorMessage, UpdateErrorValue, UpdateErrorField: string;
  public            
    temp_id : integer;
    DatasetList: TSQLQueryList;
    SQLWhereProductCategory: TSQLWhereClause;
    class procedure Open;
    procedure Import(ATable: TDataset; AData: TVariantArray1; var msg: string);
    procedure EditAndCommit(ATable: TDataSet; PKname: string; var msg: string;
      new: boolean=false);
    procedure DeleteAndCommit(ATable: TDataSet; var msg: string);
    procedure ApplyAndCommit(ATable: TDataSet);
    procedure CancelAndRollback(ATable: TDataSet);
    function CanEditProductCategory: Boolean;
    function CanModifyRecord(ATable: TDataSet): Boolean; 
    procedure OpenProductsCategory;
    procedure CloseProductsCategory;
    procedure OpenProducts;
    procedure CloseProducts;
    procedure DataSource1StateChange( Sender: TObject );
  end;

var
  dmInventory: TdmInventory;

const
  CONST_CANNOT_EDIT = 'Editing/Deleting not allowed for this record.';

implementation

uses mainDM, BookmarkList_helper, Variants, Contnrs, Forms, Dialogs, Controls;

{$R *.lfm}

{ TdmInventory }

procedure TdmInventory.DataModuleCreate(Sender: TObject);
begin
  qryProductCategory.DataBase := dmMain.Connection.Connection; 
  qryProductCategory.SQL.add('select p.PRODUCT_CATEGORY_ID, p.PRODUCT_CATEGORY_NAME, p.VISUAL_SEQ, p.IS_SYSTEM ');
  qryProductCategory.SQL.add('  from PRODUCT_CATEGORY p ');
  qryProductCategory.SQL.add('  order by p.PRODUCT_CATEGORY_ID');
  //qryProductCategory.BeforeDelete:= @qryProductCategoryBeforeDelete;
  SQLWhereProductCategory:= TSQLWhereClause.Create(qryProductCategory);

  qryProduct.DataBase := dmMain.Connection.Connection;
  qryProduct.SQL.add('select p.PRODUCT_ID, p.PRODUCT_NAME, p.UNIT_MEASURE, ');
  qryProduct.SQL.add('  p.PRODUCT_CATEGORY_ID, c.PRODUCT_CATEGORY_NAME from product p');
  qryProduct.SQL.add('  join PRODUCT_CATEGORY c on c.PRODUCT_CATEGORY_ID=p.PRODUCT_CATEGORY_ID;');

  temp_id := -1;
  DatasetList := TSQLQueryList.Create;
  DatasetList.Add(TDatasetItem.Create(qryProductCategory,'PRODUCT_CATEGORY_ID'));
end;

procedure TdmInventory.DataModuleDestroy(Sender: TObject);
begin
  DatasetList.Free;
end;

procedure TdmInventory.qryProductCategoryBeforeDelete(DataSet: TDataSet);
begin
  if not CanModifyRecord(DataSet) then
  begin
    //ShowMessage(CONST_CAMNNOT_EDIT);
    //abort;
    raise Exception.Create(CONST_CANNOT_EDIT);
  end;
end;

procedure TdmInventory.qryProductCategoryUpdateError(Sender: TObject;
  DataSet: TCustomBufDataset; E: EUpdateError; UpdateKind: TUpdateKind;
  var Response: TResolverResponse);
begin
  UpdateErrorMessage:= e.Message;
  UpdateErrorValue:= dataset.FieldByName(UpdateErrorField).AsString;
  Response:= rrAbort;
end;

class procedure TdmInventory.Open;
begin
  if not assigned(dmInventory) then
    Application.CreateForm(TdmInventory, dmInventory);
end;

procedure TdmInventory.Import(ATable: TDataset; AData: TVariantArray1; var msg: string);
var
  visual_seq_fld: TField;
  newkey, i, j: Integer;
begin
  UpdateErrorField:= 'PRODUCT_CATEGORY_NAME';
  UpdateErrorMessage:= '';
  UpdateErrorValue:= '';

  visual_seq_fld := ATable.FindField('VISUAL_SEQ');
  newkey := 0;
  for i := 0 to VarArrayHighBound(Adata,1 ) do
    with ATable do
    begin
      // Fields[0]      = pk field
      // Fields[1..n-1] = non-pk fields
      // Fields[n]      = visual_seq (if used)
      newkey:= dmMain.HiLoGenerator.NextValue;
      Append;
      Fields[0].AsInteger:= newkey;
      if assigned(visual_seq_fld) then
        visual_seq_fld.AsInteger:= newkey;
      for j := 0 to VarArrayHighBound(AData[i],1) do
        Fields[j+1].AsVariant:= AData[i,j];
      Post;
    end;
  ApplyAndCommit(ATable);
  if UpdateErrorMessage <> '' then
    begin
      if Pos('UNIQUE', UpdateErrorMessage)>0 then
        msg := 'Duplicate record : '+UpdateErrorValue
      else
        msg := UpdateErrorMessage;
      CancelAndRollback(ATable);
    end;
end;

procedure TdmInventory.OpenProductsCategory;
begin
  qryProductCategory.Open;
end;

procedure TdmInventory.CloseProductsCategory;
begin
  qryProductCategory.Close;
end;

procedure TdmInventory.EditAndCommit( ATable: TDataSet; PKname: string; var msg: string; new: boolean = false);
var
  sequence_field: tfield;
begin
  sequence_field := atable.findfield('VISUAL_SEQ');
  if not (atable.State in [dsInsert, dsEdit]) then
    ATable.edit;
  if new then
  begin
    ATable.FieldByName(PKname).AsInteger := dmMain.HiLoGenerator.NextValue;
    if assigned(sequence_field) then
      sequence_field.AsInteger := ATable.FieldByName(PKname).AsInteger;
  end;
  msg := '';
  try                
    ATable.Post;
    ApplyAndCommit(atable);
  except
    on e: Exception do
    begin
      if Pos('UNIQ',Uppercase(e.message))> 0 then
        msg := 'Duplicate record found.'
      else
        msg := e.message;
      CancelAndRollback(atable);
    end;
  end;
end;

procedure TdmInventory.DeleteAndCommit(ATable: TDataSet; var msg: string);

  //procedure _commit;
  //begin
  //  TSQLQuery(ATable).ApplyUpdates(0);
  //  TSQLQuery(ATable).SQLConnection.Transaction.CommitRetaining;
  //end;
  //
  //procedure _rollback;
  //begin
  //  TSQLQuery(ATable).CancelUpdates;
  //  TSQLQuery(ATable).SQLConnection.Transaction.RollbackRetaining;
  //end;

begin
  msg := '';
  if CanModifyRecord(ATable) then
    begin
      atable.delete;
      ApplyAndCommit(atable);
    end
  else
    msg := CONST_CANNOT_EDIT;

  //try
  //  //if assigned(ACheckList) and (ACheckList.Count > 0) then
  //  //  begin
  //  //    if QuestionDlg('Confirm delete', Format('Delete %d record(s) selected?',
  //  //        [ACheckList.Count]),mtConfirmation,[mrYes,mrNO],'')=mrYes then
  //  //      begin
  //  //        //ACheckList.Delete;
  //  //        //_commit;
  //  //        for i := ACheckList.Count-1 downto 0 do
  //  //          begin
  //  //            ATable.GotoBookmark(ACheckList.items[i]);
  //  //            if CanModifyRecord(ATable) then
  //  //            begin
  //  //              ATable.Delete;
  //  //              //ACheckList.CurrentRowSelected:= False;
  //  //            end;
  //  //          end;
  //  //        _commit;
  //  //      end;
  //  //  end
  //  //else
  //  //  begin     
  //  //    //if not CanModifyRecord(ATable) then
  //  //    //  raise Exception.Create(CONST_CANNOT_EDIT);
  //  //    //begin
  //  //    //  msg := CONST_CANNOT_EDIT;
  //  //    //  exit;
  //  //    //end;
  //  //    ATable.Delete;
  //  //    _commit;
  //  //  end;
  //except
  //  on e: Exception do
  //  begin
  //    msg := e.message;
  //    _rollback;
  //  end;
  //end;
end;

procedure TdmInventory.ApplyAndCommit(ATable: TDataSet);
begin
  TSQLQuery(atable).ApplyUpdates;
  TSQLQuery(atable).SQLConnection.Transaction.CommitRetaining;
end;

procedure TdmInventory.CancelAndRollback(ATable: TDataSet);
begin
  TSQLQuery(atable).CancelUpdates;
  TSQLQuery(atable).SQLConnection.Transaction.RollbackRetaining;
end;

function TdmInventory.CanEditProductCategory: Boolean;
begin
  result := qryProductCategory.FieldByName('IS_SYSTEM').AsInteger<>1;
end;

function TdmInventory.CanModifyRecord(ATable: TDataSet): Boolean;
var
  system_field: TField;
begin
  system_field := ATable.FindField('IS_SYSTEM');
  Result := assigned(system_field) and (system_field.AsInteger = 1);
  Result := not Result;
end;

procedure TdmInventory.OpenProducts;
begin
  qryProduct.Open;
end;

procedure TdmInventory.CloseProducts;
begin
  qryProduct.Close;
end;

procedure TdmInventory.DataSource1StateChange(Sender: TObject);
var
  data: TDataset;
  pkname: String;
begin
  data := TDataSource(Sender).DataSet;
  case data.state of
  dsEdit:
    if data.FieldByName('IS_SYSTEM').AsInteger = 1 then
    begin
      ShowMessage('Editing/Deleting not allowed on this record.');
      data.Cancel;
    end;
  dsInsert:
    begin
      pkname := DatasetList.GetPKFieldName(data);
      data.fieldbyname(pkname).asinteger := temp_id;
      dec(temp_id);
    end;
  end;
end;

end.

