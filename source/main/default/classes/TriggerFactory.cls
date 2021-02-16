/****************************************************************************************************
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 *****************************************************************************************************/
public without sharing class TriggerFactory {

	/**
	 * Public static method to create and execute a trigger handler
	 *
	 * Arguments:	Schema.SObjectType objType - Object type to process (SObject.SObjectType)
	 *
	 * Throws a TriggerException if no handler has been coded.
	 */
	public static void executeTriggerHandlers(Schema.SObjectType objType) {
		// Get a handler appropriate to the object being processed
		List<ITrigger> handlers = getHandlers(objType);
		
		if(handlers.size() == 0){
			throw new TriggerException('No Trigger Handler registered for Object Type: ' + objType);
		}
		// Execute the handlers to fulfil the trigger
		for(ITrigger handler : handlers){
			execute(handler);
		}
	}
	
	/**
	 * private static method to control the execution of the handler
	 *
	 * Arguments:	ITrigger handler - A Trigger Handler to execute
	 */	
	private static void execute(ITrigger handler) {
		if(!handler.isDisabled()){
			// Before Trigger
			if (Trigger.isBefore) {
				// Call the bulk before to handle any caching of data and enable bulkification
				handler.bulkBefore();
				
				// Iterate through the records to be deleted passing them to the handler.
				if (Trigger.isDelete) {
					for (SObject obj : Trigger.old) {
						handler.beforeDelete(obj);
					}
				}
				// Iterate through the records to be inserted passing them to the handler.
				else if (Trigger.isInsert) {
					for (SObject obj : Trigger.new) {
						handler.beforeInsert(obj);
					}
				}
				// Iterate through the records to be updated passing them to the handler.
				else if (Trigger.isUpdate) {
					for (SObject obj : Trigger.old) {
						handler.beforeUpdate(obj, Trigger.newMap.get(obj.Id));
					}
				}
			} else {
				// Call the bulk after to handle any caching of data and enable bulkification
				handler.bulkAfter();
				
				// Iterate through the records deleted passing them to the handler.
				if (Trigger.isDelete) {
					for (SObject obj : Trigger.old) {
						handler.afterDelete(obj);
					}
				}
				// Iterate through the records inserted passing them to the handler.
				else if (Trigger.isInsert) {
					for (SObject obj : Trigger.new) {
						handler.afterInsert(obj);
					}
				}
				// Iterate through the records updated passing them to the handler.
				else if (Trigger.isUpdate) {
					for (SObject obj : Trigger.old) {
						handler.afterUpdate(obj, Trigger.newMap.get(obj.Id));
					}
				}
			}
		
			// Perform any post processing
			handler.andFinally();
		}
	}
	
	/**
	 * private static method to get the appropriate handler for the object type.
	 * Modify this method to add any additional handlers.
	 *
	 * Arguments:	Schema.SObjectType objType - Object type tolocate (SObject.SObjectType)
	 *
	 * Returns:		ITrigger - A trigger handler if one exists or null.
	 */
	private static List<ITrigger> getHandlers(Schema.SObjectType objType) {
		
		List<ITrigger> handlers = new List<ITrigger>();

		for(String className : TriggerMapping.getInstance().get(objType.getDescribe().getName().toUpperCase())){
			handlers.add((ITrigger) Type.forName(className).newInstance());
		}

		return handlers;
	}
	
	/**
	 * Class TriggerException
	 *
	 * Used to instantiate custom Trigger Handler Exceptions.
	 */
	public class TriggerException extends Exception {}
}