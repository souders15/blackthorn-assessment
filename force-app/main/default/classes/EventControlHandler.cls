public class EventControlHandler {
    /**
     * @method updateCustomEvent
     * @description syncs changes to subject, start & end with their respective fields on the related custom event
     */
    public static void updateCustomEvent(Map<Id, Event> triggerNewMap, Map<Id, Event> triggerOldMap){
        //Check previously updated native events
        Set<Id> updatedEvents = CheckRecursion.updatedEvents;
        //Events keyed by Custom Event Ids of all changed events 
        Map<Id, Event> changedEvents = new Map<Id, Event>(); //using a map here for easier retrieval later so that we don't need to do the field analysis or a separate collection
        for(Event e : triggerNewMap.values()){
            //Check for changed events that have not already updated (prevent recursion)
            if((e.StartDateTime != triggerOldMap.get(e.Id).StartDateTime || e.EndDateTime != triggerOldMap.get(e.Id).EndDateTime || e.Subject != triggerOldMap.get(e.Id).Subject) && !updatedEvents.contains(e.WhatId)){
                changedEvents.put(e.WhatId, e);
            }
        }

        if(changedEvents.size() > 0){
            //Holds custom events keyed by its id
            Map<Id, Custom_Event__c> customEventMap = new Map<Id, Custom_Event__c>([SELECT Id FROM Custom_Event__c WHERE Id IN: changedEvents.keyset()]);

            for(Id customEventId : customEventMap.keyset()){
                //Get our objects so that we aren't continually getting from map to update each field
                //Get source event that changed
                Event evt = changedEvents.get(customEventId);
                //Get custom event for updating
                Custom_Event__c ce = customEventMap.get(customEventId);
                //This is the field mapping for the custom event & native event
                ce.Event_Start__c = evt.StartDateTime;
                ce.Event_End__c = evt.EndDateTime;
                ce.Name = evt.Subject;

                customEventMap.put(customEventId, ce);
            }
            //Must be added prior to dml call to prevent recusion
            CheckRecursion.updatedEvents.addAll(customEventMap.keyset());
            //Finally update our events
            update customEventMap.values();

        }
    }

    /**
     * @method restrictMultipleEvents
     * @description prevents creating multiple events for the same custom event
     */
    public static void restrictMultipleEvents(List<Event> triggerNew){
        String custEventPrefix = Custom_Event__c.sObjectType.getDescribe().getKeyPrefix();
        Map<Id, Event> customEventIds = new Map<Id, Event>();
        for(Event evt : triggerNew){
            if(evt.WhatId != null && String.valueOf(evt.WhatId).startsWith(custEventPrefix)){
                customEventIds.put(evt.WhatId, evt);
            }
        }

        //Check if an event exists for the given whatid, if the id does not match id from trigger an error will be added
        //Note: this wouldn't account for multiple events added within the same dml, but should be sufficient for this exercise
        if(customEventIds.size() > 0){
            //Holds events keyed by the custom event id
            Map<Id, Event> eventMap = new Map<Id, Event>();
            for(Event evt : [SELECT Id, WhatId FROM Event WHERE WhatId IN: customEventIds.keyset()]){
                eventMap.put(evt.WhatId, evt);
            }           
            for(Event evt : customEventIds.values()){
                if(evt.Id != eventMap.get(evt.WhatId)?.Id){
                    evt.addError('Event already exists for Custom Event: ' + evt.WhatId);
                }
            } 
        }
    }
}