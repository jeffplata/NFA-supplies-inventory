unit dataset_helper;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, generics.Collections;

type

  { TDatasetItem }

  TDatasetItem = class
  private
    Fdataset: TSQLQuery;
    FPKFieldName: string;
    function GetDataSetName: string;
  public
    constructor Create; overload;
    constructor Create( dataset: TSQLQuery; PKFieldName: string); overload;
  published
    property dataset: TSQLQuery read Fdataset write Fdataset;
    property DataSetName: string read GetDataSetName;
    property PKFieldName: string read FPKFieldName write FPKFieldName;
  end;

  { TDatasetList }

  TDatasetList<T:TDatasetItem> = class
  private
    function GetCount: integer;
    function GetItem(Index: Integer): T;
  protected
    FItems: TObjectList<T>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add( NewItem: T=Default(T) ): T;
    function GetPKFieldName(data: TDataSet): string;
    property Count: integer read GetCount;
    property Items[Index: Integer]: T read GetItem; default;
  end;

  TSQLQueryList = TDatasetList<TDatasetItem>;

implementation

{ TDatasetList }

function TDatasetList<T>.GetCount: integer;
begin
  Result := FItems.Count;
end;

function TDatasetList<T>.GetItem(Index: Integer): T;
begin
  Result := FItems[Index];
end;

constructor TDatasetList<T>.Create;
begin
  inherited Create;
  FItems := TObjectList<T>.Create(True);
end;

destructor TDatasetList<T>.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TDatasetList<T>.Add(NewItem: T): T;
begin
  if NewItem = Default(T) then
    Result := T.Create
  else
    Result :=  Newitem;
  FItems.Add(Result);
end;

function TDatasetList<T>.GetPKFieldName(data: TDataSet): string;
var
  i: Integer;
begin
  for i := 0 to FItems.Count-1 do
  begin
    if FItems[i].dataset = data then
    begin
      Result := FItems[i].PKFieldName;
      Break;
    end;
  end;
end;

{ TDatasetItem }

function TDatasetItem.GetDataSetName: string;
begin
  Result := Fdataset.Name;
end;

constructor TDatasetItem.Create;
begin
  inherited Create;
end;

constructor TDatasetItem.Create(dataset: TSQLQuery; PKFieldName: string);
begin
  inherited Create;
  Fdataset := dataset;
  FPKFieldName:= PKFieldName;
end;

end.

