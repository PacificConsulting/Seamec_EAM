codeunit 50002 "Process EAM Process Stagging"
{

    trigger OnRun()
    begin
        PurchasesPayablesSetup.GET;
        //IF PurchasesPayablesSetup."Enable For Processed" THEN BEGIN  // pcpl-065
        ReviewEAMProcessData(FALSE);
        CreateEamProcess;
        // END; //pcpl-065
    end;

    var
        ErrorText: Text;
        Text001: Label 'Purchase %1 %2 already exist.';
        ErrorExist: Boolean;
        "PreDocNo.": Code[20];
        Text002: Label 'Vendor %1 does not exist.';
        Text003: Label 'Payment Term %1 does not exist.';
        PaymentTerms: Record 3;
        Location: Record 14;
        Text004: Label 'Location %1 does not exist.';
        Currency: Record 4;
        Text005: Label 'Currency %1 does not exist.';
        Text006: Label '%1 %2 does not exist.';
        Text007: Label 'Type field is blank.';
        GSTGroup: Record "GST Group";
        Text008: Label 'Tax code %1 is not associated with any GST Group.';
        Item: Record 27;
        Text009: Label 'Purchase Line %1 for Document %1 does not exist .';
        Text000: Label 'The field %1  of table EAM Processing Stagging contains a value (%2) that cannot be found in the related table (%3).';
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
        ItemUnitofMeasure: Record 5404;
        PurchasesPayablesSetup: Record 312;
        text010: Label '%1 does not have any value in Purchases & Payables Setup';
        text011: Label '%1 does not exist either in loaction %2 or Purchases & Payables Setup';
        Text012: Label 'Purchase Order %1 with  line no %2 and Item No. %3 does does not exist can''t create document .';
        User: Record 2000000120;
        Text013: Label ' Empoyee %1 does not attch with any User.';
        Text014: Label 'The field %1 is blank in table Purchases & Payables Setup.';
        Text015: Label '%1  must have a value in %2 No.=%3. It cannot be zero or empty.';
        Text016: Label 'Type must be equal to ''Inventory''  in Item: No.= %1.';
        GeneralLedgerSetup: Record 98;
        Text017: Label 'Currency %1  is not associated with any currency and not EAM LCY code in General Ledger Setup.';
        Text018: Label 'Supplier ID %1 is not associated with any any vendor.';
        Text019: Label 'There is no Currency Exchange Rate within the filter.  Filters: Currency Code: %1, Starting Date: ''''..%2';
        Text020: Label 'You can not receive more than %1 quantity.';
        NoOfLines: Integer;
        PurchaseHeaderTemp: Record 38 temporary;
        PurchRcptHeaderTemp: Record 120 temporary;
        Text021: Label 'Don''t have related EAM Purchase Order Lines .';
        Text022: Label 'The field Project Code contains a value %1 that cannot be found in the related table (Dimension Value).';
        Text023: Label 'Vendor %1 is in blocked state.Can''t create doument.';
        Text024: Label 'Item %1 is in blocked.';
        Text025: Label 'Purchase order is released. you do''t have right to modify it .';
        Text026: Label 'Quantity Invoiced or Received Quantity  in the existing purchase line is grater then the UOM(Requested Quantity)';
        Text027: Label 'Purchase Order %1 is in %2 status.Can''t post Receipt.';
        Text028: Label 'Purchase Order %1 with  Line no. %2 does not exist';
        Vend: Record 23;
        Location1: Record 14;
        PurchHead: Record 38;
        Text030: Label 'GST Registration No must have a value for venfor %1.';
        Text029: Label 'You can not receive quantity %1 ,as this is less than 0.';
        Text031: Label 'Vendor %1 is blocked can''t create Purchase Order.';
        Text032: Label 'Dimesion %1 is in blocked state.';

    local procedure "-------Generate Error Log----"()
    begin
    end;

    //[Scope('Internal')]
    procedure ReviewEAMProcessData(ManuallyReview: Boolean)
    begin
        ReviewEAMPurchaseOrderStagging(FALSE);
        ReviewEAMPurchaseReceiptStagging(FALSE);
        ReviewEAMSupplierReturnStagging(FALSE);
    end;

    //[Scope('Internal')]
    procedure ReviewEAMPurchaseOrderStagging(ManuallyReview: Boolean)
    var
        EAMPurchaseOrder: Record 50005;
        EAMPurchOrder: Record 50005;
        PurchaseHeader: Record 38;
        PurchaseLine: Record 39;
        Vendor: Record 23;
        ColumnLayoutName: Record 330;
        OrderDate: Date;
        DimensionValue: Record 349;
    begin
        PurchasesPayablesSetup.GET;
        //   IF NOT PurchasesPayablesSetup."Enable For Processed" THEN //pcpl-065
        EXIT;
        GeneralLedgerSetup.GET;
        EAMPurchaseOrder.RESET;
        IF ManuallyReview THEN
            EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Error)
        ELSE
            EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Received);
        //EAMPurchaseOrder.SETFILTER("Nav Status",'%1|%2',EAMPurchaseOrder."Nav Status"::Received,EAMPurchaseOrder."Nav Status"::Error);
        EAMPurchaseOrder.SETRANGE("Transaction Type", EAMPurchaseOrder."Transaction Type"::"Purchase Order");
        NoOfLines := EAMPurchaseOrder.COUNT;
        IF EAMPurchaseOrder.FINDSET THEN
            REPEAT
                ErrorExist := FALSE;
                ClearErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order");

                Vendor.RESET;
                Vendor.SETRANGE("EAM Code", EAMPurchaseOrder.Supplier);
                IF Vendor.FINDFIRST THEN BEGIN
                    IF Vendor."Gen. Bus. Posting Group" = '' THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text015, Vendor.FIELDCAPTION("Gen. Bus. Posting Group"), Vendor.TABLECAPTION, Vendor."No."));
                    IF Vendor."Vendor Posting Group" = '' THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text015, Vendor.FIELDCAPTION("Vendor Posting Group"), Vendor.TABLECAPTION, Vendor."No."));
                    IF Vendor.Blocked <> Vendor.Blocked::" " THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text023, Vendor."No."));
                    IF Vendor."GST Vendor Type" IN [Vendor."GST Vendor Type"::Registered, Vendor."GST Vendor Type"::Composite] THEN BEGIN
                        IF Vendor."GST Registration No." = '' THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text030, Vendor."No."))
                    END;
                    IF Vendor.Blocked = Vendor.Blocked::All THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text031, Vendor."No."))
                END ELSE
                    GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text018, EAMPurchaseOrder.Supplier));

                IF NOT PaymentTerms.GET(EAMPurchaseOrder."Payment Terms") AND (EAMPurchaseOrder."Payment Terms" <> '') THEN
                    GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text000, EAMPurchaseOrder.FIELDCAPTION("Payment Terms"), EAMPurchaseOrder."Payment Terms", PaymentTerms.TABLECAPTION));

                IF NOT Location.GET(EAMPurchaseOrder.Store) AND (EAMPurchaseOrder.Store <> '') THEN
                    GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text000, EAMPurchaseOrder.FIELDCAPTION(Store), EAMPurchaseOrder.Store, Location.TABLECAPTION));

                IF EAMPurchaseOrder.Currency <> '' THEN BEGIN
                    IF NOT EamCurrencyExist(EAMPurchaseOrder) AND NOT IsEamLCYCode(EAMPurchaseOrder) THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text017, EAMPurchaseOrder.Currency));
                END;

                ErrorText := GetLineTypeError(EAMPurchaseOrder.Type, EAMPurchaseOrder."Item No/Trade", EAMPurchaseOrder);
                IF ErrorText <> '' THEN
                    GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", ErrorText);

                PurchasesPayablesSetup.GET;

                PurchaseLine.RESET;
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", EAMPurchaseOrder."Purchase order code");
                IF Item.Type = Item.Type::Inventory THEN
                    PurchaseLine.SETRANGE("Line No.", EAMPurchaseOrder.Line)
                ELSE
                    PurchaseLine.SETRANGE("No.", EAMPurchaseOrder."Item No/Trade");
                IF PurchaseLine.FINDFIRST THEN BEGIN
                    IF Item.Type = Item.Type::Inventory THEN BEGIN
                        IF EAMPurchaseOrder."UOM (Requested Quantity)" < PurchaseLine."Quantity Received" THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", Text026)
                    END ELSE BEGIN
                        IF EAMPurchaseOrder."UOM (Requested Quantity)" < PurchaseLine."Quantity Invoiced" THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", Text026);
                    END;

                END;
                //Test for the purchase Receipt no series
                IF EAMPurchaseOrder.Store <> '' THEN BEGIN
                    IF Location.GET(EAMPurchaseOrder.Store) THEN BEGIN
                        // IF (Location."Purch. Receipt Nos." = '') AND (PurchasesPayablesSetup."Posted Receipt Nos." = '') THEN //pcpl-065
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(text011, PurchasesPayablesSetup.FIELDCAPTION("Posted Receipt Nos."), EAMPurchaseOrder.Store));
                    END;
                END ELSE BEGIN
                    IF PurchasesPayablesSetup."Posted Receipt Nos." = '' THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(text011, PurchasesPayablesSetup.FIELDCAPTION("Posted Receipt Nos."), EAMPurchaseOrder.Store));
                END;

                //Test for the purchase Invoice No. series
                IF EAMPurchaseOrder.Store <> '' THEN BEGIN
                    IF Location.GET(EAMPurchaseOrder.Store) THEN BEGIN
                        /* // pcpl-065
                           IF Location."Trading Location" AND (PurchasesPayablesSetup."Posted Invoice Nos. (Trading)" = '') THEN
                                GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(text010, PurchasesPayablesSetup.FIELDCAPTION("Posted Invoice Nos. (Trading)"), EAMPurchaseOrder.Store))
                            ELSE
                              IF PurchasesPayablesSetup."Posted Invoice Nos." = '' THEN
                                 GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(text010, PurchasesPayablesSetup.FIELDCAPTION("Invoice Nos.")));
                            */ // pcpl-065
                    END
                END ELSE BEGIN
                    IF PurchasesPayablesSetup."Posted Invoice Nos." = '' THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(text010, PurchasesPayablesSetup.FIELDCAPTION("Posted Invoice Nos.")));
                END;

                IF EAMPurchaseOrder."Project code" <> '' THEN BEGIN
                    IF NOT DimensionValue.GET(GeneralLedgerSetup."Global Dimension 2 Code", EAMPurchaseOrder."Project code") THEN
                        GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text022, EAMPurchaseOrder."Project code"))
                    ELSE
                        IF
                     DimensionValue.Blocked THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text032, EAMPurchaseOrder."Project code"))
                END;

                EAMPurchOrder.RESET;
                EAMPurchOrder.SETRANGE("Transaction Type", EAMPurchOrder."Transaction Type"::"Purchase Order");
                EAMPurchOrder.SETRANGE("Purchase order code", EAMPurchaseOrder."Purchase order code");
                EAMPurchOrder.SETRANGE(Line, EAMPurchaseOrder.Line);
                IF EAMPurchOrder.COUNT > 1 THEN BEGIN
                    EAMPurchOrder.SETRANGE("Nav Status", EAMPurchOrder."Nav Status"::Error);
                    IF EAMPurchOrder.FINDFIRST THEN BEGIN
                        EAMPurchOrder."Nav Status" := EAMPurchOrder."Nav Status"::Skipped;
                        EAMPurchOrder.MODIFY;
                    END;
                END;

                IF EAMPurchOrder.GET(EAMPurchaseOrder."Entry No.") THEN BEGIN
                    IF ErrorExist THEN
                        EAMPurchOrder."Nav Status" := EAMPurchOrder."Nav Status"::Error
                    ELSE
                        EAMPurchOrder."Nav Status" := EAMPurchOrder."Nav Status"::Reviewed;
                    EAMPurchOrder.MODIFY;
                END;

            UNTIL EAMPurchaseOrder.NEXT = 0;
        MESSAGE('%1 Lines are Reviewd.', NoOfLines);
    end;

    //[Scope('Internal')]
    procedure ReviewEAMSupplierReturnStagging(ManuallyReview: Boolean)
    var
        EAMSupplierReturn: Record 50005;
        EAMSupplierReturn2: Record 50005;
        EAMPurchaseOrder: Record 50005;
        Currency: Record 4;
        PostingDate: Date;
        PurchaseHeader: Record 38;
        Item: Record 27;
        Vendor: Record 23;
        PurchaseLine: Record 39;
    begin
        PurchasesPayablesSetup.GET;
        // IF NOT PurchasesPayablesSetup."Enable For Processed" THEN //pcpl-065
        EXIT;
        GeneralLedgerSetup.GET;
        EAMSupplierReturn.RESET;
        IF ManuallyReview THEN
            EAMSupplierReturn.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Error)
        ELSE
            EAMSupplierReturn.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Received);
        //EAMSupplierReturn.SETFILTER("Nav Status",'%1|%2',EAMSupplierReturn."Nav Status"::Received,EAMSupplierReturn."Nav Status"::Error);
        EAMSupplierReturn.SETRANGE("Transaction Type", EAMSupplierReturn."Transaction Type"::"Purchase Return Order");
        NoOfLines := EAMSupplierReturn.COUNT;
        IF EAMSupplierReturn.FINDSET THEN
            REPEAT

                ErrorExist := FALSE;
                ClearErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order");

                IF GetVendorNoForReturnOrder(EAMSupplierReturn) = '' THEN
                    GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text018, EAMSupplierReturn.Supplier));

                IF NOT PurchaseLine.GET(PurchaseHeader."Document Type"::Order, EAMSupplierReturn."Purchase order code", EAMSupplierReturn.Line) THEN
                    GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text028, EAMSupplierReturn."Purchase order code", EAMSupplierReturn.Line));

                IF NOT Location.GET(EAMSupplierReturn.Store) AND (EAMSupplierReturn.Store <> '') THEN
                    GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text000, EAMSupplierReturn.FIELDCAPTION(Store), EAMSupplierReturn.Store, Location.TABLECAPTION));

                //  User.RESET;
                //  User.SETRANGE("Employee ID",EAMSupplierReturn."Approved by");
                //  IF User.FINDFIRST THEN
                //    EAMSupplierReturn."User ID" := User."User Name"
                //  ELSE
                //     GenerateErrorLog(EAMSupplierReturn."Entry No.",TransType::"Purchase Return Order",STRSUBSTNO(Text013,EAMSupplierReturn."Approved by"));

                CLEAR(EAMPurchaseOrder);
                GetEAMPurchaseOrder(EAMSupplierReturn, EAMPurchaseOrder);
                IF NOT EAMPurchaseOrder.ISEMPTY THEN BEGIN
                    Currency.RESET;
                    Currency.SETRANGE("EAM Code", EAMPurchaseOrder.Currency);
                    IF Currency.FINDFIRST THEN BEGIN
                        PostingDate := GetDateForDDMMYYYY(EAMSupplierReturn."Return Date");
                        IF NOT IsCurrencyRateExist(PostingDate, Currency.Code, 1) THEN
                            GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text019, Currency.Code, PostingDate))
                    END;

                    IF Item.GET(EAMPurchaseOrder."Item No/Trade") THEN BEGIN
                        IF Item.Type = Item.Type::Inventory THEN BEGIN
                            IF Item."Inventory Posting Group" = '' THEN
                                GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text015, Item.FIELDCAPTION("Inventory Posting Group"), Item.TABLECAPTION, Item."No."));
                        END;
                        IF Item."Gen. Prod. Posting Group" = '' THEN
                            GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text015, Item.FIELDCAPTION("Gen. Prod. Posting Group"), Item.TABLECAPTION, Item."No."));
                    END;

                    Vendor.RESET;
                    Vendor.SETRANGE("EAM Code", EAMPurchaseOrder.Supplier);
                    IF Vendor.FINDFIRST THEN BEGIN
                        IF Vendor.Blocked <> Vendor.Blocked::" " THEN
                            GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text023, Vendor."No."));
                        IF Vendor."Gen. Bus. Posting Group" = '' THEN
                            GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text015, Vendor.FIELDCAPTION("Gen. Bus. Posting Group"), Vendor.TABLECAPTION, Vendor."No."));
                        IF Vendor."Vendor Posting Group" = '' THEN
                            GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text015, Vendor.FIELDCAPTION("Vendor Posting Group"), Vendor.TABLECAPTION, Vendor."No."))
                    END ELSE
                        GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text018, EAMPurchaseOrder.Supplier));


                END;

                //Test for the purchase Receipt Shipment no series
                IF PurchasesPayablesSetup."Posted Return Shpt. Nos." = '' THEN
                    GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text014, PurchasesPayablesSetup.FIELDCAPTION("Posted Return Shpt. Nos.")));

                IF PurchasesPayablesSetup."Posted Credit Memo Nos." = '' THEN
                    GenerateErrorLog(EAMSupplierReturn."Entry No.", TransType::"Purchase Return Order", STRSUBSTNO(Text014, PurchasesPayablesSetup.FIELDCAPTION("Posted Credit Memo Nos.")));

                IF ErrorExist THEN
                    EAMSupplierReturn."Nav Status" := EAMSupplierReturn."Nav Status"::Error
                ELSE
                    EAMSupplierReturn."Nav Status" := EAMSupplierReturn."Nav Status"::Reviewed;
                EAMSupplierReturn.MODIFY;

            UNTIL EAMSupplierReturn.NEXT = 0;
        MESSAGE('%1 Lines are Reviewd.', NoOfLines);
    end;

    //[Scope('Internal')]
    procedure ReviewEAMPurchaseReceiptStagging(ManuallyReview: Boolean)
    var
        EAMPurchaseReceipt: Record 50005;
        EAMPurchReceipt: Record 50005;
        PurchaseHeader: Record 38;
        PurchaseLine: Record 39;
        PurchPostYesNo: Codeunit 91;
        SingleInstance: Codeunit 50003;
        EAMPurchaseOrder: Record 50005;
    begin
        PurchasesPayablesSetup.GET;
        //  IF NOT PurchasesPayablesSetup."Enable For Processed" THEN //pcpl-065
        EXIT;
        GeneralLedgerSetup.GET;
        EAMPurchaseReceipt.RESET;
        // IF ManuallyReview THEN
        //  EAMPurchaseReceipt.SETRANGE("Nav Status",EAMPurchaseReceipt."Nav Status"::Error)
        // ELSE
        //EAMPurchaseReceipt.SETRANGE("Nav Status",EAMPurchaseReceipt."Nav Status"::Received);
        EAMPurchaseReceipt.SETFILTER("Nav Status", '%1|%2', EAMPurchaseReceipt."Nav Status"::Received, EAMPurchaseReceipt."Nav Status"::Error);
        EAMPurchaseReceipt.SETRANGE("Transaction Type", EAMPurchaseReceipt."Transaction Type"::"Purchase Receipt");
        NoOfLines := EAMPurchaseReceipt.COUNT;
        IF EAMPurchaseReceipt.FINDSET THEN
            REPEAT

                ErrorExist := FALSE;
                ClearErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt");
                PurchaseLine.RESET;
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", EAMPurchaseReceipt."Purchase order code");
                PurchaseLine.SETRANGE("Line No.", EAMPurchaseReceipt.Line);
                //  IF Item.GET(EAMPurchaseReceipt."Item No/Trade") THEN BEGIN
                //    IF Item.Type = Item.Type::Inventory THEN
                //      PurchaseLine.SETRANGE("Line No.",EAMPurchaseReceipt.Line)
                //    ELSE BEGIN
                //      EAMPurchaseOrder.SETRANGE("Transaction Type",EAMPurchaseOrder."Transaction Type"::"Purchase Order");
                //      EAMPurchaseOrder.SETRANGE("Nav Status",EAMPurchaseOrder."Nav Status"::Processed);
                //      EAMPurchaseOrder.SETRANGE("Purchase order code",EAMPurchaseReceipt."Purchase order code");
                //      EAMPurchaseOrder.SETRANGE("Item No/Trade",EAMPurchaseReceipt."Item No/Trade");
                //      IF EAMPurchaseOrder.FINDFIRST THEN
                //       PurchaseLine.SETRANGE("Line No.",EAMPurchaseOrder.Line)
                //     END
                //  END;
                IF NOT PurchaseLine.FINDFIRST THEN
                    GenerateErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt", STRSUBSTNO(Text012, EAMPurchaseReceipt."Purchase order code", EAMPurchaseReceipt.Line, EAMPurchaseReceipt."Item No/Trade"))
                ELSE BEGIN
                    IF (PurchaseLine."Outstanding Quantity" < EAMPurchaseReceipt."Receipt Quantity (UOM)") OR (EAMPurchaseReceipt."Receipt Quantity (UOM)" < 0) THEN BEGIN
                        GenerateErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt", STRSUBSTNO(Text020, EAMPurchaseReceipt."Receipt Quantity (UOM)"));
                    END ELSE BEGIN
                        PurchaseLine.VALIDATE("Qty. to Receive", EAMPurchaseReceipt."Receipt Quantity (UOM)");
                        PurchaseLine.MODIFY;
                    END;
                    GetPreviewPostingError(EAMPurchaseReceipt);
                    PurchaseLine.VALIDATE("Qty. to Receive", 0);
                    PurchaseLine.MODIFY;
                END;

                IF ErrorExist THEN
                    EAMPurchaseReceipt."Nav Status" := EAMPurchaseReceipt."Nav Status"::Error
                ELSE
                    EAMPurchaseReceipt."Nav Status" := EAMPurchaseReceipt."Nav Status"::Reviewed;
                EAMPurchaseReceipt.MODIFY;
            UNTIL EAMPurchaseReceipt.NEXT = 0;

        MESSAGE('%1 Lines are Reviewd.', NoOfLines);
    end;

    //[Scope('Internal')]
    procedure ClearErrorLog(EntryNo: Integer; TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY)
    var
        EamProcessErrorLog: Record 50009;
    begin
        EamProcessErrorLog.RESET;
        EamProcessErrorLog.SETRANGE("Entry No", EntryNo);
        EamProcessErrorLog.SETRANGE("Transaction Type", TransactionType);
        IF EamProcessErrorLog.FINDSET THEN
            EamProcessErrorLog.DELETEALL;
    end;

    //[Scope('Internal')]
    procedure GenerateErrorLog(EntryNo: Integer; TransactionType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY; Error: Text)
    var
        EamProcessErrorLog: Record 50009;
        ErrorEntryNo: Integer;
    begin
        IF Error = '' THEN
            EXIT;
        EamProcessErrorLog.RESET;
        EamProcessErrorLog.SETRANGE("Entry No", EntryNo);
        EamProcessErrorLog.SETRANGE("Transaction Type", TransactionType);
        IF EamProcessErrorLog.FINDLAST THEN
            ErrorEntryNo := EamProcessErrorLog."Error No" + 1
        ELSE
            ErrorEntryNo := 1;
        EamProcessErrorLog.INIT;
        EamProcessErrorLog."Entry No" := EntryNo;
        EamProcessErrorLog."Error No" := ErrorEntryNo;
        EamProcessErrorLog."Transaction Type" := TransactionType;
        EamProcessErrorLog.Error := Error;
        EamProcessErrorLog.INSERT;
        ErrorExist := TRUE;
    end;

    local procedure GetLineTypeError(Type: Option " ","G/L Account",Item,,"Fixed Asset","Charge (Item)"; No: Code[20]; EAMPurchaseOrder: Record 50005): Text
    var
        GLAccount: Record 15;
        Item: Record 27;
        FixedAsset: Record 5600;
        ItemCharge: Record 5800;
    begin
        CASE Type OF
            Type::"G/L Account":
                BEGIN
                    IF NOT GLAccount.GET(No) THEN
                        EXIT(STRSUBSTNO(Text006, Type, No))
                END;
            Type::Item:
                BEGIN
                    IF Item.GET(No) THEN BEGIN
                        IF Item.Type = Item.Type::Service THEN
                            EXIT;
                        IF Item.Type = Item.Type::Inventory THEN BEGIN
                            IF Item."Inventory Posting Group" = '' THEN
                                GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text015, Item.FIELDCAPTION("Inventory Posting Group"), Item.TABLECAPTION, Item."No."));
                        END;

                        IF Item."Gen. Prod. Posting Group" = '' THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text015, Item.FIELDCAPTION("Gen. Prod. Posting Group"), Item.TABLECAPTION, Item."No."));

                        IF Item."Base Unit of Measure" = '' THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text015, Item.FIELDCAPTION("Base Unit of Measure"), Item.TABLECAPTION, Item."No."));

                        IF Item.Blocked THEN
                            GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", STRSUBSTNO(Text024, Item."No."));

                    END ELSE
                        EXIT(STRSUBSTNO(Text006, Type, No))
                END;
            Type::"Fixed Asset":
                BEGIN
                    IF NOT FixedAsset.GET(No) THEN
                        EXIT(STRSUBSTNO(Text006, Type, No))
                END;
            Type::"Charge (Item)":
                BEGIN
                    IF NOT ItemCharge.GET THEN
                        EXIT(STRSUBSTNO(Text006, Type, No))
                END;
            Type::" ":
                EXIT(Text007)
        END
    end;

    //[Scope('Internal')]
    procedure IsCurrencyRateExist(Date: Date; CurrencyCode: Code[10]; CacheNo: Integer): Boolean
    var
        CurrencyExchRate2: array[2] of Record 330;
    begin
        IF Date = 0D THEN
            Date := WORKDATE;
        CurrencyExchRate2[CacheNo].SETRANGE("Currency Code", CurrencyCode);
        CurrencyExchRate2[CacheNo].SETRANGE("Starting Date", 0D, Date);
        IF CurrencyExchRate2[CacheNo].FINDLAST THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    local procedure "-------ProcessEAMStagging-------"()
    begin
    end;

    // [Scope('Internal')]
    procedure CreateEamProcess()
    begin
        /*
        CreatePurchaseOrder;
        CreatePurchaseReceipt;
        CreatePurchaseReturnOrder;
        */ //pcpl-065

        //Creation of purchase Order
    end;

    //[Scope('Internal')]
    procedure CreatePurchaseOrder()
    var
        EAMPurchaseOrder: Record 50005;
        EAMPurchOrder: Record 50005;
        PurchaseHeader: Record 38;
        EAMPurchaseOrder2: Record 50005;
        LineCreated: Boolean;
    begin
        PurchasesPayablesSetup.GET;
        //    IF NOT PurchasesPayablesSetup."Enable For Processed" THEN pcpl-065
        EXIT;
        CLEAR("PreDocNo.");
        GeneralLedgerSetup.GET;
        PurchasesPayablesSetup.GET;
        EAMPurchaseOrder.RESET;
        EAMPurchaseOrder.SETRANGE("Transaction Type", EAMPurchaseOrder."Transaction Type"::"Purchase Order");
        EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Reviewed);
        NoOfLines := EAMPurchaseOrder.COUNT;
        IF EAMPurchaseOrder.FINDSET THEN
            REPEAT
                IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseOrder."Purchase order code") THEN BEGIN
                    IF PurchaseHeader.Status <> PurchaseHeader.Status::Open THEN BEGIN
                        //  GenerateErrorLog(EAMPurchaseOrder."Entry No.", TransType::"Purchase Order", Text025); //pcpl-065
                        EAMPurchaseOrder."Nav Status" := EAMPurchaseOrder."Nav Status"::Error;
                        EAMPurchaseOrder.MODIFY
                    END;
                END;
                EAMPurchaseOrder2.SETCURRENTKEY("Nav Status", "Purchase order code", Line);
                EAMPurchaseOrder2.RESET;
                EAMPurchaseOrder2.SETRANGE("Transaction Type", EAMPurchaseOrder2."Transaction Type"::"Purchase Order");
                EAMPurchaseOrder2.SETRANGE("Purchase order code", EAMPurchaseOrder."Purchase order code");
                EAMPurchaseOrder2.SETFILTER("Nav Status", '%1|%2', EAMPurchaseOrder2."Nav Status"::Error, EAMPurchaseOrder2."Nav Status"::Received);
                IF NOT EAMPurchaseOrder2.FINDFIRST THEN BEGIN
                    IF ("PreDocNo." <> EAMPurchaseOrder."Purchase order code") AND (NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseOrder."Purchase order code")) THEN
                        CreatePurchOrderHeader(EAMPurchaseOrder);
                    LineCreated := FALSE;
                    LineCreated := CreatePurchOrderLine(EAMPurchaseOrder);
                    "PreDocNo." := EAMPurchaseOrder."Purchase order code";
                    IF EAMPurchaseOrder.Status <> EAMPurchaseOrder.Status::OPEN THEN BEGIN
                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseOrder."Purchase order code") THEN BEGIN
                            PurchaseHeader.Status := EAMPurchaseOrder.Status;
                            PurchaseHeader.MODIFY;
                        END;
                    END;

                    IF EAMPurchOrder.GET(EAMPurchaseOrder."Entry No.") THEN BEGIN
                        EAMPurchOrder."Nav Document No." := EAMPurchaseOrder."Purchase order code";
                        IF LineCreated THEN
                            EAMPurchOrder."Nav Status" := EAMPurchOrder."Nav Status"::Processed
                        ELSE BEGIN
                            EAMPurchOrder."Nav Status" := EAMPurchOrder."Nav Status"::Error;
                            //  GenerateErrorLog(EAMPurchOrder."Entry No.", TransType::"Purchase Order", Text025); //pcpl-065
                        END;
                        EAMPurchOrder.MODIFY;

                    END
                END;
            UNTIL EAMPurchaseOrder.NEXT = 0;
        MESSAGE('%1 Lines are Processed.', NoOfLines);
    end;

    local procedure CreatePurchOrderHeader(var EAMPurchaseOrder: Record 50005)
    var
        PurchaseHeader: Record 38;
        VendorNo: Code[20];
        Item: Record 27;
    begin
        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseOrder."Purchase order code") THEN BEGIN
            PurchaseHeader.INIT;
            PurchaseHeader."No." := EAMPurchaseOrder."Purchase order code";
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
            // PurchaseHeader.VALIDATE("Order Date", GetDate(EAMPurchaseOrder."Order date")); // pcpl-065
            PurchaseHeader.VALIDATE("Posting Date", PurchaseHeader."Order Date");
            PurchaseHeader.INSERT;
        END;
        IF PurchaseHeader.Status = PurchaseHeader.Status::Released THEN
            EXIT;
        VendorNo := GetVendorNoForPO(EAMPurchaseOrder);
        PurchaseHeader.VALIDATE("Buy-from Vendor No.", VendorNo);
        /*
        IF PurchasesPayablesSetup."Default VAT Bus. Posting Group" <> '' THEN
            PurchaseHeader.VALIDATE("VAT Bus. Posting Group", PurchasesPayablesSetup."Default VAT Bus. Posting Group"); */ //pcpl-065
                                                                                                                           // PurchaseHeader.VALIDATE("Order Date" ,GetDate(EAMPurchaseOrder."Order date"));
                                                                                                                           // PurchaseHeader.VALIDATE("Posting Date",PurchaseHeader."Order Date");
                                                                                                                           // PurchaseHeader.VALIDATE("Location Code", PurchasesPayablesSetup."Default Location"); //pcpl-065
        IF EAMPurchaseOrder.Currency <> '' THEN BEGIN
            IF NOT IsEamLCYCode(EAMPurchaseOrder) THEN BEGIN
                IF EamCurrencyExist(EAMPurchaseOrder) THEN
                    PurchaseHeader.VALIDATE("Currency Code", Currency.Code);
            END ELSE
                PurchaseHeader.VALIDATE("Currency Code", '');
        END;

        IF PurchaseHeader."Currency Code" <> '' THEN
            PurchaseHeader.VALIDATE("Currency Factor", EAMPurchaseOrder."Exchange Rate");
        // PurchaseHeader.VALIDATE(Structure, 'GST');//pcpl-065
        //PurchaseHeader.VALIDATE("Posting Date",PurchaseHeader."Order Date");
        //PurchaseHeader."Document Date" := PurchaseHeader."Posting Date";
        PurchaseHeader."Posting Description" := EAMPurchaseOrder.Description;
        PurchaseHeader.VALIDATE("Payment Terms Code", EAMPurchaseOrder."Payment Terms");
        // PurchaseHeader.VALIDATE("Due Date", GetDate(EAMPurchaseOrder."Due Date")); //pcpl-065

        PurchaseHeader."Replicated From EAM" := TRUE;
        PurchaseHeader.VALIDATE("Shortcut Dimension 2 Code", EAMPurchaseOrder."Project code");
        //<<OA.DT
        IF Vend.GET(PurchaseHeader."Pay-to Vendor No.") THEN BEGIN
            IF Vend."GST Registration No." <> '' THEN BEGIN
                PurchaseHeader."Vendor GST Reg. No." := Vend."GST Registration No.";
                IF Location1.GET(PurchaseHeader."Location Code") THEN BEGIN
                    PurchaseHeader."Location GST Reg. No." := Location1."GST Registration No.";
                    PurchaseHeader."Location State Code" := Location1."State Code";
                END;
            END;
        END;
        //>>OA.DT

        PurchaseHeader.MODIFY;
    end;

    local procedure CreatePurchOrderLine(var EAMPurchaseOrder: Record 50005): Boolean
    var
        PurchaseLine: Record 39;
        VendorNo: Code[20];
        GSTGroup: Record "GST Group";//16404; //pcpl-065
        Item: Record 27;
        PurchaseHeader: Record 38;
    begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseOrder."Purchase order code") THEN BEGIN
            IF PurchaseHeader.Status = PurchaseHeader.Status::Released THEN
                EXIT(FALSE);
        END;
        IF NOT PurchaseLine.GET(PurchaseLine."Document Type"::Order, EAMPurchaseOrder."Purchase order code", EAMPurchaseOrder.Line) THEN BEGIN
            PurchaseLine.INIT;
            PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
            PurchaseLine."Document No." := EAMPurchaseOrder."Purchase order code";
            PurchaseLine."Line No." := EAMPurchaseOrder.Line;
            PurchaseLine.INSERT;
        END;
        // VendorNo := GetVendorNoForPO(EAMPurchaseOrder);
        // PurchaseLine.VALIDATE("Buy-from Vendor No.",VendorNo);
        // PurchaseLine.VALIDATE("Location Code",PurchasesPayablesSetup."Default Location");
        IF IsInventoryItem(EAMPurchaseOrder) THEN BEGIN
            PurchaseLine.VALIDATE(Type, EAMPurchaseOrder.Type);
            PurchaseLine.VALIDATE("No.", EAMPurchaseOrder."Item No/Trade");
        END ELSE BEGIN
            PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
            //  PurchaseLine.VALIDATE("No.", PurchasesPayablesSetup."Default G/L"); //pcpl-065
        END;
        PurchaseLine.VALIDATE(Quantity, EAMPurchaseOrder."UOM (Requested Quantity)");
        PurchaseLine.VALIDATE("Direct Unit Cost", EAMPurchaseOrder."Price (UOP)");
        PurchaseLine.VALIDATE("Qty. to Receive", EAMPurchaseOrder."UOM (Requested Quantity)");
        // GSTGroup.RESET;
        // GSTGroup.SETRANGE("EAM Code",EAMPurchaseOrder."Tax Code");
        // IF GSTGroup.FINDFIRST THEN
        //  PurchaseLine.VALIDATE("GST Group Code",GSTGroup.Code);
        // PurchaseLine.VALIDATE("GST %",EAMPurchaseOrder."Tax percentage");
        // PurchaseLine.VALIDATE("Total GST Amount",EAMPurchaseOrder."Total Tax Amount");
        PurchaseLine."EAM Item Code" := EAMPurchaseOrder."Item No/Trade";
        PurchaseLine."EAM Qtantity" := EAMPurchaseOrder."UOM (Requested Quantity)";
        PurchaseLine."EAM Amount" := EAMPurchaseOrder."Price (UOP)";
        PurchaseLine."EAM Location" := EAMPurchaseOrder.Store;

        //OA.DT<<
        PurchHead.SETRANGE("Document Type", PurchaseLine."Document Type");
        PurchHead.SETRANGE("No.", PurchaseLine."Document No.");
        IF PurchHead.FINDSET THEN
            PurchaseLine."Buy-From GST Registration No" := PurchHead."Vendor GST Reg. No.";
        //OA.DT>>

        PurchaseLine.MODIFY;
        EXIT(TRUE);
    end;

    //[Scope('Internal')] //pcpl-065
    procedure CreatePurchaseReceipt()
    var
        EAMPurchaseReceipt: Record 50005;
    begin
        PurchasesPayablesSetup.GET;
        //  IF NOT PurchasesPayablesSetup."Enable For Processed" THEN //pcpl-065
        EXIT;
        TransferReceivingQtyInPO;
    end;

    local procedure TransferReceivingQtyInPO()
    var
        PurchaseLine: Record 39;
        EAMPurchaseReceipt: Record 50005;
        EAMPurchReceipt: Record 50005;
        PurchaseHeader: Record 38;
        NAVtoEAMSubscriber: Codeunit 50000;
        Cnt: Integer;
        ReceiptErrorExist: Boolean;
        Item: Record 27;
        PurchHeader: Record 38;
        EAMPurchaseOrder: Record 50005;
        SkipRecord: Boolean;
    begin
        PurchaseHeaderTemp.DELETEALL;
        EAMPurchaseReceipt.RESET;

        EAMPurchaseReceipt.SETCURRENTKEY("Nav Status", "Purchase order code", "PO Receipt", Date);
        EAMPurchaseReceipt.SETRANGE("Nav Status", EAMPurchaseReceipt."Nav Status"::Reviewed);
        EAMPurchaseReceipt.SETRANGE("Transaction Type", EAMPurchaseReceipt."Transaction Type"::"Purchase Receipt");
        EAMPurchaseReceipt.SETRANGE("Qty Transfered in PO", FALSE);
        EAMPurchaseReceipt.SETFILTER("Nav Document No.", '%1', '');
        IF EAMPurchaseReceipt.FINDSET THEN
            REPEAT
                EAMPurchReceipt.RESET;
                EAMPurchReceipt.SETCURRENTKEY("Nav Status", "Purchase order code", "PO Receipt", Date);
                EAMPurchReceipt.SETRANGE("Transaction Type", EAMPurchaseReceipt."Transaction Type"::"Purchase Receipt");
                EAMPurchReceipt.SETRANGE("PO Receipt", EAMPurchaseReceipt."PO Receipt");
                //EAMPurchReceipt.SETFILTER("Item No/Trade",'<>%1',EAMPurchaseReceipt."Item No/Trade");
                EAMPurchReceipt.SETFILTER(Line, '<>%1', EAMPurchaseReceipt.Line);
                EAMPurchReceipt.SETFILTER("Nav Status", '%1|%2', EAMPurchReceipt."Nav Status"::Error, EAMPurchReceipt."Nav Status"::Received);
                IF NOT EAMPurchReceipt.FINDFIRST THEN
                    ReceiptErrorExist := FALSE;
                SkipRecord := FALSE;
                IF PurchaseHeaderTemp.GET(PurchHeader."Document Type"::Order, EAMPurchaseReceipt."Purchase order code") THEN BEGIN
                    IF EAMPurchaseReceipt."PO Receipt" <> PurchaseHeaderTemp."Receiving No." THEN
                        SkipRecord := TRUE
                END;
                IF NOT SkipRecord THEN BEGIN
                    IF PurchHeader.GET(PurchHeader."Document Type"::Order, EAMPurchaseReceipt."Purchase order code") THEN BEGIN
                        IF PurchHeader.Status = PurchHeader.Status::Released THEN BEGIN
                            PurchaseLine.RESET;
                            PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                            PurchaseLine.SETRANGE("Document No.", EAMPurchaseReceipt."Purchase order code");
                            PurchaseLine.SETRANGE("Line No.", EAMPurchaseReceipt.Line);
                            //    IF Item.GET(EAMPurchaseReceipt."Item No/Trade") THEN BEGIN
                            //      IF Item.Type = Item.Type::Inventory THEN
                            //        PurchaseLine.SETRANGE("Line No.",EAMPurchaseReceipt.Line)
                            //      ELSE BEGIN
                            //        EAMPurchaseOrder.SETRANGE("Transaction Type",EAMPurchaseOrder."Transaction Type"::"Purchase Order");
                            //        EAMPurchaseOrder.SETRANGE("Nav Status",EAMPurchaseOrder."Nav Status"::Processed);
                            //        EAMPurchaseOrder.SETRANGE("Purchase order code",EAMPurchaseReceipt."Purchase order code");
                            //        EAMPurchaseOrder.SETRANGE("Item No/Trade",EAMPurchaseReceipt."Item No/Trade");
                            //        IF EAMPurchaseOrder.FINDFIRST THEN
                            //          PurchaseLine.SETRANGE("Line No.",EAMPurchaseOrder.Line);
                            //      END;
                            //    END;
                            IF PurchaseLine.FINDFIRST THEN BEGIN
                                IF PurchaseLine."Outstanding Quantity" < EAMPurchaseReceipt."Receipt Quantity (UOM)" THEN BEGIN
                                    GenerateErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt", STRSUBSTNO(Text020, EAMPurchaseReceipt."Receipt Quantity (UOM)"));
                                    ReceiptErrorExist := TRUE;
                                END ELSE BEGIN
                                    PurchaseLine.VALIDATE("Qty. to Receive", EAMPurchaseReceipt."Receipt Quantity (UOM)");
                                    PurchaseLine.MODIFY;
                                END;
                                ReceiptErrorExist := GetPreviewPostingError(EAMPurchaseReceipt);
                            END;
                        END ELSE BEGIN //
                            ReceiptErrorExist := TRUE;
                            ReceiptErrorExist := GetStatusError(EAMPurchaseReceipt);
                        END;
                    END;



                    IF NOT ReceiptErrorExist THEN BEGIN
                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseReceipt."Purchase order code") THEN BEGIN
                            IF NOT PurchaseHeaderTemp.GET(PurchaseHeader."Document Type", PurchaseHeader."No.") THEN BEGIN
                                PurchaseHeaderTemp.INIT;
                                PurchaseHeaderTemp.TRANSFERFIELDS(PurchaseHeader);
                                PurchaseHeaderTemp."Receiving No." := EAMPurchaseReceipt."PO Receipt";
                                //PurchaseHeaderTemp."Receiving Date" := EAMPurchaseReceipt.Date; //pcpl-065
                                PurchaseHeaderTemp.Receive := TRUE;
                                PurchaseHeaderTemp.INSERT;
                            END;
                            PurchaseHeaderTemp.RESET;
                        END;
                    END;
                END;
            UNTIL EAMPurchaseReceipt.NEXT = 0;

        COMMIT;
        PostPurchaseReceipt;
        UpdateEAMPurchaseReceiptEntry;
    end;

    local procedure PostPurchaseReceipt()
    var
        NAVtoEAMSubscriber: Codeunit 50000;
        PurchPost: Codeunit 90;
    begin
        //Post Receipt Entry
        PurchaseHeaderTemp.RESET;
        PurchaseHeaderTemp.SETFILTER("Receiving No.", '<>%1', '');
        IF PurchaseHeaderTemp.FINDSET THEN
            REPEAT
                PurchRcptHeaderTemp.INIT;
                PurchRcptHeaderTemp."No." := PurchaseHeaderTemp."Receiving No.";
                PurchRcptHeaderTemp.INSERT;
                NAVtoEAMSubscriber.RUN(PurchaseHeaderTemp);
                COMMIT;
            UNTIL PurchaseHeaderTemp.NEXT = 0;

        IF NOT PurchaseHeaderTemp.ISEMPTY THEN
            PurchaseHeaderTemp.DELETEALL;
    end;

    local procedure UpdateEAMPurchaseReceiptEntry()
    var
        Cnt: Integer;
        EAMPurchaseReceipt: Record 50005;
        ErrorCnt: Integer;
    begin
        Cnt := 0;
        EAMPurchaseReceipt.RESET;
        IF PurchRcptHeaderTemp.FINDSET THEN
            REPEAT
                EAMPurchaseReceipt.SETRANGE("PO Receipt", PurchRcptHeaderTemp."No.");
                IF EAMPurchaseReceipt.FINDSET THEN
                    REPEAT
                        IF PurchRcptHeaderTemp."Posting Description" = 'Error' THEN BEGIN
                            ErrorCnt += 1;
                            EAMPurchaseReceipt."Nav Status" := EAMPurchaseReceipt."Nav Status"::Error
                        END ELSE BEGIN
                            EAMPurchaseReceipt.SETRANGE("Nav Status", EAMPurchaseReceipt."Nav Status"::Reviewed);
                            Cnt += 1;
                            EAMPurchaseReceipt."Nav Document No." := PurchRcptHeaderTemp."No.";
                            EAMPurchaseReceipt."Qty Transfered in PO" := TRUE;
                            EAMPurchaseReceipt."Nav Status" := EAMPurchaseReceipt."Nav Status"::Processed;

                        END;
                        EAMPurchaseReceipt.MODIFY;
                    UNTIL EAMPurchaseReceipt.NEXT = 0;
            UNTIL PurchRcptHeaderTemp.NEXT = 0;

        EAMPurchaseReceipt.RESET;
        IF EAMPurchaseReceipt.FINDSET THEN
            REPEAT
                EAMPurchaseReceipt.CALCFIELDS("Error Text");
                IF EAMPurchaseReceipt."Error Text" <> '' THEN BEGIN
                    ErrorCnt += 1;
                    EAMPurchaseReceipt."Nav Status" := EAMPurchaseReceipt."Nav Status"::Error;
                    EAMPurchaseReceipt.MODIFY;
                END;
            UNTIL EAMPurchaseReceipt.NEXT = 0;

        IF NOT PurchRcptHeaderTemp.ISEMPTY THEN
            PurchRcptHeaderTemp.DELETEALL;
        MESSAGE('%1  Lines are Processed successfully and %2 error found .', Cnt, ErrorCnt);
    end;

    //[Scope('Internal')] //pcpl-065
    procedure CreatePurchaseReturnOrder()
    var
        EAMSupplierReturn: Record 50005;
        EAMSupplierReturn2: Record 50005;
        PurchaseHeader: Record 38;
        PurchaseLine: Record 39;
        EAMPurchaseOrder: Record 50005;
        UnprocessedEAMSupplierReturn: Record 50005;
    begin
        PurchasesPayablesSetup.GET;
        // IF NOT PurchasesPayablesSetup."Enable For Processed" THEN //pcpl-065
        EXIT;
        GeneralLedgerSetup.GET;
        EAMSupplierReturn.RESET;
        CLEAR("PreDocNo.");
        EAMSupplierReturn.SETRANGE("Transaction Type", EAMSupplierReturn."Transaction Type"::"Purchase Return Order");

        EAMSupplierReturn.SETRANGE("Nav Status", EAMSupplierReturn."Nav Status"::Reviewed);
        NoOfLines := EAMSupplierReturn.COUNT;
        IF EAMSupplierReturn.FINDSET THEN
            REPEAT
                UnprocessedEAMSupplierReturn.RESET;
                UnprocessedEAMSupplierReturn.SETCURRENTKEY("Nav Status", "Supplier Return No.", "Purchase order code", Line);
                UnprocessedEAMSupplierReturn.SETRANGE("Transaction Type", EAMSupplierReturn."Transaction Type"::"Purchase Return Order");
                UnprocessedEAMSupplierReturn.SETRANGE("Supplier Return No.", EAMSupplierReturn."Supplier Return No.");
                UnprocessedEAMSupplierReturn.SETFILTER("Nav Status", '%1|%2', UnprocessedEAMSupplierReturn."Nav Status"::Error, UnprocessedEAMSupplierReturn."Nav Status"::Received);
                IF NOT UnprocessedEAMSupplierReturn.FINDFIRST THEN BEGIN
                    GetEAMPurchaseOrder(EAMSupplierReturn, EAMPurchaseOrder);
                    IF ("PreDocNo." <> EAMSupplierReturn."Supplier Return No.") AND (NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::"Return Order", EAMSupplierReturn."Supplier Return No.")) THEN
                        CreatePurchaseReturnHeader(EAMSupplierReturn);
                    CreatePurchaseReturnLine(EAMSupplierReturn);
                    "PreDocNo." := EAMSupplierReturn."Supplier Return No.";

                    IF EAMSupplierReturn2.GET(EAMSupplierReturn."Entry No.") THEN BEGIN
                        EAMSupplierReturn2."Nav Document No." := EAMSupplierReturn2."Supplier Return No.";
                        EAMSupplierReturn2."Nav Status" := EAMSupplierReturn2."Nav Status"::Processed;
                        EAMSupplierReturn2.MODIFY;
                    END
                END;
            UNTIL EAMSupplierReturn.NEXT = 0;
        MESSAGE('%1 Lines are Processed.', NoOfLines);
    end;

    local procedure CreatePurchaseReturnHeader(var EAMSupplierReturn: Record 50005)
    var
        PurchaseHeader: Record 38;
        Currency: Record 4;
        CurrencyExchangeRate: Record 330;
        PostingDate: Date;
        PurchHeader: Record 38;
    begin
        IF PurchHeader.GET(PurchHeader."Document Type"::Order, EAMSupplierReturn."Purchase order code") THEN;
        PurchaseHeader.INIT;
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader."No." := EAMSupplierReturn."Supplier Return No.";
        PurchaseHeader.VALIDATE("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
        PostingDate := GetDateForDDMMYYYY(EAMSupplierReturn."Return Date");
        PurchaseHeader.VALIDATE("Posting Date", PostingDate);
        PurchaseHeader.INSERT;
        PurchaseHeader.VALIDATE("Location Code", EAMSupplierReturn.Store);
        // PurchaseHeader.VALIDATE("User ID", EAMSupplierReturn."User ID"); //pcpl-065
        PurchaseHeader.VALIDATE("Shortcut Dimension 2 Code", PurchHeader."Shortcut Dimension 2 Code");
        PurchaseHeader.MODIFY;
    end;

    local procedure CreatePurchaseReturnLine(var EAMSupplierReturn: Record 50005)
    var
        PurchaseLine: Record 39;
        PurchaseLine2: Record 39;
        VendorNo: Code[20];
        Description: Text;
        I: Integer;
        LineNo: Integer;
    begin
        IF PurchaseLine2.GET(PurchaseLine2."Document Type"::Order, EAMSupplierReturn."Purchase order code", EAMSupplierReturn.Line) THEN;
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::"Return Order");
        PurchaseLine.SETRANGE("Document No.", EAMSupplierReturn."Supplier Return No.");
        IF PurchaseLine.FINDLAST THEN
            LineNo := PurchaseLine."Line No." + 10000
        ELSE
            LineNo := 10000;
        PurchaseLine.INIT;
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::"Return Order";
        PurchaseLine."Document No." := EAMSupplierReturn."Supplier Return No.";
        PurchaseLine."Line No." := LineNo;
        PurchaseLine.Description := 'PO: ' + FORMAT(EAMSupplierReturn."Purchase order code") + ' ,Item: ' + FORMAT(PurchaseLine2."No.") + ' ,Qty: ' + FORMAT(EAMSupplierReturn."Return Qty");
        PurchaseLine.INSERT;
    end;

    //[Scope('Internal')]
    procedure GetDate(var DateText: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        MonthText: Text;
    begin
        //Date formate 17-DEC-2)20
        EVALUATE(Day, COPYSTR(DateText, 1, 2));
        EVALUATE(Year, COPYSTR(DateText, 8, 4));
        MonthText := COPYSTR(DateText, 4, 3);
        CASE MonthText OF
            'JAN':
                Month := 1;
            'FEB':
                Month := 2;
            'MAR':
                Month := 3;
            'APR':
                Month := 4;
            'MAY':
                Month := 5;
            'JUN':
                Month := 6;
            'JUL':
                Month := 7;
            'AUG':
                Month := 8;
            'SEP':
                Month := 9;
            'OCT':
                Month := 10;
            'NOV':
                Month := 11;
            'DEC':
                Month := 12;
        END;
        EXIT(DMY2DATE(Day, Month, Year));
    end;

    //[Scope('Internal')]
    procedure GetDateForDDMMYYYY(var DateText: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        MonthText: Text;
    begin
        //Date formate 17-01-2020
        EVALUATE(Day, COPYSTR(DateText, 1, 2));
        EVALUATE(Month, COPYSTR(DateText, 4, 2));
        EVALUATE(Year, COPYSTR(DateText, 7, 4));
        EXIT(DMY2DATE(Day, Month, Year));
    end;

    local procedure EamCurrencyExist(var EAMPurchaseOrder: Record 50005): Boolean
    var
        GeneralLedgerSetup: Record 98;
    begin
        Currency.RESET;
        Currency.SETRANGE("EAM Code", EAMPurchaseOrder.Currency);
        IF Currency.FINDFIRST THEN
            EXIT(TRUE);

        EXIT(FALSE)
    end;

    local procedure IsEamLCYCode(var EAMPurchaseOrder: Record 50005): Boolean
    begin
        IF GeneralLedgerSetup."EAM LCY Code" = EAMPurchaseOrder.Currency THEN
            EXIT(TRUE);
        EXIT(FALSE)
    end;

    local procedure GetVendorNoForPO(var EAMPurchaseOrder: Record 50005): Code[20]
    var
        Vendor: Record 23;
    begin
        Vendor.RESET;
        Vendor.SETRANGE("EAM Code", EAMPurchaseOrder.Supplier);
        IF Vendor.FINDFIRST THEN
            EXIT(Vendor."No.");
    end;

    local procedure GetVendorNoForReturnOrder(var EAMSupplierReturn: Record 50005): Code[20]
    var
        Vendor: Record 23;
    begin
        Vendor.RESET;
        Vendor.SETRANGE("EAM Code", EAMSupplierReturn.Supplier);
        IF Vendor.FINDFIRST THEN
            EXIT(Vendor."No.");
    end;

    // [Scope('Internal')] pcpl-065
    procedure GetPreviewPostingError(EAMPurchaseReceipt: Record 50005): Boolean
    var
        PurchaseHeader: Record 38;
        PurchasePreviewPosting: Codeunit 50003;
        ErrorExist: Boolean;
    begin
        COMMIT;
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseReceipt."Purchase order code") THEN BEGIN
            PurchaseHeader."Vendor Invoice No." := 'Preview';
            IF NOT PurchasePreviewPosting.RUN(PurchaseHeader) THEN BEGIN
                IF GETLASTERRORTEXT <> '' THEN BEGIN
                    ErrorExist := TRUE;
                    GenerateErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt", GETLASTERRORTEXT);
                END;
            END;
        END;
        EXIT(ErrorExist);
    end;

    // [Scope('Internal')] pcpl-065
    procedure GetStatusError(EAMPurchaseReceipt: Record 50005): Boolean
    var
        PurchaseHeader: Record 38;
        PurchasePreviewPosting: Codeunit 50003;
        ErrorExist: Boolean;
    begin
        COMMIT;
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EAMPurchaseReceipt."Purchase order code") THEN BEGIN
            IF PurchaseHeader.Status <> PurchaseHeader.Status::Released THEN BEGIN
                ErrorExist := TRUE;
                GenerateErrorLog(EAMPurchaseReceipt."Entry No.", TransType::"Purchase Receipt", STRSUBSTNO(Text027, PurchaseHeader."No.", PurchaseHeader.Status));
            END;
        END;
        EXIT(ErrorExist);
    end;

    local procedure GetEAMPurchaseOrder(EAMSupplierReturn: Record 50005; var EAMPurchaseOrder: Record 50005)
    begin
        EAMPurchaseOrder.RESET;
        EAMPurchaseOrder.SETRANGE(EAMPurchaseOrder."Transaction Type", EAMPurchaseOrder."Transaction Type"::"Purchase Order");
        EAMPurchaseOrder.SETRANGE("Purchase order code", EAMSupplierReturn."Purchase order code");
        EAMPurchaseOrder.SETRANGE(Line, EAMSupplierReturn.Line);
        IF EAMPurchaseOrder.FINDFIRST THEN;
    end;

    local procedure IsInventoryItem(EAMPurchaseOrder: Record 50005): Boolean
    begin
        IF Item.GET(EAMPurchaseOrder."Item No/Trade") THEN BEGIN
            IF Item.Type = Item.Type::Inventory THEN
                EXIT(TRUE)
        END;
        EXIT(FALSE);
    end;
}

