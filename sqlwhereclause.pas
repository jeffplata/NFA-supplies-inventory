unit SQLWhereClause;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RegExpr, SQLDB;  

const
  WHERECLAUSE_RE = 'where\s+(.+?)(\s+group\s+by\s+|\s+order\s+by\s+|\s+$)';
  SELECTCLAUSE_RE = '(select\s+.+?)(\s+where\s+|\s+group\s+by\s+|\s+order\s+by\s+|\s+$)';

type

  { TSQLWhereClause }

  TSQLWhereClause = class

  private
    FDataset: TSQLQuery;
    FSelectClause: string;
    FWhereClause: string;
  public
    constructor Create(ADataset: TSQLQuery);
    destructor Destroy; override;
    function ExtractClause( ARegEx: string ): string;
    procedure AndCondition( ACondition: string; AOperator: string = ' and ' );
    procedure OrCondition( ACondition: string );
  published
    property Dataset: TSQLQuery read FDataset write FDataset;
    property WhereClause: string read FWhereClause;
    property SelectClause: string read FSelectClause;
  end;

implementation

{ TSQLWhereClause }

constructor TSQLWhereClause.Create(ADataset: TSQLQuery);
begin
  FDataset := ADataset;
  FWhereClause:= ExtractClause(WHERECLAUSE_RE);
  FSelectClause:= ExtractClause(SELECTCLAUSE_RE);
end;

destructor TSQLWhereClause.Destroy;
begin
  FDataset := nil;
end;

function TSQLWhereClause.ExtractClause(ARegEx: string): string;
var
  re: TRegExpr;
begin
  Result := '';
  re := TRegExpr.Create;
  try
    re.Expression:= ARegEx;
    re.InputString:= FDataset.SQL.Text;
    re.Exec;
    Result := re.Match[1];
  finally
    re.free;
  end;
end;

procedure TSQLWhereClause.AndCondition(ACondition: string; AOperator: string);
var
  newWhereClause, CondOperator: String;
begin
  if FWhereClause <> '' then CondOperator := AOperator else CondOperator:= '';
  newWhereClause := FWhereClause + CondOperator + ACondition;
end;

procedure TSQLWhereClause.OrCondition(ACondition: string);
begin
  AndCondition(ACondition, ' or ');
end;

end.

