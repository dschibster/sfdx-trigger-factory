@isTest
public with sharing class TriggerMappingTest {
    @isTest
    static void getTriggerMap() {
        //It is a given that we have at least one Custom Metadata Type in the Trigger Factory Setting (e.g. the Dummy Object from this pkg)
        //Therefore we only need to initialize the Map

        TriggerMapping trigMap = TriggerMapping.getInstance();
        System.assert(trigMap.mappedHandlers.size() > 0);

        //Additionally DummyObject2 should not come up in this instance, because it is disabled.
        System.assert(!trigMap.mappedHandlers.containsKey('DUMMYOBJECT2'));
        System.assert(trigMap.recordTypeFilter.containsKey('PersonAccountHandler'));
    }
}
