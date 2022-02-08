public with sharing class PersonAccountHandler extends TriggerHandlerExtension {
    public static Boolean wasCalled = false;
    public PersonAccountHandler() {
        super();
    }

    public override void beforeInsert(SObject sobj) {
        TriggerHandlerExtensionTest.calledHandlers.add(this.handlerName);
        Account acc = (Account) sobj;
        acc.Name = 'person ' + acc.Name;
    }

    public override void beforeUpdate(SObject sobj, SObject sobj2) {
        TriggerHandlerExtensionTest.calledHandlers.add(this.handlerName);
        wasCalled = true;
    }
}
