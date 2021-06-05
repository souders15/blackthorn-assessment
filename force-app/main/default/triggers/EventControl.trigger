trigger EventControl on Event (before insert, before update, after update) {
    switch on trigger.operationType {
            when BEFORE_INSERT, BEFORE_UPDATE{
                EventControlHandler.restrictMultipleEvents(Trigger.new);
            }
            when AFTER_UPDATE{
                EventControlHandler.updateCustomEvent(Trigger.newMap, Trigger.oldMap);
            }
        }
}