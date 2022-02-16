# Order of Execution
## Standard Order

This assumes that all contexts are referenced in the Apex Trigger that calls `executeTriggerHandlers`.
* Starting Point: DML Statement is fired
  * **BEFORE CONTEXT**
    * Trigger Handler is instantiated once, constructor is called
    * `bulkBefore()` is called
    * `beforeUpdate(), beforeInsert(), or beforeDelete()` is called
    * `andFinally()` is called
  * **AFTER CONTEXT**
    * Trigger Handler is instantiated another time, constructor is called again
    * `bulkAfter()` is called
    * `afterUpdate(), afterInsert(), or afterDelete()` is called
    * `andFinally()` is called a second time

Commit is finalized only after all of these actions have been executed.  

## Multiple Handlers
This process looks like this across more than one Trigger Handler:

* Trigger Handler 1
  * BEFORE CONTEXT
* Trigger Handler 2
  * BEFORE CONTEXT
* Trigger Handler 3
  * BEFORE CONTEXT
* Trigger Handler 1
  * AFTER CONTEXT
* Trigger Handler 2
  * AFTER CONTEXT
* Trigger Handler 3
  * AFTER CONTEXT