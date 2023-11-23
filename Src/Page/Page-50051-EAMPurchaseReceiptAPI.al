page 50051 "EAM Purchase Receipt API"
{
    PageType = List;
    SourceTable = "EAM Transaction";
    SourceTableView = WHERE ("Transaction Type"=FILTER("Purchase Receipt"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Nav Document No.";Rec."Nav Document No.")
                {
                }
                field("PO Receipt";Rec."PO Receipt")
                {
                }
                field("Purchase Order No";Rec."Purchase order code")
                {
                    Caption = 'Purchase Order No';
                }
                field("Purchase Order Line";Rec.Line)
                {
                    Caption = 'Purchase Order Line';
                }
                field(Type;Rec.Type)
                {
                }
                field("Item No/Trade";Rec."Item No/Trade")
                {
                }
                field("Receipt Quantity (UOM)";Rec."Receipt Quantity (UOM)")
                {
                }
                field("Receipt Quantity (PURUOM)";Rec."Receipt Quantity (PURUOM)")
                {
                }
                field("Conversion Factor";Rec."Conversion Factor")
                {
                }
                field(Store;Rec.Store)
                {
                }
                field("Project code";Rec."Project code")
                {
                }
                field("Date Received";Rec."Date Received")
                {
                }
                field("Received By";Rec."Received By")
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
        rec."Transaction Type" := rec."Transaction Type"::"Purchase Receipt";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        rec."Transaction Type" := rec."Transaction Type"::"Purchase Receipt";
        rec."Date Time" := CURRENTDATETIME;
    end;
}

