table 50000 "EAM Setup"
{

    fields
    {
        field(1; "Source Type"; Option)
        {
            OptionCaption = ' ,Vendor,Stock Item,Service Item,Order,Invoice,Payment,Currency,Payment Term,TAX';
            OptionMembers = " ",Vendor,"Stock Item","Service Item","Order",Invoice,Payment,Currency,"Payment Term",TAX;
        }
        field(2; "NAV Transaction Type"; Option)
        {
            OptionCaption = ' ,Inbound,Outbound';
            OptionMembers = " ",Inbound,Outbound;
        }
        field(3; "Service URL"; Text[100])
        {
        }
        field(4; "Authentication Text"; Text[250])
        {
        }
        field(5; "XML TAG"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Source Type", "NAV Transaction Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

