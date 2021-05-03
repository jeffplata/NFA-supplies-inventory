unit MyDBGridExt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, Grids;

type

  { TMyDBGridExt }

  TMyDBGridExt = class(TDBGrid) 
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1UserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
  private

  protected

  public              
    CheckList: TBookmarkList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Data Controls',[TMyDBGridExt]);
end;

{ TMyDBGridExt }

procedure TMyDBGridExt.DBGrid1CellClick(Column: TColumn);
begin
  if Column.Index =0 then
    CheckList.CurrentRowSelected:= not CheckList.CurrentRowSelected;
end;

procedure TMyDBGridExt.DBGrid1UserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
  if CheckList.CurrentRowSelected then
    AState:= cbChecked
  else
    AState:= cbUnchecked;
end;

constructor TMyDBGridExt.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckList := TBookmarkList.Create(self); 
  TColumn(self.Columns.Insert(0)).Title.Caption:= 'Select';
  self.Columns[0].ButtonStyle:=cbsCheckboxColumn;
  self.OnCellClick:= @DBGrid1CellClick;
  self.OnUserCheckboxState:= @DBGrid1UserCheckboxState;
end;

destructor TMyDBGridExt.Destroy;
var
  i: Integer;
begin
  //IMPORTANT: somewhere outside this code, MyDbgridExt.CheckList must be
  //  cleared. Exmple:
  //  MyDBGridExt1.CheckList.Clear;
  //  MyDBGridExt1.Datasource.Dataset.Close;
  //
  //  Access violation errors, otherwise, as Checklist.Free tries to free each
  //  saved bookmark individually, which is no longer existent when table is
  //  closed.
  CheckList.Free;
  inherited destroy;
end;

end.
