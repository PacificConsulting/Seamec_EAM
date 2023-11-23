tableextension 50103 VendorExt1 extends Vendor
{
    fields
    {
        field(50001; "Replicate To EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Replicated From EAM"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "EAM Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "EAM Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "EAM Address 2"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}