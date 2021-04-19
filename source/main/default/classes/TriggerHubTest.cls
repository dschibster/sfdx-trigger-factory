/**
 *
**/
@isTest
public with sharing class TriggerHubTest {
    @isTest static void executeDummyTrigger_throwException(){
		
		Exception ex;
        if(TriggerMapping.getInstance().containsKey('LEAD')){
            TriggerMapping.getInstance().remove('LEAD');
        }
		try{
			TriggerHub.executeTriggerHandlers(Lead.SObjectType);
		}catch(Exception e){
			ex = e;
		}
		System.assert(ex != null, 'TriggerException was not thrown');
		
	}

	@isTest static void executeDummyFactoryMethods(){
		
		//Dependency Inject into the Trigger Factory in order to have our methods run even though they are not called via Trigger
		TriggerMapping.getInstance().put('LEAD', new List<String>{'TriggerHandlerExtension'});
        List<ITrigger> triggerHandlers = TriggerHub.getHandlers(Lead.SObjectType);
        ITrigger handler = triggerHandlers[0];

        //to inject into the triggerNew/triggerOld parameters.
        Lead testLead = new Lead(LastName = 'Test', Company = 'mindsquare');
		List<Lead> leadList = new List<Lead>{testLead};
		insert leadList;
        Map<Id, Lead> leadMap = new Map<Id, Lead>(leadList);

        TriggerHub.execute(handler, 'BEFORE_INSERT', leadList, null);
        TriggerHub.execute(handler, 'BEFORE_DELETE', null, leadMap);
        TriggerHub.execute(handler, 'BEFORE_UPDATE', leadList, leadMap);
        TriggerHub.execute(handler, 'AFTER_INSERT', leadList, null);
        TriggerHub.execute(handler, 'AFTER_DELETE', null, leadMap);
        TriggerHub.execute(handler, 'AFTER_UPDATE', leadList, leadMap);
        
		
	}
}