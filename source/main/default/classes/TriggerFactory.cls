
public without sharing class TriggerFactory {

	/**
	 * @description Retrieves Handlers from Trigger Factory Setting and executes them by Order of Execution
	 * @author mindsquare AG
	 * @param  objType The Object Type of the Trigger you are calling.
	 * @throws TriggerException when there is no Trigger Factory Setting or no class found.
	 */
	
	public static void executeTriggerHandlers(Schema.SObjectType objType) {
		List<ITrigger> handlers = getHandlers(objType);
		
		if(handlers.size() == 0){
			throw new TriggerException('No Trigger Handler registered for Object Type: ' + objType);
		}
		
		for(ITrigger handler : handlers){
			execute(handler);
		}
	}
	
	/**
	 * @description Takes the Trigger execution methods from the retrieved Handlers and executes them. Starts with bulkBefore / bulkAfter and then goes into single-record methods
	 * @author mindsquare AG
	 * @param  handler The implementation of the Trigger Handler.
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
	 * @description retrieves a List of all Trigger Handlers that need to be executed for a given SObject Type. Returns an empty list if no Trigger Handler is registered.
	 * @author mindsquare AG
	 * @param  objType The SObject Type of the calling Trigger
	 * @return A list of all Trigger Handlers of the currently calling Trigger's SObject Type. 
	 */
	private static List<ITrigger> getHandlers(Schema.SObjectType objType) {
		
		List<ITrigger> handlers = new List<ITrigger>();

		String objectName = objType.getDescribe().getName().toUpperCase();

		if(TriggerMapping.getInstance().containsKey(objectName)){
			for(String className : TriggerMapping.getInstance().get(objectName)){
				handlers.add((ITrigger) Type.forName(className).newInstance());
			}
		}

		return handlers;
	}
	

	public class TriggerException extends Exception {}
}