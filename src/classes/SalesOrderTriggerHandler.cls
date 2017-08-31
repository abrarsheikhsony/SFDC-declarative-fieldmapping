/*----------------------------------------------------------------------
Name: 		SalesOrderTriggerHandler.cls
Purpose: 	Trigger Handler of SalesOrder__c object
------------------------------History----------------------------------
Version 	Author 		Date 				Detail Description 
-------		-------		-------------- 		------------------
1.0 		Abrar 		25-August-2017		Initial Development	
----------------------------------------------------------------------*/
public with sharing class SalesOrderTriggerHandler{

	// Execute on After Update
    public void OnAfterUpdate(List<SalesOrder__c> updatedSalesOrders, List<SalesOrder__c> oldSalesOrders, Map<Id, SalesOrder__c> updatedSalesOrdersMap, Map<Id, SalesOrder__c> oldSalesOrdersMap){
        // Call to Sales Invoice utility to create Sales Invoice from Sales Order
        SalesInvoiceUtility.createSalesInvoice(ApplicationConstant.TRIGGER_CONTEXT.AFTER_UPDATE, updatedSalesOrders, oldSalesOrdersMap);
    }

}