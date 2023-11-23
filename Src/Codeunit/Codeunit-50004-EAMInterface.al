// codeunit 50004 "EAM Interface"
// {
//     Permissions = TableData 25 = rm,
//                   TableData 122 = rimd;

//     trigger OnRun()
//     var
//         JobQueue: Record 470; ///pcpl-065
//     begin
//         // SendStockItemRequest;
//         // SendServiceItemRequest;
//         // SendVendorRequest;
//         // SendCurrencyExhangeRateRequest;
//         // SendPurchaseOrderRequest(FALSE);
//         // SendPurchaseInvoiceRequest;
//         JobQueue.CHANGECOMPANY('SEAMEC LIMITED');
//         IF JobQueue.GET('EAM') THEN
//             JobQueue.StopQueue;
//         FillCreateInvoicePaymentEntry;
//         //SendPaymentRequest;
//     end;

//     var
//         WebserviceRoot: Label 'http://103.61.231.180:8090/api/';
//         UserName: Label 'EAMINTERFACE';
//         Password: Label 'wut)Dj^&3](,w=M*';
//         Host: ;
//         ContentType: Label 'application/json; charset=utf-8';
//         ConnectionFailedErr: Label 'Connection failed.';
//         RequestAuthCodeTxt: Label 'Request authorization code.', Locked = true;
//         RequestAccessTokenTxt: Label 'Request access token.', Locked = true;
//         RefreshAccessTokenTxt: Label 'Refresh access token.', Locked = true;
//         InvokeRequestTxt: Label 'Invoke %1 request.', Comment = '{Locked}, %1 - request type, e.g. GET, POST';
//         RefreshSuccessfulTxt: Label 'Refresh token successful.';
//         RefreshFailedTxt: Label 'Refresh token failed.';
//         AuthorizationSuccessfulTxt: Label 'Authorization successful.';
//         AuthorizationFailedTxt: Label 'Authorization failed.';
//         ReasonTxt: Label 'Reason: ';
//         EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';
//         ActivityLogContextTxt: Label 'OAuth 2.0', Locked = true;
//         TestTokenTok: Label 'Test', Locked = true;
//         ContentTypexml: Label 'application/xml';
//         EAMServiceURL: Text;
//         GlobalPassword: Text;
//         GlobalUsername: Text;
//         XMLRootStart: Label 'xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/EAMIntegration.Models">';
//         WinHttpService: Automation;
//         StockItemTxt: Label 'StockItem';
//         ServiceItemTxt: Label 'ServiceItem';
//         VendorTxt: Label 'Vendor';
//         Dat: Text;
//         GeneralLedgerSetup: Record 98;
//         XMLRootStartForInvoice: Label 'xmlns:i="http://www.w3.org/2001/XMLSchemainstance" xmlns="http://schemas.datacontract.org/2004/07/EAMIntegration.Models">';
//         ErrorMessage: Text;
//         PurchasesPayablesSetup: Record 312;

//     [Scope('Internal')]
//     procedure SendStockItemRequest()
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::"Stock Item", EAMSetup."NAV Transaction Type"::Outbound) THEN
//            // CreateStockItemRequestStream(EAMSetup); //pcpl-065
//     end;

//     [Scope('Internal')]
//     procedure CreateStockItemRequestStream(var EAMSetup: Record 50000)
//     var
//         ResponseText: Text;
//         StringBuilder: DotNet StringBuilder;
//         RequestVar: Text;
//         Item: Record 27;
//     begin
//         StringBuilder := StringBuilder.StringBuilder();

//         StringBuilder.Append('<ArrayOfStockItemParam ');
//         StringBuilder.Append(XMLRootStart);

//         Item.SETRANGE("Replicate To EAM", TRUE);
//         Item.SETRANGE("Replicated From EAM", TRUE);
//         Item.SETRANGE(Type, Item.Type::Inventory);
//         IF Item.FINDSET THEN
//             REPEAT
//             //pcpl-065
//             /*
//                 StringBuilder.Append('<StockItemParam>');
//                 StringBuilder.Append('<Code>' + Item."No." + '</Code>');
//                 StringBuilder.Append('<Desc>' + Item.Description + '</Desc>');
//                 StringBuilder.Append('<HSNCode>' + Item."HSN/SAC Code" + '</HSNCode>');
//                 StringBuilder.Append('<Type>Stock Item</Type>');
//                 StringBuilder.Append('<UOM>' + Item."Base Unit of Measure" + '</UOM>');
//                 StringBuilder.Append('</StockItemParam>');
//                 */

//             UNTIL Item.NEXT = 0;

//         // StringBuilder.Append('</ArrayOfStockItemParam>'); //pcpl-065

//         RequestVar := StringBuilder.ToString;
//         StringBuilder.Clear;
//         IF NOT Item.ISEMPTY THEN BEGIN
//             IF SendRequestToEAM(EAMSetup, RequestVar, Item.RECORDID) = 200 THEN
//                 Item.MODIFYALL("Replicate To EAM", FALSE);
//         END;
//         MESSAGE('Lines are processed.');
//     end;

//     [Scope('Internal')]
//     procedure SendServiceItemRequest()
//     var
//         Item: Record 27;
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::"Service Item", EAMSetup."NAV Transaction Type"::Outbound) THEN;
//         CreateServiceItemRequestStream(EAMSetup);
//     end;

//     local procedure CreateServiceItemRequestStream(var EAMSetup: Record 50000)
//     var
//         Parameter: Text;
//         ResponseText: Text;
//         RequestVar: Text;
//         StringBuilder: DotNet StringBuilder;
//         Item: Record 27;
//         Status: Integer;
//     begin
//         StringBuilder := StringBuilder.StringBuilder();

