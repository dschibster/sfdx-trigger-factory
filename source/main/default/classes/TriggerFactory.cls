public without sharing class TriggerFactory {
    @TestVisible
    private static Boolean hasReachedErrorLog = false;

    /**
     * @description Retrieves Handlers from Trigger Factory Setting and executes them by Order of Execution
     * @author mindsquare AG
     * @param  objType The Object Type of the Trigger you are calling.
     * @throws TriggerException when there is no Trigger Factory Setting or no class found.
     */

    public static void executeTriggerHandlers(Schema.SObjectType objType) {
        List<TriggerHandlerExtension> handlers = getHandlers(objType);

        if (handlers.size() == 0) {
            System.debug(LoggingLevel.ERROR, 'No Trigger Handler registered or all Triggers disabled for Object Type: ' + objType);
            hasReachedErrorLog = true;
            return;
        }

        for (TriggerHandlerExtension handler : handlers) {
            execute(handler);
        }
    }

    /**
     * @description Takes the Trigger execution methods from the retrieved Handlers and executes them. Starts with bulkBefore / bulkAfter and then goes into single-record methods
     * @author mindsquare AG
     * @param  handler The implementation of the Trigger Handler.
     */
    @TestVisible
    private static void execute(TriggerHandlerExtension handler) {
        if (handler.isDisabled() || handler.hasNoRecordsToProcess()) {
            return;
        }
        //Split the operationtype (for example AFTER_INSERT) into its two pieces to determine what we need.
        List<String> operations = handler.triggerContext.name().split('_');
        Boolean isBefore = operations[0] == 'BEFORE';
        String dmlOperation = operations[1];

        // Before Trigger
        if (isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            switch on dmlOperation {
                when 'DELETE' {
                    for (SObject obj : handler.triggerOldMap.values()) {
                        handler.beforeDelete(obj);
                    }
                }
                when 'INSERT' {
                    for (SObject obj : handler.triggerNew) {
                        handler.beforeInsert(obj);
                    }
                }
                when 'UPDATE' {
                    for (SObject obj : handler.triggerNew) {
                        handler.beforeUpdate(handler.triggerOldMap.get(obj.Id), obj);
                    }
                }
            }
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();

            switch on dmlOperation {
                when 'DELETE' {
                    for (SObject obj : handler.triggerOldMap.values()) {
                        handler.afterDelete(obj);
                    }
                }
                when 'INSERT' {
                    for (SObject obj : handler.triggerNew) {
                        handler.afterInsert(obj);
                    }
                }
                when 'UPDATE' {
                    for (SObject obj : handler.triggerNew) {
                        handler.afterUpdate(handler.triggerOldMap.get(obj.Id), obj);
                    }
                }
                when 'UNDELETE' {
                    for (SObject obj : handler.triggerNew) {
                        handler.afterUndelete(obj);
                    }
                }
            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    /**
     * @description retrieves a List of all Trigger Handlers that need to be executed for a given SObject Type. Returns an empty list if no Trigger Handler is registered.
     * @author mindsquare AG
     * @param  objType The SObject Type of the calling Trigger
     * @return A list of all Trigger Handlers of the currently calling Trigger's SObject Type.
     */
    @TestVisible
    private static List<TriggerHandlerExtension> getHandlers(Schema.SObjectType objType) {
        List<TriggerHandlerExtension> handlers = new List<TriggerHandlerExtension>();

        String objectName = objType.getDescribe().getName().toUpperCase();

        if (TriggerMapping.getInstance().mappedHandlers.containsKey(objectName)) {
            for (String className : TriggerMapping.getInstance().mappedHandlers.get(objectName)) {
                TriggerHandlerExtension handler = (TriggerHandlerExtension) Type.forName(className).newInstance();
                handler.handlerName = className;
                handler.triggerContext = Trigger.operationType;
                handlers.add(handler);
            }
        }

        return handlers;
    }
}
