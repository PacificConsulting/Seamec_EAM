tableextension 50113 GSTGroupExt extends "GST Group"
{
    fields
    {
        field(50001; "EAM Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}