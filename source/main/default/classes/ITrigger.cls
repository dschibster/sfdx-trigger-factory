/****************************************************************************************************
 * Interface ITrigger
 *
 *   Create By	:   Patrick Holder (mindsquare GmbH)
 *   Create Date	:   10.10.2017
 *   Description	:	Interface containing methods Trigger Handlers must implement to enforce best practice
 * 					and bulkification of triggers.
 *
 *   Modification Log:
 *   -------------------------------------------------------------------------------------------------
 *   * Developer                        	Date             	Description
 *   * -----------------------------------------------------------------------------------------------                 
 *   * Patrick Holder (mindsquare GmbH) 	10.10.2017       	Init version.
 *****************************************************************************************************/
public interface ITrigger {	
	
	/**
	 * isDisabled
	 *
	 * This method is called to check Trigger Settings on trigger handler initialization to enable or disable the trigger. 
	 */
	Boolean isDisabled();
	
	/**
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	void bulkBefore();
	
	/**
	 * bulkAfter
	 *
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	void bulkAfter();
	
	/**
	 * beforeInsert
	 *
	 * This method is called iteratively for each record to be inserted during a BEFORE
	 * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
	 */
	void beforeInsert(SObject obj);
	
	/**
	 * beforeUpdate
	 *
	 * This method is called iteratively for each record to be updated during a BEFORE
	 * trigger.
	 */
	void beforeUpdate(SObject oldObj, SObject obj);

	/**
	 * beforeDelete
	 *
	 * This method is called iteratively for each record to be deleted during a BEFORE
	 * trigger.
	 */
	void beforeDelete(SObject obj);

	/**
	 * afterInsert
	 *
	 * This method is called iteratively for each record inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The record is 'read only' by this point.
	 */
	void afterInsert(SObject obj);

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	void afterUpdate(SObject oldObj, SObject obj);

	/**
	 * afterDelete
	 *
	 * This method is called iteratively for each record deleted during an AFTER
	 * trigger.
	 */
	void afterDelete(SObject obj);

	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	void andFinally();
}