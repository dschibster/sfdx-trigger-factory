public with sharing class PersonAccountHandler extends TriggerHandlerExtension {
    public PersonAccountHandler() {
        super();
    }

    public override void beforeInsert(SObject sobj) {
        Account acc = (Account) sobj;
        acc.Name = 'person ' + acc.Name;
    }
}
