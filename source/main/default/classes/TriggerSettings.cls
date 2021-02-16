public without sharing class TriggerSettings {
    
    public Map<Id, Profile> profileMapById;
    @TestVisible private Map<String, Set<String>> disabledTriggerMapBySObjectType;
    @TestVisible private Map<String, Set<String>> disabledTriggerMapByClassName;
    @TestVisible private Set<String> disabledClassesAndObjects;

    public static TriggerSettings instance;

    public TriggerSettings(){

    }

    public static TriggerSettings getInstance(){
        if (instance == null){
            instance = new TriggerSettings();
            instance.load();
        }
        return instance;
    }

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