Trigger PreventDupLead on Lead(before update) {
    Set<String> emails = new Set<String>();
    for(Lead aLead : Trigger.new) {
        if(aLead.Email != null){
            emails.add(aLead.Email);
        }
    }
    // Find dups based on the email
    Map<String, Lead> leadMap = new Map<String, Lead>();
    List<Lead> leadList = [SELECT Id, Email FROM Lead WHERE Email IN: emails];
    for(Lead l : leadList){
        leadMap.put(l.Email, l);
    }
    for(Lead aLead : Trigger.new) {
        if(leadMap.get(aLead.Email) != null){
            aLead.addError('Duplicate Lead!');
        }
    }
}