//         StringBuilder.Append('<ArrayOfServiceItemParam ');
//         StringBuilder.Append(XMLRootStart);

//         Item.SETRANGE("Replicate To EAM", TRUE);
//         Item.SETRANGE("Replicated From EAM", TRUE);
//         Item.SETRANGE(Type, Item.Type::Service);
//         IF Item.FINDSET THEN
//             REPEAT
//                 StringBuilder.Append('<ServiceItemParam>');
//                 StringBuilder.Append('<Code>' + Item."No." + '</Code>');
//                 StringBuilder.Append('<Desc>' + Item.Description + '</Desc>');
//                 StringBuilder.Append('<HSNCode>' + Item."HSN/SAC Code" + '</HSNCode>');
//                 StringBuilder.Append('<UOM>' + Item."Base Unit of Measure" + '</UOM>');
//                 StringBuilder.Append('</ServiceItemParam>');
//             UNTIL Item.NEXT = 0;

//         StringBuilder.Append('</ArrayOfServiceItemParam>');

//         Parameter := ServiceItemTxt;
//         RequestVar := StringBuilder.ToString;
//         StringBuilder.Clear;
//         IF NOT Item.ISEMPTY THEN BEGIN
//             IF SendRequestToEAM(EAMSetup, RequestVar, Item.RECORDID) = 200 THEN
//                 Item.MODIFYALL("Replicate To EAM", FALSE);
//         END;
//         MESSAGE('Lines are processed.');
//     end;

//     [Scope('Internal')]
//     procedure SendVendorRequest()
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::Vendor, EAMSetup."NAV Transaction Type"::Outbound) THEN
//             CreateVendorRequestStream(EAMSetup);
//     end;

//     local procedure CreateVendorRequestStream(var EAMSetup: Record 50000)
//     var
//         Parameter: Text;
//         ResponseText: Text;
//         RequestVar: Text;
//         StringBuilder: DotNet StringBuilder;
//         Vendor: Record 23;
//         Status: Option Approved,"Not Approved";
//     begin
//         StringBuilder := StringBuilder.StringBuilder();
//         StringBuilder.Append('<ArrayOfSupplierParam ');
//         StringBuilder.Append(XMLRootStart);
//         Vendor.SETRANGE("Replicate To EAM", TRUE);
//         Vendor.SETRANGE("Replicated From EAM", TRUE);
//         IF Vendor.FINDSET THEN
//             REPEAT
//                 StringBuilder.Append('<SupplierParam>');
//                 StringBuilder.Append('<Code>' + Vendor."No." + '</Code>');
//                 IF Vendor.Blocked = Vendor.Blocked::" " THEN
//                     Status := Status::Approved
//                 ELSE
//                     Status := Status::"Not Approved";
//                 StringBuilder.Append('<Status>' + FORMAT(Status) + '</Status>');
//                 StringBuilder.Append('</SupplierParam>');

//             UNTIL Vendor.NEXT = 0;

//         StringBuilder.Append('</ArrayOfSupplierParam>');

//         Parameter := VendorTxt;
//         RequestVar := StringBuilder.ToString;
//         StringBuilder.Clear;
//         IF NOT Vendor.ISEMPTY THEN BEGIN
//             IF SendRequestToEAM(EAMSetup, RequestVar, Vendor.RECORDID) = 200 THEN
//                 Vendor.MODIFYALL("Replicate To EAM", FALSE);
//         END;
//         MESSAGE('Lines are processed.');
//     end;

//     [Scope('Internal')]
//     procedure SendCurrencyExhangeRateRequest()
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::Currency, EAMSetup."NAV Transaction Type"::Outbound) THEN
//             CreateExhangeRateRequest(EAMSetup);
//     end;

//     local procedure CreateExhangeRateRequest(var EAMSetup: Record 50000)
//     var
//         Parameter: Text;
//         ResponseText: Text;
//         RequestVar: Text;
//         StringBuilder: DotNet StringBuilder;
//         CurrencyExchangeRate: Record 330;
//         GeneralLedgerSetup: Record 98;
//         BaseCurrency: Code[20];
//         Currency: Record 4;
//     begin
//         GeneralLedgerSetup.GET;
//         StringBuilder := StringBuilder.StringBuilder();

