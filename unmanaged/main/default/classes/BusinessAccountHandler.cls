public with sharing class BusinessAccountHandler extends TriggerHandlerExtension {
    public static Boolean wasCalled = false;
    public BusinessAccountHandler() {
        super();
    }

    public override void beforeInsert(SObject sobj) {
        TriggerHandlerExtensionTest.calledHandlers.add(this.handlerName);
        Account acc = (Account) sobj;
        acc.Name = 'business ' + acc.Name;
    }

    public override void beforeUpdate(SObject sobj, SObject sobj2) {
        TriggerHandlerExtensionTest.calledHandlers.add(this.handlerName);
    }
}
