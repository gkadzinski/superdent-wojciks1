public class DEN_ClientExtension {
    public List<Contact> clients {get; set;}
    public DEN_ClientExtension(ApexPages.StandardController stdController) {
        clients = [SELECT Id, FirstName, LastName, Name, Phone, Email FROM Contact WHERE Id IN (SELECT Patient__c FROM DEN_Appointment__c)];
    }
}