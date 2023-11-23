tableextension 50112 CurrExchangerateExt extends "Currency Exchange Rate"
{
    fields
    {
        field(50001; "Replicate To EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Replicate To EAM" then begin
                    TestField("Replicate To EAM", false);
                    //TestField("Ending Date");
                    IF Currency.GET("Currency Code") THEN
                        Currency.TESTFIELD("EAM Code");
                    "Eam Error" := ''
                end;
            end;
        }
        field(50003; "Replicated To Eam"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50004; "Eam Error"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    var
        myInt: Integer;
        Currency: Record Currency;
}