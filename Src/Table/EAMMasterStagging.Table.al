table 50004 "EAM Master Stagging"
{

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            MinValue = 1;
        }
        field(2; "Record ID"; Code[40])
        {
            Caption = 'NAV Record ID';
        }
        field(3; "Date Time"; DateTime)
        {
            Editable = false;
        }
        field(4; "Master Type"; Option)
        {
            NotBlank = true;
            OptionCaption = ',VENDOR,ITEM,UOM,EMPLOYEE,ITEM UOM,PAY';
            OptionMembers = ,VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY;
        }
        field(5; Status; Option)
        {
            OptionCaption = 'Received,Error,Processed,Reviewed';
            OptionMembers = Received,Error,Processed,Reviewed;
        }
        field(6; "Currency code"; Code[10])
        {
            TableRelation = Currency.Code;
            ValidateTableRelation = false;
        }
        field(7; "Starting Date"; Text[30])
        {
        }
        field(8; "Exchange Rate"; Text[10])
        {
        }
        field(9; "Ending Date"; Text[30])
        {
        }
        field(10; "Supplier ID"; Code[20])
        {
            TableRelation = Vendor."No.";
            ValidateTableRelation = false;
        }
        field(11; Description; Text[50])
        {
        }
        field(12; Address; Text[50])
        {
        }
        field(13; City; Text[30])
        {
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
        }
        field(14; "Contact name"; Text[50])
        {
        }
        field(15; Telephone; Text[30])
        {
        }
        field(16; "Seamec Part/Trade"; Code[20])
        {
            TableRelation = Item."No.";
            ValidateTableRelation = false;
        }
        field(17; "Unit of measure"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
            ValidateTableRelation = false;
        }
        field(18; "Out of Service"; Boolean)
        {
        }
        field(19; "HSN Code"; Code[8])
        {
            TableRelation = "HSN/SAC".Code;
            ValidateTableRelation = false;
        }
        field(20; "Ship Vai"; Code[10])
        {
            TableRelation = "Shipment Method".Code;
            ValidateTableRelation = false;
        }
        field(21; "Email Address"; Text[50])
        {
        }
        field(22; "GST No"; Text[15])
        {
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;
        }
        field(23; "Payment Terms"; Code[10])
        {
            TableRelation = "Payment Terms".Code;
            ValidateTableRelation = false;
        }
        field(24; Country; Text[30])
        {
            TableRelation = "Country/Region".Code;
            ValidateTableRelation = false;
        }
        field(25; "Employee ID"; Code[20])
        {
            TableRelation = Employee."No.";
            ValidateTableRelation = false;
        }
        field(26; "UOM Code"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
            ValidateTableRelation = false;
        }
        field(27; "Seamac Part"; Code[20])
        {
            TableRelation = Item."No.";
            ValidateTableRelation = false;
        }
        field(28; UOP; Code[10])
        {
        }
        field(29; "Quantity per UOP"; Decimal)
        {
        }
        field(30; "Zip Code"; Code[20])
        {
            TableRelation = "Post Code".Code;
            ValidateTableRelation = false;
        }
        field(31; "P.A.N. No."; Text[30])
        {
        }
        field(32; "Error Log"; Text[250])
        {
            FieldClass = Normal;
        }
        field(33; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,PAY,SHIP,FRTR';
            OptionMembers = " ",PAY,SHIP,FRTR;
        }
        field(34; "UOM Conversion"; Decimal)
        {
        }
        field(35; State; Code[10])
        {
        }
        field(36; Operation; Option)
        {
            OptionCaption = 'Insert,Modify';
            OptionMembers = Insert,Modify;
        }
        field(37; "Item Type"; Option)
        {
            OptionCaption = 'STOCK,SERVICE';
            OptionMembers = STOCK,SERVICE;
        }
        field(38; "Replicated To EAM"; Boolean)
        {
        }
        field(40; "Address 2"; Text[250])
        {
        }
        field(401; "Trasaction Type"; Option)
        {
            OptionCaption = 'Purchase Order,Purchase Receipt,Purchase Return Order,Purchase Invoice,VENDOR,ITEM,UOM,EMPLOYEE,ITEM UOM,PAY,ALL';
            OptionMembers = "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Master Type", Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        EAMMasterStagging: Record 50004;
    begin
    end;

    trigger OnModify()
    begin
        CheckMendatoryField;
    end;

    var
        Text001: Label 'The Item description length can''t be greater than 10.';
        Employee: Record 5200;
        ItemUnitofMeasure: Record 5404;
        Text002: Label 'This record is already inserted.';
        Text003: Label 'Item Unit of Measure WITH Seamac Part %1 ,UOP %2 already exist in the sytem;';
        Item: Record 27;
        Vendor: Record 23;
        Text010: Label 'Supplier ID can not be blank for %1.';
        Text011: Label 'Employee ID can not be blank.';
        Text012: Label 'Seamec Part/Trade can not be blank.';
        NotBlank: Label '%1 can not be blank for %2.';
        EAMMasterStagging: Record 50004;
        UnitofMeasure: Record 204;
        PaymentTerms: Record 3;

    local procedure CheckMendatoryField()
    begin
        "Date Time" := CURRENTDATETIME;
        IF "Master Type" = "Master Type"::VENDOR THEN BEGIN
            IF "Supplier ID" = '' THEN
                ERROR(STRSUBSTNO(NotBlank, FIELDCAPTION("Supplier ID"), Rec."Master Type"));
            IF Address = '' THEN
                ERROR(STRSUBSTNO(NotBlank, FIELDCAPTION(Address), Rec."Master Type"));

            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("Supplier ID", Rec."Supplier ID");
            IF EAMMasterStagging.COUNT > 1 THEN
                Operation := Operation::Modify;

            //  Vendor.RESET;
            //  Vendor.SETRANGE("EAM Code",EAMMasterStagging."Supplier ID");
            //  IF Vendor.FINDFIRST THEN
            //    Operation := Operation::Modify;
        END;

        IF "Master Type" = "Master Type"::ITEM THEN BEGIN
            IF "Seamec Part/Trade" = '' THEN
                ERROR(NotBlank, FIELDCAPTION("Seamec Part/Trade"), "Master Type");

            IF Description = '' THEN
                ERROR(NotBlank, FIELDCAPTION(Description), "Master Type");

            IF "Unit of measure" = '' THEN
                ERROR(NotBlank, FIELDCAPTION("Unit of measure"), "Master Type");

            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("Seamec Part/Trade", Rec."Seamec Part/Trade");
            IF EAMMasterStagging.COUNT > 1 THEN
                Operation := Operation::Modify;

            IF Item.GET("Seamec Part/Trade") THEN
                Operation := Operation::Modify;
        END;

        IF "Master Type" = "Master Type"::EMPLOYEE THEN BEGIN
            IF "Employee ID" = '' THEN
                ERROR(NotBlank, FIELDCAPTION("Employee ID"), "Master Type");

            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("Employee ID", Rec."Employee ID");
            IF EAMMasterStagging.FINDFIRST THEN
                Operation := Operation::Modify;
            IF Employee.GET("Employee ID") THEN
                Operation := Operation::Modify;
        END;

        IF "Master Type" = "Master Type"::UOM THEN BEGIN
            IF "UOM Code" = '' THEN
                ERROR(NotBlank, FIELDCAPTION("UOM Code"), Rec."Master Type");

            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("UOM Code", Rec."UOM Code");
            IF EAMMasterStagging.COUNT > 1 THEN
                Operation := Operation::Modify;

            IF UnitofMeasure.GET("UOM Code") THEN
                Operation := Operation::Modify;
        END;

        IF "Master Type" = "Master Type"::"ITEM UOM" THEN BEGIN
            IF "Seamac Part" = '' THEN
                ERROR(NotBlank, FIELDCAPTION("Seamac Part"), "Master Type");

            IF UOP = '' THEN
                ERROR(NotBlank, FIELDCAPTION(UOP), "Master Type");

            IF ItemUnitofMeasure.GET("Seamac Part", UOP) THEN
                Operation := Operation::Modify;

            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("Seamac Part", EAMMasterStagging."Seamac Part");
            EAMMasterStagging.SETRANGE(UOP, EAMMasterStagging.UOP);
            IF EAMMasterStagging.COUNT > 1 THEN BEGIN
                Operation := Operation::Modify;
            END;
        END;
        IF "Master Type" = "Master Type"::PAY THEN BEGIN
            EAMMasterStagging.RESET;
            EAMMasterStagging.SETRANGE("Master Type", Rec."Master Type");
            EAMMasterStagging.SETRANGE("Payment Terms", EAMMasterStagging."Payment Terms");
            IF EAMMasterStagging.COUNT > 1 THEN
                Operation := Operation::Modify;
        END;
    end;
}

