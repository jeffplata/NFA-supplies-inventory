unit IssuanceForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, DBGrids, ActnList;

type

  { TfrmIssuance }

  TfrmIssuance = class(TForm)
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
  frmIssuance: TfrmIssuance;

implementation

{$R *.lfm}

{ TfrmIssuance }

procedure TfrmIssuance.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmIssuance.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:= caFree;
  frmIssuance := nil;
end;

end.

