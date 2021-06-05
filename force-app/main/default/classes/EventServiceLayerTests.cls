@isTest
private class EventServiceLayerTests {

    @isTest
    private static void testRegistrationRest(){

        Custom_Event__c evt = new Custom_Event__c(Name = 'My Event', Event_Start__c = System.now(), Event_End__c = System.now().addDays(1), External_UUID__c = 'e8b9e17d-a3c6-433c-a6d0-81c13ec9449b');
        insert evt;

        Map<String, Object> obj = new Map<String, Object>();
        obj.put('first', 'timmy');
        obj.put('last', 'test');
        obj.put('email', 'timmy@test.example');
        obj.put('eventUUID', 'e8b9e17d-a3c6-433c-a6d0-81c13ec9449b');

        // MyClass reqst=new MyClass();
        String JsonMsg=JSON.serialize(obj);
        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Registration/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        EventRegistrationRest.postRegistration('timmy', 'test', 'timmy@test.example', 'e8b9e17d-a3c6-433c-a6d0-81c13ec9449b');

        //Could be more thorough here and create data with new method to test against, doing double post for brevity
        EventRegistrationRest.postRegistration('timmy', 'test', 'timmy@test.example', 'e8b9e17d-a3c6-433c-a6d0-81c13ec9449b');

        // update TestOpp;
        Test.stopTest();
        List<Event_Registration__c> registrations = [SELECT Id FROM Event_Registration__c];

        System.assertEquals(1, registrations.size(), 'Registration was not created');
    }
}