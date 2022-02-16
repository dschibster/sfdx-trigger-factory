# How to use 

## Step-by-Step Guide
### Step 1: Install the Framework
Well, obviously you need the framework to start working with it. :) Head over to [Installation](installation.md) to find the correct version for you.

### Step 2: Create a Trigger Handler and have it extend `TriggerHandlerExension`
You need to create the class the TriggerFactory instantiates. The factory expects classes of Type `TriggerHandlerExtension`, so to get started, use the newly installed virtual class in your own Handler class. Make sure to call `super()` in your constructor, or else all other functionality (including actually using the [Trigger Collections](features.md#trigger-collections-delivered-to-your-class)) will not work.


``` java
public class ExampleTriggerHandler extends TriggerHandlerExtension{
    public ExampleTriggerHandler(){
        super();
    }
}
```

### Step 3: Create a Trigger
Should an Apex Trigger not exist yet, you should definitely create a Trigger right about now. Make sure to include all contexts (*except when handling Platform Events*) and call `TriggerFactory.executeTriggerHandlers(SOBJECT_TYPE_OF_YOUR_TRIGGERING_OBJECT)`.

``` java
trigger AccountTrigger on Account(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    TriggerFactory.executeTriggerHandlers(Account.SObjectType);
}
```

### Step 4: Create a Trigger Factory Setting
In order to make the Trigger run, you need to create a Custom Metadata Record for the Handler you are working on. For more about the Custom Metadata driven trigger execution, check out the [feature page](features.md#custom-metadata-based-triggers)

### Step 5: Add functionality
This step is different depending on the size of your org and the structure of your other Triggers, so this is left very vague on purpose. Check [Structural examples](structure.md) to find out what approach fits your org best.

### Step 6: You're done!
What happens next is up to the rest of ongoing development - Test and Release your Triggers and start your next automation!
