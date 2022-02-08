@IsTest
private class TriggerHandlerExtensionTest {
    private static Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
    public static Set<String> calledHandlers = new Set<String>(); //used to benchmark which trigger handlers were called between filtered RecordTypes

    @isTest
    static void disabledInApex_Object_positive() {
        TriggerHandlerExtension.disableObject(Account.SObjectType);
        TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
        handlerExtension.sObjType = Account.SObjectType;
        handlerExtension.isDisabled = handlerExtension.isDisabled();

        System.assert(handlerExtension.isDisabled, 'Object was not disabled');

        TriggerHandlerExtension.enableObject(Account.SObjectType);
        handlerExtension.isDisabled = handlerExtension.isDisabled();

        System.assert(!handlerExtension.isDisabled, 'Object was not enabled after disabling');
    }

    @isTest
    static void disabledInApex_Class_positive() {
        TriggerHandlerExtension.disableClass('TriggerHandlerExtension');
        TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
        handlerExtension.sObjType = Account.SObjectType;
        handlerExtension.isDisabled = handlerExtension.isDisabled();

        System.assert(handlerExtension.isDisabled, 'Class was not disabled');

        TriggerHandlerExtension.enableClass('TriggerHandlerExtension');
        handlerExtension.isDisabled = handlerExtension.isDisabled();

        System.assert(!handlerExtension.isDisabled, 'Class was not enabled after disabling');
    }

