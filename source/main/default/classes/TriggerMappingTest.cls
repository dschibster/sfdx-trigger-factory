@isTest
public with sharing class TriggerMappingTest {
    private static String factoryDummyValues = '[{"Label":"Account_Person","MasterLabel":"Account_Person","ClassName__c":"PersonAccountHandler","Language":"en_US","RecordTypeIds__c":"0121X000003twHvQAI","IsDisabled__c":false,"QualifiedApiName":"Account_Person","SObjectName__c":"Account","Id":"m005E0000002NLS","OrderOfExecution__c":1,"DeveloperName":"Account_Person","NamespacePrefix":null}]';
    @isTest
    static void getTriggerMap() {
        //Since we got rid of unmanaged metadata in our package, we are now verifying the existence of mapped Handlers by mocking an active Handler with a Record Type Filter.
        TriggerMapping.triggerFactorySettings = (List<TriggerFactorySetting__mdt>) JSON.deserialize(factoryDummyValues, List<TriggerFactorySetting__mdt>.class);

        TriggerMapping trigMap = TriggerMapping.getInstance();
        System.assert(trigMap.mappedHandlers.size() == 1);

        //DummyObject2 was previously part of the unmanaged metadata, but is auto-excluded here because it does not come up in a query where IsDisabled__c = false

        System.assert(!trigMap.mappedHandlers.containsKey('DUMMYOBJECT2'));

        System.assert(trigMap.recordTypeFilter.containsKey('PersonAccountHandler'));
    }

    @isTest
    static void getTriggerMapWhenTriggerFactorySettingsExist() {
        if ([SELECT COUNT() FROM TriggerFactorySetting__mdt] != 0) {
            TriggerMapping.getInstance();
        }
    }
}
