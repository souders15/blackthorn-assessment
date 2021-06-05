@isTest
private class EventDomainLayerTests {
//By no means a complete and comprehensive test suite but it achieves minimum viable for purposes of this assessment
    @TestSetup
    static void makeData(){
        Custom_Event__c evt = new Custom_Event__c(Name = 'My Event', Event_Start__c = System.now(), Event_End__c = System.now().addDays(1));
        insert evt;
    }

    @isTest
    private static void testEventSync(){
        //This could be much more robust and should also test negatives 
        List<Event> eventList = [SELECT Id, Subject, WhatId, EndDateTime FROM Event]; 

        System.assertEquals(1, eventList.size(), 'Incorrect number of events created');

        Event evt = eventList[0];
        evt.EndDateTime = eventList[0].EndDateTime.addDays(1);
        update evt;
        List<Custom_Event__c> ceList = [SELECT Id, Name, Event_Start__c, Event_End__c FROM Custom_Event__c];
        System.assertEquals(1, ceList.size(), 'Incorrect number of custom events created');
        System.assertEquals(evt.EndDateTime, ceList[0].Event_End__c, 'Event End was not updated by event');

        //Kind of hacky but doing this to refresh the static set. Refreshes as normal outside of the test, could also move this to a separate method to achieve same result
        CheckRecursion.updatedEvents.clear();
        Custom_Event__c ce = ceList[0];
        ce.Name = 'My Updated Event';
        update ce;
        

        eventList = [SELECT Id, Subject, WhatId, EndDateTime FROM Event]; 
        System.assertEquals('My Updated Event', eventList[0].Subject, 'Event subject was not updated by custom event');
    }
}