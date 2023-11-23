codeunit 50101 "Table-Events"
{
    //START*********************************Table-121******************************
    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine', '', false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; var NextLineNo: Integer; var Handled: Boolean);
    begin
        PurchLine.Description := StrSubstNo('Receipt No. %1', PurchRcptLine."Document No.") + 'Date' + Format(PurchRcptLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnBeforeInsertInvLineFromRcptLine', '', false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line"; var IsHandled: Boolean);
    begin
        PurchRcptLine.UpdateReplicatedFromEAMPurchaseLine(PurchLine);
    end;
    //END***********************************Table-121******************************

    var
        myInt: Integer;
}