unit selectProdCategory_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  ListFilterEdit;

type

  { TfrmSelectProdCategory }

  TfrmSelectProdCategory = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DataSource1: TDataSource;
    ListBox1: TListBox;
    ListFilterEdit1: TListFilterEdit;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private

  public
    class function SelectedItem: string;

  end;

var
  frmSelectProdCategory: TfrmSelectProdCategory;

implementation

uses inventoryDM;

{$R *.lfm}

{ TfrmSelectProdCategory }

procedure TfrmSelectProdCategory.FormCreate(Sender: TObject);
var
  i: QWord;
begin
  with dmInventory.qryProdCategoryLku do
  begin
    first;
    while not eof do
    begin
      i := fieldbyname('PRODUCT_CATEGORY_ID').asinteger;
      ListBox1.items.AddObject(fieldbyname('PRODUCT_CATEGORY_NAME').asstring,
        TObject(i));
      next;
    end;
  end;
  ListFilterEdit1.FilteredListbox := ListBox1;
end;

procedure TfrmSelectProdCategory.ListBox1DblClick(Sender: TObject);
begin
  if tlistbox(sender).ItemIndex <> -1 then button1.Click;
end;

procedure TfrmSelectProdCategory.Button2Click(Sender: TObject);
begin
  close;
end;

class function TfrmSelectProdCategory.SelectedItem: string;
var
  ind: integer;
begin
  result := '';
  with TfrmSelectProdCategory.Create(nil) do
  try
    if (Showmodal = mrOk) then
    begin
      ind := listbox1.itemindex;
      if ind = -1 then result := ''
      else result := Inttostr(qword(ListBox1.items.Objects[ind]));
    end;
  finally
    Free;
  end;
end;

end.

