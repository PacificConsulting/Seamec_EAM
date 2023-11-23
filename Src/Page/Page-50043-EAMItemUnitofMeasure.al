page 50043 "EAM Item Unit of Measure"
{
    Caption = 'EAM Item Unit of Measure';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = 50004;
    SourceTableView = WHERE("Master Type" = FILTER("ITEM UOM"));

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
                field("Seamac Part"; Rec."Seamac Part")
                {
                }
                field(UOP; Rec.UOP)
                {
                }
                field("Quantity per UOP"; Rec."Quantity per UOP")
                {
                }
                field("UOM Conversion"; Rec."UOM Conversion")
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
                    //  CreateEAMMaster.ReviewEamStagging(TransType::"ITEM UOM", TRUE); //pcpl-065
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
                    // CreateEAMMaster.CreateEamMaster(TransType::"ITEM UOM");//pcpl-065
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
                              "Transaction Type" = FILTER("ITEM UOM");
            }
        }
        area(navigation)
        {
            action("Item UOM")
            {
                Ellipsis = true;
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "Item Units of Measure";//5404; 
                RunPageLink = "Item No." = FIELD("Seamac Part"),
                              Code = FIELD(UOP);
            }
            action("Reviewed EAM Item UOM")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "EAM Item Unit of Measure";//50043;
                RunPageLink = Status = CONST(Reviewed);
            }
            action("Processed EAM Item UOM")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "EAM Item Unit of Measure";//50043;
                RunPageLink = Status = CONST(Processed);
            }
        }
    }

    var
        CreateEAMMaster: Codeunit "Process EAM Master";
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
}

