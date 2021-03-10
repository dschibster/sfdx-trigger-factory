@isTest
public with sharing class TriggerUnitOfWorkTest {
    @isTest static void constructors(){
        TriggerUnitOfWork tuow = new TriggerUnitOfWork();
        tuow = new TriggerUnitOfWork(new List<SObjectType>());
        tuow.getSObjectTypeList();
    }

    @isTest static void testHasWork(){
        TriggerUnitOfWork tuow = new TriggerUnitOfWork(new List<SObjectType>{Account.SObjectType});
        tuow.registerNew(new Account(Name = 'mindsquare'));

        System.assert(tuow.hasWork(), 'Work was not found by hasWork check');
    }
}
