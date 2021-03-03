public without sharing class TriggerSettings {
    
    public Map<Id, Profile> profileMapById;
    @TestVisible private Map<String, Set<String>> disabledTriggerMapBySObjectType;
    @TestVisible private Map<String, Set<String>> disabledTriggerMapByClassName;
    @TestVisible private Set<String> disabledClassesAndObjects;

    public static TriggerSettings instance;

    public TriggerSettings(){

    }

    /**
     * @description Singleton Design Pattern method for TriggerSettings. For each control flow, this class only needs to be instantiated once. AFter that we are working with the same instance.
     * @author mindsquare AG
     * @return The currently instantiated instance of TriggerSettings
     */
    public static TriggerSettings getInstance(){
        if (instance == null){
            instance = new TriggerSettings();
            instance.load();
        }
        return instance;
    }


    /**
     * @description Loads all different possibilities of the currently running Trigger Handler to be disabled with Custom Metadata
     * @author mindsquare AG
     */
    public void load(){
        this.profileMapById = new Map<Id, Profile>([SELECT Id, Name FROM Profile]);
        this.disabledTriggerMapBySObjectType = new Map<String, Set<String>>();
        this.disabledTriggerMapByClassName = new Map<String, Set<String>>();
        this.disabledClassesAndObjects = new Set<String>();

        List<TriggerSetting__mdt> triggerSettings = [SELECT SObjectName__c, ClassName__c, UserNamesIds__c, ProfileNamesIds__c FROM TriggerSetting__mdt WHERE IsDisabled__c = true];

        for(TriggerSetting__mdt setting : triggerSettings){
            
            if(setting.SObjectName__c != null){
                addStringsToMap(this.disabledTriggerMapBySObjectType, setting, 'SObjectName__c');
            } else if(setting.ClassName__c != null){
                addStringsToMap(this.disabledTriggerMapByClassName, setting, 'ClassName__c');
            }
        }
    }

    /**
     * @description Checks if all Triggers of a certain SObject are disabled.
     * @author mindsquare AG
     * @param sobjType the SObject Type you want to check against (normally run directly in the Trigger Handler constructor)
     * @return          The result is true if there is any indication that the SObject is disabled and false otherwise
     */
    public Boolean isDisabledBySObjectType(SObjectType sobjType){
        String sobjectName = sobjType.getDescribe().getName().toUpperCase();

        return this.disabledClassesAndObjects.contains(sobjectName) 
        || (this.disabledTriggerMapBySObjectType.containsKey(sobjectName) &&
            (
                this.disabledTriggerMapBySObjectType.get(sobjectName).contains(UserInfo.getUserId().toUpperCase())
                || this.disabledTriggerMapBySObjectType.get(sobjectName).contains(UserInfo.getUserName().toUpperCase())
                || this.disabledTriggerMapBySObjectType.get(sobjectName).contains(UserInfo.getProfileId().toUpperCase())
                || this.disabledTriggerMapBySObjectType.get(sobjectName).contains(this.profileMapById.get(UserInfo.getProfileId()).Name.toUpperCase())
            )
        );
    }

    /**
     * @description Checks if the execution of a certain class is disabled.
     * @author mindsquare AG
     * @param className The class name of the Trigger Handler currently running
     * @return          The result is true if there is any indication that the class is disabled and false otherwise
     */
    public Boolean isDisabledByClassName(String className){
        className = className.toUpperCase();

        return this.disabledClassesAndObjects.contains(className)  
            || (this.disabledTriggerMapByClassName.containsKey(className) && 
                (
                    this.disabledTriggerMapByClassName.get(className).contains(UserInfo.getUserId().toUpperCase())
                    || this.disabledTriggerMapByClassName.get(className).contains(UserInfo.getUserName().toUpperCase())
                    || this.disabledTriggerMapByClassName.get(className).contains(UserInfo.getProfileId().toUpperCase())
                    || this.disabledTriggerMapByClassName.get(className).contains(this.profileMapById.get(UserInfo.getProfileId()).Name.toUpperCase())
                )
            );
    }

    /**
     * @description Puts the corresponsing fields of the Trigger Settings Custom Metadata into a Map for Profiles/Users or in a Set for things generally disabled
     * @author mindsquare AG
     * @param  disableMap The map that contains the correct type of disabling (object or class)
     * @param  setting    The Trigger Setting containing the relevant data.
     * @param  fieldName  The field name of the Trigger Setting that contains the correct data (object name or class name)
     */
    @TestVisible 
    private void addStringsToMap(Map<String, Set<String>> disableMap, TriggerSetting__mdt setting, String fieldName){
        String objectOrClass = (String) setting.get(fieldName);
        objectOrClass = objectOrClass.toUpperCase();
        if(!disableMap.containsKey(objectOrClass)){
            disableMap.put(objectOrClass, new Set<String>());
        }
        if(setting.UserNamesIds__c != null){
            disableMap.get(objectOrClass).addAll(setting.UserNamesIds__c.toUpperCase().split(','));
        }
        if(setting.ProfileNamesIds__c != null){
            disableMap.get(objectOrClass).addAll(setting.ProfileNamesIds__c.toUpperCase().split(','));
        }
        if(setting.ProfileNamesIds__c == null && setting.UserNamesIds__c == null){
            this.disabledClassesAndObjects.add(objectOrClass);
        }

    }

}