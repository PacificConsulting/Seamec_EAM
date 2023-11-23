tableextension 50105 PurchaseHdrExt extends "Purchase Header"
{
    fields
    {
        field(50005; "Replicate To EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Replicated From EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}