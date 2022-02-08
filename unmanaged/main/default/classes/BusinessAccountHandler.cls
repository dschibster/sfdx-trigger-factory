public with sharing class BusinessAccountHandler extends TriggerHandlerExtension {
    public BusinessAccountHandler() {
        super();
    }

    public override void beforeInsert(SObject sobj) {
        Account acc = (Account) sobj;
        acc.Name = 'business ' + acc.Name;
    }
}
