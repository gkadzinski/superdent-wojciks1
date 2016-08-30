@isTest
public class DEN_ClientExtensionTest {
    @isTest static void testExtension() {
        Test.setCurrentPage(Page.DEN_Client);
        Contact c = new Contact(FirstName = 'Bob', LastName = 'Klop', email = 'testContactEmail@email.pl');
        insert c;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'DEN_dentist'];
        User u = new User(FirstName = 'John', lastName = 'Bob', email = 'test@test.pl', profileId = p.Id, Type__c = 'Ortodonta', Username='testDentist@fortesting.pl', Alias='johnbo', CommunityNickname='johnbo', TimeZoneSidKey='Europe/Berlin', LocaleSidKey='pl_PL', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert u;
        DateTime dt = DateTime.newInstance(Date.newInstance(2016, 8, 22), Time.newInstance(6, 30, 0, 0));
        insert new DEN_Appointment__c(Patient__c = [SELECT Id FROM Contact WHERE email = 'testContactEmail@email.pl'].Id, Dentist__c = [SELECT Id FROM User WHERE Username = 'testDentist@fortesting.pl'].Id, DateTime__c = dt, Date__c = dt.date());
        DEN_ClientExtension ext = new DEN_ClientExtension(new ApexPages.StandardController(new Contact()));
        system.assert(!ext.clients.isEmpty());
        system.assert(ext.clients.size() == 1);
    }
}