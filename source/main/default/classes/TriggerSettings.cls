public without sharing class TriggerSettings {
    @TestVisible
    private Set<String> disabledTriggers = new Set<String>();
    @TestVisible
    private Set<String> disabledObjects = new Set<String>();
    @TestVisible
    private Boolean isEverythingDisabled = false;

    public static TriggerSettings instance;

    public TriggerSettings() {
    }

    /**
     * @description Singleton Design Pattern method for TriggerSettings. For each control flow, this class only needs to be instantiated once. After that we are working with the same instance.
     * @author mindsquare AG
     * @return The currently instantiated instance of TriggerSettings
     */
    public static TriggerSettings getInstance() {
        if (instance == null) {
            instance = new TriggerSettings();
            instance.load();
        }
        return instance;
    }

    /**
     * @description Loads all different possibilities of the currently running Trigger Handler to be disabled with Custom Settings
     * @author mindsquare AG
     */
    public void load() {
        TriggerSettings__c triggerSetting = TriggerSettings__c.getInstance();
        if (triggerSetting.DisableAllTriggers__c) {
            this.isEverythingDisabled = true;
            return;
        }
        if (String.isNotBlank(triggerSetting.DisabledObjects__c)) {
            disabledObjects = new Set<String>(triggerSetting.DisabledObjects__c.toUpperCase().split(';'));
        }
        if (String.isNotBlank(triggerSetting.DisabledHandlers__c)) {
            disabledTriggers = new Set<String>(triggerSetting.DisabledHandlers__c.toUpperCase().split(';'));
        }
    }

    /**
     * @description Checks if all Triggers  are disabled.
     * @author mindsquare AG
     * @param sobjType the SObject Type you want to check against (normally run directly in the Trigger Handler constructor)
     * @return          The result is true if there is any indication that the SObject is disabled and false otherwise
     */
    public Boolean isAllTriggersDisabled() {
        return this.isEverythingDisabled;
    }

    /**
     * @description Checks if all Triggers of a certain SObject are disabled.
     * @author mindsquare AG
     * @param sobjType the SObject Type you want to check against (normally run directly in the Trigger Handler constructor)
     * @return          The result is true if there is any indication that the SObject is disabled and false otherwise
     */
    public Boolean isDisabledBySObjectType(SObjectType sobjType) {
        if (this.isEverythingDisabled) {
            return true;
        }
        if (sobjType != null) {
            String sobjectName = sobjType.getDescribe().getName().toUpperCase();
            return this.disabledObjects.contains(sobjectName);
        } else {
            return false;
        }
    }

    /**
     * @description Checks if the execution of a certain class is disabled.
     * @author mindsquare AG
     * @param className The class name of the Trigger Handler currently running
     * @return          The result is true if there is any indication that the class is disabled and false otherwise
     */
    public Boolean isDisabledByClassName(String className) {
        if (this.isEverythingDisabled) {
            return true;
        }
        className = className.toUpperCase();
        return this.disabledTriggers.contains(className);
    }
}
