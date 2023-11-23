tableextension 50111 UnitOfMeasureExt extends "Unit of Measure"
{
    fields
    {
        field(50001; "EAM Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}