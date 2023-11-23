page 50049 "Execute EAM"
{
    PromotedActionCategories = 'New,Process,Document,List';

    layout
    {
        area(content)
        {
            group(control1)
            {
                field(Text001; Text001)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SendStockItem)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                //  EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    // EAMInterface.SendStockItemRequest; pcpl-065
                end;
            }
            action(SendServiceItem)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit "EAM Interface"; 50004//pcpl-065
                begin
                    // EAMInterface.SendServiceItemRequest; //pcpl-065
                end;
            }
            action(SendVendorStatus)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit "EAM Interface"; //pcpl-065
                begin
                    //EAMInterface.SendVendorRequest;  //pcpl-065
                end;
            }
            action(SendPaymentTerm)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    //EAMInterface.SendPaymentTermRequest;
                end;
            }
            action(SendCuurencyExchangeRate)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit 50004; //pcpl-065
                begin
                    //EAMInterface.SendCurrencyExhangeRateRequest; //pcpl-065
                end;
            }
            action(SendPOStatus)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                // EAMInterface: Codeunit 50004;  //pcpl-065
                begin
                    //EAMInterface.SendPurchaseOrderRequest(TRUE); //pcpl-065
                end;
            }
            action(SendInvoices)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                //EAMInterface: Codeunit EAM Interface; //50004 //pcpl-065
                begin
                    //EAMInterface.SendPurchaseInvoiceRequest //pcpl-065
                end;
            }
            action(SendInvoicePayment)
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;

                trigger OnAction()
                var
                // EAMInterface: Codeunit "EAM Interface"; //50004 //pcpl-065
                begin
                    // EAMInterface.SendPaymentRequest;
                end;
            }
            separator("--------------")
            {
                Caption = '--------------';
            }
            action("Review EAM Purchase Order")
            {
                Caption = 'Review EAM Purchase Order';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //ProcessEamProcessStagging.ReviewEAMPurchaseOrderStagging(FALSE); //pcpl-065
                    MESSAGE('Lines are Reviewd.');
                end;
            }
            action("Create Purchase Order")
            {
                Caption = 'Create Purchase Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //ProcessEamProcessStagging.CreatePurchaseOrder; //pcpl-065
                    MESSAGE('Lines are Processed.');
                end;
            }
            action("Review EAM Purchase Receipt")
            {
                Caption = 'Review EAM Purchase Receipt';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //  ProcessEamProcessStagging.ReviewEAMPurchaseReceiptStagging(FALSE); //pcpl-065
                    MESSAGE('Lines are Reviewd.');
                end;
            }
            action("Create Purchase Receipt")
            {
                Caption = 'Create Purchase Receipt';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // ProcessEamProcessStagging.CreatePurchaseReceipt; //pcpl-065
                    MESSAGE('Lines are Processed.');
                end;
            }
            action("Review EAM Supplier Return")
            {
                Caption = 'Review EAM Supplier Return';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //ProcessEamProcessStagging.ReviewEAMSupplierReturnStagging(FALSE); //pcpl-065
                    MESSAGE('Lines are Reviewd.');
                end;
            }
            action("Create Supplier Return")
            {
                Caption = 'Create Master';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // ProcessEamProcessStagging.CreatePurchaseReturnOrder; //pcpl-065
                    MESSAGE('Lines are Processed.');
                end;
            }
            action("Review EAM Purchase Invoice")
            {
                Caption = 'Review EAM Purchase Invoice';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //ProcessEamProcessStagging.ReviewEAMProcessData(FALSE); //pcpl-065
                    MESSAGE('Lines are Reviewd.');
                end;
            }
            action("Create Purchase Invoice")
            {
                Caption = 'Create Purchase Invoice';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
    }

    var
        // EAMInterface: Codeunit 50004;  //pcpl-065
        Text001: Label 'Send Data from nav to EAM';
        ProcessEamProcessStagging: Codeunit 50002;
}

