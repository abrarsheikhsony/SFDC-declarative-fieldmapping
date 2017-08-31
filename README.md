# SFDC-Declarative-FieldMapping

Sometime you get a requirement to create record(s) in "XYZ" object from "ABC" object. During this implementation you would need to have a mapping of "XYZ" object fields. Means how each field of the "XYZ" object will be populated during this creation process.

Usually this kind of functionality requires an Apex trigger on "ABC" object and that executes on particular field update. Developers write the data mapping of each field in the code. If you are a Salesforce Administrator and wants to change the data mapping you would need someone help to dig into code and make a change for you.

What if we have this data mapping option as Declarative feature? Does it possible? Yes it does! Here you would find the code of this recipe/feature.

### Example Considerations
1. Here in this example we have following objects: <br/>
(a) Standard Objects <br/>
-Account <br/>
(b) Custom Objects <br/>
-SalesOrder__c <br/>
-SalesInvoice__c <br/>
(c) Custom Setting (List Type) <br/>
-SalesOrderToInvoiceFieldMapping__c <br/>
(d) Data Model <br/>
<img src="supportedimages/Image0.png" />
2. An after update Apex trigger "SalesOrderTrigger" on SalesOrder__c. <br/>
3. An Apex utility class "SalesInvoiceUtility" to create Sales Invoice records. <br/>

## Field Mapping using Custom Setting
4. The custom setting "SalesOrderToInvoiceFieldMapping__c" contains the data mapping from different Source objects (e.g. Account, SalesOrder__c, Default Values) to SalesInvoice__c objects. <br/>
<img src="supportedimages/Image5.png" />
<img src="supportedimages/Image6.png" />

### Pros of Custom Setting
1. Don't need to use SOQL query. You can use standard method "getAll()" to get all records of a custom setting.
2. Salesforce expose the data of custom setting in the application cache, which enables efficient access without the cost of repeated queries to the database.
3. You can create records in Apex.
4. You can create records via SOAP API/REST API/Data Loader/Workbench.

### Cons of Custom Setting
1. You can't deploy records of custom setting from one org into another org.

### Declarative Field Mapping in Action!
<img src="supportedimages/Image1.png" />
<img src="supportedimages/Image2.png" />
<img src="supportedimages/Image3.png" />
<img src="supportedimages/Image4.png" />

## Field Mapping using Custom Metadata Type
1. You can achieve the functionality using a new feature called Custom Metadata Type.

### Pros of Custom Metadata Type
1. You can deploy records of custom metadata type easily from one org into another org. Because records of custom metadata types are metadata NOT data. 

### Cons of Custom Metadata Type
1. You need to use SOQL query to get the records from the database as you do for standard and custom objects.
2. You can't create records in Apex or via SOAP API/REST API/Data Loader/Workbench. There is a GitHub branch <a href="https://github.com/forcedotcom/CustomMetadataLoader">"CustomMetadataLoader"</a> by forcedotcom to load records using CSV file in Salesforce.



