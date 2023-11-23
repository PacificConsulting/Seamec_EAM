table 50009 "Eam Process Error Log"
{
    // DrillDownPageID = 50045;
    // LookupPageID = 50045;

    fields
    {
        field(1; "Entry No"; Integer)
        {
        }
        field(2; "Error No"; Integer)
        {
            MinValue = 1;
        }
        field(3; "Transaction Type"; Option)
        {
            Caption = 'Trasaction Type';
            OptionCaption = 'Purchase Order,Purchase Receipt,Purchase Return Order,Purchase Invoice,VENDOR,ITEM,UOM,EMPLOYEE,ITEM UOM,PAY,ALL';
            OptionMembers = "Purchase Order","Purchase Receipt","Purchase Return Order","Purchase Invoice",VENDOR,ITEM,UOM,EMPLOYEE,"ITEM UOM",PAY,ALL;
        }
        field(4; Error; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No", "Error No", "Transaction Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

