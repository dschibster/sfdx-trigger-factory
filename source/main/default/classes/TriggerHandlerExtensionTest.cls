@IsTest
private class TriggerHandlerExtensionTest {

	private static Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();

	@isTest static void triggerDisabledByObject_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
    	System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
    	
		TriggerSettings.getInstance().disabledClassesAndObjects.add('ACCOUNT');
		
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert(handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}  
	}

	@isTest static void objectDisabledForProfile_positive_methodTest(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
    	System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerSetting__mdt setting = new TriggerSetting__mdt(SObjectName__c = 'Account', ProfileNamesIds__c = 'Standard User', IsDisabled__c = true);
		TriggerSettings ts = TriggerSettings.getInstance();
		TriggerSettings.getInstance().addStringsToMap(ts.disabledTriggerMapBySObjectType, setting, 'SObjectName__c');
		
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert(handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}  
	}

	@isTest static void objectDisabledForUser_positive_methodTest(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
    	System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		
		
		System.runAs(objUser) {
			TriggerSetting__mdt setting = new TriggerSetting__mdt(SObjectName__c = 'Account', UserNamesIds__c = UserInfo.getUserId(), IsDisabled__c = true);
			TriggerSettings ts = TriggerSettings.getInstance();
			TriggerSettings.getInstance().addStringsToMap(ts.disabledTriggerMapBySObjectType, setting, 'SObjectName__c');

			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert(handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}  
	}

	@isTest static void objectDisabled_positive_methodTest(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
    	System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerSetting__mdt setting = new TriggerSetting__mdt(SObjectName__c = 'Account', IsDisabled__c = true);
		TriggerSettings ts = TriggerSettings.getInstance();
		TriggerSettings.getInstance().addStringsToMap(ts.disabledTriggerMapBySObjectType, setting, 'SObjectName__c');
		
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert(handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}  
	}

	@isTest static void triggerDisabledByObject_negative(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
    	System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( !handlerExtension.isDisabled , 'Trigger is disabled' );    
    	}  
	}

	@isTest static void objectDisabledByUser_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerSettings.getInstance().disabledTriggerMapBySObjectType.put('ACCOUNT', new Set<String>());
		TriggerSettings.getInstance().disabledTriggerMapBySObjectType.get('ACCOUNT').add(String.valueOf(objUser.Id).toUpperCase());

					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}  
	}

	@isTest static void objectDisabledByApex_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerHandlerExtension.disableObject(Account.SObjectType);
					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}
	}

	@isTest static void objectDisabledByApex_negative(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerHandlerExtension.disableObject(Account.SObjectType);
		TriggerHandlerExtension.enableObject(Account.SObjectType);

					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( !handlerExtension.isDisabled , 'Trigger is disabled' );    
    	}
	}

	@isTest static void classDisabledByApex_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerHandlerExtension.disableClass('TriggerHandlerExtension');

					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert(handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}
	}

	@isTest static void classDisabledByApex_negative(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerHandlerExtension.disableClass('TriggerHandlerExtension');
		TriggerHandlerExtension.enableClass('TriggerHandlerExtension');


					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( !handlerExtension.isDisabled , 'Trigger is disabled' );    
    	}
	}

	@isTest static void objectDisabledByProfile_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerSettings.getInstance().disabledTriggerMapBySObjectType.put('ACCOUNT', new Set<String>());
		TriggerSettings.getInstance().disabledTriggerMapBySObjectType.get('ACCOUNT').add('STANDARD USER');

					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}
	}

	@isTest static void classDisabledByProfile_positive(){
		Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
		}
		
		Database.SaveResult resultUserInsert = database.insert( objUser );
		System.assert( resultUserInsert.isSuccess() , 'Testuser insert has failed');
		
		TriggerSettings.getInstance().disabledTriggerMapByClassName.put('TRIGGERHANDLEREXTENSION', new Set<String>());
		TriggerSettings.getInstance().disabledTriggerMapByClassName.get('TRIGGERHANDLEREXTENSION').add('STANDARD USER');

					
		System.runAs(objUser) {
			TriggerHandlerExtension handlerExtension = new TriggerHandlerExtension();
			handlerExtension.sObjType = Account.SObjectType;
			handlerExtension.isDisabled = handlerExtension.isDisabled();
	        // check if DML Lists are initialized
	        System.assert( handlerExtension.lstInsert != null , 'lstInsert is NULL' );
	        System.assert( handlerExtension.lstUpsert != null , 'lstUpsert is NULL' );
	        System.assert( handlerExtension.lstUpdate != null , 'lstUpdate is NULL' );
	        System.assert( handlerExtension.lstDelete != null , 'lstDelete is NULL' );
	        
	        // check if Trigger is disabled
	        System.assert( handlerExtension.isDisabled , 'Trigger is enabled' );    
    	}
	}

	@isTest static void triggerRecursionTest() {
    	
    	Profile objProfile = [SELECT Id, Name FROM profile WHERE name = 'Standard User'];
        User objUser = new User(alias = 'alias', email='mail@mail.de', emailencodingkey='ISO-8859-1', lastname='Tester', languagelocalekey='en_US', localesidkey='en_US', profileid = objProfile.Id, username='username@user.de', TimeZoneSidKey='Europe/Berlin');
		if(isMultiCurrency){
			objUser.put('CurrencyIsoCode','EUR');
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
    		System.assertEquals(String.valueOf(handlerExtension).substring(0,String.valueOf(handlerExtension).indexOf(':')), handlerName, 'handler name is wrong');
    		 
    		// check depth of loopControll
    		Integer maxTriggerLoops = TriggerHandlerExtension.loopCountMap.get(handlerName).max;
			System.assertEquals( 1, maxTriggerLoops);
			
			// check depth of loopControll
    		Integer triggerLoopCount = TriggerHandlerExtension.loopCountMap.get(handlerName).count;
			System.assertEquals( 0, triggerLoopCount);
			
			// set max recursion to depth of 2
    		handlerExtension.setMaxLoopCount(2);
    		
    		// check depth of loopControll
    		maxTriggerLoops = TriggerHandlerExtension.loopCountMap.get(handlerName).max;
			System.assertEquals( 2, maxTriggerLoops);   		
    			        
	        // check if Trigger is enabled
	        System.assert( !handlerExtension.isDisabled , 'Trigger is disabled' );  
	        
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
	        System.assert( hasRecursionException , 'No recursion exception has been thrown' );
	        
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
	        System.assert( !hasRecursionException , 'Recursion exception has been thrown' );
    	}    	
	}

	


}