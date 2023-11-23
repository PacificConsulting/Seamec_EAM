tableextension 50109 PurchRcptLineExt extends "Purch. Rcpt. Line"
{
    fields
    {
        // Add changes to table fields here
    }
    procedure UpdateReplicatedFromEAMPurchaseLine(PurchInvLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    Begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type", "Order No.") THEN BEGIN
            IF PurchaseHeader."Replicated From EAM" THEN BEGIN
                IF PurchaseLine.GET(PurchaseLine."Document Type"::Order, "Order No.", "Order Line No.") THEN BEGIN
                    PurchInvLine.VALIDATE("GST Group Type", PurchaseLine."GST Group Type");
                    PurchInvLine.VALIDATE("GST Group Code", PurchaseLine."GST Group Code");
                    PurchInvLine.VALIDATE("HSN/SAC Code", PurchaseLine."HSN/SAC Code");
                END;
            END;
        END;
    End;

    var
        myInt: Integer;
}