//         CurrencyExchangeRate.SETRANGE("Replicate To EAM", TRUE);
//         IF CurrencyExchangeRate.FINDSET THEN
//             REPEAT
//                 /*//pcpl-065
//                 StringBuilder.Append('<ArrayOfCurrencyExchangeRateParam ');
//                 StringBuilder.Append(XMLRootStart);
//                 StringBuilder.Append('<CurrencyExchangeRateParam>');
//                 */
//                 IF CurrencyExchangeRate."Relational Currency Code" = '' THEN
//                     BaseCurrency := GeneralLedgerSetup."EAM LCY Code"
//                 ELSE BEGIN
//                     Currency.RESET;
//                     Currency.SETRANGE(Code, CurrencyExchangeRate."Relational Currency Code");
//                     IF Currency.FINDFIRST THEN
//                         BaseCurrency := Currency."EAM Code"
//                 END;
//                 StringBuilder.Append('<BaseCurrency>' + BaseCurrency + '</BaseCurrency>');
//                 Currency.RESET;
//                 Currency.SETRANGE(Code, CurrencyExchangeRate."Currency Code");
//                 IF Currency.FINDFIRST THEN
//                     /*
//                         StringBuilder.Append('<CurrencyCode>' + Currency."EAM Code" + '</CurrencyCode>');
//                     StringBuilder.Append('<EndDate>' + GetDate(CurrencyExchangeRate."Ending Date") + '</EndDate>');
//                     StringBuilder.Append('<ExchangeRate>' + FORMAT(ROUND(1 / CurrencyExchangeRate."Relational Exch. Rate Amount", 0.0001, '=')) + '</ExchangeRate>');
//                     StringBuilder.Append('<StartDate>' + GetDate(CurrencyExchangeRate."Starting Date") + '</StartDate>');
//                     StringBuilder.Append('</CurrencyExchangeRateParam>');
//                     StringBuilder.Append('</ArrayOfCurrencyExchangeRateParam> ');
//                     RequestVar := StringBuilder.ToString;
//                     StringBuilder.Clear;
//                     */
//                 IF SendRequestToEAM(EAMSetup, RequestVar, CurrencyExchangeRate.RECORDID) = 200 THEN BEGIN
//                         CurrencyExchangeRate."Replicate To EAM" := FALSE;
//                         CurrencyExchangeRate."Replicated To Eam" := TRUE;
//                     END;
//                 CurrencyExchangeRate."Eam Error" := ErrorMessage;
//                 CurrencyExchangeRate.MODIFY;
//             UNTIL CurrencyExchangeRate.NEXT = 0;

//         MESSAGE('Lines are processed.');
//     end;

//     [Scope('Internal')]
//     procedure SendPurchaseOrderRequest(ShowMessage: Boolean)
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::Order, EAMSetup."NAV Transaction Type"::Outbound) THEN
//             CreatePurchaseOrderRequest(EAMSetup);
//         IF ShowMessage THEN
//             MESSAGE('Lines are processed.');
//     end;

//     local procedure CreatePurchaseOrderRequest(var EAMSetup: Record 50000)
//     var
//         UserJson: Label '{''User'': {''last_name'' : ''%1'' , ''first_name'' : ''%2'' , ''email'' : ''%3'' , ''language'' : ''%4'' , ''username'' : ''%5'' , ''enabled'' : ''%6'' }}';
//         Parameter: Label '/%1';
//         WebserviceRoot: Label 'http://103.61.231.180:8090/api/Terms';
//         UserName: Label 'EAMINTERFACE';
//         Password: Label 'wut)Dj^&3](,w=M*';
//         Host: Label 'Merino.com';
//         ContentType: Label 'application/xml; charset=utf-8';
//         ResponseText: Text;
//         StringBuilder: DotNet StringBuilder;
//         RequestVar: Text;
//         PurchaseHeader: Record 38;
//         EAMPurchaseOrder: Record 50005;
//         PurchaseLine: Record 39;
//         DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";//16412;
//         Status: Text;
//         TotalGstAmount: Decimal;
//         GSTGroup: Record "GST Group";//16404;
//         Item: Record 27;
//     begin
//         StringBuilder := StringBuilder.StringBuilder();

