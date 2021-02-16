@isTest
public with sharing class TriggerMappingTest {
    
    @isTest static void getTriggerMap(){
        //It is a given that we have at least one Custom Metadata Type in the Trigger Factory Setting (e.g. the Dummy Object from this pkg)
        //Therefore we only need to initialize the Map

        Map<String, List<String>> trigMap = TriggerMapping.getInstance();
        System.assert(trigMap.size() > 0);
    }
}