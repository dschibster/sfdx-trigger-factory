/****************************************************************************************************
 * Trigger Handler Extension for Trigger Handler. This class help ensure that all
 * generic methodes are in one place.
 *****************************************************************************************************/
public virtual without sharing class TriggerHandlerExtension implements ITrigger{
    
    public Schema.sObjectType sObjType;    
    public Boolean isDisabled;
	public static Set<SObjectType> disabledObjects = new Set<SObjectType>();
	public static Set<String> disabledClasses = new Set<String>();
    @TestVisible  
	private static Map<String, LoopCount> loopCountMap;

  	// static map
  	static {
    	loopCountMap = new Map<String, LoopCount>();
  	}
    
    public List<sObject> lstInsert;
	public List<sObject> lstUpsert;
	public List<sObject> lstUpdate;
	public List<sObject> lstDelete;

	/**
        * bulkBefore
        *
        * This method is called prior to execution of a BEFORE trigger. Use this to cache
        * any data required into maps prior execution of the trigger.
        */
	virtual public void bulkBefore(){}

	/**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
	virtual public void bulkAfter(){}

	/**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
	virtual public void beforeInsert(SOBject newSObj){}

	/**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
	virtual public void beforeUpdate(SOBject oldSObj, SOBject newSObj){}

	/**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
	virtual public void beforeDelete(SOBject oldSObj){}

	/**
	 * afterInsert
	 *
	 * This method is called iteratively for each record inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The record is 'read only' by this point.
	 */
	virtual public void afterInsert(SOBject newSObj){}

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	virtual public void afterUpdate(SOBject oldSObj, SOBject newSObj){}

	/**
	 * afterDelete
	 *
	 * This method is called iteratively for each record deleted during an AFTER
	 * trigger.
	 */
	virtual public void afterDelete(SOBject oldSObj){}

	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	virtual public void andFinally(){}
	
    // Constructor
    public TriggerHandlerExtension(){
    	if(Trigger.isExecuting){
			this.sObjType = Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();
			this.isDisabled = isDisabled();
			if(Trigger.isBefore){
				addToLoopCount();
			}
		}
    	    	
    	lstInsert = new List<sObject>();
    	lstUpsert = new List<sObject>();    
    	lstUpdate = new List<sObject>(); 
    	lstDelete = new List<sObject>();
	}
	

    
    /**
	 * isDisabled
	 *
	 * This method is called to check Trigger Settings on trigger handler initialization to enable or disable the trigger. 
	 */
	@TestVisible 
	public virtual Boolean isDisabled() {	
		TriggerSettings ts = TriggerSettings.getInstance();
		String className = getHandlerName();

		return disabledObjects.contains(this.sObjType) || disabledClasses.contains(className.toUpperCase()) || ts.isDisabledBySObjectType(this.sObjType) || ts.isDisabledByClassName(className);
    }
    
    /**
	 * getHandlerName
	 *
	 * This method is called to get Trigger Handler-Name to register the Handler for the loopCount controlling. 
	 */
    @TestVisible 
	private String getHandlerName() {
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}

	public static void disableObject(SObjectType sobjectType){
		disabledObjects.add(sobjectType);
	}

	public static void enableObject(SObjectType sobjectType){
		disabledObjects.remove(sobjectType);
	}

	public static void disableClass(String className){
		disabledClasses.add(className.toUpperCase());
	}

	public static void enableClass(String className){
		disabledClasses.remove(className.toUpperCase());
	}
	
	/**
	 * setMaxLoopCount
	 *
	 * This method is called to set the max loop for the Trigger Handler. 
	 */
	public void setMaxLoopCount(Integer max) {
    	String handlerName = getHandlerName();
    	if(!TriggerHandlerExtension.loopCountMap.containsKey(handlerName)) {
    		TriggerHandlerExtension.loopCountMap.put(handlerName, new LoopCount(max));
    	} else {
    		TriggerHandlerExtension.loopCountMap.get(handlerName).setMax(max);
    	}
  	}
	
	/**
	 * clearMaxLoopCount
	 *
	 * This method is called to clear the max loop for the Trigger Handler. 
	 */
	public void clearMaxLoopCount() {
		this.setMaxLoopCount(-1);
	}
    
    /**
	 * clearMaxLoopCount
	 *
	 * This method is called for increment the loop count.
	 */
 	@TestVisible
  	protected void addToLoopCount() {
		String handlerName = getHandlerName();			
		if(TriggerHandlerExtension.loopCountMap.containsKey(handlerName)) {
			Boolean exceeded = TriggerHandlerExtension.loopCountMap.get(handlerName).increment();		  
		  	if(exceeded) {
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
			if(this.max < 0) return false;
	      	if(this.count > this.max) {
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
  	public class TriggerHandlerException extends Exception {}

}