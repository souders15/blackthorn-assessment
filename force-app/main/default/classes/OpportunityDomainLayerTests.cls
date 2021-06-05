@isTest
private class OpportunityDomainLayerTests {

    @TestSetup
    static void makeData(){
        Account a = new Account(Name = 'Test Account', CustomField__c = 'Something Important');
        insert a;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() - 7;
        opp.StageName = 'Prospecting';
        opp.AccountId = a.Id;
        insert opp;
    }
    @isTest
    private static void testOppLogic(){
        Opportunity opp = [SELECT Id, StageName, CustomField__c FROM Opportunity LIMIT 1];

        //preflight
        System.assertEquals(null, opp.CustomField__c, 'Custom Field should not be set on insert');
        System.assertEquals('Prospecting', opp.StageName, 'StageName should not be updated on insert');

        opp.Name = 'Test Opp Update';
        update opp;

        Opportunity updatedOpp = [SELECT Id, StageName, CustomField__c FROM Opportunity LIMIT 1];

        System.assertEquals('Something Important', updatedOpp.CustomField__c, 'Custom Field was not updated as expected.');
        System.assertEquals('Closed', updatedOpp.StageName, 'StageName was not marked closed when CloseDate has been reached.');

    }
}