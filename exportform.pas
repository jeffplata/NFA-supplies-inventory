unit exportForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ActnList, fpsexport, Variants, fpsTypes, fpspreadsheet, fpsallformats, DB;

type

  { TfrmExport }

  TfrmExport = class(TForm)
    actExport: TAction;
    actClose: TAction;
    actExport2: TAction;
    ActionList1: TActionList;
    btnClose: TButton;
    btnImport: TButton;
    chkPK: TCheckBox;
    chkSystemData: TCheckBox;
    EditButton1: TEditButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    procedure actCloseExecute(Sender: TObject);
    procedure actExport2Execute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDataset : TDataset;
    FFieldNames: TStringList;
  public
    class procedure OpenForm(ADataset: TDataset; AColumns: string);
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

procedure TfrmExport.FormCreate(Sender: TObject);
begin
 FFieldNames := TStringList.create;
end;

procedure TfrmExport.FormDestroy(Sender: TObject);
begin
  FFieldNames.free;
end;

procedure TfrmExport.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmExport.actExport2Execute(Sender: TObject);
var
  wb : TsWorkbook;
  ws : TsWorksheet;
  i, j: integer;
  bm: TBookMark;
  v: variant;
  dt: TFieldType;
begin
  if EditButton1.Text = '' then exit;  //<==
  if FileExists(SaveDialog1.FileName) then
    if MessageDlg('Overwrite','File already exists. Overwrite?',mtInformation,[mbYes,mbNo],0) =  mrNo then
      exit;  //<==
  wb := TsWorkbook.Create;
  ws := wb.AddWorksheet('Sheet1');

  bm := fdataset.Bookmark;
  fdataset.First;

  try
    for i := 0 to FFieldNames.Count-1 do
      ws.WriteText(0, i, FFieldNames[i]);
    j := 1;
    while not fdataset.EOF do
    begin

      // include system data?
      if not chkSystemData.checked then
        v := fdataset.FieldByName('IS_SYSTEM').Asinteger
      else
        v := 0;
      if v = 1 then
      begin
        fdataset.next;
        continue;
      end;

      for i := 0 to FFieldNames.Count-1 do
      begin
        //TODO: finalize export
        v := fdataset.FindField(FFieldNames[i]).Value;
        dt := fdataset.FieldByName(FFieldNames[i]).DataType;
        if VarIsNull(v) then v := '[NULL]';
        if VarType(v) = vardate then
          ws.WriteDateTime(j, i, v)
        else if VarIsNumeric(v) then
          ws.WriteNumber(j, i, v)
        else
          ws.WriteText(j, i, v);
      end;
      fdataset.Next;
      inc(j);
    end;
    wb.WriteToFile(SaveDialog1.filename, sfOOXML, True);  
    showmessage('Data export successful.');
  finally
    wb.Free;
    fdataset.GotoBookmark(bm);
  end;

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

class procedure TfrmExport.OpenForm(ADataset: TDataset; AColumns: string);
begin
  with TfrmExport.Create(nil) do
  try
    FDataset := ADataset;
    FFieldNames.Delimiter:= ';';
    FFieldNames.DelimitedText:= AColumns;
    showmodal;
  finally
    free;
  end;
end;

end.

