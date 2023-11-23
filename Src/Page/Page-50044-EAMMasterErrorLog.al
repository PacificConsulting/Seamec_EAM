page 50044 "EAM Master Error Log"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = 50009;
    SourceTableView = WHERE("Transaction Type" = FILTER(VENDOR | ITEM | UOM | EMPLOYEE | "ITEM UOM" | PAY));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Error; Rec.Error)
                {
                }
            }
        }
    }

    actions
    {
    }
}

