@isTest
public class DEN_AppointmentExtensionTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'DEN_dentist'];
        User u = new User(FirstName = 'John', lastName = 'Bob', email = 'test@test.pl', profileId = p.Id, Type__c = 'Ortodonta', Username='testDentist@fortesting.pl', Alias='johnbo', CommunityNickname='johnbo', TimeZoneSidKey='Europe/Berlin', LocaleSidKey='pl_PL', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert u;
        Contact c = new Contact(FirstName = 'ContFirst', LastName = 'ContLast', email = 'testContact@test.pl');
        insert c;
        c = [SELECT Id FROM Contact WHERE email = 'testContact@test.pl'];
        u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        DateTime dt1 = DateTime.newInstance(Date.newInstance(2016, 8, 22), Time.newInstance(6, 30, 0, 0));
        insert new DEN_Appointment__c(Date__c = dt1.date(), DateTime__c = dt1, Dentist__c = u.Id, Patient__c = c.Id);
    }
    
    public static testMethod void extensionInit() {
        Test.setCurrentPage(Page.DEN_Appointment);
        User u = [SELECT Id FROM User Where Username='testDentist@fortesting.pl'];
        System.runAs(u) {
            DEN_AppointmentExtension ext = new DEN_AppointmentExtension(new ApexPages.StandardController(new DEN_Appointment__c()));
            system.assert(!ext.startHours.isEmpty());
            system.assert(ext.startHours.size() == 48);
        }
    }
    
    public static testMethod void gettersTest() {
        Test.setCurrentPage(Page.DEN_Appointment);
        DEN_AppointmentExtension ext = new DEN_AppointmentExtension(new ApexPages.StandardController(new DEN_Appointment__c()));
        List<SelectOption> statuses = ext.getStatuses();
        List<SelectOption> clients = ext.getClients();
        List<SelectOption> dentists = ext.getDentists();
        List<SelectOption> dentistTypes = ext.getDentistTypes();
        List<SelectOption> apTypes = ext.getAppointmentTypes();
        system.assert(!statuses.isEmpty());
        system.assert(!clients.isEmpty());
        system.assert(!dentists.isEmpty());
        system.assert(!dentistTypes.isEmpty());
        system.assert(!apTypes.isEmpty());
    }
    
    /*
    public static testMethod void getQueryStringTest() {
        Test.setCurrentPage(Page.DEN_Appointment);
        DEN_AppointmentExtension ext = new DEN_AppointmentExtension(new ApexPages.StandardController(new DEN_Appointment__c()));
        ext.isOwnerLogged = false;
        PageReference pr = ext.applyFilter();
        
    }
	*/
}