//         PurchaseHeader.SETRANGE("Replicate To EAM", TRUE);
//         IF PurchaseHeader.FINDSET THEN
//             REPEAT
//                 /*
//                     StringBuilder.Append('<ArrayOfPurchaseOrderParam ');
//                     StringBuilder.Append(XMLRootStart);
//                     */
//                 PurchaseLine.RESET;
//                 PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
//                 PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
//                 IF PurchaseLine.FINDSET THEN
//                     REPEAT
//                         EAMPurchaseOrder.RESET;
//                         EAMPurchaseOrder.SETRANGE("Transaction Type", EAMPurchaseOrder."Transaction Type"::"Purchase Order");
//                         EAMPurchaseOrder.SETRANGE("Purchase order code", PurchaseLine."Document No.");
//                         EAMPurchaseOrder.SETRANGE(Line, PurchaseLine."Line No.");
//                         IF EAMPurchaseOrder.FINDLAST THEN;
//                         /*
//                         StringBuilder.Append('<PurchaseOrderParam>');
//                         StringBuilder.Append('<Buyer>' + EAMPurchaseOrder.Buyer + '</Buyer>');
//                         StringBuilder.Append('<Cleaning_and_Fwd_Chrg_INR>' + DELCHR(FORMAT(EAMPurchaseOrder."Cleaning & Fwd Chrg (INR)"), '=', ',') + '</Cleaning_and_Fwd_Chrg_INR>');
//                         StringBuilder.Append('<Description></Description>');
//                         StringBuilder.Append('<Exchange_Rate>' + FORMAT(EAMPurchaseOrder."Exchange Rate") + '</Exchange_Rate>');
//                         StringBuilder.Append('<Extra_Charges_Currency>' + EAMPurchaseOrder."Extra Charges Currency" + '</Extra_Charges_Currency>');
//                         StringBuilder.Append('<Freight_INR>' + DELCHR(FORMAT(EAMPurchaseOrder."Freight (INR)"), '=', ',') + '</Freight_INR>');
//                         StringBuilder.Append('<GST_Amount_INR>0</GST_Amount_INR>');
//                         //StringBuilder.Append('<GST_Amount_INR>'+DELCHR(FORMAT(PurchaseLine."Total GST Amount"),'=',',')+'</GST_Amount_INR>');
//                         StringBuilder.Append('<Line>' + FORMAT(EAMPurchaseOrder.Line) + '</Line>');
//                         StringBuilder.Append('<Miscalleaneous_Charges_INR>' + DELCHR(FORMAT(EAMPurchaseOrder."Miscalleaneous Charges (INR)"), '=', ',') + '</Miscalleaneous_Charges_INR>');
//                         StringBuilder.Append('<Originator>' + EAMPurchaseOrder.Originator + '</Originator>');
//                         StringBuilder.Append('<Payment_Terms>' + PurchaseHeader."Payment Terms Code" + '</Payment_Terms>');
//                         StringBuilder.Append('<Price_UOP>' + DELCHR(FORMAT(EAMPurchaseOrder."Price (UOP)"), '=', ',') + '</Price_UOP>');
//                         StringBuilder.Append('<Project_code>' + FORMAT(EAMPurchaseOrder."Project code") + '</Project_code>');
//                         StringBuilder.Append('<Purchase_Quantity_UOP>' + DELCHR(FORMAT(PurchaseLine.Quantity), '=', ',') + '</Purchase_Quantity_UOP>');
//                         StringBuilder.Append('<Purchase_order_code>' + EAMPurchaseOrder."Purchase order code" + '</Purchase_order_code>');
//                         *///pcpl-065
//                         IF PurchaseHeader.Status = PurchaseHeader.Status::Released THEN
//                             Status := 'AR'
//                         ELSE
//                             Status := 'C';
//                         //  StringBuilder.Append('<Status>' + Status + '</Status>'); //pcpl-065
//                         GSTGroup.RESET;
//                         GSTGroup.SETRANGE(Code, PurchaseLine."GST Group Code");
//                         IF GSTGroup.FINDFIRST THEN
//                             StringBuilder.Append('<Tax_Code>' + GSTGroup."EAM Code" + '</Tax_Code>')
//                         ELSE
//                             StringBuilder.Append('<Tax_Code></Tax_Code>');
//                         IF EAMPurchaseOrder."Total Extra" = '' THEN
//                             StringBuilder.Append('<Total_Extra>0</Total_Extra>')
//                         ELSE
//                             StringBuilder.Append('<Total_Extra>' + EAMPurchaseOrder."Total Extra" + '</Total_Extra>');
//                         IF EAMPurchaseOrder."Total Extra Charge" = 0 THEN
//                             StringBuilder.Append('<Total_Extra_Charge>0</Total_Extra_Charge>')
//                         ELSE
//                             StringBuilder.Append('<Total_Extra_Charge>' + DELCHR(FORMAT(EAMPurchaseOrder."Total Extra Charge"), '=', ',') + '</Total_Extra_Charge>');
//                         IF PurchaseLine."Total GST Amount" = 0 THEN
//                             TotalGstAmount := 0
//                         ELSE
//                             TotalGstAmount := PurchaseLine."Total GST Amount";
//                         StringBuilder.Append('<Total_Tax_Amount>' + DELCHR(FORMAT(PurchaseLine."Total GST Amount"), '=', ',') + '</Total_Tax_Amount>');
//                         StringBuilder.Append('</PurchaseOrderParam>');
//                     UNTIL PurchaseLine.NEXT = 0;
//                 StringBuilder.Append('</ArrayOfPurchaseOrderParam>');
//                 RequestVar := StringBuilder.ToString;
//                 StringBuilder.Clear;
//                 IF SendRequestToEAM(EAMSetup, RequestVar, PurchaseHeader.RECORDID) = 200 THEN BEGIN
//                     PurchaseHeader."Replicate To EAM" := FALSE;
//                     PurchaseHeader.MODIFY;
//                 END;
//             UNTIL PurchaseHeader.NEXT = 0;
//     end;

//     [Scope('Internal')]
//     procedure SendPurchaseInvoiceRequest()
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         GeneralLedgerSetup.GET;
//         IF EAMSetup.GET(EAMSetup."Source Type"::Invoice, EAMSetup."NAV Transaction Type"::Outbound) THEN
//             CreatePurchaseInvoiceRequest(EAMSetup);
//     end;

//     local procedure CreatePurchaseInvoiceRequest(var EAMSetup: Record 50000)
//     var
//         UserJson: Label '{''User'': {''last_name'' : ''%1'' , ''first_name'' : ''%2'' , ''email'' : ''%3'' , ''language'' : ''%4'' , ''username'' : ''%5'' , ''enabled'' : ''%6'' }}';
//         Parameter: Label '/%1';
//         WebserviceRoot: Label 'http://103.61.231.180:8090/api/Terms';
//         UserName: Label 'EAMINTERFACE';
//         Password: Label 'wut)Dj^&3](,w=M*';
//         Host: Label 'Merino.com';
//         ContentType: Label 'application/xml; charset=utf-8';
//         ResponseText: Text;
//         StringBuilder: DotNet StringBuilder;
//         RequestVar: Text;
//         Status: Text;
//         TotalGstAmount: Decimal;
//         PurchInvLine: Record 123;
//         PurchInvHeader: Record 122;
//         Vendor: Record 23;
//         Currency: Record 4;
//         PurchRcptLine: Record 121;
//         GSTGroup: Record "GST Group";//16404;
//         PurchaseLine: Record 39;
//     begin
//         StringBuilder := StringBuilder.StringBuilder();

//         PurchInvHeader.RESET;
//         PurchInvHeader.SETRANGE("Replicated to EAM", FALSE);
//         PurchInvHeader.SETRANGE("Replicate from EAM", TRUE);
//         IF PurchInvHeader.FINDSET THEN
//             REPEAT
//                 StringBuilder.Append('<ArrayOfPurchaseInvoiceParam ');
//                 StringBuilder.Append(XMLRootStartForInvoice);
//                 PurchInvLine.RESET;
//                 PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
//                 PurchInvLine.SETFILTER(Type, '<>%1', PurchInvLine.Type::" ");
//                 IF PurchInvLine.FINDSET THEN
//                     REPEAT

