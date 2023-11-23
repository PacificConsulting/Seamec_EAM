page 50045 "EAM Process Error Log"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Eam Process Error Log";
    SourceTableView = WHERE("Transaction Type" = FILTER("Purchase Order" | "Purchase Receipt" | "Purchase Return Order" | "Purchase Invoice"));

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

