[![codecov](https://codecov.io/gh/dschibster/sfdx-trigger-factory/branch/master/graph/badge.svg?token=WPU1N1CNE8)](https://codecov.io/gh/dschibster/sfdx-trigger-factory)
[![Code Coverage and Release](https://github.com/dschibster/sfdx-trigger-factory/actions/workflows/deployment.yml/badge.svg)](https://github.com/dschibster/sfdx-trigger-factory/actions/workflows/deployment.yml)

# Installation
<div>
<span><a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ijXAAAY">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/deploy_unlocked.png">
</a>
<span>
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/deploy_unmanaged.png">
</a>
</span>
<div>
For your Sandbox:
  <div><span>
    <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ijXAAAY">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/deploy_unlocked.png">
</a></span><div>


## Mindsquare Trigger Framework 2.0 - Now with dynamic Handler Calls ##

### Overview ### 

<img src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/framework.png">

### Using the Trigger Framework ###
The classes provided by the Framework do not need to be changed in any way, as they work on their own and only serve to offer you a template for your own Trigger Handlers.

`ITrigger` offers methods to be executed by the `TriggerFactory`

`TriggerFactory` fetches the Trigger Handlers to execute and executes them.

`TriggerMapping` fetches your Trigger Factory Settings and hands them over to the `Trigger Factory`

`TriggerSettings` make checks on recursion and disabling of your Triggers.

`TriggerHandlerExtension` is a virtual class for your own Trigger Handlers to extend. It already implements `ITrigger` so you only have to implement methods that are of interest to you. It additionally gives you access to recursion checks, disabling of triggers and more.



#### Create a Trigger ####
In order to work with this Trigger Framework, create a single Trigger on an SObject and have it call the `executeTriggerHandlers` method of the `TriggerFactory` class.
```java
  trigger AccountTrigger on Account (before update, before insert, before delete, after update, after insert, after delete){
    TriggerFactory.executeTriggerHandlers(Account.SObjectType);
  }
```

### Create a Trigger Factory Setting ###
In order to keep the Trigger Factory Dynamic, we are not checking for explicit SObject types in the factory, but are instead referencing a **Custom Metadata Type**. Go into Setup to create a `Trigger Factory Setting` with your SObject and the Trigger Handler you want to execute. Optionally, you can use an Order of Execution in case you want to create more than one Trigger Handler on one Object.

    Trigger Factory Setting:
      Label: Choose freely, such as Account.AccountHandler
      Name: Choose freely, such as Account_AccountHandler
      SObject Name: Account
      Class Name: AccountHandler

### Create the Trigger Handler ###
Our virtual class `TriggerHandlerExtension` needs to be extended in order to execute logic, as it is only a template for how to execute triggers.

Create the Trigger Handler and call `super()` in order to get the `TriggerHandlerExtension` going (it checks for disabling the Trigger, for example).

Then, `override` all the methods that you want to execute inside your new class.
```java
public class AccountHandler extends TriggerHandlerExtension{
  
  public AccountHandler(){
    super();
  }

  public override void bulkBefore(){
    //your logic may go here;
  }
}
```


### What do the methods do? ###
The interface `ITrigger` has several different methods that are executed at different points and are to be used for different purposes. 

When executing a Trigger Handler, this Trigger Framework makes use of the methods offered by `ITrigger`.

#### Bulk Operations
`bulkBefore` is called before processing of records in any BEFORE context (before insert, before update, before delete). Use it for bulkified methods or to get data into your Handler that you want to use at a later time.

`bulkAfter` behaves the same as `bulkBefore`, but is executed before any AFTER context. (after insert, after update, after delete). Use it for bulkified methods or caching of data.

#### Single-Record processing
Absolutely **DO NOT** use DML or SOQL in these methods!


`beforeInsert(SObject newSO)` processes a single record (`newSO`) in your BEFORE_INSERT TriggerOperation and is called for each of your records. 

`beforeUpdate(SObject newSO, SObject oldSO)` processes a single record in your BEFORE_UPDATE TriggerOperation and is called for each of your records. It contains the old state of your record (`oldSO`) and the new one (`newSO`). You can therefore make comparisons on field changes etc.

`beforeDelete(SObject oldSO)` processes a single record in your BEFORE_DELETE TriggerOperation and is called for each of your records. It contains the old state of your record (`oldSO`), making you able to validate if the record should even be deleted.

`afterInsert(SObject newSO)` processes a single record (`newSO`) in your AFTER_INSERT TriggerOperation and is called for each of your records. 

`afterUpdate(SObject newSO, SObject oldSO)` processes a single record in your AFTER_UPDATE TriggerOperation and is called for each of your records. It contains the old state of your record (`oldSO`) and the new one (`newSO`). You can therefore make comparisons on field changes etc.

`afterDelete(SObject oldSO)` processes a single record in your AFTER_DELETE TriggerOperation and is called for each of your records. It contains the old state of your record (`oldSO`). That way, you can still reference the Id of the deleted record in order to, for example, delete related objects.

#### Final Processing

`andFinally()` is called at the end of each BEFORE and AFTER operation (i.e. 2x per Trigger execution). If you have collected any data to insert / update / delete in your Trigger Handler, it is recommended to take care of any DML inside this method.


### Usage example
An example usage of the Trigger Framework (excluding the Trigger itself) can look like this.

```java
public class OpportunityHandler extends TriggerHandlerExtension{

  Map<Id, Opportunity> mapAdditionalData = new Map<Id, Opportunity>();

  public AccountHandler(){
    super();
  }

  public override void bulkBefore(){
      //I want to add the Account Name to the Opportunity Name. Therefore I need to get the Account Name from somwewhere.
      if(Trigger.isInsert){
        mapAdditionalData = new Map<Id, Opportunity>([SELECT Id, Account.Name, Account.Type FROM Opportunity  WHERE Id IN :Trigger.new]);
      }
  }

  public override void beforeInsert(SObject newSO){
      Opportunity opp = (Opportunity) newSO;

      addAccountName(opp);
  }

  public override void afterInsert(SObject newSO){
      //I also want to create an initial Task for each Opportunity
      Opportunity opp = (Opportunity) newSO;

      createKickOffTask(opp);
  }

  public override void andFinally(){
      //Insert Records that were added to the lstInsert in the mean time.
      //This will be empty in the BEFORE context.
      if(!lstInsert.isEmpty()){
          insert lstInsert;
      }
  }


  /**
  You are free to use Helper Classes instead. Here we are using class methods.
  */

  public void addAccountName(Opportunity opp){
      opp.Name = mapAdditionalData.get(opp.Id).Account.Name + ' '+opp.Name;
  }

  public void createKickOffTask(Opportunity opp){
    lstInsert.add(new Task(Subject = 'Organize Kick-Off Meeting', WhatId = opp.Id, OwnerId = opp.OwnerId, ActivityDate = Date.today().addDays(1), Status = 'Open'));
  }
}
```