//                         PurchInvHeader.CALCFIELDS(Amount);
//                         StringBuilder.Append('<PurchaseInvoiceParam>');
//                         StringBuilder.Append('<Amount>' + DELCHR(FORMAT(PurchInvHeader.Amount), '=', ',') + '</Amount>');
//                         IF Vendor.GET(PurchInvHeader."Buy-from Vendor No.") THEN
//                             StringBuilder.Append('<Buy_From_Vendor_No>' + Vendor."EAM Code" + '</Buy_From_Vendor_No>');
//                         IF PurchInvHeader."Currency Code" = '' THEN
//                             StringBuilder.Append('<Currency_Code>' + GeneralLedgerSetup."EAM LCY Code" + '</Currency_Code>')
//                         ELSE BEGIN
//                             IF Currency.GET(PurchInvHeader."Currency Code") THEN
//                                 StringBuilder.Append('<Currency_Code>' + Currency."EAM Code" + '</Currency_Code>');
//                         END;
//                         IF PurchInvHeader."Currency Factor" = 0 THEN
//                             StringBuilder.Append('<Currency_Factor>1</Currency_Factor>')
//                         ELSE
//                             StringBuilder.Append('<Currency_Factor>' + FORMAT(PurchInvHeader."Currency Factor") + '</Currency_Factor>');
//                         StringBuilder.Append('<Direct_Unit_Cost>' + DELCHR(FORMAT(PurchInvLine."Direct Unit Cost"), '=', ',') + '</Direct_Unit_Cost>');
//                         StringBuilder.Append('<Discount>' + DELCHR(FORMAT(PurchInvLine."Line Discount Amount"), '=', ',') + '</Discount>');
//                         StringBuilder.Append('<Document_No>' + PurchInvHeader."No." + '</Document_No>');
//                         StringBuilder.Append('<Line_No>' + FORMAT(PurchInvLine."Line No.") + '</Line_No>');
//                         StringBuilder.Append('<Posting_Date>' + GetDate(PurchInvHeader."Posting Date") + '</Posting_Date>');
//                         IF PurchInvLine."Receipt No." <> '' THEN BEGIN
//                             IF PurchRcptLine.GET(PurchInvLine."Receipt No.", PurchInvLine."Receipt Line No.") THEN BEGIN
//                                 StringBuilder.Append('<Purchase_Order>' + PurchInvHeader."Order No." + '</Purchase_Order>');
//                                 StringBuilder.Append('<Purchase_Order_Line>' + FORMAT(PurchRcptLine."Order Line No.") + '</Purchase_Order_Line>');
//                             END;
//                         END ELSE BEGIN
//                             StringBuilder.Append('<Purchase_Order>' + PurchInvHeader."Order No." + '</Purchase_Order>');
//                             StringBuilder.Append('<Purchase_Order_Line>' + FORMAT(PurchInvLine."Purchase Line No.") + '</Purchase_Order_Line>');
//                         END;

//                         StringBuilder.Append('<Quantity>' + DELCHR(FORMAT(PurchInvLine.Quantity), '=', ',') + '</Quantity>');
//                         GSTGroup.RESET;
//                         GSTGroup.SETRANGE(Code, PurchInvLine."GST Group Code");
//                         IF GSTGroup.FINDFIRST THEN
//                             StringBuilder.Append('<TaxCode1>' + GSTGroup."EAM Code" + '</TaxCode1>')
//                         ELSE
//                             StringBuilder.Append('<TaxCode1></TaxCode1>');
//                         StringBuilder.Append('<Taxcode2></Taxcode2>');
//                         StringBuilder.Append('<Total_Extra>0</Total_Extra>');
//                         PurchaseLine.RESET;
//                         PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
//                         PurchaseLine.SETRANGE("Document No.", PurchInvHeader."Order No.");
//                         IF PurchaseLine.FINDSET THEN;
//                         StringBuilder.Append('<Total_Number_of_lines>' + FORMAT(PurchaseLine.COUNT) + '</Total_Number_of_lines>');
//                         StringBuilder.Append('<Total_Tax_Amount>' + DELCHR(FORMAT(PurchInvLine."Total GST Amount"), '=', ',') + '</Total_Tax_Amount>');
//                         StringBuilder.Append('<Vendor_Invoice_No>' + PurchInvHeader."Vendor Invoice No." + '</Vendor_Invoice_No>');

//                         StringBuilder.Append('</PurchaseInvoiceParam>');
//                     UNTIL PurchInvLine.NEXT = 0;
//                 StringBuilder.Append('</ArrayOfPurchaseInvoiceParam>');
//                 RequestVar := StringBuilder.ToString;
//                 StringBuilder.Clear;
//                 IF SendRequestToEAM(EAMSetup, RequestVar, PurchInvHeader.RECORDID) = 200 THEN BEGIN
//                     PurchInvHeader."Replicated to EAM" := TRUE;
//                     PurchInvHeader.MODIFY;
//                 END;
//             UNTIL PurchInvHeader.NEXT = 0;
//         MESSAGE('Lines are processed.');
//     end;

//     [Scope('Internal')]
//     procedure SendPaymentRequest()
//     var
//         EAMSetup: Record 50000;
//     begin
//         PurchasesPayablesSetup.GET;
//         IF NOT PurchasesPayablesSetup."Enable For Masters" THEN
//             EXIT;
//         IF EAMSetup.GET(EAMSetup."Source Type"::Payment, EAMSetup."NAV Transaction Type"::Outbound) THEN
//             CreatePaymentRequest(EAMSetup);
//     end;

