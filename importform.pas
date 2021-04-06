unit importForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  EditBtn, fpspreadsheetctrls, fpspreadsheet, fpsTypes, xlsxooxml, xlsxml,
  xlsbiff8, xlsbiff5;

type

  { TfrmImport }

  TfrmImport = class(TForm)
    actImport: TAction;
    actClose: TAction;
    ActionList1: TActionList;
    btnClose: TButton;
    btnImport: TButton;
    EditButton1: TEditButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    sWorkbookSource1: TsWorkbookSource;
    procedure actCloseExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
  private
    FCanImport : Boolean;
    worksheet: TsWorksheet;
  public
    class procedure OpenForm;
  end;

var
  frmImport: TfrmImport;

implementation

uses Variants, inventoryDM;

{$R *.lfm}

{ TfrmImport }

procedure TfrmImport.actCloseExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmImport.actImportExecute(Sender: TObject);
var
  r, c: Integer;
  rowcount, colcount: integer;
  data: array of variant;
  s, msg: String;
begin
  if not FCanImport then Exit;  // <==

  //row 0 = column names
  rowcount := worksheet.GetLastRowIndex;
  colcount := worksheet.GetLastColIndex+1;
  data := varArrayCreate([0,rowcount-1], varvariant);
  for r := 1 to rowcount do
    begin
      data[r-1] := VarArrayCreate([0,colcount-1], varvariant);
      for c := 0 to colcount-1 do
        begin
          s := worksheet.ReadAsText(r,c);
          data[r-1,c] := s;
        end;
    end;

  dmInventory.Import(dmInventory.qryProductCategory, data, msg);

  memo1.Lines.add('-----');
  if msg <> '' then
    begin
      memo1.Lines.add(msg);
      memo1.Lines.add('** Please correct error before continuing.');
      FCanImport:= False;
    end
  else
    memo1.lines.add('Import successful.');

end;

procedure TfrmImport.EditButton1ButtonClick(Sender: TObject);
var
  cell: PCell;
  columns_required, columns_in_file: String;
begin
  OpenDialog1.Filter:= 'Excel files|*.xlsx;*.xls';
  if OpenDialog1.Execute then
    begin
      EditButton1.Text:= OpenDialog1.FileName;

      sWorkbookSource1.FileName:= OpenDialog1.FileName;
      worksheet := sWorkbookSource1.Workbook.GetWorksheetByIndex(0);
      columns_in_file:= '';
      for cell in worksheet.Cells.GetRowEnumerator(0) do
        columns_in_file := columns_in_file + ';' + Uppercase(worksheet.ReadAsText(cell));

      columns_in_file := copy(columns_in_file,2,length(columns_in_file)-1);
      columns_required := 'PRODUCT_CATEGORY_NAME';

      memo1.Clear;
      if columns_required <> columns_in_file then
        begin
          memo1.Lines.add('File does not match the required columns.');
          memo1.Lines.Add('Required      : '+ columns_required);
          memo1.Lines.Add('Read from file: '+ columns_in_file);
          memo1.Lines.add('Choose another file.');
          FCanImport := False;
        end
      else
        begin
          memo1.lines.add('File ok. Press ''Import'' to start.');
          FCanImport:= True;
        end;

    end;
end;

class procedure TfrmImport.OpenForm;
begin
  with TfrmImport.Create(nil) do
    try
      FCanImport:= False;
      ShowModal;
    finally
      Free;
    end;
end;

end.

