public with sharing class CustomEventControlHandler {
    /**
    * @method updateEvent
    * @description updates the native salesforce event when the custom event is modified
    * @test EventDomainLayer.testUpdateEvent
	*/
    public static void updateEvent(Map<Id, Custom_Event__c> triggerNewMap){
		List<Event> eventsToCreate = new List<Event>();
        for(Custom_Event__c e : triggerNewMap.values()){
            Event evt = new Event();
            //This is the field mapping for the custom event & native event
            evt.StartDateTime = e.Event_Start__c;
            evt.EndDateTime = e.Event_End__c;
            evt.Subject = e.Name;
            evt.WhatId = e.Id;
            eventsToCreate.add(evt);
        }

        CheckRecursion.updatedEvents.addAll(triggerNewMap.keyset());
        insert eventsToCreate;
    }

    /**
     * @method updateEvent
     * @description handles sync between event and custom event when the custom event is updated
     */
    public static void updateEvent(Map<Id, Custom_Event__c> triggerNewMap, Map<Id, Custom_Event__c> triggerOldMap){
        //Check previously updated native events
        Set<Id> updatedEvents = CheckRecursion.updatedEvents;
        //Ids of all changed events
        Set<Id> changedEvents = new Set<Id>();
        for(Custom_Event__c e : triggerNewMap.values()){
            //Check for changed custom events that have not already updated (prevent recursion)
            if((e.Event_Start__c != triggerOldMap.get(e.Id).Event_Start__c || e.Event_End__c != triggerOldMap.get(e.Id).Event_End__c || e.Name != triggerOldMap.get(e.Id).Name) && !updatedEvents.contains(e.Id)){
                changedEvents.add(e.Id);
            }
        }

        if(changedEvents.size() > 0){
            //Holds native events keyed by the custom event id
            Map<Id, Event> eventMap = new Map<Id, Event>();

            for(Event evt : [SELECT Id, WhatId FROM Event WHERE WhatId IN: changedEvents]){
                eventMap.put(evt.WhatId, evt);
            }

            for(Id customEventId : eventMap.keyset()){
                //Update the related event for each updated custom event
                Event evt = eventMap.get(customEventId);
                Custom_Event__c ce = triggerNewMap.get(customEventId);
                //This is the field mapping for the custom event & native event
                evt.StartDateTime = ce.Event_Start__c;
                evt.EndDateTime = ce.Event_End__c;
                evt.Subject = ce.Name;

                eventMap.put(customEventId, evt);
            }
            //Must be added prior to dml call to prevent recusion
            CheckRecursion.updatedEvents.addAll(eventMap.keyset());
            //Finally update our events
            update eventMap.values();

        }
    }
    
}