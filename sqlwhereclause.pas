unit SQLWhereClause;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RegExpr;

type

  { TSQLWhereClause }

  TSQLWhereClause = class

  public
    procedure ExtractWhere;

  end;

implementation

{ TSQLWhereClause }

procedure TSQLWhereClause.ExtractWhere(ASQL: string);
var
  re: TRegExpr;
begin
  re := TRegExpr.Create;
  try
    re.Expression:= 'where[\s]+(.+)(\s+group\s+by\s+|\s+order\s+by\s+|)';
    re.InputString:= ASQL;
    re.sub;
  finally
    re.free;
  end;
end;

end.

