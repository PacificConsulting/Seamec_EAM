tableextension 50110 PurchInvHdrExt extends "Purch. Inv. Header"
{
    fields
    {
        field(50004; "Replicated to EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "Replicated Form EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}