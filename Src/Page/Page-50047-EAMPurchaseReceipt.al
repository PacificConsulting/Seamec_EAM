page 50047 "EAM Purchase Receipt"
{
    Caption = 'EAM Purchase Receipt';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Document,List';
    SourceTable = "EAM Transaction";
    SourceTableView = WHERE("Transaction Type" = FILTER("Purchase Receipt"));

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
                field("PO Receipt"; Rec."PO Receipt")
                {
                }
                field("Purchase order code"; Rec."Purchase order code")
                {
                    Caption = 'Purchase Order No';
                }
                field("Purchase Order Line"; Rec.Line)
                {
                    Caption = 'Purchase Order Line';
                }
                field(Type; Rec.Type)
                {
                }
                field("Item No/Trade"; Rec."Item No/Trade")
                {
                    Caption = 'Item No./Trade';
                }
                field("Receipt Quantity (UOM)"; Rec."Receipt Quantity (UOM)")
                {
                }
                field("Receipt Quantity (PURUOM)"; Rec."Receipt Quantity (PURUOM)")
                {
                }
                field("Quantity In PO Line"; Rec."Quantity In PO Line")
                {
                }
                field("Qty to Receive in PO Line"; Rec."Qty to Receive in PO Line")
                {
                }
                field("Qty Received in PO Line"; Rec."Qty Received in PO Line")
                {
                }
                field("Conversion Factor"; Rec."Conversion Factor")
                {
                }
                field(Store; Rec.Store)
                {
                }
                field("Project code"; Rec."Project code")
                {
                }
                field("Date Received"; Rec."Date Received")
                {
                }
                field(Date; Rec.Date)
                {
                }
                field("Received By"; Rec."Received By")
                {
                }
                field("Error Text"; Rec."Error Text")
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
            action("Review EAM Purchase Receipt")
            {
                Caption = 'Review EAM Purchase Receipt';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.ReviewEAMPurchaseReceiptStagging(TRUE);  //pcpl-065
                end;
            }
            action("Create Purchase Receipt")
            {
                Caption = 'Create Purchase Receipt';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.CreatePurchaseReceipt; //pcpl-065
                end;
            }
            action("Show Error")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "EAM Process Error Log";//50045;//pcpl-065
                RunPageLink = "Entry No" = FIELD("Entry No."),
                              "Transaction Type" = FILTER("Purchase Receipt");
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
                RunObject = Page "Purchase Order";//50; pcpl-065
                RunPageLink = "No." = FIELD("Purchase order code"),
                              "Document Type" = FILTER(Order);
            }
            action("Posted Purchase Receipt")
            {
                Ellipsis = true;
                Image = Receipt;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 136;
                RunPageLink = "No." = FIELD("PO Receipt");
            }
            action("Reviewed EAM Purchase Receipt")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50047;
                RunPageLink = "Nav Status" = FILTER(Reviewed);
            }
            action("Processed EAM Purchase Receipt")
            {
                Caption = 'Processed EAM Purchase Receipt';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50047;
                RunPageLink = "Nav Status" = FILTER(Processed);
            }
        }
    }

    var
        ProcessEamProcessStagging: Codeunit 50002;
}

