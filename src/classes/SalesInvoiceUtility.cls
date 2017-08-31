/*----------------------------------------------------------------------
Name: 		SalesInvoiceUtility.cls
Purpose: 	A utility class of "SalesInvoice__c" object
------------------------------History----------------------------------
Version 	Author 		Date 				Detail Description 
-------		-------		-------------- 		------------------
1.0 		Abrar 		30-August-2017		Initial Development	
----------------------------------------------------------------------*/
public with sharing class SalesInvoiceUtility{

	// List type Custom Setting "SalesOrderToInvoiceFieldMapping__c" contains field mapping from Source to Target object fields
    @TestVisible private static Map<String, SalesOrderToInvoiceFieldMapping__c> salesOrderToInvoiceFieldMapping = SalesOrderToInvoiceFieldMapping__c.getAll();
	// Field Mapping from Account To SalesInvoice__c
	@TestVisible private static Map<String,String> fieldMappingFromAccountToSalesInvoice = buildFieldMapping(ApplicationConstant.OBJECT_TYPE_ACCOUNT, ApplicationConstant.OBJECT_TYPE_SALES_INVOICE, false);
	// Field Mapping from SalesOrder__c To SalesInvoice__c
	@TestVisible private static Map<String,String> fieldMappingFromSalesOrderToSalesInvoice = buildFieldMapping(ApplicationConstant.OBJECT_TYPE_SALES_ORDER, ApplicationConstant.OBJECT_TYPE_SALES_INVOICE, false);
	// Field Mapping for Default Value fields of SalesInvoice__c
	@TestVisible private static Map<String,String> fieldMappingSalesInvoiceDefaultValues = buildFieldMapping('', ApplicationConstant.OBJECT_TYPE_SALES_INVOICE, true);

	/*----------------------------------------------------------------------
	Purpose: 	Declarative field mapping approach to create records dynamically
				(1) Don't need to add field mapping in the code which would be difficult to change in the future for Administrators.
				(2) This method creates record(s) in SalesInvoice__c object using a field mapping stored in a List type Custom Setting "SalesOrderToInvoiceFieldMapping__c"
				(3) Populate SalesInvoice__c fields from different sources (Account, SalesOrder__c and Default Values)
	Parameters: Trigger Context, List of SalesOrder__c
	Returns:	None
	------------------------------History----------------------------------
	Version 	Author 		Date 				Detail Description 
	-------		-------		-------------- 		------------------
	1.0 		Abrar 		30-August-2017		Initial Development
	----------------------------------------------------------------------*/
	public static void createSalesInvoice(ApplicationConstant.TRIGGER_CONTEXT triggerContext, List<SalesOrder__c> lstSalesOrders, Map<Id, SalesOrder__c> mapSalesOrders){
		if( lstSalesOrders.size() > 0 ){
            String errorLogDescription = '';
			Set<Id> setCustomerIds = new Set<Id>();
			List<SalesInvoice__c> lstSalesInvoicesToInsert = new List<SalesInvoice__c>();
			Map<Id, String> mapSalesOrderIdANDErrors = new Map<Id, String>();
			Map<Id, Account> mapAccounts = new Map<Id, Account>();

			// Process SalesOrder__c records
			for(SalesOrder__c salesOrder : lstSalesOrders){
				if(triggerContext == ApplicationConstant.TRIGGER_CONTEXT.AFTER_UPDATE){
					if( 
						salesOrder.Status__c <> mapSalesOrders.get(salesOrder.Id).Status__c &&
						salesOrder.Status__c == ApplicationConstant.SALES_ORDER_STATUS_APPROVED &&
						mapSalesOrders.get(salesOrder.Id).Status__c <> ApplicationConstant.SALES_ORDER_STATUS_APPROVED 
					){
						// Get the Customer Ids to get additional fields from Account object
						if(salesOrder.Customer__c <> null){
							setCustomerIds.add(salesOrder.Customer__c);
						}
					}
				}
			}

			// Query Account by Account Ids to get the requried fields for field mapping 
			if(setCustomerIds.size() > 0){
				mapAccounts = new Map<Id, Account>( getAccounts(setCustomerIds) );
			}

			// Process SalesOrder__c records
			for(SalesOrder__c salesOrder : lstSalesOrders){
				if(triggerContext == ApplicationConstant.TRIGGER_CONTEXT.AFTER_UPDATE){
					if( 
						salesOrder.Status__c <> mapSalesOrders.get(salesOrder.Id).Status__c &&
						salesOrder.Status__c == ApplicationConstant.SALES_ORDER_STATUS_APPROVED &&
						mapSalesOrders.get(salesOrder.Id).Status__c <> ApplicationConstant.SALES_ORDER_STATUS_APPROVED 
					){
						Account customer = new Account();
						SalesInvoice__c salesInvoice = new SalesInvoice__c();

						// Get the Account/Customer record
						if(mapAccounts.containsKey(salesOrder.Customer__c)){
							customer = mapAccounts.get(salesOrder.Customer__c);
						}

						// Field Mapping from Account To SalesInvoice__c
						// SalesInvoice__c fields after data mapping : {ShippingStreet__c=One Market St Suite 300, ShippingCountry__c=USA, ShippingCity__c=San Francisco, ShippingPostalCode__c=94105}
						for (String field : fieldMappingFromAccountToSalesInvoice.keySet()){
							salesInvoice.put(fieldMappingFromAccountToSalesInvoice.get(field), customer.get(field));
						}

						// Field Mapping from SalesOrder__c To SalesInvoice__c
						// SalesInvoice__c fields after data mapping :{Customer__c=001B000000WD7I0IAL, Amount__c=50.00, Quantity__c=50}
						for (String field : fieldMappingFromSalesOrderToSalesInvoice.keySet()){
							salesInvoice.put(fieldMappingFromSalesOrderToSalesInvoice.get(field), salesOrder.get(field));
						}

						// Field Mapping for Default Value fields of SalesInvoice__c
						// SalesInvoice__c Default Value fields after data mapping :{Status__c=Ready to Send}
						for (String field : fieldMappingSalesInvoiceDefaultValues.keySet()){
							salesInvoice.put(field, fieldMappingSalesInvoiceDefaultValues.get(field));
						}

						// All SalesInvoice__c fields populated with data from different objects and with Default Values
						// {ShippingStreet__c=One Market St Suite 300, ShippingCountry__c=USA, ShippingCity__c=San Francisco, ShippingPostalCode__c=94105, Customer__c=001B000000WD7I0IAL, Amount__c=50.00, Quantity__c=50, Status__c=Ready to Send}
						
						lstSalesInvoicesToInsert.add(salesInvoice);
					}
				}
			}

			if(lstSalesInvoicesToInsert.size() > 0){
				Database.SaveResult[] lstUpdatedSalesInvoices = Database.insert(lstSalesInvoicesToInsert, false);                    
			}
		}
	}

	/*----------------------------------------------------------------------
	Purpose: 	Build a dynamic query of Account using field mapping of a List type Custom Setting "SalesOrderToInvoiceFieldMapping__c"
	Parameters: None
	Returns:	None
	------------------------------History----------------------------------
	Version 	Author 		Date 				Detail Description 
	-------		-------		-------------- 		------------------
	1.0 		Abrar 		30-August-2017		Initial Development
	----------------------------------------------------------------------*/
    @TestVisible
    private static List<Account> getAccounts(Set<Id> setAccountIds){
		List<Account> lstAccounts = new List<Account>();
    	if(setAccountIds.size() > 0){
	        String soql = '';
				soql = 'SELECT ';
				soql += buildQueryFields( fieldMappingFromAccountToSalesInvoice.keySet() );
	            soql += ', Id FROM Account WHERE Id IN :setAccountIds';
            lstAccounts = Database.query(soql);
    	}
    	return lstAccounts;
    }

	/*----------------------------------------------------------------------
	Purpose: 	Build different maps of sources (Account, SalesOrder__c and Default Values)
				using a List type Custom Setting "SalesOrderToInvoiceFieldMapping__c"
	Parameters: None
	Returns:	None
	------------------------------History----------------------------------
	Version 	Author 		Date 				Detail Description 
	-------		-------		-------------- 		------------------
	1.0 		Abrar 		30-August-2017		Initial Development
	----------------------------------------------------------------------*/
    @TestVisible 
    private static Map<String,String> buildFieldMapping(String fromObject, String toObject, Boolean isDefaultValue){
    	// From Field >> To Field
        Map<String,String> fieldMap = new Map<String,String>();
        for (SalesOrderToInvoiceFieldMapping__c field : salesOrderToInvoiceFieldMapping.values()){
            // Build a field map where From field and To field both are present and there is no Default Value
            if ( field.FromObject__c == fromObject && field.ToObject__c == toObject && String.isBlank(field.DefaultToFieldValue__c) ){
				fieldMap.put(field.FromField__c, field.ToField__c);
            }
            // Build a field map where From field does not exist because there is a Default Value of To Field
            else if( isDefaultValue && field.ToObject__c == toObject && String.isNotBlank(field.DefaultToFieldValue__c) ){
				fieldMap.put(field.ToField__c, field.DefaultToFieldValue__c);
            }
        }
        return fieldMap;
    }

	/*----------------------------------------------------------------------
	Purpose: 	Build a string of fields using a set of fields
	Parameters: None
	Returns:	None
	------------------------------History----------------------------------
	Version 	Author 		Date 				Detail Description 
	-------		-------		-------------- 		------------------
	1.0 		Abrar 		30-August-2017		Initial Development
	----------------------------------------------------------------------*/
    @TestVisible 
    private static String buildQueryFields(Set<String> fields) {
        String columns = '';
        for (String curr : fields) {
            columns += ',' + curr;
        }
        columns = columns.replaceFirst(',','');
        return columns;
    }

}