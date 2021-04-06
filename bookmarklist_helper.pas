unit BookmarkList_helper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, DBGrids;

type

  { TBookmarkListEx }

  TBookmarkListEx = class(TBookmarkList)
  public
    FList: TFPList;
    FDataset: TDataset; 
    procedure Delete;
    function CanDeleteRecord(ATable: TDataSet): Boolean;
  end;

implementation

{ TBookmarkListEx }

procedure TBookmarkListEx.Delete;
var
  i: Integer;
  {$ifndef noautomatedbookmark}
  Bookmark: Pointer;
  {$endif}
begin
  {$ifdef dbgDBGrid}
  DebugLn('%s.Delete', [ClassName]);
  {$endif}
  for i := Self.Count-1 downto 0 do begin
    FDataset.GotoBookmark(Items[i]);
    {$ifndef noautomatedbookmark}
    Bookmark := FList[i];
    SetLength(TBookmark(Bookmark),0); // decrease reference count
    {$else}
    FDataset.FreeBookmark(Items[i]);
    {$endif noautomatedbookmark}
    if CanDeleteRecord(FDataset) then
    begin
      FDataset.Delete;
      FList.Delete(i);
    end;
  end;
end;

function TBookmarkListEx.CanDeleteRecord(ATable: TDataSet): Boolean;
var
  system_field: TField;
begin
  system_field := ATable.FindField('IS_SYSTEM');
  Result := assigned(system_field) and (system_field.AsInteger = 1);
  Result := not Result;
end;

end.

