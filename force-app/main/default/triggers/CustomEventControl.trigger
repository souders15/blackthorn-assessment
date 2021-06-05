trigger CustomEventControl on Custom_Event__c (after insert, after update) {
    switch on trigger.operationType {
        when AFTER_INSERT{
            CustomEventControlHandler.updateEvent(Trigger.newMap);
        }
        when AFTER_UPDATE{
            CustomEventControlHandler.updateEvent(Trigger.newMap, Trigger.oldMap);
        }
    }
}