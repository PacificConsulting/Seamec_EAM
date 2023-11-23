page 50056 "EAM Payment Term"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = 50004;
    SourceTableView = WHERE("Master Type" = FILTER(PAY));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Record ID"; Rec."Record ID")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Payment Terms1"; Rec."Payment Terms")//pcpl-065
                {
                }
                field(Type; Rec.Type)
                {
                }
                field("Error Log"; Rec."Error Log")
                {
                }
                field("Date Time"; Rec."Date Time")
                {
                }
                field("Entry No."; Rec."Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Review Masters")
            {
                Caption = 'Review Masters';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // CreateEAMMaster.ReviewEamStagging(TransType::PAY, TRUE); //pcpl-065
                end;
            }
            action("Create Master")
            {
                Caption = 'Create Master';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // CreateEAMMaster.CreateEamMaster(TransType::PAY); //pcpl-065
                end;
            }
            action("Show Error")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50044;
                RunPageLink = "Entry No" = FIELD("Entry No."),
                             "Transaction Type" = FILTER('PAY');//pcpl-065
            }
        }
        area(navigation)
        {
            action("Payment Terms")
            {
                Ellipsis = true;
                Image = Payment;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 4;
                RunPageLink = "Code" = FIELD("Record ID");
            }
            action("Reviewed EAM Employee")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50041;
                RunPageLink = Status = CONST(Reviewed);
            }
            action("Processed EAM Employee")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50041;
                RunPageLink = Status = CONST(Processed);
            }
        }
    }

    var
        CreateEAMMaster: Codeunit 50001;
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
}

