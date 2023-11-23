page 50046 "EAM Purchase Order"
{
    Caption = 'EAM Purchase Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Document,List';
    SourceTable = 50005;
    SourceTableView = WHERE("Transaction Type" = FILTER("Purchase Order"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Nav Status"; Rec."Nav Status")
                {
                }
                field("Nav Document No."; Rec."Nav Document No.")
                {
                }
                field(Supplier; Rec.Supplier)
                {
                }
                field("Purchase order code"; Rec."Purchase order code")
                {
                }
                field("Order date"; Rec."Order date")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field(Store; Rec.Store)
                {
                }
                field(Currency; '')// Rec.RCurrency)  //pcpl-065
                {
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("GST Amount (INR)"; Rec."GST Amount (INR)")
                {
                }
                field("Freight (INR)"; Rec."Freight (INR)")
                {
                }
                field("Miscalleaneous Charges (INR)"; Rec."Miscalleaneous Charges (INR)")
                {
                }
                field("Cleaning & Fwd Chrg (INR)"; Rec."Cleaning & Fwd Chrg (INR)")
                {
                }
                field("Extra Charges Currency"; Rec."Extra Charges Currency")
                {
                }
                field("Total Extra Charge"; Rec."Total Extra Charge")
                {
                }
                field(Buyer; Rec.Buyer)
                {
                }
                field(Originator; Rec.Originator)
                {
                }
                field("Project code"; Rec."Project code")
                {
                }
                field(Line; Rec.Line)
                {
                }
                field(Type; Rec.Type)
                {
                }
                field("Item No/Trade"; Rec."Item No/Trade")
                {
                }
                field("UOM (Requested Quantity)"; Rec."UOM (Requested Quantity)")
                {
                }
                field("Purchase Quantity (UOP)"; Rec."Purchase Quantity (UOP)")
                {
                }
                field("Price (UOP)"; Rec."Price (UOP)")
                {
                }
                field("Tax Code"; Rec."Tax Code")
                {
                }
                field("Tax percentage"; Rec."Tax percentage")
                {
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {
                }
                field("Total Extra"; Rec."Total Extra")
                {
                }
                field("Error Log"; Rec."Error Log")
                {
                }
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Date Time"; Rec."Date Time")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Review EAM Purchase Order")
            {
                Caption = 'Review EAM Purchase Order';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.ReviewEAMPurchaseOrderStagging(TRUE); //pcpl-065
                end;
            }
            action("Create Purchase Order")
            {
                Caption = 'Create Purchase Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.CreatePurchaseOrder;//pcpl-065
                end;
            }
            action("Show Error")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50045;
                RunPageLink = "Entry No" = FIELD("Entry No."),
                              "Transaction Type" = FILTER("Purchase Order");
            }
            action(SendPOStatus)
            {
                Caption = 'Send PO Status';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    // EAMInterface.SendPurchaseOrderRequest(TRUE);
                end;
            }
            action(SendInvoices)
            {
                Caption = 'Send Invoices';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                //  EAMInterface: Codeunit 50004; //page-065
                begin
                    //  EAMInterface.SendPurchaseInvoiceRequest //papl-065
                end;
            }
            action(SendInvoicePayment)
            {
                Caption = 'Send Invoice Payment';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                /// EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    //  EAMInterface.SendPaymentRequest; //pcpl-065
                end;
            }
        }
        area(navigation)
        {
            action("Purchase Order")
            {
                Ellipsis = true;
                Image = "Order";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 50;
                RunPageLink = "No." = FIELD("Purchase order code"),
                              "Document Type" = FILTER(Order);
            }
            action("EAM Purchase Order Error List")
            {
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50046;
                RunPageLink = "Nav Status" = FILTER(Error);
            }
            action("Ready To Approve EAM Purchase Order")
            {
                Caption = 'Ready To Approve EAM Purchase Order';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    EAMPurchaseOrder.RESET;
                    PurchaseHeaderTemp.DELETEALL;
                    EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Processed);
                    EAMPurchaseOrder.SETRANGE("Ready To Invoice", FALSE);
                    EAMPurchaseOrder.SETRANGE(Invoiced, FALSE);
                    IF EAMPurchaseOrder.FINDSET THEN
                        REPEAT
                            InserNotApprovedPurhOrderTemp(EAMPurchaseOrder."Purchase order code");
                        UNTIL EAMPurchaseOrder.NEXT = 0;
                    IF NOT PurchaseHeaderTemp.ISEMPTY THEN
                        ShowPurchaseOrderListPage(TRUE)
                    ELSE
                        ERROR(Text002);
                end;
            }
            action("Created Purchase Order")
            {
                Caption = 'Created Purchase Order';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    EAMPurchaseOrder.RESET;
                    PurchaseHeaderTemp.DELETEALL;
                    EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Processed);
                    IF EAMPurchaseOrder.FINDSET THEN
                        REPEAT
                            InserNotApprovedPurhOrderTemp(EAMPurchaseOrder."Purchase order code");
                        UNTIL EAMPurchaseOrder.NEXT = 0;
                    IF NOT PurchaseHeaderTemp.ISEMPTY THEN
                        ShowPurchaseOrderListPage(FALSE)
                    ELSE
                        ERROR(Text001);
                end;
            }
            action("Completly Received EAM Purchase Order")
            {
                Caption = 'Completly Received EAM Purchase Order';
                Image = Purchase;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    EAMPurchaseOrder.RESET;
                    PurchaseHeaderTemp.DELETEALL;
                    EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Processed);
                    IF EAMPurchaseOrder.FINDSET THEN
                        REPEAT
                            InsertCompletlyRecivedPurhOrderTemp(EAMPurchaseOrder."Purchase order code");
                        UNTIL EAMPurchaseOrder.NEXT = 0;
                    IF NOT PurchaseHeaderTemp.ISEMPTY THEN
                        ShowPurchaseOrderListPage(FALSE)
                    ELSE
                        ERROR(Text001);
                end;
            }
            action("Created Invoice")
            {
                Caption = 'Created Invoice';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PurchInvHeader: Record "Purch. Inv. Header";
                    PurchInvHeaderTemp: Record "Purch. Inv. Header" temporary;
                    PostedPurchaseInvoicesPage: Page 146;
                begin
                    PurchInvHeaderTemp.DELETEALL;
                    EAMPurchaseOrder.RESET;
                    EAMPurchaseOrder.SETRANGE("Nav Status", EAMPurchaseOrder."Nav Status"::Processed);
                    IF EAMPurchaseOrder.FINDSET THEN
                        REPEAT
                            PurchInvHeader.RESET;
                            PurchInvHeader.SETRANGE("Order No.", EAMPurchaseOrder."Purchase order code");
                            IF PurchInvHeader.FINDSET THEN
                                REPEAT
                                    IF NOT PurchInvHeaderTemp.GET(PurchInvHeader."No.") THEN BEGIN
                                        PurchInvHeaderTemp.INIT;
                                        PurchInvHeaderTemp.TRANSFERFIELDS(PurchInvHeader);
                                        PurchInvHeaderTemp.INSERT;
                                    END;
                                UNTIL PurchInvHeader.NEXT = 0;
                        UNTIL EAMPurchaseOrder.NEXT = 0;
                    IF NOT PurchInvHeaderTemp.ISEMPTY THEN
                        PAGE.RUN(146, PurchInvHeaderTemp)
                    ELSE
                        ERROR(Text001);
                end;
            }
        }
    }

    var
        ProcessEamProcessStagging: Codeunit 50002;
        PurchaseHeaderTemp: Record "Purchase Header" temporary;
        EAMPurchaseOrder: Record "EAM Transaction";//50005;
        PurchaseOrderList: Page "Purchase Order List";//9307
        Text001: Label 'There is not any completly received EAM Purchase Order exist.';
        Text002: Label 'There is not any purchase order to approve.';

    local procedure InserNotApprovedPurhOrderTemp(OrderNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        IF NOT PurchaseHeaderTemp.GET(PurchaseHeaderTemp."Document Type"::Order, OrderNo) THEN BEGIN
            PurchaseHeaderTemp.INIT;
            IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, OrderNo) THEN BEGIN
                PurchaseHeaderTemp.TRANSFERFIELDS(PurchaseHeader);
                PurchaseHeaderTemp.INSERT;
            END
        END;
    end;

    local procedure InsertCompletlyRecivedPurhOrderTemp(OrderNo: Code[20])
    var
        PurchaseLine: Record 39;
        CompletelyReceived: Boolean;
        PurchaseHeader: Record 38;
    begin
        CompletelyReceived := FALSE;
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SETRANGE("Document No.", OrderNo);
        IF PurchaseLine.FINDSET THEN BEGIN
            PurchaseLine.CALCSUMS("Quantity");
            PurchaseLine.CALCSUMS("Quantity Received");
            PurchaseLine.CALCSUMS("Quantity Invoiced");
            IF NOT (PurchaseLine.Quantity = PurchaseLine."Quantity Invoiced") THEN BEGIN
                IF (PurchaseLine.Quantity = PurchaseLine."Quantity Received") THEN
                    CompletelyReceived := TRUE;
            END
        END;
        IF NOT CompletelyReceived THEN
            EXIT;
        IF NOT PurchaseHeaderTemp.GET(PurchaseHeaderTemp."Document Type"::Order, EAMPurchaseOrder."Purchase order code") THEN BEGIN
            PurchaseHeaderTemp.INIT;
            IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, OrderNo) THEN BEGIN
                PurchaseHeaderTemp.TRANSFERFIELDS(PurchaseHeader);
                PurchaseHeaderTemp.INSERT;
            END
        END;
    end;

    local procedure ShowPurchaseOrderListPage(ReadyToApprove: Boolean)
    begin
        CLEAR(PurchaseOrderList);
        IF ReadyToApprove THEN
            PurchaseHeaderTemp.SETFILTER(Status, '<>%1', PurchaseHeaderTemp.Status::Released);
        PAGE.RUN(9307, PurchaseHeaderTemp);
    end;
}

