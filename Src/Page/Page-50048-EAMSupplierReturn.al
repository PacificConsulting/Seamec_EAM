page 50048 "EAM Supplier Return"
{
    Caption = 'EAM Supplier Return';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Document,List';
    SourceTable = "EAM Transaction";
    SourceTableView = WHERE("Transaction Type" = FILTER("Purchase Return Order"));

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
                field("Supplier Return No."; Rec."Supplier Return No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Purchase order code"; Rec."Purchase order code")
                {
                }
                field(Line; Rec.Line)
                {
                }
                field(Supplier; Rec.Supplier)
                {
                }
                field(Store; Rec.Store)
                {
                }
                field("Return Qty"; Rec."Return Qty")
                {
                }
                field("Return Date"; Rec."Return Date")
                {
                }
                field("Approved by"; Rec."Approved by")
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
            action("Review EAM Supplier Return")
            {
                Caption = 'Review EAM Supplier Return';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.ReviewEAMSupplierReturnStagging(TRUE); //pcpl-065
                end;
            }
            action("Create Purchase Return Order")
            {
                Caption = 'Create Purchase Return Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.CreatePurchaseReturnOrder; //pcpl-065
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
                              "Transaction Type" = FILTER('Purchase Return Order');
            }
        }
        area(navigation)
        {
            action("Purchase Return Order")
            {
                Ellipsis = true;
                Image = "Order";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 6640;
                RunPageLink = "Document Type" = FILTER("Return Order"),
                              "No." = FIELD("Supplier Return No.");
            }
            action("Reviewed EAM Supplier Return")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50048;
                RunPageLink = "Nav Status" = FILTER('Reviewed');
            }
            action("Processed EAM Suppplier Return")
            {
                Caption = 'Processed EAM Purchase Receipt';
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50048;
                RunPageLink = "Nav Status" = FILTER('Processed');
            }
        }
    }

    var
        ProcessEamProcessStagging: Codeunit "Process EAM Process Stagging";//50002;
}

