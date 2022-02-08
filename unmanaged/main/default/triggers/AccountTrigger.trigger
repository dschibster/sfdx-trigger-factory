trigger AccountTrigger on Account(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    TriggerFactory.executeTriggerHandlers(Account.SObjectType);
}
