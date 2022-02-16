# Features
The framework comes with a variety of features that you can leverage to your liking. 

## Trigger collections delivered to your class
The virtual class `TriggerHandlerExtension` that is your Trigger Handler class base offers you the following variables:

* `triggerNew`
* `triggerNewMap`
* `triggerOld`
* `triggerOldMap`

To use in your `bulkBefore`/`bulkAfter` calls (as they are already leveraged in the single-record methods). This makes it possible to mock a run of a trigger by simply filling in these collections before calling `TriggerFactory.execute()` with the handler object.

If you want to create a manual run of the Trigger Handler without actually calling the Trigger (for example for unit testing), simply use the class method `fillTriggerCollections(newList, newMap, oldList, oldMap)`.

In practice you may want to use the `triggerNew` list in your queries to create a Map, for example like this:

``` java
public override void bulkBefore(){
    mapIdToOppWithRelated = new Map<Id, Opportunity>(
        [
            SELECT  Id,
                    Account.Name,
                    Account.ShippingCountry 
            FROM Opportunity 
            WHERE Id IN :triggerNew
        ]
    );
}
```
## Custom Metadata Based Triggers
The `Trigger Factory Setting` Metadata Type prescribes the Objects, the Classes and the order of execution that the Handlers should run in. This is especially useful for very loaded objects, where we usually only require a fraction of the functionality depending on the type of record we are processing (ref. [Record Type Filtering](features.md#record-type-filtering)).

This also enables you to use SFDX Trigger Factory in a package-based development model where the Trigger Factory is a part of a larger package landscape. Packages can be developed independently from one another and only the Factory Setting is necessary for the factory package to recognize that a Trigger has to be executed. Therefore, the Apex Trigger is only required in one of the packages (preferably the one that contains the most dependencies). If your Object is package-exclusive - even easier! Just include both Apex Trigger and Factory Setting in your package.

An example Trigger Factory Setting would look something like this:
```json
{
    "Label":"Opportunity General Handler",
    "DeveloperName":"OpportunityGeneralHandler",
    "ClassName__c":"OpportunityHandler",
    "SObjectName__c":"Opportunity",
    "OrderOfExecution__c":1,
    "IsDisabled__c":false
}
```
This would call the `OpportunityHandler` class at runtime.

## Temporarily Disable Your Triggers in Settings and Code
### Custom Setting
The `TriggerSettings__c` custom settings gives you the option to disable all triggers for either the entire org, a single profile or a single user. As such, it functions as a complete killswitch, if you are for example riding on a Data Migration User Profile that is already delivering complete data to you. However, you can also selectively disable Objects and/or Trigger Handlers by inserting their names into the Text Area fields with the corresponding name. Should the space not fit, let me know! It's not intended to be used for the disablement of more than, say, two or three Classes at the same time, but there should be options to extend the functionality across multiple fields for you.

### Apex
`disableClass(String className)` and `disableObject(SObjectType sobjType)` as well as their counterparts `enableClass()` and `enableObject()` can be used from within your Apex executions to disable Triggers from running in just the transaction that calls the method. Any other apex executions that do not come across this line of code will be unaffected. Use this if you are planning a big data update on an object that you do not need the automations of when running the update.

## Filter your Records before the Handler runs
Record Types often serve vastly different business uses, and standard trigger logic therefore often has to make the explicit distinction between `RecordTypeId A` and `RecordTypeId B` when checking if certain pieces of functionality should be executed. Instead you can already specify one or multiple Record Type Ids in the `Trigger Factory Setting`. The class variables `triggerNew` etc. will then have only the records with the matching record types. This saves you the trouble of checking them in every method you run across.

Adjusting the above example, it could look like this:
```json
{
    "Label":"Existing Business Opportunity Handler",
    "DeveloperName":"ExistingBusinessOppHandler",
    "ClassName__c":"ExistingBusinessOppHandler",
    "SObjectName__c":"Opportunity",
    "OrderOfExecution__c":2,
    "IsDisabled__c":false,
    "RecordTypeIds__c": "18-digit Salesforce Id"
}
```

This Opp Handler would run after `OpportunityHandler` because the `OrderOfExecution__c` is lower. It would also only contain records that have the correct Record Type Id.

### Store Database Operations directly in your Handler
Out of the box, this framework brings you four lists that you can leverage to collect database operations instead of calling DML all at once:

* `lstUpdate`
* `lstInsert`
* `lstUpsert`
* `lstDelete`

You can use these out-of-the-box collections to perform DML in `andFinally()`. 
**Please note however that should the contents of these lists not be ordered by SObject Type, that each break in the Typing will cause another DML statement**. If you want to bundle based on SObject Type, either sort the list beforehand or leverage another pattern such as the lovely [Unit of Work](https://trailhead.salesforce.com/de/content/learn/modules/apex_patterns_sl/apex_patterns_sl_learn_uow_principles).

## Control Recursion (WIP)
This trigger framework presents you with the option of setting a maximum LoopCount. This count will be increased everytime a Trigger is entering the BEFORE context. When the maximum Loop Count is exceeded, an exception is thrown.
For example, use `this.setMaxLoopCount(1)` in the Trigger Constructor to make sure that the code breaks if the Trigger Handler runs more than once.

**Work In Progress: Soon there will be an option to gracefully skip Triggers when the Loop Count is exceeded instead of throwing an Exception.** 