@isTest
public with sharing class TriggerFactoryTest {
    @isTest
    static void executeDummyTrigger_noHandlers() {
        Exception ex;
        if (TriggerMapping.getInstance().mappedHandlers.containsKey('LEAD')) {
            TriggerMapping.getInstance().mappedHandlers.remove('LEAD');
        }
        try {
            TriggerFactory.executeTriggerHandlers(Lead.SObjectType);
        } catch (Exception e) {
            ex = e;
        }
        System.assert(TriggerFactory.hasReachedErrorLog, 'Trigger Handlers were executed although they were not supposed to');
    }

    @isTest
    static void executeDummyFactoryMethods() {
        //Dependency Inject into the Trigger Factory in order to have our methods run even though they are not called via Trigger
        TriggerMapping.getInstance().mappedHandlers.put('LEAD', new List<String>{ 'TriggerHandlerExtension' });
        List<TriggerHandlerExtension> triggerHandlers = TriggerFactory.getHandlers(Lead.SObjectType, new Set<Id>());
        TriggerHandlerExtension handler = triggerHandlers[0];

        //to inject into the triggerNew/triggerOld parameters.
        Lead testLead = new Lead(LastName = 'Test', Company = 'mindsquare');
        List<Lead> leadList = new List<Lead>{ testLead };
        insert leadList;

        handler.setSObjectType(Lead.SObjectType);
        handler.triggerContext = TriggerOperation.BEFORE_INSERT;

        TriggerCollection collection = new TriggerCollection(leadList, null);
        handler.records = collection;
        handler.fillTriggerCollections();

        handler.hasNoRecordsToProcess();
        TriggerFactory.execute(handler);
        handler.triggerContext = TriggerOperation.AFTER_INSERT;
        TriggerFactory.execute(handler);
        handler.triggerContext = TriggerOperation.AFTER_UNDELETE;
        TriggerFactory.execute(handler);

        collection = new TriggerCollection(null, leadList);
        handler.records = collection;
        handler.fillTriggerCollections();
        handler.triggerContext = TriggerOperation.BEFORE_DELETE;
        handler.hasNoRecordsToProcess();
        TriggerFactory.execute(handler);
        handler.triggerContext = TriggerOperation.AFTER_DELETE;
        TriggerFactory.execute(handler);

        collection = new TriggerCollection(leadList, leadList);
        handler.records = collection;
        handler.fillTriggerCollections();
        handler.triggerContext = TriggerOperation.BEFORE_UPDATE;
        TriggerFactory.execute(handler);
        handler.triggerContext = TriggerOperation.AFTER_UPDATE;
        TriggerFactory.execute(handler);
    }
}
