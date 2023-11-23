codeunit 50001 "Process EAM Master"
{
    // CAS-08401-V3L9J5 300921 oa.sb
    //  <cod> code commented


    trigger OnRun()
    begin
        //  ReviewEamStagging(TransType::ALL, FALSE);  //pcpl-065
        //  CreateEamMaster(TransType::ALL);//pcpl-065
    end;

    var
        ErrorText: Text;
        ErrorExist: Boolean;
        InsertOeration: Boolean;
        CannotModifyUnitOfMeasureErr: Label 'You cannot modify %1 %2 for item %3 because non-zero %5 with %2 exists in %4.', Comment = '%1 Table name (Item Unit of measure), %2 Value of Measure (KG, PCS...), %3 Item ID, %4 Entry Table Name, %5 Field Caption';
        CannotModifyUOMWithWhseEntriesErr: Label 'You cannot modify %1 %2 for item %3 because there are one or more warehouse adjustment entries for the item.', Comment = '%1 = Item Unit of Measure %2 = Code %3 = Item No.';
        ItemUnitofMeasure: Record 5404;
        Currency: Record 4;
        MasterDataVariable: Option " ",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
        ItemTypeChange: Label 'Type for the Item %1 is %2 . It can''t be changed .';
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL;
        PurchasesPayablesSetup: Record 312;

    local procedure "-------Generate Error Log----"()
    begin
    end;

    [Scope('Internal')]
    procedure ReviewEamStagging(TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL; ManuallyReview: Boolean)
    var
        EAMMaster: Record 50004;
        EAMMasterStagging: Record 50004;
        NoOfLinesToReview: Integer;
    begin
        PurchasesPayablesSetup.GET;
        //pcpl-065
        /*
        IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
            EXIT;
        IF TransactionType <> TransactionType::ALL THEN
            ReviewEamStaggingDetails(TransactionType, ManuallyReview)
        ELSE
            ReviewEamStaggingDetails(TransactionType::ALL, ManuallyReview);
            */
    end;

    [Scope('Internal')]
    procedure ReviewEamStaggingDetails(TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL; ManuallyReview: Boolean)
    var
        EAMMaster: Record 50004;
        EAMMasterStagging: Record 50004;
        NoOfLinesToReview: Integer;
    begin
        EAMMasterStagging.RESET;
        IF TransactionType = TransactionType::ALL THEN
            EAMMasterStagging.SETRANGE("Master Type");
        IF TransactionType = TransactionType::VENDOR THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::VENDOR);
        IF TransactionType = TransactionType::ITEM THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::ITEM);
        IF TransactionType = TransactionType::UOM THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::UOM);
        IF TransactionType = TransactionType::"ITEM UOM" THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::"ITEM UOM");
        IF TransactionType = TransactionType::PAY THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::PAY);
        IF TransactionType = TransactionType::EMPLOYEE THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::EMPLOYEE);
        IF ManuallyReview THEN
            EAMMasterStagging.SETRANGE(Status, EAMMasterStagging.Status::Error)
        ELSE
            EAMMasterStagging.SETRANGE(Status, EAMMasterStagging.Status::Received);
        // EAMMasterStagging.SETFILTER(Status,'%1|%2',EAMMasterStagging.Status::Error,EAMMasterStagging.Status::Received);
        NoOfLinesToReview := EAMMasterStagging.COUNT;
        IF EAMMasterStagging.FINDSET THEN
            REPEAT
                CLEAR(ErrorExist);
                ClearErrorLog(EAMMasterStagging, TransactionType);
                ReviewLine(EAMMasterStagging);
                IF EAMMaster.GET(EAMMasterStagging."Entry No.") THEN BEGIN
                    IF ErrorExist THEN
                        EAMMaster.Status := EAMMaster.Status::Error
                    ELSE
                        EAMMaster.Status := EAMMaster.Status::Reviewed;
                    EAMMaster.MODIFY;
                END;
            UNTIL EAMMasterStagging.NEXT = 0;
        MESSAGE('%1 Lines are reviewed.', NoOfLinesToReview);
    end;

    local procedure ReviewLine(EAMMasterStagging: Record 50004)
    var
        Employee: Record 5200;
        ItemUnitofMeasure: Record 5404;
        Item: Record 27;
        Vendor: Record 23;
        ShipmentMethod: Record 10;
        CountryRegion: Record 9;
        Text001: Label 'The Item description length can''t be greater than 10.';
        Text002: Label 'Employee %1 already exist in the system.';
        Text003: Label 'Item Unit of Measure with Item No. %1 ,code %2 already exist in the sytem;';
        Text004: Label 'Item %1  already exist in the system.';
        Text005: Label 'Vendor %1  already exist in the system.';
        Text008: Label 'The PAN No. %1 is already used by Vendor No. %2.';
        Text010: Label 'Supplier ID can not be blank.';
        Text011: Label 'Employee ID can not be blank.';
        Text012: Label 'Seamec Part/Trade can not be blank.';
        Text014: Label '%1 is mendatory for %2.';
        EAMMaster: Record 50004;
        Text015: Label 'This record exist more than once.';
        Position: Integer;
        State: Record State;
        Text016: Label 'The GST Registration No. for the state %1 should start with %2.';
        UnitofMeasure: Record 204;
        Text017: Label 'The field %1  of table EAM Stagging Master contains a value (%2) that cannot be found in the related table (%3).';
        HSNSAC: Record "HSN/SAC";//16411; //pcpl-065
        Text018: Label 'GST Registration No %1 is incorrect.';
        PaymentTerms: Record 3;
        Text019: Label 'Master is not created can''t update.';
        Text020: Label 'Currency %1  is not attched with any currency and not EAM LCY code in General Ledger Setup.';
        ItemLedgEntry: Record 32;
        Text021: Label 'You cannot change theItem %1 on Item %2 because there exists at least one %3 then includes this item.';
        PurchOrderLine: Record 39;
    begin
        CASE EAMMasterStagging."Master Type" OF

            EAMMasterStagging."Master Type"::VENDOR:
                BEGIN
                    IF EAMMasterStagging."Supplier ID" = '' THEN
                        GenerateErrorLog(EAMMasterStagging, Text010, EAMMasterStagging."Trasaction Type");
                    //>>CAS-08401-V3L9J5 300921 oa.sb
                    IF (EAMMasterStagging."P.A.N. No." <> '') AND ((EAMMasterStagging."P.A.N. No." <> 'na') AND (EAMMasterStagging."P.A.N. No." <> 'NA')) THEN BEGIN
                        //         Vendor.RESET;
                        //         Vendor.SETRANGE(Vendor."P.A.N. No.",EAMMasterStagging."P.A.N. No.");
                        //         Vendor.SETFILTER("EAM Code",'<>%1',EAMMasterStagging."Supplier ID");
                        //         IF Vendor.FIND('-') THEN
                        //           GenerateErrorLog(EAMMasterStagging,STRSUBSTNO(Text008,EAMMasterStagging."P.A.N. No.",Vendor."No."),EAMMasterStagging."Trasaction Type");
                        //<<CAS-08401-V3L9J5 300921 oa.sb
                    END;

                    IF EAMMasterStagging."Currency code" <> '' THEN BEGIN
                        IF NOT EamCurrencyCurrencyExist(EAMMasterStagging) AND NOT IsEamLCYCode(EAMMasterStagging) THEN
                            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(STRSUBSTNO(Text020, EAMMasterStagging."Currency code")), EAMMasterStagging."Trasaction Type");
                    END;

                    IF EAMMasterStagging.Address = '' THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text014, EAMMasterStagging.FIELDCAPTION(EAMMasterStagging.Address), EAMMasterStagging."Master Type"), EAMMasterStagging."Trasaction Type");

                    IF (NOT ShipmentMethod.GET(EAMMasterStagging."Ship Vai")) AND (EAMMasterStagging."Ship Vai" <> '') THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text017, EAMMasterStagging.FIELDCAPTION("Ship Vai"), EAMMasterStagging."Ship Vai", ShipmentMethod.TABLECAPTION), EAMMasterStagging."Trasaction Type");

                    IF EAMMasterStagging."GST No" <> '' THEN BEGIN
                        State.SETFILTER("State Code (GST Reg. No.)", COPYSTR(EAMMasterStagging."GST No", 1, 2));
                        IF State.FINDFIRST THEN BEGIN
                            IF State."State Code (GST Reg. No.)" <> COPYSTR(EAMMasterStagging."GST No", 1, 2) THEN
                                GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text016, EAMMasterStagging.State, State."State Code (GST Reg. No.)"), EAMMasterStagging."Trasaction Type");
                            FOR Position := 3 TO 15 DO
                                CASE Position OF
                                    3 .. 7, 12:
                                        CheckIsAlphabet(EAMMasterStagging, EAMMasterStagging."GST No", Position, State);
                                    8 .. 11:
                                        CheckIsNumeric(EAMMasterStagging, EAMMasterStagging."GST No", Position, State);
                                    13 .. 15:
                                        CheckIsAlphaNumeric(EAMMasterStagging, EAMMasterStagging."GST No", Position, State);
                                END;
                        END
                    END;
                END;


            EAMMasterStagging."Master Type"::ITEM:
                BEGIN
                    IF EAMMasterStagging."Seamec Part/Trade" = '' THEN
                        GenerateErrorLog(EAMMasterStagging, Text012, EAMMasterStagging."Trasaction Type");

                    IF EAMMasterStagging.Description = '' THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text014, EAMMasterStagging.FIELDCAPTION(EAMMasterStagging.Description), EAMMasterStagging."Master Type"), EAMMasterStagging."Trasaction Type");

                    IF EAMMasterStagging."Unit of measure" = '' THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text014, EAMMasterStagging.FIELDCAPTION(EAMMasterStagging."Unit of measure"), EAMMasterStagging."Master Type"), EAMMasterStagging."Trasaction Type");

                    IF NOT UnitofMeasure.GET(EAMMasterStagging."Unit of measure") THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text017, EAMMasterStagging.FIELDCAPTION("Unit of measure"), EAMMasterStagging."Unit of measure", UnitofMeasure.TABLECAPTION), EAMMasterStagging."Trasaction Type");

                    IF Item.GET(EAMMasterStagging."Seamec Part/Trade") THEN BEGIN
                        ItemLedgEntry.RESET;
                        ItemLedgEntry.SETCURRENTKEY("Item No.");
                        ItemLedgEntry.SETRANGE("Item No.", Item."No.");
                        IF NOT ItemLedgEntry.ISEMPTY THEN BEGIN
                            IF EAMMasterStagging."Unit of measure" <> Item."Base Unit of Measure" THEN
                                GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text021, Item.FIELDCAPTION("Base Unit of Measure"), Item."No.", ItemLedgEntry.TABLECAPTION), EAMMasterStagging."Trasaction Type");

                            IF EAMMasterStagging."Item Type" <> Item.Type THEN
                                GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text021, Item.FIELDCAPTION(Type), Item."No.", ItemLedgEntry.TABLECAPTION), EAMMasterStagging."Trasaction Type");

                            //        IF (EAMMasterStagging."Item Type" = EAMMasterStagging."Item Type"::SERVICE) AND (Item.Type = Item.Type::Inventory)  THEN
                            //          GenerateErrorLog(EAMMasterStagging,STRSUBSTNO(Text021,Item.FIELDCAPTION(Type),Item."No.",ItemLedgEntry.TABLECAPTION),EAMMasterStagging."Trasaction Type");
                            //
                            //         IF (EAMMasterStagging."Item Type" = EAMMasterStagging."Item Type"::STOCK) AND (Item.Type = Item.Type::Service)  THEN
                            //          GenerateErrorLog(EAMMasterStagging,STRSUBSTNO(Text021,Item.FIELDCAPTION(Type),Item."No.",ItemLedgEntry.TABLECAPTION),EAMMasterStagging."Trasaction Type");
                            //
                        END;
                        PurchOrderLine.SETCURRENTKEY(Type, "No.");
                        PurchOrderLine.SETRANGE(Type, PurchOrderLine.Type::Item);
                        PurchOrderLine.SETRANGE("No.", Item."No.");
                        IF NOT PurchOrderLine.ISEMPTY THEN BEGIN
                            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text021, Item."No.", PurchOrderLine.TABLECAPTION), EAMMasterStagging."Trasaction Type");
                        END;

                    END
                END;

            EAMMasterStagging."Master Type"::EMPLOYEE:
                BEGIN
                    IF EAMMasterStagging."Employee ID" = '' THEN
                        GenerateErrorLog(EAMMasterStagging, Text011, EAMMasterStagging."Trasaction Type");
                END;

            EAMMasterStagging."Master Type"::UOM:
                BEGIN

                END;

            EAMMasterStagging."Master Type"::"ITEM UOM":
                BEGIN
                    IF NOT Item.GET(EAMMasterStagging."Seamac Part") THEN
                        GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(Text017, EAMMasterStagging.FIELDCAPTION("Seamac Part"), EAMMasterStagging."Seamac Part", Item.TABLECAPTION), EAMMasterStagging."Trasaction Type");

                    CheckNoOutstandingQty(EAMMasterStagging);

                END;

            EAMMasterStagging."Master Type"::PAY:
                BEGIN

                END;
        END
    end;

    local procedure ClearErrorLog(var EAMMasterStagging: Record 50004; TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL)
    var
        EamMasterErrorLog: Record 50009;
    begin
        EamMasterErrorLog.RESET;
        EamMasterErrorLog.SETRANGE("Entry No", EAMMasterStagging."Entry No.");
        EamMasterErrorLog.SETRANGE("Transaction Type", TransactionType);
        IF EamMasterErrorLog.FINDSET THEN
            EamMasterErrorLog.DELETEALL;
    end;

    local procedure GenerateErrorLog(var EAMMasterStagging: Record 50004; ErrorText: Text; TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL)
    var
        EamMasterErrorLog: Record 50009;
        ErrorEntryNo: Integer;
    begin
        EamMasterErrorLog.RESET;
        EamMasterErrorLog.SETRANGE("Entry No", EAMMasterStagging."Entry No.");
        EamMasterErrorLog.SETRANGE("Transaction Type", TransactionType);
        IF EamMasterErrorLog.FINDLAST THEN
            ErrorEntryNo := EamMasterErrorLog."Error No" + 1
        ELSE
            ErrorEntryNo := 1;

        EamMasterErrorLog.INIT;
        EamMasterErrorLog."Entry No" := EAMMasterStagging."Entry No.";
        EamMasterErrorLog."Error No" := ErrorEntryNo;
        EamMasterErrorLog."Transaction Type" := TransactionType;
        EamMasterErrorLog.Error := ErrorText;
        EamMasterErrorLog.INSERT;
        ErrorExist := TRUE;
    end;

    local procedure "-------------Functions To review Lines------"()
    begin
    end;

    local procedure CheckIsAlphabet(EAMMasterStagging: Record 50004; RegistrationNo: Code[15]; Position: Integer; State: Record State)
    var
        OnlyAlphabetErr: Label 'In GST Registration No. only Alphabet is allowed in the position %1.', Comment = '%1 = Integer';
    begin
        IF NOT (COPYSTR(RegistrationNo, Position, 1) IN ['A' .. 'Z']) THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(OnlyAlphabetErr, EAMMasterStagging.State, State."State Code (GST Reg. No.)"), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckIsNumeric(EAMMasterStagging: Record 50004; RegistrationNo: Code[15]; Position: Integer; State: Record State)
    var
        OnlyNumericErr: Label 'In GST Registration No. only Numeric is allowed in the position %1.', Comment = '%1 = Integer';
    begin
        IF NOT (COPYSTR(RegistrationNo, Position, 1) IN ['0' .. '9']) THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(OnlyNumericErr, Position), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckIsAlphaNumeric(EAMMasterStagging: Record 50004; RegistrationNo: Code[15]; Position: Integer; State: Record State)
    var
        OnlyAlphaNumericErr: Label 'In GST Registration No. only AlphaNumeric is allowed in the position %1.', Comment = '%1 = Integer';
    begin
        IF NOT ((COPYSTR(RegistrationNo, Position, 1) IN ['0' .. '9']) OR (COPYSTR(RegistrationNo, Position, 1) IN ['A' .. 'Z'])) THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(OnlyAlphaNumericErr, Position), EAMMasterStagging."Trasaction Type");
    end;

    local procedure ChangeEamOPerationToModify(EAMMasterStagging: Record 50004)
    var
        EAMMaster: Record 50004;
    begin
        EAMMaster.GET(EAMMaster."Entry No.");
        EAMMaster.Operation := EAMMaster.Operation::Modify;
        EAMMaster.MODIFY;
    end;

    local procedure CheckNoOutstandingQty(var EAMMasterStagging: Record 50004)
    begin
        CheckNoOutstandingQtyPurchLine(EAMMasterStagging);
        CheckNoOutstandingQtySalesLine(EAMMasterStagging);
        CheckNoOutstandingQtyTransferLine(EAMMasterStagging);
        CheckNoRemQtyProdOrderLine(EAMMasterStagging);
        CheckNoRemQtyProdOrderComponent(EAMMasterStagging);
        CheckNoOutstandingQtyServiceLine(EAMMasterStagging);
        CheckNoRemQtyAssemblyHeader(EAMMasterStagging);
        CheckNoRemQtyAssemblyLine(EAMMasterStagging);
    end;

    local procedure CheckNoOutstandingQtyPurchLine(var EAMMasterStagging: Record 50004)
    var
        PurchLine: Record 39;
    begin
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETRANGE("No.", EAMMasterStagging."Seamac Part");
        PurchLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        PurchLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
        IF NOT PurchLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              PurchLine.TABLECAPTION, PurchLine.FIELDCAPTION("Qty. to Receive")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoOutstandingQtySalesLine(var EAMMasterStagging: Record 50004)
    var
        SalesLine: Record 37;
    begin
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETRANGE("No.", EAMMasterStagging."Seamac Part");
        SalesLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        SalesLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
        IF NOT SalesLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              SalesLine.TABLECAPTION, SalesLine.FIELDCAPTION("Qty. to Ship")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoOutstandingQtyTransferLine(var EAMMasterStagging: Record 50004)
    var
        TransferLine: Record 5741;
    begin
        TransferLine.SETRANGE("Item No.", EAMMasterStagging."Seamac Part");
        TransferLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        TransferLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
        IF NOT TransferLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              TransferLine.TABLECAPTION, TransferLine.FIELDCAPTION("Qty. to Ship")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoRemQtyProdOrderLine(var EAMMasterStagging: Record 50004)
    var
        ProdOrderLine: Record 5406;
    begin
        ProdOrderLine.SETRANGE("Item No.", EAMMasterStagging."Seamac Part");
        ProdOrderLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        ProdOrderLine.SETFILTER("Remaining Quantity", '<>%1', 0);
        ProdOrderLine.SETFILTER(Status, '<>%1', ProdOrderLine.Status::Finished);
        IF NOT ProdOrderLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              ProdOrderLine.TABLECAPTION, ProdOrderLine.FIELDCAPTION("Remaining Quantity")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoRemQtyProdOrderComponent(var EAMMasterStagging: Record 50004)
    var
        ProdOrderComponent: Record 5407;
    begin
        ProdOrderComponent.SETRANGE("Item No.", EAMMasterStagging."Seamac Part");
        ProdOrderComponent.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        ProdOrderComponent.SETFILTER("Remaining Quantity", '<>%1', 0);
        ProdOrderComponent.SETFILTER(Status, '<>%1', ProdOrderComponent.Status::Finished);
        IF NOT ProdOrderComponent.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              ProdOrderComponent.TABLECAPTION, ProdOrderComponent.FIELDCAPTION("Remaining Quantity")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoOutstandingQtyServiceLine(var EAMMasterStagging: Record 50004)
    var
        ServiceLine: Record 5902;
    begin
        ServiceLine.SETRANGE(Type, ServiceLine.Type::Item);
        ServiceLine.SETRANGE("No.", EAMMasterStagging."Seamac Part");
        ServiceLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        ServiceLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
        IF NOT ServiceLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              ServiceLine.TABLECAPTION, ServiceLine.FIELDCAPTION("Qty. to Ship")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoRemQtyAssemblyHeader(var EAMMasterStagging: Record 50004)
    var
        AssemblyHeader: Record 900;
    begin
        AssemblyHeader.SETRANGE("Item No.", EAMMasterStagging."Seamac Part");
        AssemblyHeader.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        AssemblyHeader.SETFILTER("Remaining Quantity", '<>%1', 0);
        IF NOT AssemblyHeader.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              AssemblyHeader.TABLECAPTION, AssemblyHeader.FIELDCAPTION("Remaining Quantity")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure CheckNoRemQtyAssemblyLine(var EAMMasterStagging: Record 50004)
    var
        AssemblyLine: Record 901;
    begin
        AssemblyLine.SETRANGE(Type, AssemblyLine.Type::Item);
        AssemblyLine.SETRANGE("No.", EAMMasterStagging."Seamac Part");
        AssemblyLine.SETRANGE("Unit of Measure Code", EAMMasterStagging.UOP);
        AssemblyLine.SETFILTER("Remaining Quantity", '<>%1', 0);
        IF NOT AssemblyLine.ISEMPTY THEN
            GenerateErrorLog(EAMMasterStagging, STRSUBSTNO(
              CannotModifyUnitOfMeasureErr, ItemUnitofMeasure.TABLECAPTION, EAMMasterStagging.UOP, EAMMasterStagging."Seamac Part",
              AssemblyLine.TABLECAPTION, AssemblyLine.FIELDCAPTION("Remaining Quantity")), EAMMasterStagging."Trasaction Type");
    end;

    local procedure EamCurrencyCurrencyExist(var EAMMasterStagging: Record 50004): Boolean
    var
        GeneralLedgerSetup: Record 98;
    begin
        Currency.RESET;
        Currency.SETRANGE("EAM Code", EAMMasterStagging."Currency code");
        IF Currency.FINDFIRST THEN
            EXIT(TRUE);

        EXIT(FALSE)
    end;

    local procedure IsEamLCYCode(var EAMMasterStagging: Record 50004): Boolean
    var
        GeneralLedgerSetup: Record 98;
    begin
        GeneralLedgerSetup.GET;
        IF GeneralLedgerSetup."EAM LCY Code" = EAMMasterStagging."Currency code" THEN
            EXIT(TRUE);
        EXIT(FALSE)
    end;

    local procedure "-------ProcessEAMStagging-------"()
    begin
    end;

    [Scope('Internal')]
    procedure CreateEamMaster(TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL)
    var
        EAMMasterStagging: Record 50004;
        EAMMaster: Record 50004;
        NoOfLinesToProcess: Integer;
    begin
        PurchasesPayablesSetup.GET;
        //  IF NOT PurchasesPayablesSetup."Enable For Masters" THEN //pcpl-065
        EXIT;
        EAMMasterStagging.RESET;
        IF TransactionType = TransactionType::ALL THEN
            EAMMasterStagging.SETRANGE("Master Type");
        IF TransactionType = TransactionType::VENDOR THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::VENDOR);
        IF TransactionType = TransactionType::ITEM THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::ITEM);
        IF TransactionType = TransactionType::UOM THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::UOM);
        IF TransactionType = TransactionType::"ITEM UOM" THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::"ITEM UOM");
        IF TransactionType = TransactionType::PAY THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::PAY);
        IF TransactionType = TransactionType::EMPLOYEE THEN
            EAMMasterStagging.SETRANGE("Master Type", EAMMasterStagging."Master Type"::EMPLOYEE);
        EAMMasterStagging.SETRANGE(Status, EAMMasterStagging.Status::Reviewed);
        NoOfLinesToProcess := EAMMasterStagging.COUNT;
        IF EAMMasterStagging.FINDSET THEN
            REPEAT
                CLEAR(InsertOeration);
                IF EAMMasterStagging.Operation = EAMMasterStagging.Operation::Insert THEN
                    InsertOeration := TRUE;

                // CASE EAMMasterStagging."Master Type" OF
                //     EAMMasterStagging."Master Type"::VENDOR:
                /*
                    // CreateVendor(EAMMasterStagging); 
                    EAMMasterStagging."Master Type"::ITEM:
                   /// CreateItem(EAMMasterStagging);
                EAMMasterStagging."Master Type"::EMPLOYEE:
                   /// CreateEmployee(EAMMasterStagging);
                EAMMasterStagging."Master Type"::UOM:
                  //  CreateUOM(EAMMasterStagging);//pcpl-065
                EAMMasterStagging."Master Type"::"ITEM UOM":
                  //  CreateItemUOM(EAMMasterStagging);
                EAMMasterStagging."Master Type"::PAY:
                  //  CreatePaymentTerm(EAMMasterStagging);
                  *///pcpl-065

                //   END;

                EAMMasterStagging.Status := EAMMasterStagging.Status::Processed;
                EAMMasterStagging.MODIFY();

            UNTIL EAMMasterStagging.NEXT = 0;
        MESSAGE('%1 Lines are Processed.', NoOfLinesToProcess);
    end;

    [Scope('Internal')]
    procedure CreateVendor(var EAMMasterStagging: Record 50004)
    var
        Vendor: Record 23;
        Ven: Record 23;
        State: Record State;
        GeneralLedgerSetup: Record 98;
        CurrencyCode: Code[20];
    begin
        Vendor.RESET;
        Vendor.SETRANGE("EAM Code", EAMMasterStagging."Supplier ID");
        IF NOT Vendor.FINDFIRST THEN BEGIN
            Vendor.INIT;
            Vendor."No." := EAMMasterStagging."Supplier ID";
            Vendor."Replicated From EAM" := TRUE;
            Vendor.INSERT;
        END;
        Vendor.VALIDATE(Name, EAMMasterStagging.Description);
        Vendor.VALIDATE("EAM Name", EAMMasterStagging.Description);
        Vendor.VALIDATE("Search Name", EAMMasterStagging.Description);
        Vendor.VALIDATE(Address, EAMMasterStagging.Address);
        Vendor.VALIDATE("EAM Address 2", EAMMasterStagging."Address 2");
        //Vendor.VALIDATE(City,EAMMasterStagging.City);
        Vendor.VALIDATE(Contact, EAMMasterStagging."Contact name");
        Vendor.VALIDATE("Phone No.", EAMMasterStagging.Telephone);
        IF NOT IsEamLCYCode(EAMMasterStagging) THEN BEGIN
            IF EamCurrencyCurrencyExist(EAMMasterStagging) THEN
                Vendor.VALIDATE("Currency Code", Currency.Code);
        END;
        Vendor.VALIDATE("Payment Terms Code", EAMMasterStagging."Payment Terms");
        Vendor.VALIDATE("Shipment Method Code", EAMMasterStagging."Ship Vai");
        Vendor.VALIDATE(Blocked, Vendor.Blocked::All);
        Vendor.VALIDATE("E-Mail", EAMMasterStagging."Email Address");
        IF (EAMMasterStagging."P.A.N. No." <> '') AND ((EAMMasterStagging."P.A.N. No." <> 'na') AND (EAMMasterStagging."P.A.N. No." <> 'NA')) THEN
            Vendor.VALIDATE("P.A.N. No.", EAMMasterStagging."P.A.N. No.")
        ELSE
            IF (EAMMasterStagging."P.A.N. No." = 'na') OR (EAMMasterStagging."P.A.N. No." = 'NA') THEN
                Vendor.VALIDATE("P.A.N. Status", Vendor."P.A.N. Status"::PANNOTAVBL);
        IF (EAMMasterStagging."GST No" <> '') THEN BEGIN
            State.SETFILTER("State Code (GST Reg. No.)", COPYSTR(EAMMasterStagging."GST No", 1, 2));
            IF State.FINDFIRST THEN
                Vendor.VALIDATE("State Code", State.Code);
        END;
        Vendor.VALIDATE("GST Registration No.", EAMMasterStagging."GST No");
        Vendor."EAM Code" := EAMMasterStagging."Supplier ID";
        Vendor.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."Supplier ID";
    end;

    [Scope('Internal')]
    procedure CreateItem(var EAMMasterStagging: Record 50004)
    var
        Item: Record 27;
    begin
        IF NOT Item.GET(EAMMasterStagging."Seamec Part/Trade") THEN BEGIN
            Item.INIT;
            Item."No." := EAMMasterStagging."Seamec Part/Trade";
            // Item."Replicated From EAM" := TRUE; //pcpl-065
            Item.INSERT;
        END;
        Item.VALIDATE(Description, EAMMasterStagging.Description);
        Item.VALIDATE("Description 2", EAMMasterStagging.Description);
        Item.VALIDATE("Base Unit of Measure", EAMMasterStagging."Unit of measure");
        Item.VALIDATE(Blocked, EAMMasterStagging."Out of Service");
        IF Item.Type <> EAMMasterStagging."Item Type" THEN
            Item.VALIDATE(Type, EAMMasterStagging."Item Type");
        Item.VALIDATE(Blocked, TRUE);
        Item.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."Seamec Part/Trade";
    end;

    [Scope('Internal')]
    procedure CreateEmployee(var EAMMasterStagging: Record 50004)
    var
        Employee: Record 5200;
    begin
        IF NOT Employee.GET(EAMMasterStagging."Employee ID") THEN BEGIN
            Employee.INIT;
            Employee."No." := EAMMasterStagging."Employee ID";
            Employee.INSERT;
        END;
        Employee."First Name" := EAMMasterStagging.Description;
        Employee.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."Employee ID";
    end;

    [Scope('Internal')]
    procedure CreateUOM(var EAMMasterStagging: Record 50004)
    var
        UnitofMeasure: Record 204;
    begin
        IF NOT UnitofMeasure.GET(EAMMasterStagging."UOM Code") THEN BEGIN
            UnitofMeasure.INIT;
            UnitofMeasure.Code := EAMMasterStagging."UOM Code";
            UnitofMeasure.INSERT
        END;
        UnitofMeasure.Description := COPYSTR(EAMMasterStagging.Description, 1, 10);
        UnitofMeasure."EAM Description" := EAMMasterStagging.Description;

        UnitofMeasure.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."UOM Code";
    end;

    [Scope('Internal')]
    procedure CreateItemUOM(var EAMMasterStagging: Record 50004)
    var
        ItemUnitofMeasure: Record 5404;
    begin
        IF NOT ItemUnitofMeasure.GET(EAMMasterStagging."Seamac Part", EAMMasterStagging.UOP) THEN BEGIN
            ItemUnitofMeasure.INIT;
            ItemUnitofMeasure.VALIDATE("Item No.", EAMMasterStagging."Seamac Part");
            ItemUnitofMeasure.Code := EAMMasterStagging.UOP;
            ItemUnitofMeasure.INSERT;
        END;

        IF EAMMasterStagging."Quantity per UOP" <> 0 THEN
            ItemUnitofMeasure.VALIDATE("Qty. per Unit of Measure", EAMMasterStagging."Quantity per UOP");
        ItemUnitofMeasure.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."Seamac Part" + ',' + EAMMasterStagging.UOP;
    end;

    [Scope('Internal')]
    procedure CreatePaymentTerm(var EAMMasterStagging: Record 50004)
    var
        PaymentTerms: Record 3;
        PayTerms: Record 3;
    begin
        IF NOT PaymentTerms.GET(EAMMasterStagging."Payment Terms") THEN BEGIN
            PaymentTerms.INIT;
            PaymentTerms.Code := EAMMasterStagging."Payment Terms";
            PaymentTerms.INSERT;
        END;
        PaymentTerms."EAM Description" := EAMMasterStagging.Description;
        PaymentTerms.Description := COPYSTR(EAMMasterStagging.Description, 1, 10);
        PaymentTerms.Type := EAMMasterStagging.Type;
        PaymentTerms.MODIFY;
        EAMMasterStagging."Record ID" := EAMMasterStagging."Payment Terms";
    end;

    [Scope('Internal')]
    procedure SetParameter(MasterDataVariablePar: Option ,VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY)
    begin
        MasterDataVariable := MasterDataVariablePar;
    end;
}

