tableextension 50102 CurrencyExt extends Currency
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