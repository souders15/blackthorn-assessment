//Note: logic should also be moved to an apex class that is called by the trigger
trigger OpportunityControl on Opportunity (before update) {

    if(Trigger.isBefore){
        Set<Id> accountIds = new Set<Id>();
        //Assuming this record type does exist
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'renewal' AND sObjectType = 'Opportunity' LIMIT 1];
        for(Opportunity p : Trigger.New){
            accountIds.add(p.AccountId);
            if(p.CloseDate < System.today()){
                p.StageName='Closed';
                p.RecordTypeId = rt.Id;
            }
        }
        if(accountIds.size() > 0){
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, CustomField__c FROM Account WHERE Id IN: accountIds]);
            for(Opportunity p : Trigger.New){
                p.CustomField__c= accountMap.get(p.AccountId)?.CustomField__c;
            }
        }
    }
}