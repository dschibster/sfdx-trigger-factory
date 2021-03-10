public class TriggerUnitOfWork extends fflib_SObjectUnitOfWork{
    public TriggerUnitOfWork() {
        super(new List<SObjectType>());
    }

    public TriggerUnitOfWork(List<SObjectType> sobjectTypes){
        super(sobjectTypes);
    }

    public List<SObjectType> getSObjectTypeList(){
        return this.m_sObjectTypes;
    }

    public Boolean hasWork(){
        return !this.m_newListByType.isEmpty() || !this.m_dirtyMapByType.isEmpty() || !this.m_deletedMapByType.isEmpty() || !this.m_emptyRecycleBinMapByType.isEmpty() || !this.m_workList.isEmpty();
    }
}
