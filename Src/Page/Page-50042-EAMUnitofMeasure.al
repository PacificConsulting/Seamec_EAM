page 50042 "EAM Unit of Measure"
{
    Caption = 'EAM Unit of Measure';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = 50004;
    SourceTableView = WHERE("Master Type" = FILTER(UOM));

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
                field("UOM Code"; Rec."UOM Code")
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
                    // CreateEAMMaster.ReviewEamStagging(TransType::UOM,TRUE); pcpl-065
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
                    //  CreateEAMMaster.CreateEamMaster(TransType::UOM); //pcpl-065
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
                              "Transaction Type" = FILTER('UOM');
            }
        }
        area(navigation)
        {
            action("Unit of Measure")
            {
                Ellipsis = true;
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 209;
                RunPageLink = Code = FIELD("UOM Code");
            }
            action("Reviewed EAM UOM")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50043;
                RunPageLink = Status = CONST(Reviewed);
            }
            action("Processed EAM UOM")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50043;
                RunPageLink = Status = CONST(Processed);
            }
        }
    }

    var
        CreateEAMMaster: Codeunit 50001;
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
}

