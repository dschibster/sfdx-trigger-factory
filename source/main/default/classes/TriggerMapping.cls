public without sharing class TriggerMapping {
    public static TriggerMapping instance;
    public Map<String, List<String>> mappedHandlers;
    public Map<String, Set<Id>> recordTypeFilter;

    /**
     * @description Single Design Pattern method for retrieval of Trigger Mappings
     * Retrieves Trigger Factory Settings and groups the Trigger Handlers to execute based on the Object name and their Order of Execution.
     * @author Dennis Grzyb
     * @return   the current instance of TriggerMapping
     */
    public static TriggerMapping getInstance() {
        if (instance == null) {
            instance = new TriggerMapping();
            instance.load();
        }
        return instance;
    }

    private void load() {
        mappedHandlers = new Map<String, List<String>>();
        recordTypeFilter = new Map<String, Set<Id>>();
        for (TriggerFactorySetting__mdt setting : [
            SELECT SObjectName__c, ClassName__c, RecordTypeIds__c
            FROM TriggerFactorySetting__mdt
            WHERE IsDisabled__c = FALSE
            ORDER BY SObjectName__c, OrderOfExecution__c
        ]) {
            if (!mappedHandlers.containsKey(setting.SObjectName__c.toUpperCase())) {
                mappedHandlers.put(setting.SObjectName__c.toUpperCase(), new List<String>());
            }
            mappedHandlers.get(setting.SObjectName__c.toUpperCase()).add(setting.ClassName__c);
            if (setting.RecordTypeIds__c != null) {
                recordTypeFilter.put(setting.ClassName__c, new Set<Id>((List<Id>) setting.RecordTypeIds__c.split(';')));
            }
        }
    }
}
