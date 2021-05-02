unit appglobal_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, hilogeneratorU;

type

  { TAppGlobal }

  TAppGlobal = class

  private
    FHiloGenerator: THiloGenerator;
  published
    property HiloGenerator: THiloGenerator read FHiloGenerator write FHiloGenerator;
  end;

var
  AppGlobal: TAppGlobal;

implementation


//Use AppGlobal1 to access application-wide properties
// Make sure that global properties are set with a global data module,
//    dmMain, for example
initialization
  AppGlobal := TAppGlobal.Create;

finalization
  AppGlobal.Free;

end.

