@isTest(SeeAllData=false)
private class DEN_AppointmentTriggerTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'DEN_dentist'];
        User u = new User(FirstName = 'John', lastName = 'Bob', email = 'test@test.pl', profileId = p.Id, Type__c = 'Ortodonta', Username='testDentist@fortesting.pl', Alias='johnbo', CommunityNickname='johnbo', TimeZoneSidKey='Europe/Berlin', LocaleSidKey='pl_PL', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert u;
        Contact c = new Contact(FirstName = 'ContFirst', LastName = 'ContLast', email = 'testContact@test.pl');
        insert c;
        system.assertEquals(1, ([SELECT Id FROM User WHERE Type__c != null AND ProfileId =: p.Id]).size());
        system.assertEquals(1, ([SELECT Id FROM Contact WHERE Email != null]).size());
    }
    
    @isTest static void oneAppointmentVerifyNameAfterTriggerExecution() {
        Contact c = [SELECT Id FROM Contact WHERE email = 'testContact@test.pl'];
        User dentist = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        DateTime dt = DateTime.newInstance(Date.newInstance(2016, 8, 22), Time.newInstance(6, 30, 0, 0));
        DEN_Appointment__c a = new DEN_Appointment__c(Date__c = dt.date(), DateTime__c = dt, Dentist__c = dentist.Id, Patient__c = c.Id);
        insert a;
        System.assertEquals('JB_CC_20160822_0630', [SELECT Id, Name FROM DEN_Appointment__c LIMIT 1 ].Name);
    }
    
    @isTest static void multipleAppointmentVerifyNameAfterTriggerExecution() {
        Contact c = [SELECT Id FROM Contact WHERE email = 'testContact@test.pl'];
        User dentist = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        DateTime dt1 = DateTime.newInstance(Date.newInstance(2016, 8, 22), Time.newInstance(6, 30, 0, 0));        
        DateTime dt2 = DateTime.newInstance(Date.newInstance(2016, 8, 23), Time.newInstance(12, 0, 0, 0));
        List<DEN_Appointment__c> a = new List<DEN_Appointment__c>();
        a.add(new DEN_Appointment__c(Date__c = dt1.date(), DateTime__c = dt1, Dentist__c = dentist.Id, Patient__c = c.Id));
        a.add(new DEN_Appointment__c(Date__c = dt2.date(), DateTime__c = dt2, Dentist__c = dentist.Id, Patient__c = c.Id));
        insert a;
        System.assertEquals('JB_CC_20160822_0630', [SELECT Id, Name FROM DEN_Appointment__c WHERE DateTime__c =: dt1].Name);
        System.assertEquals('JB_CC_20160823_1200', [SELECT Id, Name FROM DEN_Appointment__c WHERE DateTime__c =: dt2].Name);
    }
}