tableextension 50101 PaymentTermsExt extends "Payment Terms"
{
    fields
    {
        field(50001; Type; Option)
        {
            OptionMembers = ,Pay,SHIP,FRTR;
            OptionCaption = ' ,Pay,SHIP,FRTR';
        }
        field(50002; "EAM Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}