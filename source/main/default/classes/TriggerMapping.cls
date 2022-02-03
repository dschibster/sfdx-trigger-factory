public without sharing class TriggerMapping {
    public static Map<String, List<String>> instance;

    /**
     * @description Single Design Pattern method for retrieval of Trigger Mappings
     * Retrieves Trigger Factory Settings and groups the Trigger Handlers to execute based on the Object name and their Order of Execution.
     * @author Dennis Grzyb
     * @return   the current instance of TriggerMapping
     */
    public static Map<String, List<String>> getInstance() {
        if (instance == null) {
            instance = new Map<String, List<String>>();
            for (TriggerFactorySetting__mdt setting : [
                SELECT SObjectName__c, ClassName__c
                FROM TriggerFactorySetting__mdt
                ORDER BY SObjectName__c, OrderOfExecution__c
            ]) {
                if (!instance.containsKey(setting.SObjectName__c.toUpperCase())) {
                    instance.put(setting.SObjectName__c.toUpperCase(), new List<String>());
                }
                instance.get(setting.SObjectName__c.toUpperCase()).add(setting.ClassName__c);
            }
        }
        return instance;
    }
}