//     local procedure CreatePaymentRequest(var EAMSetup: Record 50000)
//     var
//         UserJson: Label '{''User'': {''last_name'' : ''%1'' , ''first_name'' : ''%2'' , ''email'' : ''%3'' , ''language'' : ''%4'' , ''username'' : ''%5'' , ''enabled'' : ''%6'' }}';
//         Parameter: Label '/%1';
//         WebserviceRoot: Label 'http://103.61.231.180:8090/api/Terms';
//         UserName: Label 'EAMINTERFACE';
//         Password: Label 'wut)Dj^&3](,w=M*';
//         Host: Label 'Merino.com';
//         ContentType: Label 'application/xml; charset=utf-8';
//         ResponseText: Text;
//         StringBuilder: DotNet StringBuilder;
//         RequestVar: Text;
//         DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";//16412; 
//         Status: Text;
//         PurchInvHeader: Record 122;
//         VendorLedgerEntry: Record 25;
//         DetailedVendorLedgEntry: Record 380;
//         AppliedVendorLedgerEntry: Record 25;
//     // PaymentLedgerEntry: Record 50007; //pcpl-065
//     begin
//         FillCreateInvoicePaymentEntry;
//         StringBuilder := StringBuilder.StringBuilder();
//         PaymentLedgerEntry.RESET;
//         PaymentLedgerEntry.SETRANGE("Replicate in EAM", TRUE);
//         PaymentLedgerEntry.SETRANGE("Replicated in EAM", FALSE);
//         IF PaymentLedgerEntry.FINDFIRST THEN
//             REPEAT
//                 StringBuilder.Append('<ArrayOfInvoicePaymentParam ');
//                 StringBuilder.Append(XMLRootStart);
//                 StringBuilder.Append('<InvoicePaymentParam>');
//                 StringBuilder.Append('<Amount>' + DELCHR(FORMAT(PaymentLedgerEntry."Applied Amount (LCY)"), '=', ',') + '</Amount>');
//                 StringBuilder.Append('<Document_No>' + PaymentLedgerEntry."Purchase Order No" + '</Document_No>');
//                 StringBuilder.Append('<Invoice_No>' + PaymentLedgerEntry."Invoice Document No." + '</Invoice_No>');
//                 StringBuilder.Append('<Posting_Date>' + GetDate(PaymentLedgerEntry."Payment Posting Date") + '</Posting_Date>');
//                 StringBuilder.Append('<Remarks></Remarks>');
//                 StringBuilder.Append('</InvoicePaymentParam>');
//                 StringBuilder.Append('</ArrayOfInvoicePaymentParam>');
//                 RequestVar := StringBuilder.ToString;
//                 StringBuilder.Clear;
//                 IF SendRequestToEAM(EAMSetup, RequestVar, PaymentLedgerEntry.RECORDID) = 200 THEN BEGIN
//                     PaymentLedgerEntry."Replicated in EAM" := TRUE;
//                     PaymentLedgerEntry.MODIFY;
//                 END;
//             UNTIL PaymentLedgerEntry.NEXT = 0;
//         MESSAGE('Lines are processed.');
//     end;

//     local procedure SendRequestToEAM(var EAMSetup: Record 50000; RequestBody: Text; RecordID: RecordID): Integer
//     var
//         HttpWebRequest: DotNet HttpWebRequest;
//         HttpWebResponse: DotNet HttpWebResponse;
//         StreamWriter: DotNet StreamWriter;
//         Stream: DotNet Stream;
//         Encoding: DotNet Encoding;
//         Certificate: DotNet X509Certificate2;
//         ResponseText: Text;
//         StatusCode: Integer;
//         StatusText: Text;
//         StatusCodePisition: Integer;
//     begin
//         EAMServiceURL := EAMSetup."Service URL";
//         IF ISCLEAR(WinHttpService) THEN
//             CREATE(WinHttpService, FALSE, TRUE);
//         WinHttpService.Open('POST', EAMServiceURL);
//         WinHttpService.SetRequestHeader('Content-Type', ContentTypexml);
//         WinHttpService.SetRequestHeader('Authorization', EAMSetup."Authentication Text");

//         WinHttpService.Send(RequestBody);
//         ResponseText := WinHttpService.ResponseText();
//         //MESSAGE('%1',RequestBody);  //////////////
//         //MESSAGE('%1',StatusCode);  //////////////
//         // MESSAGE('%1',WinHttpService.ResponseText);  //////////////
//         StatusText := WinHttpService.StatusText;
//         StatusCodePisition := STRPOS(WinHttpService.ResponseText, '<ResponseCode>');
//         IF NOT EVALUATE(StatusCode, COPYSTR(WinHttpService.ResponseText, StatusCodePisition + 14, 3)) THEN
//             StatusCode := 500;
//         FindCurrencyError(WinHttpService.ResponseText);

//         CreateOutboundSyncLogEntry(EAMServiceURL, StatusCode, StatusText, RequestBody, WinHttpService.ResponseText, RecordID);

//         EXIT(StatusCode);
//     end;

