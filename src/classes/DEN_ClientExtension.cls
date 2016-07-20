public class DEN_ClientExtension {
    public DEN_ClientExtension(ApexPages.StandardController stdController) {
        
    }
    
    public List<Contact> getClients() {
    	//GK: jesli tak robisz to pamietaj ze przy kazdym odswiezeniu strony ten select sie wykona
        return [SELECT Id, FirstName, LastName, Name, Phone, Email FROM Contact WHERE Id IN (SELECT Patient__c FROM DEN_Appointment__c)];
    }
}