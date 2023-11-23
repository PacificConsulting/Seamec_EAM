codeunit 50003 "Purchase Preview Posting"
{
    TableNo = 38;

    trigger OnRun()
    begin
      //  PurchPostYesNo.DoNotShowAllEntries(TRUE); //pcpl-065
        PurchPostYesNo.Preview(Rec);
    end;

    var
        PurchaseHeader: Record 38;
        PurchPostYesNo: Codeunit 91;
        ProcessEamProcessStagging: Codeunit 50002;
}

