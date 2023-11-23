codeunit 50000 "NAV to EAM Subscriber"
{
    Permissions = TableData 25 = rm,
                  TableData 122 = rm;
    TableNo = 38;

    trigger OnRun()
    var
        PurchPost: Codeunit 90;
        ProcessEamProcessStagging: Codeunit 50002;
        ErrorExist: Boolean;
        EAMPurchaseOrder: Record 50005;
        ReceivingNo: Code[20];
        EAMPurchaseReceipt: Record 50005;
        ErrorTxt: Text[250];
    begin
        Rec.Receive := TRUE;
        ErrorTxt := '';
        ReceivingNo := Rec."Receiving No.";
        CLEAR(PurchPost);
        // PurchPost.SetPostingDate(TRUE, FALSE, Rec."Receiving Date"); //pcpl-065
        IF PurchPost.RUN(Rec) THEN
            ErrorExist := FALSE
        ELSE BEGIN
            ErrorExist := TRUE;
            ErrorTxt := GETLASTERRORTEXT;
            EAMPurchaseReceipt.RESET;
            EAMPurchaseReceipt.SETRANGE("PO Receipt", ReceivingNo);
            IF EAMPurchaseReceipt.FINDSET THEN
                REPEAT
                //  ProcessEamProcessStagging.GenerateErrorLog(EAMPurchaseReceipt."Entry No.", 1, ErrorTxt);//pcpl-065
                UNTIL EAMPurchaseReceipt.NEXT = 0;
            Rec."Posting Description" := 'Error';
        END;
    end;

    var
        State: Record "State";
        SingleInstance: Codeunit 50003;
        // EAMInterface: Codeunit  50004; //PCPL-065
        ReceiptPostingDate: Date;
        ReceiptQty: Decimal;
        LineNo: Integer;
        EAMPurchaseReceiptTemp: Record 50005 temporary;
        Invoiced: Boolean;
        Received: Boolean;
        Text001: Label 'HSN/SAC code must have a vaule .Do you want to continue?';
        Text002: Label 'Purchase Quantitiy or Amount is not same as EAM Quatity or EAM Amount .';
        Text003: Label 'Headeror Line Location must have a value.';
        Text004: Label 'You can not delete %1 ,as it is replicated from EAM.';
        Text005: Label 'You can not Reopen Purchase Order as this is replicated from EAM.';
        Text006: Label 'You can not insert a new %1 ,as it is replicated from EAM.';
        Text007: Label 'You can not change item in Purchase Line ,as it is replicated from EAM.';
        Text008: Label 'GST Amount is 0 in purchase line .Do you want to proceed .';
        Text009: Label 'Process is stopped.';
        Text010: Label 'You can not modify %1 ,as it is replicated from EAM.';
        Text011: Label 'Value of %1 can not be change as Eam Integration for the process is Enabled.';
        Text012: Label 'You can not open Purchase Orderas some quatity has been received.';

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyVendor(var Rec: Record 23; var xRec: Record 23; RunTrigger: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        IF UserSetup.GET(USERID) THEN BEGIN
            //  IF NOT UserSetup."Vendor Master" THEN BEGIN //pcpl-065
            Rec.VALIDATE(Blocked, Rec.Blocked::All);
            Rec.MODIFY;
            // END; //PCPL-065
        END;
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterValidateEvent', 'Blocked', false, false)]
    local procedure EnableReplicateToEamInVendor(var Rec: Record 23; var xRec: Record 23; CurrFieldNo: Integer)
    begin
        IF NOT Rec."Replicated From EAM" THEN
            EXIT;
        IF Rec.Blocked = Rec.Blocked::" " THEN BEGIN
            Rec.TESTFIELD("Vendor Posting Group");
            Rec.TESTFIELD("Gen. Bus. Posting Group");
            Rec.TESTFIELD("VAT Bus. Posting Group");
        END;
        Rec."Replicate To EAM" := TRUE;
        Rec.MODIFY;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'HSN/SAC Code', false, false)]
    local procedure EnableReplicateOnUpdateHSNItem(var Rec: Record 27; var xRec: Record 27; CurrFieldNo: Integer)
    var
        Continue: Boolean;
    begin
        //IF NOT Rec."Replicated From EAM" THEN //pcpl-065
        EXIT;
        IF Rec.Type = Rec.Type::Inventory THEN
            Rec.TESTFIELD("Inventory Posting Group");
        Rec.TESTFIELD(Blocked, FALSE);
        Rec.TESTFIELD("Gen. Prod. Posting Group");
        Rec.TESTFIELD("Base Unit of Measure");
        Rec.TESTFIELD("VAT Prod. Posting Group");
        IF Rec."HSN/SAC Code" <> xRec."HSN/SAC Code" THEN BEGIN
            Rec."Replicate To EAM" := TRUE;
            Rec.MODIFY;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 415, 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure EnableReplicateOnReleasePO(var PurchaseHeader: Record 38)
    var
        PurchaseLine: Record 39;
    begin
        IF NOT PurchaseHeader."Replicated From EAM" THEN
            EXIT;
        ValidatePOforGSTAmount(PurchaseHeader);
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        IF PurchaseLine.FINDSET THEN
            REPEAT
                IF (PurchaseLine.Quantity <> PurchaseLine."EAM Qtantity") OR (PurchaseLine."Direct Unit Cost" <> PurchaseLine."EAM Amount") THEN
                    ERROR(Text002);
                IF PurchaseLine.Type = PurchaseLine.Type::Item THEN BEGIN
                    IF (PurchaseHeader."Location Code" = '') OR (PurchaseLine."Location Code" = '') THEN
                        ERROR(Text003);
                END;
                PurchaseLine.VALIDATE("Qty. to Receive", 0);
                PurchaseLine.MODIFY;
            UNTIL PurchaseLine.NEXT = 0;
        PurchaseHeader."Replicate To EAM" := TRUE;
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order THEN
            PurchaseHeader."Vendor Invoice No." := '';
        PurchaseHeader.MODIFY;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)]
    [TryFunction]
    local procedure MarkInvoiceAsReplicateFromEam(var PurchaseHeader: Record 38; var GenJnlPostLine: Codeunit 12; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        PurchRcptHeader: Record 120;
        PurchInvLine: Record 123;
        PurchInvHeader: Record 122;
        PurchHeader: Record 38;
    begin
        IF PurchInvHeader.GET(PurchInvHdrNo) THEN BEGIN
            IF PurchInvHeader."Order No." <> '' THEN BEGIN
                EXIT;
            END;
        END;

        PurchInvLine.RESET;
        PurchInvLine.SETRANGE("Document No.", PurchInvHdrNo);
        PurchInvLine.SETFILTER("Receipt No.", '<>%1', '');
        IF PurchInvLine.FINDFIRST THEN BEGIN
            IF PurchRcptHeader.GET(PurchInvLine."Receipt No.") THEN BEGIN
                IF PurchHeader.GET(PurchHeader."Document Type"::Order, PurchRcptHeader."Order No.") THEN
                    IF PurchHeader."Replicated From EAM" = TRUE THEN BEGIN
                        PurchInvHeader."Order No." := PurchHeader."No.";
                        PurchInvHeader."Replicated to EAM" := FALSE;
                        // PurchInvHeader."Replicate from EAM" := TRUE; //pcpl-065
                        PurchInvHeader.MODIFY;
                    END
            END;
        END;
    end;

    local procedure SetEAMPurchaseOrderInvoiced(PurchaseOrderNo: Code[20]; ReadyToInvoicePar: Boolean; InvoicedPar: Boolean)
    var
        EAMPurchaseOrder: Record 50005;
    begin
        EAMPurchaseOrder.RESET;
        EAMPurchaseOrder.SETRANGE("Purchase order code", PurchaseOrderNo);
        IF EAMPurchaseOrder.FINDSET THEN BEGIN
            IF ReadyToInvoicePar THEN
                EAMPurchaseOrder.MODIFYALL("Ready To Invoice", TRUE);
            IF InvoicedPar THEN
                EAMPurchaseOrder.MODIFYALL(Invoiced, TRUE);
        END
    end;

    [EventSubscriber(ObjectType::Codeunit, 415, 'OnBeforeReopenPurchaseDoc', '', false, false)]
    local procedure RestrictEAMRepPOToOpen(var PurchaseHeader: Record 38)
    var
        UserSetup: Record 91;
        POAdmin: Boolean;
    begin
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN BEGIN
                IF UserSetup.GET(USERID) THEN
                    POAdmin := UserSetup."EAM PO Admin";
                IF NOT POAdmin THEN
                    ERROR(Text005);
                UpdateQtyToReceive(PurchaseHeader);
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeletePOHeader(var Rec: Record 38; RunTrigger: Boolean)
    var
        PurchaseHeader: Record 38;
        UserSetup: Record 91;
        POAdmin: Boolean;
        EAMPurchaseOrder: Record 50005;
        PONo: Code[20];
    begin
        IF NOT RunTrigger THEN
            EXIT;
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN
                IF UserSetup.GET(USERID) THEN
                    POAdmin := UserSetup."EAM PO Admin";
            IF NOT POAdmin THEN
                ERROR(STRSUBSTNO(Text004, PurchaseHeader.TABLECAPTION));
        END;
        EAMPurchaseOrder.RESET;
        EAMPurchaseOrder.SETRANGE("Transaction Type", EAMPurchaseOrder."Transaction Type"::"Purchase Order");
        EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Processed);
        EAMPurchaseOrder.SETRANGE("Purchase order code", Rec."No.");
        IF EAMPurchaseOrder.FINDSET THEN
            EAMPurchaseOrder.MODIFYALL("Nav Status", EAMPurchaseOrder."Nav Status"::Reviewed);
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnModifyOHeader(var Rec: Record 38; var xRec: Record 38; RunTrigger: Boolean)
    var
        PurchaseHeader: Record 38;
    begin
        IF NOT RunTrigger THEN
            EXIT;
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN
                ERROR(STRSUBSTNO(Text010, PurchaseHeader.TABLECAPTION));
        END;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeletePOLine(var Rec: Record 39; RunTrigger: Boolean)
    var
        PurchaseHeader: Record 38;
        UserSetup: Record 91;
        POAdmin: Boolean;
    begin
        IF NOT RunTrigger THEN
            EXIT;
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Document No.") THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN BEGIN
                IF UserSetup.GET(USERID) THEN
                    POAdmin := UserSetup."EAM PO Admin";
                IF NOT POAdmin THEN
                    ERROR(STRSUBSTNO(Text004, Rec.TABLECAPTION));
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertPOLine(var Rec: Record 39; RunTrigger: Boolean)
    var
        PurchaseHeader: Record 38;
    begin
        IF NOT RunTrigger THEN
            EXIT;
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Document No.") THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN
                ERROR(STRSUBSTNO(Text006, Rec.TABLECAPTION));
        END;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnValidateItemNoinPOLine(var Rec: Record 39; var xRec: Record 39; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record 38;
    begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Document No.") THEN BEGIN
            IF Rec.Type = Rec.Type::Item THEN BEGIN
                IF xRec."No." <> '' THEN BEGIN
                    IF Rec."No." <> xRec."No." THEN
                        ERROR(Text007)
                END;
            END;
        END;
    end;

    [Scope('Internal')]
    procedure UnapplyPaymentLedgerEntry(VendorLedgerEntry: Record 25)
    var
    //  PaymentLedgerEntry: Record 50007; //pcpl-065
    begin
        /* PaymentLedgerEntry.RESET;
         PaymentLedgerEntry.SETRANGE(Rec."VLE Entry No.", VendorLedgerEntry."Entry No.");
         IF PaymentLedgerEntry.FINDSET THEN
             REPEAT
                 PaymentLedgerEntry.Unapply := TRUE;
                 PaymentLedgerEntry.MODIFY;
             UNTIL PaymentLedgerEntry.NEXT = 0;
             *///pcpl-065
    end;

    [EventSubscriber(ObjectType::Table, 330, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyCurrency(var Rec: Record 330; var xRec: Record 330; RunTrigger: Boolean)
    begin
        IF RunTrigger THEN
            Rec.TESTFIELD("Replicated To Eam", FALSE);
    end;

    [EventSubscriber(ObjectType::Table, 330, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertCurrency(var Rec: Record 330; RunTrigger: Boolean)
    begin
        Rec."Replicate To EAM" := FALSE;
        Rec."Replicated To Eam" := FALSE;
        Rec."Eam Error" := '';
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeleteVendor(var Rec: Record 23; RunTrigger: Boolean)
    begin
        IF Rec."Replicated From EAM" THEN
            ERROR(STRSUBSTNO(Text004, Rec.TABLECAPTION))
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeleteItem(var Rec: Record 27; RunTrigger: Boolean)
    begin
        // IF Rec."Replicated From EAM" THEN //pcpl-065
        ERROR(STRSUBSTNO(Text004, Rec.TABLECAPTION))
    end;

    [EventSubscriber(ObjectType::Table, 330, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeleteCurrency(var Rec: Record 330; RunTrigger: Boolean)
    begin
        IF Rec."Replicated To Eam" THEN
            ERROR(STRSUBSTNO(Text004, Rec.TABLECAPTION))
    end;

    [EventSubscriber(ObjectType::Table, 330, 'OnAfterValidateEvent', 'Relational Exch. Rate Amount', false, false)]
    local procedure OnValidateRelCurrExAmount(var Rec: Record 330; var xRec: Record 330; CurrFieldNo: Integer)
    begin
        Rec."Relational Adjmt Exch Rate Amt" := Rec."Relational Exch. Rate Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePurchPost(var PurchaseHeader: Record 38)
    begin
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" = TRUE THEN
                PurchaseHeader.TESTFIELD("Vendor Invoice No.");
        END;
    end;

    local procedure ValidatePOforGSTAmount(var PurchaseHeader: Record 38)
    var
        PurchaseLine: Record 39;
        Vendor: Record 23;
    begin
        IF Vendor.GET(PurchaseHeader."Buy-from Vendor No.") THEN BEGIN
            IF Vendor."GST Vendor Type" IN [Vendor."GST Vendor Type"::Registered, Vendor."GST Vendor Type"::Unregistered, Vendor."GST Vendor Type"::Import] THEN BEGIN
                PurchaseLine.RESET;
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
                //  PurchaseLine.SETFILTER("Total GST Amount", '%1', 0); //pcpl-065
                PurchaseLine.SETFILTER("GST Group Code", '<>%1', '');
                PurchaseLine.SETFILTER("HSN/SAC Code", '<>%1', '');
                IF PurchaseLine.FINDFIRST THEN BEGIN
                    IF NOT CONFIRM(Text008, FALSE) THEN
                        ERROR(Text009);
                END;
            END;
        END;

    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterValidateEvent', 'Blocked', false, false)]
    local procedure ValidateGSTOnVendorCard(var Rec: Record 23; var xRec: Record 23; CurrFieldNo: Integer)
    begin
        //OA.DT<<
        IF Rec.Blocked = Rec.Blocked::" " THEN BEGIN
            IF Rec."GST Vendor Type" = Rec."GST Vendor Type"::" " THEN
                ERROR('Please provide the Vendor GST Details in Tax Information');
        END;
        //OA.DT>>
    end;

    [EventSubscriber(ObjectType::Table, 312, 'OnAfterValidateEvent', 'Default Qty. to Receive', false, false)]
    local procedure OnAfterValidateEventDefQtyToRec(var Rec: Record 312; var xRec: Record 312; CurrFieldNo: Integer)
    begin
        // IF "Enable For Processed" = TRUE THEN BEGIN  // pcpl-065
        IF Rec."Default Qty. to Receive" <> Rec."Default Qty. to Receive"::Blank THEN
            ERROR(STRSUBSTNO(Text011, Rec.FIELDCAPTION("Default Qty. to Receive")));
        // END; //pcpl-065
    end;

    local procedure UpdateQtyToReceive(PurchaseHeader: Record 38)
    var
        PurchaseLine: Record 39;
    begin
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE("Quantity Received", 0);
        IF PurchaseLine.ISEMPTY THEN
            ERROR(Text012)
        ELSE BEGIN
            IF PurchaseLine.FINDSET THEN
                REPEAT
                    PurchaseLine.VALIDATE("Qty. to Receive", PurchaseLine.Quantity);
                    PurchaseLine.MODIFY;
                UNTIL PurchaseLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 50005, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertEAMTrasaction(var Rec: Record 50005; RunTrigger: Boolean)
    var
    //   JobQueue: Record 470; //pcpl-065
    begin
        /*
        IF JobQueue.GET('EAM') THEN BEGIN
            IF NOT JobQueue.Started THEN
                JobQueue.StartQueue(COMPANYNAME);
        END;
        *///pcpl-065
    end;

    [EventSubscriber(ObjectType::Table, 50004, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertEamMaster(var Rec: Record 50004; RunTrigger: Boolean)
    var
    //  JobQueue: Record 470; pcpl-065
    begin
        /*
        IF JobQueue.GET('EAM') THEN BEGIN
            IF NOT JobQueue.Started THEN
                JobQueue.StartQueue(COMPANYNAME);
        END;
        */
    end;

    [EventSubscriber(ObjectType::Page, 9006, 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenNav()
    var
    // JobQueue: Record job queue;
    begin
        /*
        IF JobQueue.GET('EAM') THEN BEGIN
            IF NOT JobQueue.Started THEN
                JobQueue.StartQueue(COMPANYNAME);
        END;
        */
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyPurchaseLine(var Rec: Record 39; var xRec: Record 39; RunTrigger: Boolean)
    begin
        IF NOT RunTrigger THEN
            EXIT;
        Rec."EAM Item Code" := xRec."EAM Item Code";
        Rec."EAM Amount" := xRec."EAM Amount";
        Rec."EAM Qtantity" := xRec."EAM Qtantity";
        Rec."EAM Location" := xRec."EAM Location";
        Rec.MODIFY;
    end;
}

