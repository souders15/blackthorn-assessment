@isTest
private class LeadDomainLayerTests {

    @TestSetup
    static void makeData(){
        List<Lead> leadList = new List<Lead>();
        Lead l1= new Lead(FirstName = 'Test', LastName = 'Lead 1', Company = 'Test Company', Email = 'myEmail@example.com');
        leadList.add(l1);
        Lead l2 = new Lead(FirstName = 'Test', LastName = 'Lead 2', Company = 'Test Company', Email = 'myEmail@example.com');
        leadList.add(l2);
        insert leadList;
    }
    @isTest
    private static void testPreventDupes(){

        String errorMessage;
        //Get either lead, doesn't matter for this test
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        l.LastName = 'Update';
        try{
            update l;
        } catch(Exception e){
            errorMessage = e.getMessage();
        }
        System.assert(errorMessage.contains('Duplicate Lead!'));
    }
}