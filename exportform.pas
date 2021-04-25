unit exportForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ActnList, fpsexport, DB;

type

  { TfrmExport }

  TfrmExport = class(TForm)
    actExport: TAction;
    actClose: TAction;
    ActionList1: TActionList;
    btnClose: TButton;
    btnImport: TButton;
    EditButton1: TEditButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    procedure actCloseExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
  private
    FDataset : TDataset;
  public
    class procedure OpenForm(ADataset: TDataset);
  end;

var
  frmExport: TfrmExport;

implementation

uses StrUtils;

{$R *.lfm}

{ TfrmExport }

procedure TfrmExport.EditButton1ButtonClick(Sender: TObject);
begin                         
  SaveDialog1.Filter:= 'Excel files|*.xlsx|XLS files|*.xls';
  if SaveDialog1.Execute then
  begin
    EditButton1.Text:= savedialog1.FileName;
  end;
end;

procedure TfrmExport.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmExport.actExportExecute(Sender: TObject);   
var
  Exp: TFPSExport;
  ExpSettings: TFPSExportFormatSettings;
  p: integer;
  bm: TBookMark;
begin
  Exp := TFPSExport.Create(nil);
  ExpSettings := TFPSExportFormatSettings.Create(true);
  try
    p := rpos('.xlsx', SaveDialog1.FileName);
    if p > 0 then
      ExpSettings.ExportFormat:= efXLSX
    else
      ExpSettings.ExportFormat:= efXLS;
    ExpSettings.HeaderRow:= True;
    exp.FormatSettings := ExpSettings;
    exp.dataset := FDataset;
    exp.ExportFields.AddField('PRODUCT_CATEGORY_NAME');
    //TODO: manually build the worksheet to allow exclusion of system data
    //system data to be included in the form as checkbox
    exp.FileName:= SaveDialog1.filename;
    bm := FDataset.Bookmark;    
    FDataset.First;
    exp.Execute;
    FDataset.GotoBookmark(bm);
  finally
    exp.free;
    expsettings.free;
  end;
end;

class procedure TfrmExport.OpenForm(ADataset: TDataset);
begin
  with TfrmExport.Create(nil) do
  try
    FDataset := ADataset;
    showmodal;
  finally
    free;
  end;
end;

end.

