public virtual without sharing class TriggerHandlerExtension {
    public Schema.sObjectType sObjType;
    private Boolean isPlatformEvent;
    public Boolean isDisabled;
    public String handlerName;
    public TriggerOperation triggerContext;

    public static Set<SObjectType> disabledObjects = new Set<SObjectType>();
    public static Set<String> disabledClasses = new Set<String>();

    @TestVisible
    private static Map<String, LoopCount> loopCountMap;

    public TriggerCollection records;
    public List<SObject> triggerNew = new List<SObject>();
    public Map<Id, SObject> triggerNewMap = new Map<Id, SObject>();
    public List<SObject> triggerOld = new List<SObject>();
    public Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
    public Set<Id> filteredRecordTypes;

    static {
        loopCountMap = new Map<String, LoopCount>();
    }

    public TriggerHandlerExtension() {
        if (Trigger.isExecuting) {
            setSObjectType(Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType());
            this.isDisabled = isDisabled();
            if (isDisabled) {
                return;
            }
            //filter record type here?
            if (Trigger.isBefore) {
                addToLoopCount();
            }
        }

        lstInsert = new List<sObject>();
        lstUpsert = new List<sObject>();
        lstUpdate = new List<sObject>();
        lstDelete = new List<sObject>();
    }

    public void setSObjectType(SObjectType sobjType) {
        this.sObjType = sobjType;
        this.isPlatformEvent = sobjType.getDescribe().getName().endsWith('__e');
    }

    public void fillTriggerCollections() {
        String operation = triggerContext.name().split('_')[1];
        Boolean isUpdate = operation == 'UPDATE';
        if (filteredRecordTypes == null) {
            this.triggerNew = records.allNewRecords;
            /*
             * After this line, triggerNew will have all relevant records,
             * as this is the only collection Custom Platform Events can use
             * The rest will crash. Let's escape this here.
             */
            if (isPlatformEvent) {
                return;
            }
            if (triggerNew?.size() > 0 && triggerNew.get(0).Id != null) {
                this.triggerNewMap = new Map<Id, SObject>(triggerNew);
            }
            this.triggerOld = records.allOldRecords;
            if (triggerOld != null) {
                this.triggerOldMap = new Map<Id, SObject>(triggerOld);
            }
            return;
        }

        this.triggerNew = new List<SObject>();
        this.triggerNewMap = new Map<Id, Sobject>();
        this.triggerOld = new List<SObject>();
        this.triggerOldMap = new Map<Id, SObject>();
        Map<String, List<SObject>> operationToCollection = new Map<String, List<SObject>>{
            'INSERT' => this.triggerNew,
            'DELETE' => this.triggerOld,
            'UPDATE' => this.triggerNew,
            'UNDELETE' => this.triggerNew
        };

        for (Id recordTypeId : filteredRecordTypes) {
            operationToCollection.get(operation).addAll(records.fetchRecords(operation, recordTypeId));
            if (isUpdate) {
                this.triggerOld.addAll(records.fetchOldRecords(recordTypeId));
            }
        }

        if (triggerNew?.size() > 0 && triggerNew.get(0).Id != null) {
            this.triggerNewMap = new Map<Id, SObject>(this.triggerNew);
        }
        if (!triggerOld.isEmpty()) {
            this.triggerOldMap = new Map<Id, SObject>(triggerOld);
        }
    }

    public Boolean hasNoRecordsToProcess() {
        if (this.triggerContext.name().containsIgnoreCase('_DELETE')) {
            return triggerOld.isEmpty();
        }
        return triggerNew.isEmpty();
    }

    /**
     * These list can be used freely in any Trigger Handler and help
     * bundle the insertion or update of multiple different objects.
     */
    public List<sObject> lstInsert;
    public List<sObject> lstUpsert;
    public List<sObject> lstUpdate;
    public List<sObject> lstDelete;

    /**
     * @description Helps you call methods or collect data that you need before the processing of data in a "before" Context
     * Example: Caching of Data Before Insert to supplement the inputs given by your user. (Cache Related Object Data for your new records)
     * @author mindsquare AG
     */
    virtual public void bulkBefore() {
    }

    /**
     * @description Helps you call methods or collect data that you need before the processing of data in an "after" Context
     * Example: Caching of Data After Update to help determine if further Updates on other objects are necessary later on.
     * @author mindsquare AG
     */
    virtual public void bulkAfter() {
    }

    /**
     * @description Called for every single record in a Before Insert Context. Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  newSObj The current SObject you are checking from Trigger.new. Typecast into the SObject's proper type to use dot notation (rec.field__c)
     */
    virtual public void beforeInsert(SOBject newSObj) {
    }

    /**
     * @description Called for every single record in a Before Insert Context. Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj The current SObject you are checking from Trigger.old. Represents the record before it was updated
     * @param  newSObj The current SObject you are checking from Trigger.new. Represents the record as it will land on the database after the Trigger.
     */
    virtual public void beforeUpdate(SOBject oldSObj, SOBject newSObj) {
    }

    /**
     * @description Called for every single record in a Before Delete Context. Use to throw exceptions for your record, should you not be allowed to delete them.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj The current record that is iterated over
     */
    virtual public void beforeDelete(SOBject oldSObj) {
    }

    /**
     * @description Called for every single record in an After Insert Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * @author mindsquare AG
     * @param  newSObj newSObj The newly inserted record (it now has an Id)
     */
    virtual public void afterInsert(SOBject newSObj) {
    }

    /**
     * @description Called for every single record in an After Update Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * @author mindsquare AG
     * @param  oldSObj oldSObj The record as it was before the database update
     * @param  newSObj newSObj The record as it is on the database now after triggers
     */
    virtual public void afterUpdate(SOBject oldSObj, SOBject newSObj) {
    }

    /**
     * @description Called for every single record in an After Delete Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj Single Deleted record
     */
    virtual public void afterDelete(SOBject oldSObj) {
    }

    /**
     * @description Called for every single record in an After Undelete Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj Single Undeleted record
     */
    virtual public void afterUndelete(SOBject oldSObj) {
    }

    /**
     * @description Used for processing of data collected in record processing
     * Use to commit new records to database or fire updates
     * @author mindsquare AG
     */
    virtual public void andFinally() {
    }

    // Constructor

    /**
     * @description Checks Trigger Settings and current statically disabled Triggers/Classes
     * @author mindsquare AG
     * @return The current disabled status of the Class that is executing
     */
    @TestVisible
    public virtual Boolean isDisabled() {
        TriggerSettings ts = TriggerSettings.getInstance();

        return ts.isDisabledByClassName(getHandlerName()) || disabledClasses.contains(getHandlerName().toUpperCase());
    }

    /**
     * @description Returns the Handler Name of the Class that is currently being executed.
     * @author mindsquare AG
     * @return The Trigger Handler Name
     */
    @TestVisible
    private String getHandlerName() {
        if (handlerName == null) {
            //this will only be called when the Handler is called standalone - without the Trigger factory
            handlerName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        }
        return handlerName;
    }

    /**
     * @description Statically disables all Triggers of a specific SObject for the duration of this control flow
     * @author mindsquare AG
     * @param  sobjectType SObject Type you want to disable
     */
    public static void disableObject(SObjectType sobjectType) {
        disabledObjects.add(sobjectType);
    }

    /**
     * @description Reverses the effects of disableObject() -> Ensures that no static disabling is taking place for an Object
     * @author mindsquare AG
     * @param  sobjectType SObject Type you want to enable
     */
    public static void enableObject(SObjectType sobjectType) {
        disabledObjects.remove(sobjectType);
    }

    /**
     * @description Disables the execution of a specific Trigger Handler class
     * @author mindsquare AG
     * @param  className Name of the Class you want to disable
     */
    public static void disableClass(String className) {
        disabledClasses.add(className.toUpperCase());
    }

    /**
     * @description Re-Enables a previously disabled Handler Class
     * @author mindsquare AG
     * @param  className Name of the Class you want to enable
     */
    public static void enableClass(String className) {
        disabledClasses.remove(className.toUpperCase());
    }

    /**
     * @description Sets a maximum Loop Count for a the Trigger you are running
     * @author Dennis Grzyb
     * @param  max The maximum of executions you want to set
     */
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!TriggerHandlerExtension.loopCountMap.containsKey(handlerName)) {
            TriggerHandlerExtension.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandlerExtension.loopCountMap.get(handlerName).setMax(max);
        }
    }

    /**
     * @description Clears a previous accumulation of loops of your currently running Trigger Handler
     * @author Dennis Grzyb
     */
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /**
     * @description Adds to the LoopCount of the currently running Handler Class.
     * @author Dennis Grzyb
     * @throws TriggerHandlerException if a certain amount of Loops is exceeded.
     */
    @TestVisible
    protected void addToLoopCount() {
        String handlerName = getHandlerName();
        if (TriggerHandlerExtension.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandlerExtension.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = TriggerHandlerExtension.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    /**
     * Class LoopCount
     *
     * Used to manage the loop count per handler
     */
    @TestVisible
    public class LoopCount {
        @TestVisible
        private Integer max;
        @TestVisible
        private Integer count;

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if (this.max < 0)
                return false;
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    /**
     * Class TriggerHandlerException
     *
     * Used to instantiate custom Trigger Handler Exceptions.
     */
    public class TriggerHandlerException extends Exception {
    }
}
