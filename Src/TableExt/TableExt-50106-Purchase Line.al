tableextension 50106 PurchaseLineExt extends "Purchase Line"
{
    fields
    {
        field(50003; "EAM Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
            Editable = false;
        }
        field(50004; "EAM Qtantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50005; "EAM Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50006; "EAM Location"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                if Type = 4 then
                    "Use Duplication List" := true
                Else
                    "Use Duplication List" := false;

                UpdateEAMReplicatedLine;
            end;
        }
    }
    local procedure UpdateEAMReplicatedLine()
    var
    Begin
        IF PurchHeader."Replicated From EAM" THEN BEGIN
            VALIDATE(Quantity, TempPurchLine.Quantity);
            VALIDATE("Direct Unit Cost", TempPurchLine."Direct Unit Cost");
            "EAM Item Code" := TempPurchLine."EAM Item Code";
            "EAM Amount" := TempPurchLine."EAM Amount";
            "EAM Qtantity" := TempPurchLine."EAM Qtantity";
            "EAM Location" := TempPurchLine."EAM Location";
        END;
    End;

    var
        myInt: Integer;
        PurchHeader: Record "Purchase Header";
        TempPurchLine: Record "Purchase Line";
}