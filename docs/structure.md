# Structural Examples
## Entry-Level Org with low amount of automation
In an org where the amount of automations is still very easy to oversee, the quickest way from installation of the framework to working functionality is to create a method inside the Trigger Handler and simply call it in your triggering method.

``` java linenums="1"
public class OpportunityHandler extends TriggerHandlerExtension{
    public OpportunityHandler(){
        super();
    }

    public override beforeUpdate(SObject oldSObj, SObject newSObj){
        Opportunity oldOpp = (Opportunity) oldSObj;
        Opportunity newOpp = (Opportuntiy) newOpp;
        setCloseDateForWonOpp(oldOpp, newOpp);
    }

    @TestVisible
    private void setCloseDateForWonOpp(Opportunity oldOpp, Opportunity, newOpp){
        if(oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'Closed Won'){
            newOpp.CloseDate = Date.today();
        }
    }
}
```

## Mid-size Org with medium to high amounts of automation
Once automations grow, it is hard to oversee everything from within the same class. Editing the same class in multiple development streams and git branches at the same time become more and more likely. In such cases, it is recommended to switch to **helper classes** that leverage module-level code and make it easier to separate **trigger logistics** from **trigger logic**.

``` java linenums="1"
public class OpportunityHandler extends TriggerHandlerExtension{
    
    OpportunityDataRefinementHelper helper;
    OpprotunityAfterSalesHelper afterSalesHelper;
    
    public OpportunityHandler(){
        super();
        helper = new OpportunityDataRefinementHelper(triggerNew, triggerNewMap, triggerOld, triggerOldMap);
        afterSalesHelper = new OpprotunityAfterSalesHelper(triggerNew, triggerNewMap, triggerOld, triggerOldMap);
    }

    public override bulkBefore(){
        afterSalesHelper.fetchDataIntoMapsBeforeUpdate();
    }

    public override beforeUpdate(SObject oldSObj, SObject newSObj){
        Opportunity oldOpp = (Opportunity) oldSObj;
        Opportunity newOpp = (Opportuntiy) newOpp;
        helper.setCloseDateForWonOpp(oldOpp, newOpp);
    }
    
    //and so on.
}
```

## Enterprise-level org / org with high density of automations
An org does not need to be enterprise-level to have a high density of automations on the same object. To the contrary, some smaller customers that use the same objects for a multitude of different use cases may very quickly grow out of the above patterns due to new requirements growing out of the framework like weed beneath the pavement. In these cases, I recommend to approach triggers with a [SOLID](https://www.digitalocean.com/community/conceptual_articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design) approach. While we are not able to completely cover all of these aspects in Apex, we can at least approach them with a clear separation of concerns, for example by giving each Data Processing Function its own class. These classes can in turn access another class that contains all the relevant data that has been cached by the Trigger Handler.

``` java linenums="1" title="Example with complete separation of concerns"
public class OpportunityHandler extends TriggerHandlerExtension{
    
    OpportunityDataCache cache;
    
    public OpportunityHandler(){
        super();
    }

    public override bulkBefore(){
        new OpportunityClosedWonDataCacher(cache).run();
        //This cacher class should only run if the necessary requirements are fulfilled
        //e.g. Trigger Context is UPDATE and at least one Opportunity in context has been set to Closed Won
    }

    public override beforeUpdate(SObject oldSObj, SObject newSObj){
        Opportunity oldOpp = (Opportunity) oldSObj;
        Opportunity newOpp = (Opportuntiy) newOpp;
        new OpportunitySetFieldsForClosedWon().run(oldOpp, newOpp);
        //This class would only set fields on the triggering records, not requiring the cache at all.
    }

    public override beforeUpdate(SObject oldSObj, SObject newSObj){
        Opportunity oldOpp = (Opportunity) oldSObj;
        Opportunity newOpp = (Opportuntiy) newOpp;
        new OpportunityAfterSalesActivities(cache).run(oldOpp, newOpp);
        //This class would access data in cache where needed to create new records and update existing ones. 
        //This in turn would be handled with a Unit of Work here.
    }
    
    //and so on.
}
```
