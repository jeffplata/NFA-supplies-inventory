program SuppliesInventory;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainform, appConnectionU, mainDM, myUtils, changedatabaseform,
  pascalscript, appUserU, UserLoginForm, hilogeneratorU, UserManagerForm,
  UserManagerU, user_BOM, RoleEditForm, base_BOM, UserChangePassForm,
  IssuanceForm, ReceiptsForm, ManageInventoryForm, inventoryDM,
  ProductCategoryForm, dataset_helper, BookmarkList_helper, importForm,
  SQLWhereClause, exportForm, TableManagement_u, appglobal_u;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TdmInventory, dmInventory);
  Application.Run;
end.

