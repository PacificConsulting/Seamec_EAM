page 50052 "EAM Supplier Return API"
{
    PageType = List;
    SourceTable = "EAM Transaction";//

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Nav Document No."; Rec."Nav Document No.")
                {
                }
                field("Supplier Return No."; Rec."Supplier Return No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Purchase Order"; Rec."Purchase order code")
                {
                    Caption = 'Purchase Order';
                }
                field("PO Line"; Rec.Line)
                {
                    Caption = 'PO Line';
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
            }
        }
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    begin
        Rec."Transaction Type" := Rec."Transaction Type"::"Purchase Return Order";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Transaction Type" := Rec."Transaction Type"::"Purchase Return Order";
        Rec."Date Time" := CURRENTDATETIME;
    end;
}

