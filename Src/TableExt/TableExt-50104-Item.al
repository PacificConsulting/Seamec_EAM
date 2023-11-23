tableextension 50104 ItemExt extends Item
{
    fields
    {
        field(50012; "Replicate To EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50013; "Replicate From EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}