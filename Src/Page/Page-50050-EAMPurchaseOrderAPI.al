page 50050 "EAM Purchase Order API"
{
    PageType = List;
    SourceTable = 50005;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Supplier; Rec.Supplier)
                {
                }
                field("Purchase order code"; Rec."Purchase order code")
                {
                }
                field("Order date"; Rec."Order date")
                {
                }
                field(Description;Rec. Description)
                {
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field(Store; Rec.Store)
                {
                }
                field(Currency; Rec.Currency)
                {
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("GST Amount (INR)"; Rec."GST Amount (INR)")
                {
                }
                field("Freight (INR)"; Rec."Freight (INR)")
                {
                }
                field("Miscalleaneous Charges (INR)"; Rec."Miscalleaneous Charges (INR)")
                {
                }
                field("Cleaning & Fwd Chrg (INR)"; Rec."Cleaning & Fwd Chrg (INR)")
                {
                }
                field("Extra Charges Currency"; Rec."Extra Charges Currency")
                {
                }
                field("Total Extra Charge"; Rec."Total Extra Charge")
                {
                }
                field(Buyer;Rec. Buyer)
                {
                }
                field(Originator; Rec.Originator)
                {
                }
                field("Project code"; Rec."Project code")
                {
                }
                field(Line; Rec.Line)
                {
                }
                field(Type;Rec. Type)
                {
                }
                field("Item No/Trade"; Rec."Item No/Trade")
                {
                }
                field("UOM (Requested Quantity)"; Rec."UOM (Requested Quantity)")
                {
                }
                field("Purchase Quantity (UOP)";Rec. "Purchase Quantity (UOP)")
                {
                }
                field("Price (UOP)"; Rec."Price (UOP)")
                {
                }
                field("Tax Code"; Rec."Tax Code")
                {
                }
                field("Tax percentage"; Rec."Tax percentage")
                {
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {
                }
                field("Total Extra"; Rec."Total Extra")
                {
                }
                field("Total Number of lines"; Rec."Total Number of lines")
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
        Rec."Transaction Type" := Rec."Transaction Type"::"Purchase Order";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Transaction Type" := Rec."Transaction Type"::"Purchase Order";
       Rec."Date Time" := CURRENTDATETIME;
    end;
}

