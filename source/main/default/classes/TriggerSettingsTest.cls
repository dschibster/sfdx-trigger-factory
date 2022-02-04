@isTest
public with sharing class TriggerSettingsTest {
    /**
     * If there are no other Trigger Settings than the Dummys, the Dummy will be enough
     * To fill the gap between TriggerHandlerExtension and what can't be covered by it.
     */

    static final String OBJECT_NAME_TO_TEST = 'TriggerSettings__c';
    static final String CLASS_NAME_TO_TEST = 'DummyClassName';

    @isTest
    static void getInstanceTest() {
        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = UserInfo.getUserId(), DisabledObjects__c = OBJECT_NAME_TO_TEST);
        insert newSettingForUser;
        TriggerSettings ts = TriggerSettings.getInstance();
        System.assert(ts.disabledObjects.size() > 0);
    }

    @isTest
    static void checkDisabledByObjectName() {
        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = UserInfo.getUserId(), DisabledObjects__c = OBJECT_NAME_TO_TEST);
        insert newSettingForUser;
        TriggerSettings ts = TriggerSettings.getInstance();
        System.assert(ts.isDisabledBySObjectType(((SObject) Type.forName(OBJECT_NAME_TO_TEST).newInstance()).getSObjectType()));
    }

    @isTest
    static void checkGeneralBlock() {
        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = UserInfo.getUserId(), DisableAllTriggers__c = true);
        insert newSettingForUser;
        System.assert(TriggerSettings.getInstance().isEveryThingDisabled);
    }

    @isTest
    static void checkDisabledByClassName() {
        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = UserInfo.getUserId(), DisabledHandlers__c = CLASS_NAME_TO_TEST);
        insert newSettingForUser;
        System.assert(TriggerSettings.getInstance().isDisabledByClassName(CLASS_NAME_TO_TEST));
    }
}
