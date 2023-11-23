page 50040 "EAM Item"
{
    Caption = 'EAM Item';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = "EAM Master Stagging";
    SourceTableView = WHERE("Master Type" = FILTER(ITEM));

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
                field("Seamec Part/Trade"; Rec."Seamec Part/Trade")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Unit of measure"; Rec."Unit of measure")
                {
                }
                field("Out of Service"; Rec."Out of Service")
                {
                }
                field("HSN Code"; Rec."HSN Code")
                {
                }
                field("Error Log"; Rec."Error Log")
                {
                }
                field("Item Type"; Rec."Item Type")
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
                    //  CreateEAMMaster.ReviewEamStagging(TransType::ITEM, TRUE); //pcpl-065
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
                    //  CreateEAMMaster.CreateEamMaster(TransType::ITEM); //pcpl-065
                end;
            }
            action("Show Error")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "EAM Master Error Log";//50044;
                RunPageLink = "Entry No" = FIELD("Entry No."),
                              "Transaction Type" = FILTER(ITEM);
            }
            action(SendStockItem)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                //EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    // EAMInterface.SendStockItemRequest; //pcpl-065
                end;
            }
            action(SendServiceItem)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                //EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    // EAMInterface.SendServiceItemRequest;//pcpl-065
                end;
            }
        }
        area(navigation)
        {
            action(Item)
            {
                Ellipsis = true;
                Image = Item;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 30;
                RunPageLink = "No." = FIELD("Seamec Part/Trade");
            }
            action("Reviewed EAM Item")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50040;
                RunPageLink = Status = CONST(Reviewed);
            }
            action("Processed EAM Item")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50040;
                RunPageLink = Status = CONST(Processed);
            }
        }
    }

    var
        CreateEAMMaster: Codeunit 50001;
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
}

