page 50041 "EAM Employee"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = "EAM Master Stagging";
    SourceTableView = WHERE("Master Type" = FILTER(EMPLOYEE));

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
                field("Employee ID"; Rec."Employee ID")
                {
                }
                field(Description; Rec.Description)
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
                    //CreateEAMMaster.ReviewEamStagging(TransType::EMPLOYEE, TRUE); PCPL-065
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
                    // CreateEAMMaster.CreateEamMaster(TransType::EMPLOYEE); //pcpl-065
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
                              "Transaction Type" = FILTER(EMPLOYEE);
            }
        }
        area(navigation)
        {
            action(Employee)
            {
                Ellipsis = true;
                Image = Vendor;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 5200;
                RunPageLink = "No." = FIELD("Employee ID");
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

