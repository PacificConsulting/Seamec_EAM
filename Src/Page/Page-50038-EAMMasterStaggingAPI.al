page 50038 "EAM Master Stagging API"
{
    Caption = 'EAM Master Stagging API';
    PageType = List;
    SourceTable = "EAM Master Stagging";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Record ID"; Rec."Record ID")
                {
                }
                field("Master Type"; Rec."Master Type")
                {
                    ShowMandatory = true;
                }
                field("Currency code"; Rec."Currency code")
                {
                }
                field("Starting Date"; Rec."Starting Date")
                {
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                }
                field("Ending Date"; Rec."Ending Date")
                {
                }
                field("Supplier ID"; Rec."Supplier ID")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Address; Rec.Address)
                {
                }
                field(Address2; Rec."Address 2")
                {
                    Caption = 'Address2';
                }
                field(City; Rec.City)
                {
                }
                field("Contact name"; Rec."Contact name")
                {
                }
                field(Telephone; Rec.Telephone)
                {
                }
                field("Seamec Part/Trade"; Rec."Seamec Part/Trade")
                {
                }
                field("Unit of measure"; Rec."Unit of measure")
                {
                }
                field("Out of Service"; Rec."Out of Service")
                {
                }
                field("HSN Code"; Rec."HSN Code")
                {
                }
                field("Ship Vai"; Rec."Ship Vai")
                {
                }
                field("Email Address"; Rec."Email Address")
                {
                }
                field("GST No"; Rec."GST No")
                {
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                }
                field(Country; Rec.Country)
                {
                }
                field("Employee ID"; Rec."Employee ID")
                {
                }
                field("UOM Code"; Rec."UOM Code")
                {
                }
                field("Seamac Part"; Rec."Seamac Part")
                {
                }
                field(UOP; Rec.UOP)
                {
                }
                field("Quantity per UOP"; Rec."Quantity per UOP")
                {
                }
                field("Zip Code"; Rec."Zip Code")
                {
                }
                field("P.A.N. No."; Rec."P.A.N. No.")
                {
                }
                field(Type; Rec.Type)
                {
                }
                field("UOM Conversion"; Rec."UOM Conversion")
                {
                }
                field(State; Rec.State)
                {
                }
                field("Item Type"; Rec."Item Type")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec."Date Time" := CURRENTDATETIME;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CheckMendatoryField;
    end;

    var
        Employee: Record 5200;
        ItemUnitofMeasure: Record 5404;
        Item: Record 27;
        Vendor: Record 23;
        EAMMasterStagging: Record 50004;
        UnitofMeasure: Record 204;
        Text001: Label 'The Item description length can''t be greater than 10.';
        Text002: Label 'This record is already inserted.';
        Text003: Label 'Item Unit of Measure WITH Seamac Part %1 ,UOP %2 already exist in the sytem;';
        Text010: Label 'Supplier ID can not be blank for %1.';
        Text011: Label 'Employee ID can not be blank.';
        Text012: Label 'Seamec Part/Trade can not be blank.';
        NotBlank: Label '%1 can not be blank for %2.';

    local procedure CheckMendatoryField()
    begin
        IF rec."Master Type" = rec."Master Type"::VENDOR THEN BEGIN
            IF rec."Supplier ID" = '' THEN
                ERROR(STRSUBSTNO(NotBlank, rec.FIELDCAPTION("Supplier ID"), Rec."Master Type"));
            IF rec.Address = '' THEN
                ERROR(STRSUBSTNO(NotBlank, rec.FIELDCAPTION(Address), Rec."Master Type"));
            rec."Trasaction Type" := rec."Trasaction Type"::VENDOR;
        END;

        IF rec."Master Type" = rec."Master Type"::ITEM THEN BEGIN
            IF rec."Seamec Part/Trade" = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION("Seamec Part/Trade"), rec."Master Type");

            IF rec.Description = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION(Description), rec."Master Type");

            IF rec."Unit of measure" = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION("Unit of measure"), rec."Master Type");
            rec."Trasaction Type" := rec."Trasaction Type"::ITEM;
        END;

        IF rec."Master Type" = rec."Master Type"::EMPLOYEE THEN BEGIN
            IF rec."Employee ID" = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION("Employee ID"), rec."Master Type");

            rec."Trasaction Type" := rec."Trasaction Type"::EMPLOYEE;
        END;

        IF rec."Master Type" = rec."Master Type"::UOM THEN BEGIN
            IF rec."UOM Code" = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION("UOM Code"), Rec."Master Type");

            rec."Trasaction Type" := rec."Trasaction Type"::UOM;
        END;

        IF rec."Master Type" = rec."Master Type"::"ITEM UOM" THEN BEGIN
            IF rec."Seamac Part" = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION("Seamac Part"), rec."Master Type");
            IF rec.UOP = '' THEN
                ERROR(NotBlank, rec.FIELDCAPTION(UOP), rec."Master Type");
            rec."Trasaction Type" := rec."Trasaction Type"::"ITEM UOM"
        END;

        IF rec."Master Type" = rec."Master Type"::"ITEM UOM" THEN BEGIN
            rec."Trasaction Type" := rec."Trasaction Type"::"ITEM UOM";
        END;
    end;
}

