unit TableManagement_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DBGrids, Grids, StdCtrls, DB, SQLDB;

type

  PChecklistPtr = ^TBookmarkList;

  { TDBGridExtender }

  TDBGridExtender = class(TDBGrid)
  private
  public      
    CheckList : PChecklistPtr;
    procedure InitCheckColumn1(ACheckList: PChecklistPtr);
    procedure FinalCheckColumn1;
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1UserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
  end;

const
  C_CANNOT_EDIT = 'Editing/Deleting this record is not allowed.';

  procedure EditAndCommit( ATable: TDataSet; PKname: string; var msg: string;
    new: boolean = false);
  procedure DeleteAndCommit(ATable: TDataSet; var msg: string);
  procedure ApplyAndCommit(ATable: TDataSet);
  procedure CancelAndRollback(ATable: TDataSet);    
  function CanModifyRecord(ATable: TDataSet): Boolean;

implementation

uses appglobal_u;


procedure EditAndCommit( ATable: TDataSet; PKname: string; var msg: string; new: boolean = false);
var
  sequence_field: tfield;
begin
  sequence_field := atable.findfield('VISUAL_SEQ');
  if not (atable.State in [dsInsert, dsEdit]) then
    ATable.edit;
  if new then
  begin
    ATable.FieldByName(PKname).AsInteger := AppGlobal.HiLoGenerator.NextValue;
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

procedure DeleteAndCommit(ATable: TDataSet; var msg: string);
begin
  msg := '';
  if CanModifyRecord(ATable) then
    begin
      atable.delete;
      ApplyAndCommit(atable);
    end
  else
    msg := C_CANNOT_EDIT;
end;

procedure ApplyAndCommit(ATable: TDataSet);
begin
  TSQLQuery(atable).ApplyUpdates;
  TSQLQuery(atable).SQLConnection.Transaction.CommitRetaining;
end;

procedure CancelAndRollback(ATable: TDataSet);
begin
  TSQLQuery(atable).CancelUpdates;
  TSQLQuery(atable).SQLConnection.Transaction.RollbackRetaining;
end;

function CanModifyRecord(ATable: TDataSet): Boolean;
var
  system_field: TField;
begin
  system_field := ATable.FindField('IS_SYSTEM');
  Result := assigned(system_field) and (system_field.AsInteger = 1);
  Result := not Result;
end;

{ TDBGridExtender }

procedure TDBGridExtender.InitCheckColumn1(ACheckList: PChecklistPtr);
begin
  Checklist := ACheckList;
  TColumn(self.Columns.Insert(0)).Title.Caption:= 'Select';
  self.Columns[0].ButtonStyle:=cbsCheckboxColumn;
  self.OnCellClick:= @DBGrid1CellClick;
  self.OnUserCheckboxState:= @DBGrid1UserCheckboxState;
end;

procedure TDBGridExtender.FinalCheckColumn1;
//var
//  i: Integer;
begin
  //for i := ColCount-2 downto 0 do
  //  Columns[i].Destroy;
  //CheckList.Clear;
  //Checklist.Free;
  //TODO: check if bare hack (without doing anything) works
end;

procedure TDBGridExtender.DBGrid1CellClick(Column: TColumn);
begin
  if Column.Index =0 then
    CheckList^.CurrentRowSelected:= not CheckList^.CurrentRowSelected;
end;

procedure TDBGridExtender.DBGrid1UserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
  if CheckList^.CurrentRowSelected then
    AState:= cbChecked
  else
    AState:= cbUnchecked;
end;

end.

