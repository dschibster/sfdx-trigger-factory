<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/deploy.png">
</a>

## Mindsquare Trigger Framework 2.0 - Now with dynamic Handler Calls ##

### Overview ### 

<img src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/framework.png">

### Using the Trigger Framework ###

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