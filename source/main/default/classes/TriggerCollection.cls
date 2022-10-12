public class TriggerCollection {
    public List<SObject> allNewRecords;
    public List<SObject> allOldRecords;
    Map<String, Map<Id, List<SObject>>> databaseStatusToRecordTypeIdToRecords;

    @TestVisible
    private static String RECORDTYPEID_FIELD = 'RecordTypeId';

    public static final Map<String, String> COLLECTION_MAPPING = new Map<String, String>{
        'DELETE' => 'old',
        'UPDATE' => 'new',
        'INSERT' => 'new',
        'UNDELETE' => 'new'
    };

    public TriggerCollection(List<SObject> triggerNew, List<SObject> triggerOld) {
        allNewRecords = triggerNew;
        allOldRecords = triggerOld;
    }

    public void filter(Set<Id> recordTypeIds, String operationType) {
        String operation = operationType.split('_')[1];
        List<SObject> relevantCollection = operation == 'DELETE' ? allOldRecords : allNewRecords;
        Boolean isUpdate = operation == 'UPDATE';

        String retrievalKey = COLLECTION_MAPPING.get(operation);
        databaseStatusToRecordTypeIdToRecords = new Map<String, Map<Id, List<SObject>>>();
        databaseStatusToRecordTypeIdToRecords.put(retrievalKey, new Map<Id, List<SObject>>());

        if (isUpdate) {
            databaseStatusToRecordTypeIdToRecords.put('old', new Map<Id, List<SObject>>());
        }

        Map<Id, SObject> mapOld = new Map<Id, SObject>(allOldRecords != null ? allOldRecords : new List<Sobject>());
        Map<Id, SObject> mapNew = new Map<Id, SObject>();

        for (SObject sobj : relevantCollection) {
            if (sobj.get(RECORDTYPEID_FIELD) == null) {
                return;
            }

            Id recordTypeId = (Id) sobj.get(RECORDTYPEID_FIELD);

            if (!databaseStatusToRecordTypeIdToRecords.get(retrievalKey).containsKey(recordTypeId)) {
                databaseStatusToRecordTypeIdToRecords.get(retrievalKey).put(recordTypeId, new List<SObject>());
                if (isUpdate) {
                    databaseStatusToRecordTypeIdToRecords.get('old').put(recordTypeId, new List<SObject>());
                }
            }

            databaseStatusToRecordTypeIdToRecords.get(retrievalKey).get(recordTypeId).add(sobj);
            if (isUpdate) {
                databaseStatusToRecordTypeIdToRecords.get('old').get(recordTypeId).add(mapOld.get(sobj.Id));
            }
        }
    }

    public List<SObject> fetchRecords(String operation, Id recordTypeId) {
        List<SObject> records = databaseStatusToRecordTypeIdToRecords.get(COLLECTION_MAPPING.get(operation)).get(recordTypeId);
        if (records == null) {
            records = new List<Sobject>();
        }
        return records;
    }

    public List<SObject> fetchOldRecords(Id recordTypeId) {
        List<SObject> records = databaseStatusToRecordTypeIdToRecords.get('old').get(recordTypeId);
        if (records == null) {
            records = new List<Sobject>();
        }
        return records;
    }
}
