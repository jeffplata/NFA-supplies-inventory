unit ReceiptsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList, ComCtrls,
  DBGrids;

type

  { TfrmReceipts }

  TfrmReceipts = class(TForm)
    actAdd: TAction;
    actClose: TAction;
    actDelete: TAction;
    actEdit: TAction;
    ActionList1: TActionList;
    DBGrid1: TDBGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure actCloseExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  frmReceipts: TfrmReceipts;

implementation

{$R *.lfm}

{ TfrmReceipts }

procedure TfrmReceipts.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:= caFree;
  frmReceipts := nil;
end;

procedure TfrmReceipts.actCloseExecute(Sender: TObject);
begin
  close
end;

end.