    @isTest
    static void disabledForProfile_Object_positive() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objProfile.Id, DisabledObjects__c = 'Account');
        insert newSettingForUser;

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
        }
    }

    @isTest
    static void disabledForProfile_Object_negative() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(!handlerExtension.isDisabled, 'Trigger is disabled^');
            System.assert(TriggerSettings.getInstance().disabledObjects.isEmpty());
        }
    }

    @isTest
    static void disabledForUser_Object_positive() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objProfile.Id, DisabledObjects__c = 'Account');
            insert newSettingForUser;

            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
        }
    }

    @isTest
    static void disabledForUser_Object_negative() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(!handlerExtension.isDisabled, 'Trigger is disabled');
            System.assert(TriggerSettings.getInstance().disabledObjects.isEmpty());
        }
    }

    @isTest
    static void disabledForProfile_Class_positive() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objProfile.Id, DisabledHandlers__c = 'TriggerHandlerExtension');
        insert newSettingForUser;

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            /* check if Trigger is disabled */
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
        }
    }

    @isTest
    static void disabledForProfile_Class_negative() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(!handlerExtension.isDisabled, 'Trigger is disabled');
            System.assert(TriggerSettings.getInstance().disabledTriggers.isEmpty());
        }
    }

    @isTest
    static void disabledForUser_Class_positive() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objUser.Id, DisabledHandlers__c = 'TriggerHandlerExtension');
            insert newSettingForUser;

            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
        }
    }

    @isTest
    static void disabledForUser_Class_negative() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(!handlerExtension.isDisabled, 'Trigger is disabled');
            System.assert(TriggerSettings.getInstance().disabledTriggers.isEmpty());
        }
    }

    @isTest
    static void disableForUser_everything() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objUser.Id, DisableAllTriggers__c = true);
            insert newSettingForUser;

            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
            System.assert(TriggerSettings.getInstance().isEverythingDisabled);
        }
    }

    @isTest
    static void disableForProfile_everything() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        TriggerSettings__c newSettingForUser = new TriggerSettings__c(SetupOwnerId = objProfile.Id, DisableAllTriggers__c = true);
        insert newSettingForUser;

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        Database.SaveResult resultUserInsert = database.insert(objUser);
        System.assert(resultUserInsert.isSuccess(), 'Testuser insert has failed');

        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();
            // check if DML Lists are initialized
            System.assert(handlerExtension.lstInsert != null, 'lstInsert is NULL');
            System.assert(handlerExtension.lstUpsert != null, 'lstUpsert is NULL');
            System.assert(handlerExtension.lstUpdate != null, 'lstUpdate is NULL');
            System.assert(handlerExtension.lstDelete != null, 'lstDelete is NULL');

            // check if Trigger is disabled
            System.assert(handlerExtension.isDisabled, 'Trigger is enabled');
            System.assert(TriggerSettings.getInstance().isEverythingDisabled);
        }
    }

    @isTest
    static void triggerRecursionTest() {
        Profile objProfile = [SELECT Id, Name FROM profile WHERE Name LIKE '%Admin%' LIMIT 1];

        User objUser = new User(
            alias = 'alias',
            email = 'mail@mail.de',
            emailencodingkey = 'ISO-8859-1',
            lastname = 'Tester',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = objProfile.Id,
            username = 'username@user.de',
            TimeZoneSidKey = 'Europe/Berlin'
        );
        if (isMultiCurrency) {
            objUser.put('CurrencyIsoCode', 'EUR');
        }

        // runTest
        System.runAs(objUser) {
            TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
            handlerExtension.sObjType = Account.SObjectType;
            handlerExtension.isDisabled = handlerExtension.isDisabled();

            // set max recursion to depth of 1
            handlerExtension.setMaxLoopCount(1);

            // check if handlername-check is right
            String handlerName = handlerExtension.getHandlerName();
            System.assertEquals(
                String.valueOf(handlerExtension).substring(0, String.valueOf(handlerExtension).indexOf(':')),
                handlerName,
                'handler name is wrong'
            );

            // check depth of loopControll
            Integer maxTriggerLoops = TriggerHandlerExtension.loopCountMap.get(handlerName).max;
            System.assertEquals(1, maxTriggerLoops);

            // check depth of loopControll
            Integer triggerLoopCount = TriggerHandlerExtension.loopCountMap.get(handlerName).count;
            System.assertEquals(0, triggerLoopCount);

            // set max recursion to depth of 2
            handlerExtension.setMaxLoopCount(2);

            // check depth of loopControll
            maxTriggerLoops = TriggerHandlerExtension.loopCountMap.get(handlerName).max;
            System.assertEquals(2, maxTriggerLoops);

            // check if Trigger is enabled
            System.assert(!handlerExtension.isDisabled, 'Trigger is disabled');

            // simulate the first trigger handler run
            handlerExtension.addToLoopCount();

            // simulate the second trigger handler run
            handlerExtension.addToLoopCount();

            // simulate the third trigger handler run
            Boolean hasRecursionException;
            try {
                handlerExtension.addToLoopCount();
                hasRecursionException = false;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                hasRecursionException = true;
            }

            // check if recursion exception have been thrown
            System.assert(hasRecursionException, 'No recursion exception has been thrown');

            // clear Recursion counter
            handlerExtension.clearMaxLoopCount();

            // simulate the third trigger handler run
            try {
                handlerExtension.addToLoopCount();
                hasRecursionException = false;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                hasRecursionException = true;
            }

            // check if recursion exception have been thrown
            System.assert(!hasRecursionException, 'Recursion exception has been thrown');
        }
    }

    @isTest
    static void testRecordTypeFilter() {
        //First we need to make sure that the correct Record Type Ids are in use, as these will differ on new Scratch Orgs.
        Id personAccountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account').getRecordTypeId();
        Id businessAccountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();

        TriggerMapping.getInstance().recordTypeFilter.put('PersonAccountHandler', new Set<Id>(new List<Id>{ personAccountRecordTypeId }));
        TriggerMapping.getInstance().recordTypeFilter.put('BusinessAccountHandler', new Set<Id>(new List<Id>{ businessAccountRecordTypeId }));

        //Now we can create two Accounts and check that they are only calling the respective Trigger Handler function

        Account acc = new Account(Name = 'Test Person Account', RecordTypeId = personAccountRecordTypeId);
        insert acc;
        System.assert(calledHandlers.contains('PersonAccountHandler'), 'Person Account Handler was not called');
        System.assert(!calledHandlers.contains('BusinessAccountHandler'), 'beforeInsert Method for Business Account Handler was called for Person Account');

        //When the Account is updated, only the new Record Type is relevant.
        acc.RecordTypeId = businessAccountRecordTypeId;
        calledHandlers = new Set<String>();
        update acc;
        System.assert(calledHandlers.contains('BusinessAccountHandler'), 'Business Account Handler was not called');
        System.assert(!calledHandlers.contains('PersonAccountHandler'), 'beforeUpdate Method for Person Account Handler was called for Business Account');

        //The last two checks are done mostly for coverage, as the two examples make it clear that the filter is working.
        delete acc;
        undelete acc;
    }
}