//     local procedure CreateOutboundSyncLogEntry(var DesignationAddress: Text; var StatusCode: Integer; var "Error Description": Text; RequestPayload: Text; ResponseText: Text; var RecordID: RecordID)
//     var
//         // OutboundSyncLogEntry: Record 50008; //pcpl-065
//         RequestPayloadStream: OutStream;
//         ResponseStream: OutStream;
//     begin
//         OutboundSyncLogEntry.INIT;
//         OutboundSyncLogEntry."Destination Address" := DesignationAddress;
//         OutboundSyncLogEntry."Error Code" := StatusCode;
//         OutboundSyncLogEntry."Error Description" := "Error Description";
//         OutboundSyncLogEntry."Message Payload".CREATEOUTSTREAM(RequestPayloadStream);
//         RequestPayloadStream.WRITE(RequestPayload);
//         OutboundSyncLogEntry."Response Payload".CREATEOUTSTREAM(ResponseStream);
//         ResponseStream.WRITE(ResponseText);
//         OutboundSyncLogEntry."Creation Date Time" := CURRENTDATETIME;
//         OutboundSyncLogEntry."Table ID" := RecordID.TABLENO;
//         OutboundSyncLogEntry."Record ID" := RecordID;
//         SetProcessStatus(OutboundSyncLogEntry, StatusCode);
//         IF StatusCode = 200 THEN
//             OutboundSyncLogEntry.Acknowledgement := OutboundSyncLogEntry.Acknowledgement::Completed;
//         OutboundSyncLogEntry."Response Message" := ErrorMessage;
//         OutboundSyncLogEntry.INSERT;
//     end;

//     local procedure SetProcessStatus(var OutboundSyncLogEntry: Record 50008; var StatusCode: Integer)
//     begin
//         CASE StatusCode OF
//             200:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::Success;
//             201:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::Created;
//             400:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Bad Request";
//             401:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::Unauthorized;
//             403:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::Forbidden;
//             404:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Not Found";
//             405:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Method Not Allowed";
//             409:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::Conflict;
//             411:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Length Required";
//             412:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Precondition Failed";
//             429:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Too Many Requests";
//             500:
//                 OutboundSyncLogEntry."Process Status" := OutboundSyncLogEntry."Process Status"::"Internal Server Error";
//         END
//     end;

//     local procedure GetDate(var Date: Date): Text
//     var
//         DateText: Text;
//         DayText: Text;
//         MonthText: Text;
//         YearText: Text;
//         Month: Integer;
//     begin
//         //Date formate 17-DEC-2020
//         IF Date = 0D THEN
//             EXIT('');
//         DayText := FORMAT(DATE2DMY(Date, 1));
//         IF STRLEN(DayText) = 1 THEN
//             DayText := '0' + DayText;
//         Month := DATE2DMY(Date, 2);
//         IF STRLEN(MonthText) = 1 THEN
//             MonthText := '0' + MonthText;
//         YearText := FORMAT(DATE2DMY(Date, 3));
//         CASE Month OF
//             1:
//                 MonthText := 'JAN';
//             2:
//                 MonthText := 'FEB';
//             3:
//                 MonthText := 'MAR';
//             4:
//                 MonthText := 'APR';
//             5:
//                 MonthText := 'MAY';
//             6:
//                 MonthText := 'JUN';
//             7:
//                 MonthText := 'JUL';
//             8:
//                 MonthText := 'AUG';
//             9:
//                 MonthText := 'SEP';
//             10:
//                 MonthText := 'OCT';
//             11:
//                 MonthText := 'NOV';
//             12:
//                 MonthText := 'DEC';
//         END;
//         DateText := DayText + '-' + MonthText + '-' + YearText;
//         EXIT(DateText);
//     end;

//     local procedure FindCurrencyError(Response: Text): Text
//     var
//         MsgStartPos: Integer;
//         MsgEndPos: Integer;
//     begin
//         CLEAR(ErrorMessage);
//         MsgStartPos := STRPOS(Response, 'ata>');
//         IF MsgStartPos <> 0 THEN BEGIN
//             MsgStartPos += 4;
//             MsgEndPos := STRPOS(Response, '</Data>')
//         END ELSE BEGIN
//             MsgStartPos := STRPOS(Response, '<Message>Error :') + 17;
//             MsgEndPos := STRPOS(Response, '</Message>');
//         END;
//         IF MsgEndPos > MsgStartPos THEN BEGIN
//             ErrorMessage := COPYSTR(Response, MsgStartPos, MsgEndPos - MsgStartPos);
//             ErrorMessage := COPYSTR(ErrorMessage, 1, 250);
//         END ELSE
//             ErrorMessage := 'Bad Request';
//         EXIT(ErrorMessage);
//     end;

//     local procedure FillCreateInvoicePaymentEntry()
//     var
//         VendorLedgerEntry: Record 25;
//         AppliedVendLedgEntry: Record 25 temporary;
//     begin
//         VendorLedgerEntry.RESET;
//         VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
//         VendorLedgerEntry.SETRANGE(Open, FALSE);
//         VendorLedgerEntry.SETRANGE("Replicated in PLE", FALSE);
//         IF VendorLedgerEntry.FINDFIRST THEN
//             REPEAT
//                 AppliedVendLedgEntry.DELETEALL;
//                 GetAppliedVendEntries(AppliedVendLedgEntry, VendorLedgerEntry, TRUE);
//                 IF AppliedVendLedgEntry.FINDFIRST THEN
//                     REPEAT
//                         FillEntryInPaymentLedgerEntry(AppliedVendLedgEntry, VendorLedgerEntry);
//                     UNTIL AppliedVendLedgEntry.NEXT = 0;
//                 VendorLedgerEntry."Replicated in PLE" := TRUE;
//                 VendorLedgerEntry.MODIFY;
//             UNTIL VendorLedgerEntry.NEXT = 0;
//     end;

