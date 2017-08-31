trigger SalesOrderTrigger on SalesOrder__c (after update) {

    SalesOrderTriggerHandler handler = new SalesOrderTriggerHandler();

    if( Trigger.isAfter ){
        // Execute on After Update
        if( Trigger.isUpdate ){
            handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }

}