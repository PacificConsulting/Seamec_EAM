page 50039 "EAM Vendor"
{
    Caption = 'EAM Vendor';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Master,List';
    SourceTable = "EAM Master Stagging";
    SourceTableView = WHERE("Master Type" = FILTER(VENDOR));

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
                field("Supplier ID"; Rec."Supplier ID")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Address; Rec.Address)
                {
                }
                field("Address 2"; Rec."Address 2")
                {
                }
                field(City; Rec.City)
                {
                }
                field("Contact name"; Rec."Contact name")
                {
                }
                field(Telephone; Rec.Telephone)
                {
                }
                field("Currency code"; Rec."Currency code")
                {
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                }
                field("Ship Vai"; Rec."Ship Vai")
                {
                }
                field(Country; Rec.Country)
                {
                }
                field("Out of Service"; Rec."Out of Service")
                {
                }
                field("Zip Code"; Rec."Zip Code")
                {
                }
                field("Email Address"; Rec."Email Address")
                {
                }
                field("P.A.N. No."; Rec."P.A.N. No.")
                {
                }
                field("GST No"; Rec."GST No")
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
                    //  CreateEAMMaster.ReviewEamStagging(TransType::VENDOR, TRUE); //pcpl-065
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
                    //CreateEAMMaster.CreateEamMaster(TransType::VENDOR); //pcpl-065

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
                             "Transaction Type" = FILTER(VENDOR);
            }
            action("Send Vendor Status")
            {
                Caption = 'Send Vendor Status';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    //  EAMInterface.SendVendorRequest;//pcpl-065
                end;
            }
        }
        area(navigation)
        {
            action(Vendor)
            {
                Ellipsis = true;
                Image = Vendor;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page 26;
                RunPageLink = "No." = FIELD("Supplier ID");
            }
            action("Vendor to Approve")
            {
                Ellipsis = true;
                Image = Vendor;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Reviewed EAM Vendor")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50039;
                RunPageLink = Status = CONST(Reviewed);
            }
            action("Processed EAM Vendor")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page 50039;
                RunPageLink = Status = CONST(Processed);

                trigger OnAction()
                begin
                    VendorCreated := TRUE;
                end;
            }
        }
    }

    var
        CreateEAMMaster: Codeunit 50001;
        VendorCreated: Boolean;
        EAMMasterStagging: Record 50004;
        Vendor: Record 23 temporary;
        TransType: Option "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
}

