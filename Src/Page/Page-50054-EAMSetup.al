page 50054 "EAM Setup"
{
    PageType = Card;
    SourceTable = "EAM Setup";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source Type"; Rec."Source Type")
                {
                }
                field("NAV Transaction Type"; Rec."NAV Transaction Type")
                {
                }
                field("Service URL"; Rec."Service URL")
                {
                }
                field("Authentication Text"; Rec."Authentication Text")
                {
                }
                field("XML TAG"; Rec."XML TAG")
                {
                }
            }
        }
    }

    actions
    {
    }
}

