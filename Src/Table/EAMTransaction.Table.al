table 50005 "EAM Transaction"
{

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            MinValue = 1;
        }
        field(2; "Nav Status"; Option)
        {
            OptionCaption = 'Received,Error,Processed,Reviewed,Skipped';
            OptionMembers = Received,Error,Processed,Reviewed,Skipped;
        }
        field(3; "Nav Document No."; Code[20])
        {
        }
        field(4; Supplier; Code[20])
        {
            NotBlank = true;
            TableRelation = Vendor."No.";
            ValidateTableRelation = false;
        }
        field(5; "Purchase order code"; Code[20])
        {
            Caption = 'Purchase order code';
            NotBlank = true;
        }
        field(6; "Order date"; Text[30])
        {
            NotBlank = true;
        }
        field(7; Description; Text[50])
        {
        }
        field(8; "Payment Terms"; Code[10])
        {
            NotBlank = true;
            TableRelation = "Payment Terms".Code;
            ValidateTableRelation = false;
        }
        field(9; "Due Date"; Text[30])
        {
            NotBlank = true;
        }
        field(10; Store; Code[10])
        {
        }
        field(11; Currency; Code[10])
        {
            TableRelation = Currency.Code;
            ValidateTableRelation = false;
        }
        field(12; "Exchange Rate"; Decimal)
        {
            NotBlank = true;
        }
        field(13; Status; Option)
        {
            OptionCaption = 'OPEN,RELEASED,PENDING APPROVAL,PENDING PREPAYMENT';
            OptionMembers = OPEN,RELEASED,"PENDING APPROVAL","PENDING PREPAYMENT";
        }
        field(14; "GST Amount (INR)"; Text[30])
        {
        }
        field(15; "Freight (INR)"; Decimal)
        {
        }
        field(16; "Miscalleaneous Charges (INR)"; Decimal)
        {
        }
        field(17; "Cleaning & Fwd Chrg (INR)"; Decimal)
        {
            Caption = 'Cleaning & Forwading Charge (INR)';
        }
        field(18; "Extra Charges Currency"; Text[30])
        {
        }
        field(19; "Total Extra Charge"; Decimal)
        {
        }
        field(20; Buyer; Text[30])
        {
        }
        field(21; Originator; Text[30])
        {
        }
        field(22; "Project code"; Text[30])
        {
        }
        field(23; Line; Integer)
        {
            NotBlank = true;
        }
        field(24; Type; Option)
        {
            NotBlank = true;
            OptionCaption = ' ,G/L ACCOUNT,ITEM,,FIXED ASSET,CHARGE (ITEM)';
            OptionMembers = " ","G/L ACCOUNT",ITEM,,"FIXED ASSET","CHARGE (ITEM)";
        }
        field(25; "Item No/Trade"; Code[20])
        {
            Caption = 'Item No/Trade';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L ACCOUNT")) "G/L Account"
            ELSE
            IF (Type = CONST(ITEM)) Item
            ELSE
            IF (Type = CONST("FIXED ASSET")) "Fixed Asset"
            ELSE
            IF (Type = CONST("CHARGE (ITEM)")) "Item Charge";
            ValidateTableRelation = false;
        }
        field(26; "UOM (Requested Quantity)"; Decimal)
        {
        }
        field(27; "Purchase Quantity (UOP)"; Decimal)
        {
            NotBlank = true;
        }
        field(28; "Price (UOP)"; Decimal)
        {
            NotBlank = true;
        }
        field(29; "Tax Code"; Code[20])
        {
            TableRelation = "GST Group";
            ValidateTableRelation = false;
        }
        field(30; "Tax percentage"; Decimal)
        {
        }
        field(31; "Total Tax Amount"; Decimal)
        {
        }
        field(32; "Total Extra"; Text[30])
        {

            trigger OnValidate()
            begin
                IF "Total Extra" = '' THEN
                    "Total Extra" := '0';
            end;
        }
        field(33; "Error Log"; Text[250])
        {
            CalcFormula = Lookup("Eam Process Error Log".Error WHERE("Entry No" = FIELD("Entry No."),
                                                                      "Transaction Type" = FILTER("Purchase Order")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(34; "Total Number of lines"; Integer)
        {
        }
        field(35; "Ready To Invoice"; Boolean)
        {
        }
        field(36; Invoiced; Boolean)
        {
        }
        field(37; "Date Time"; DateTime)
        {
        }
        field(104; "PO Receipt"; Code[20])
        {
            NotBlank = true;
        }
        field(109; "Receipt Quantity (UOM)"; Decimal)
        {
        }
        field(110; "Receipt Quantity (PURUOM)"; Decimal)
        {
        }
        field(111; "Conversion Factor"; Decimal)
        {
        }
        field(114; "Date Received"; Text[30])
        {

            trigger OnValidate()
            begin
                //Date := ProcessEamProcessStagging.GetDateForDDMMYYYY("Date Received"); //PCPL-0070
            end;
        }
        field(115; "Received By"; Text[30])
        {
        }
        field(116; "Error Text"; Text[250])
        {
            CalcFormula = Lookup("Eam Process Error Log".Error WHERE("Entry No" = FIELD("Entry No."),
                                                                      "Transaction Type" = FILTER("Purchase Receipt")));
            FieldClass = FlowField;
        }
        field(117; Date; Date)
        {
        }
        field(118; "Quantity In PO Line"; Decimal)
        {
            CalcFormula = Sum("Purchase Line".Quantity WHERE("Document Type" = FILTER(Order),
                                                              "Document No." = FIELD("Purchase order code"),
                                                              "No." = FIELD("Item No/Trade")));
            FieldClass = FlowField;
        }
        field(119; "Qty to Receive in PO Line"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Qty. to Receive" WHERE("Document Type" = FILTER(Order),
                                                                       "Document No." = FIELD("Purchase order code"),
                                                                       "No." = FIELD("Item No/Trade")));
            FieldClass = FlowField;
        }
        field(120; "Qty Received in PO Line"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Quantity Received" WHERE("Document Type" = FILTER(Order),
                                                                         "Document No." = FIELD("Purchase order code"),
                                                                         "No." = FIELD("Item No/Trade")));
            FieldClass = FlowField;
        }
        field(121; "Qty Transfered in PO"; Boolean)
        {
        }
        field(204; "Supplier Return No."; Code[20])
        {
        }
        field(209; "Return Qty"; Decimal)
        {
            NotBlank = true;
        }
        field(210; "Return Date"; Text[30])
        {
            NotBlank = false;
        }
        field(211; "Approved by"; Text[50])
        {
        }
        field(401; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            OptionCaption = 'Purchase Order,Purchase Receipt,Purchase Return Order,Purchase Invoice';
            OptionMembers = "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL;
        }
        field(402; "User ID"; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Nav Status", "Purchase order code", Line)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Date Time" := CURRENTDATETIME;
    end;

    var
        EAMPurchaseOrder: Record 50005;
        Text001: Label 'This record is already inserted.';
    //ProcessEamProcessStagging: Codeunit 50002; //PCPl-0070
}

