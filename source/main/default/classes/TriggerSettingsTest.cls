@isTest
public with sharing class TriggerSettingsTest {

    /**
     * If there are no other Trigger Settings than the Dummys, the Dummy will be enough
     * To fill the gap between TriggerHandlerExtension and what can't be covered by it.
     */
    
    static final String OBJECT_NAME_TO_TEST = 'TriggerSetting__mdt';
    static final String CLASS_NAME_TO_TEST = 'DummyClassName';
    
     @isTest static void getInstanceTest(){
         TriggerSettings ts = TriggerSettings.getInstance();
         System.assert(ts.disabledClassesAndObjects.size() > 0);
     }

     @isTest static void checkDisabledByObjectName(){
        TriggerSettings ts = TriggerSettings.getInstance();
        System.assert(ts.isDisabledBySObjectType(((SObject) Type.forName(OBJECT_NAME_TO_TEST).newInstance()).getSObjectType()));
    }

    @isTest static void checkDisabledByObjectName_withoutGeneralBlock(){
        TriggerSettings ts = TriggerSettings.getInstance();
        ts.disabledClassesAndObjects.remove(OBJECT_NAME_TO_TEST.toUpperCase());
        System.assert(ts.disabledTriggerMapBySObjectType.containsKey(OBJECT_NAME_TO_TEST.toUpperCase()));
    }

    @isTest static void checkDisabledByClassName(){
        TriggerSettings ts = TriggerSettings.getInstance();
        System.assert(ts.disabledTriggerMapByClassName.containsKey(CLASS_NAME_TO_TEST.toUpperCase()));
    }
}