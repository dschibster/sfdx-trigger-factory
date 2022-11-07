trigger CPETrigger on CustomPlatformEvent__e(after insert) {
    TriggerFactory.executeTriggerHandlers(CustomPlatformEvent__e.SObjectType);
}