//     [Scope('Internal')]
//     procedure GetAppliedVendEntries(var AppliedVendLedgEntry: Record 25 temporary; VendLedgEntry: Record 25; UseLCY: Boolean)
//     var
//         DtldVendLedgEntry: Record 380;
//         PmtDtldVendLedgEntry: Record 380;
//         PmtVendLedgEntry: Record 5;
//         ClosingVendLedgEntry: Record 25;
//         AmountToApply: Decimal;
//         PaymentDiscount: Decimal;
//     begin
//         AppliedVendLedgEntry.RESET;
//         AppliedVendLedgEntry.DELETEALL;

//         DtldVendLedgEntry.SETCURRENTKEY("Vendor Ledger Entry No.");
//         DtldVendLedgEntry.SETRANGE("Vendor Ledger Entry No.", VendLedgEntry."Entry No.");
//         DtldVendLedgEntry.SETRANGE("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
//         DtldVendLedgEntry.SETRANGE(Unapplied, FALSE);
//         IF DtldVendLedgEntry.FIND('-') THEN
//             REPEAT
//                 PmtDtldVendLedgEntry.SETFILTER("Vendor Ledger Entry No.", '<>%1', VendLedgEntry."Entry No.");
//                 PmtDtldVendLedgEntry.SETRANGE("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
//                 PmtDtldVendLedgEntry.SETRANGE("Transaction No.", DtldVendLedgEntry."Transaction No.");
//                 PmtDtldVendLedgEntry.SETRANGE("Application No.", DtldVendLedgEntry."Application No.");
//                 PmtDtldVendLedgEntry.FINDSET;
//                 REPEAT
//                     PaymentDiscount := 0;
//                     IF PmtDtldVendLedgEntry."Posting Date" <= PmtDtldVendLedgEntry."Initial Entry Due Date" THEN
//                         PaymentDiscount := PmtDtldVendLedgEntry."Remaining Pmt. Disc. Possible";
//                     IF UseLCY THEN
//                         AmountToApply := -PmtDtldVendLedgEntry."Amount (LCY)" - PaymentDiscount
//                     ELSE
//                         AmountToApply := -PmtDtldVendLedgEntry.Amount - PaymentDiscount;
//                     PmtVendLedgEntry.GET(PmtDtldVendLedgEntry."Vendor Ledger Entry No.");
//                     AppliedVendLedgEntry := PmtVendLedgEntry;
//                     IF AppliedVendLedgEntry.FIND THEN BEGIN
//                         AppliedVendLedgEntry."Amount to Apply" += AmountToApply;
//                         AppliedVendLedgEntry.MODIFY;
//                     END ELSE BEGIN
//                         AppliedVendLedgEntry := PmtVendLedgEntry;
//                         AppliedVendLedgEntry."Amount to Apply" := AmountToApply;
//                         IF VendLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
//                             ClosingVendLedgEntry.GET(PmtDtldVendLedgEntry."Vendor Ledger Entry No.");
//                             IF ClosingVendLedgEntry."Closed by Entry No." <> AppliedVendLedgEntry."Entry No." THEN
//                                 AppliedVendLedgEntry."Pmt. Disc. Rcd.(LCY)" := 0;
//                         END;
//                         AppliedVendLedgEntry.INSERT;
//                     END;
//                 UNTIL PmtDtldVendLedgEntry.NEXT = 0;
//             UNTIL DtldVendLedgEntry.NEXT = 0;
//     end;

//     local procedure FillEntryInPaymentLedgerEntry(AppliedVendLedgEntry: Record 25 temporary; VendorLedgerEntry: Record 25)
//     var
//         // PaymentLedgerEntry: Record 50007; //pcpl-065
//         PurchInvHeader: Record 122;
//     begin
//         PaymentLedgerEntry.RESET;
//         PaymentLedgerEntry.SETRANGE("Applied VLE Entry No.", AppliedVendLedgEntry."Entry No.");
//         PaymentLedgerEntry.SETRANGE("VLE Entry No.", VendorLedgerEntry."Entry No.");
//         IF PaymentLedgerEntry.FINDFIRST THEN
//             EXIT;
//         PaymentLedgerEntry.INIT;
//         PaymentLedgerEntry."Applied VLE Entry No." := AppliedVendLedgEntry."Entry No.";
//         PaymentLedgerEntry."Vendor No." := VendorLedgerEntry."Vendor No.";
//         PaymentLedgerEntry."Payment Posting Date" := VendorLedgerEntry."Posting Date";
//         PaymentLedgerEntry."Payment Document No." := VendorLedgerEntry."Document No.";
//         PaymentLedgerEntry."Invoice Document No." := AppliedVendLedgEntry."Document No.";
//         PaymentLedgerEntry."Invoice Posting Date" := AppliedVendLedgEntry."Posting Date";
//         AppliedVendLedgEntry.CALCFIELDS(Amount);
//         PaymentLedgerEntry."Invoice Amount" := AppliedVendLedgEntry.Amount;
//         PaymentLedgerEntry."Currency Code" := AppliedVendLedgEntry."Currency Code";
//         PaymentLedgerEntry."Applied Amount (LCY)" := AppliedVendLedgEntry."Closed by Amount";
//         PaymentLedgerEntry."External Document No." := AppliedVendLedgEntry."External Document No.";
//         IF PurchInvHeader.GET(AppliedVendLedgEntry."Document No.") THEN BEGIN
//             IF PurchInvHeader."Replicate from EAM" = TRUE THEN
//                 PaymentLedgerEntry."Replicate in EAM" := TRUE;
//             PaymentLedgerEntry."Purchase Order No" := PurchInvHeader."Order No.";
//         END;
//         PaymentLedgerEntry."VLE Entry No." := VendorLedgerEntry."Entry No.";
//         PaymentLedgerEntry.INSERT;
//     end;
// }

