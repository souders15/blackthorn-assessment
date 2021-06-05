@RestResource(urlMapping='/Registration/*')
global with sharing class EventRegistrationRest {
  
    /**
     * @method postRegistration
     * @description upserts a contact and creates an event registration
     */
    @HttpPost
    global static void postRegistration(String first, String last, String email, String eventUUID) {
        RestResponse res = RestContext.response;

        Contact relatedContact = setContact(first, last, email);
        try{
            createRegistration(relatedContact, eventUUID);
            res.statusCode = 201;

        }catch(System.QueryException e){
            res.statusCode = 404;
            SalesforceError[] errs = new SalesforceError[]{ 
                new SalesforceError('NOT_FOUND', 'Event not found')
            };
            res.responseBody = Blob.valueOf(JSON.serialize(errs));
        }catch(Exception e){
            res.statusCode = 500;
            SalesforceError[] errs = new SalesforceError[]{ 
                new SalesforceError('Error', e.getMessage())
            };
            res.responseBody = Blob.valueOf(JSON.serialize(errs));
        }
    }
    
    /**
     * @method setContact
     * @description upserts contact based on email
     */
    private static Contact setContact(String first, String last, String email){
        Contact con;
        //Check for existing contact
        if(email != null){
            List<Contact> conList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: email];
            //This assumes emails are unique for contacts, could be achieved through duplicate rules or domain logic, skipping that for brevity
            con = conList.size() == 1 ? conList[0] : new Contact();
        }
        
        if(first != con.Firstname || last != con.LastName || email != con.Email){
            //This allows updating first/last with fresh info related to the email
            con.FirstName = first;
            con.LastName = last;
            con.Email = email;
            upsert con;
        }
        
        return con;
    }

    /**
     * @method createRegistration
     * @description create an event registration for a given event and contact
     */
    private static String createRegistration(Contact con, String eventUUID){
     
        Custom_Event__c evt = [SELECT Id, (SELECT Id FROM Event_Registrations__r WHERE Contact__c =: con.Id) FROM Custom_Event__c WHERE External_UUID__c =: eventUUID];

        //Integrity check
        if(evt.Event_Registrations__r.size() > 0){
            throw new DmlException('A registration to this event already exists for ' + con.FirstName + ' ' + con.LastName);
        }

        Event_Registration__c reg = new Event_Registration__c();
        reg.Contact__c = con.Id;
        reg.Event__c = evt.Id;
        insert reg;

        return reg.Id;
    }

    public class SalesforceError {
    public String errorCode;
    public String message;
    public SalesforceError(String errorCode, string message){
        this.errorCode = errorCode;
        this.message = message;
    }
}
}