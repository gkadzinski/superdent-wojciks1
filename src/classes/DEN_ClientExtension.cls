public class DEN_ClientExtension {
    public DEN_ClientExtension(ApexPages.StandardController stdController) {
        
    }
    
    public List<Contact> getClients() {
        return [SELECT Id, FirstName, LastName, Name, Phone, Email FROM Contact WHERE Id IN (SELECT Patient__c FROM DEN_Appointment__c)];
    }
}