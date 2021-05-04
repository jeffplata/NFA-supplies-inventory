unit inventoryDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DBGrids, dataset_helper, SQLDB, DB,
  BufDataset;

type

  TVariantArray1 = array of variant;

  { TdmInventory }

  TdmInventory = class(TDataModule)
    qryProduct: TSQLQuery;
    qryProductCategory: TSQLQuery;
    qryProdCategoryLku: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure qryProductCategoryBeforeDelete(DataSet: TDataSet);
    procedure qryImportApplyUpdateError(Sender: TObject;
      DataSet: TCustomBufDataset; E: EUpdateError; UpdateKind: TUpdateKind;
  var Response: TResolverResponse);
  private
    UpdateErrorMessage, UpdateErrorValue, UpdateErrorField: string;
  public            
    temp_id : integer;
    DatasetList: TSQLQueryList;
    class procedure Open;
    procedure Import(ATable: TDataset; AData: TVariantArray1; var msg: string);
    procedure EditAndCommit(ATable: TDataSet; PKname: string; var msg: string;
      new: boolean=false);
    procedure DeleteAndCommit(ATable: TDataSet; var msg: string);
    procedure ApplyAndCommit(ATable: TDataSet);
    procedure CancelAndRollback(ATable: TDataSet);
    function CanEditProductCategory: Boolean;
    function CanModifyRecord(ATable: TDataSet): Boolean;
    procedure OpenProductsCategory(const parameters: TVariantArray1);
    procedure CloseProductsCategory;
    procedure OpenProducts(const parameters: TVariantArray1);
    procedure CloseProducts;
    procedure DataSource1StateChange( Sender: TObject );
  end;

var
  dmInventory: TdmInventory;

const
  C_CANNOT_EDIT = 'Editing/Deleting not allowed for this record.';
  C_SQL_PRODUCT_CATEGORY = 'SELECT p.PRODUCT_CATEGORY_ID, p.PRODUCT_CATEGORY_NAME, p.VISUAL_SEQ, p.IS_SYSTEM '+
    'from PRODUCT_CATEGORY p '+
    #13#10'where (cast(:PRODUCT_CATEGORY_NAME as varchar(80)) is null) or (p.PRODUCT_CATEGORY_NAME containing :PRODUCT_CATEGORY_NAME) '+
    #13#10'order by p.VISUAL_SEQ, p.PRODUCT_CATEGORY_ID ';
  C_SQL_PRODUCT = 'select p.PRODUCT_ID, p.PRODUCT_NAME, p.UNIT_MEASURE, '+
    #13#10'p.PRODUCT_CATEGORY_ID, c.PRODUCT_CATEGORY_NAME '+
    #13#10'from PRODUCT p '+          
    #13#10'join PRODUCT_CATEGORY c on c.PRODUCT_CATEGORY_ID=p.PRODUCT_CATEGORY_ID '+
    #13#10'where (cast(:PRODUCT_NAME as varchar(80)) is null) or (p.PRODUCT_NAME containing :PRODUCT_NAME) ' ;
  C_SQL_PRODUCT_EDIT = 'update PRODUCT set PRODUCT_NAME = :PRODUCT_NAME, '+
    ' UNIT_MEASURE = :UNIT_MEASURE,'+
    ' PRODUCT_CATEGORY_ID = :PRODUCT_CATEGORY_ID'+
    ' where PRODUCT_ID = :PRODUCT_ID';
  C_SQL_PRODUCT_INSERT = 'insert into PRODUCT (PRODUCT_ID, PRODUCT_NAME, UNIT_MEASURE, PRODUCT_CATEGORY_ID) '+
    ' values (:PRODUCT_ID, :PRODUCT_NAME, :UNIT_MEASURE, :PRODUCT_CATEGORY_ID)';
  C_SQL_PRODUCT_REFRESH = 'select c.PRODUCT_CATEGORY_NAME '+
    #13#10'from PRODUCT p '+
    #13#10'join PRODUCT_CATEGORY c on c.PRODUCT_CATEGORY_ID=p.PRODUCT_CATEGORY_ID '+
    #13#10'where PRODUCT_ID = :PRODUCT_ID' ;
  C_SQL_PRODUCT_DELETE = 'delete from PRODUCT where PRODUCT_ID=:PRODUCT_ID';


implementation

uses mainDM, Variants, Forms, Dialogs, Controls;

{$R *.lfm}

{ TdmInventory }

procedure TdmInventory.DataModuleCreate(Sender: TObject);
begin
  qryProductCategory.DataBase := dmMain.Connection.Connection;
  qryProductCategory.SQL.Add(C_SQL_PRODUCT_CATEGORY);

  qryProduct.DataBase := dmMain.Connection.Connection;
  qryProduct.SQL.Add(C_SQL_PRODUCT);
  qryProduct.UpdateSQL.Add(C_SQL_PRODUCT_EDIT);
  qryProduct.InsertSQL.Add(C_SQL_PRODUCT_INSERT);
  qryProduct.RefreshSQL.add(C_SQL_PRODUCT_REFRESH);
  qryProduct.DeleteSQL.add(C_SQL_PRODUCT_DELETE);

  //Product category lookup      
  qryProdCategoryLku.DataBase := dmMain.Connection.Connection;
  qryProdCategoryLku.SQL.Add('select PRODUCT_CATEGORY_ID, PRODUCT_CATEGORY_NAME from PRODUCT_CATEGORY order by upper(PRODUCT_CATEGORY_NAME)');

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
    raise Exception.Create(C_CANNOT_EDIT);
  end;
end;

procedure TdmInventory.qryImportApplyUpdateError(Sender: TObject;
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
  vUpdateError: TResolverErrorEvent;
begin
  UpdateErrorField:= 'PRODUCT_CATEGORY_NAME';
  UpdateErrorMessage:= '';
  UpdateErrorValue:= '';
  vUpdateError:= TSQLQuery(ATable).OnUpdateError;
  TSQLQuery(ATable).OnUpdateError:= @qryImportApplyUpdateError;

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
  TSQLQuery(ATable).OnUpdateError:= vUpdateError;
end;

procedure TdmInventory.OpenProductsCategory(const parameters: TVariantArray1);
var
  _params : TVariantArray1;
begin
  if length(parameters) = 0 then
    _params := [null]
  else
    _params := parameters;
  with qryProductCategory do
  begin
    ParamByName('PRODUCT_CATEGORY_NAME').Value:= _params[0];
  end;

  // IMPORTANT NOTE
  // If table is ordered by visual sequence, then be sure to
  //    rebuild index when refreshing
  qryProductCategory.IndexFieldNames:= 'VISUAL_SEQ';
  if qryProductCategory.Active then
    begin
      qryProductCategory.IndexFieldNames:='';
      qryProductCategory.Refresh;  
      qryProductCategory.IndexFieldNames:= 'VISUAL_SEQ';
    end
  else
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
    msg := C_CANNOT_EDIT;

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
  //  //    //  raise Exception.Create(C_CANNOT_EDIT);
  //  //    //begin
  //  //    //  msg := C_CANNOT_EDIT;
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

procedure TdmInventory.OpenProducts(const parameters: TVariantArray1);
var
  _params : TVariantArray1;
begin
  if length(parameters) = 0 then
    _params := [null]
  else
    _params := parameters;
  with qryProduct do
  begin
    ParamByName('PRODUCT_NAME').Value:= _params[0];
  end;

  if qryProduct.active then
    qryProduct.refresh
  else
    qryProduct.Open;   

  qryProduct.FieldByName('product_category_name').Required := False;
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

