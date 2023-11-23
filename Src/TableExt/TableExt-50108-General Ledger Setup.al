tableextension 50108 GenLedgSetupExt extends "General Ledger Setup"
{
    fields
    {
        field(50002; "EAM LCY Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}