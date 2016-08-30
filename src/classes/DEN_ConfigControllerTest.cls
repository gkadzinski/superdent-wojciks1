@isTest
public class DEN_ConfigControllerTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'DEN_dentist'];
        User u = new User(FirstName = 'John', lastName = 'Bob', email = 'test@test.pl', profileId = p.Id, Type__c = 'Ortodonta', Username='testDentist@fortesting.pl', Alias='johnbo', CommunityNickname='johnbo', TimeZoneSidKey='Europe/Berlin', LocaleSidKey='pl_PL', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert u;
        List<DEN_Config__c> configList = new List<DEN_Config__c>();
		configList.add(new DEN_Config__c(Dentist__c = u.Id, EndingHour__c = 360, StartingHour__c = 720, Weekday__c = 'MON'));
        configList.add(new DEN_Config__c(Dentist__c = u.Id, EndingHour__c = 690, StartingHour__c = 780, Weekday__c = 'WED'));
        insert configList;
        system.assert(!([SELECT Id From User WHERE Type__c != null]).isEmpty());
        system.assert(!([SELECT Id FROM DEN_Config__c]).isEmpty());
    }
    
    
    public static testMethod void controller_Init() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        System.assert(!controller.startHours.isEmpty());
        System.assert(!controller.endHours.isEmpty());
        System.assertEquals(48, controller.startHours.size());
        System.assertEquals(48, controller.endHours.size());
    }
    
    public static testMethod void testGetWeekDayConfig() {
		Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.runAs(u) {
            List<DEN_Config__c> configList = controller.getWeekDayConfig();
            System.assertEquals(2, configList.size());
        }
    }
    
    public static testMethod void testGetSpecificDateConfig() {
		Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.runAs(u) {
            List<DEN_Config__c> configList = controller.getSpecificDateConfig();
            System.assert(configList.isEmpty());
        }
        insert new DEN_Config__c(Dentist__c = u.Id, EndingHour__c = 360, StartingHour__c = 720, Date__c = Date.newInstance(2016, 9, 22));
        System.runAs(u) {
            List<DEN_Config__c> configList = controller.getSpecificDateConfig();
            System.assert(!configList.isEmpty());
            System.assertEquals(1, configList.size());
        }
    }
    
    public static testMethod void testGetConfigTypeItems() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        List<SelectOption> testList = controller.getConfigTypeItems();
        System.assert(testList.size() == 2);
        System.assert(testList[0].getLabel() == 'Weekday');
        System.assert(testList[1].getLabel() == 'Specific Date');
    }
    
    public static testMethod void testAddToSummaryMsg1() {
		Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        DEN_Config__c config = controller.config;
        controller.configType = 'DAY';
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.runAs(u) {
			controller.addToSummary();
        }
        Boolean b;
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Please specify date in \'Select Date\' field')) {
                b = true;
            }
        }
        System.assert(b);
    }
    
    public static testMethod void testAddToSummaryMsg2() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        DEN_Config__c config = controller.config;
        controller.configType = 'WDAY';
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.runAs(u) {
			controller.addToSummary();
        }
		Boolean b;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Please specify Weekday field')) {
                b = true;
            }
        }
        System.assert(b);
    }
    
    public static testMethod void testAddToSummaryMsg3() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        DEN_Config__c config = controller.config;
        controller.configType = 'WDAY';
        config.Weekday__c = 'MON';
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.runAs(u) {
			controller.addToSummary();
        }
		Boolean b;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Please specify Starting/Ending hours')) {
                b = true;
            }
        }
        System.assert(b);
    }
    
    public static testMethod void testAddToSummary() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        DEN_Config__c config = controller.config;
        controller.configType = 'WDAY';
        config.Weekday__c = 'TUE';
        config.StartingHour__c = 360;
        config.EndingHour__c = 720;
        User u = [SELECT Id FROM User WHERE Username='testDentist@fortesting.pl'];
        System.assertEquals(2, ([SELECT Id FROM DEN_Config__c WHERE Dentist__c =: u.Id]).size());
        System.runAs(u) {
            config.Dentist__c = u.Id;
			controller.addToSummary();
        }
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(3, ([SELECT Id FROM DEN_Config__c WHERE Dentist__c =: u.Id]).size());
    }
    
    public static testMethod void testRemoveRow() {
        Test.setCurrentPage(Page.DEN_Config);
        DEN_ConfigController controller = new DEN_ConfigController();
        System.assertEquals(2, ([SELECT Id FROM DEN_Config__c]).size());
        controller.rowId = [SELECT Id FROM DEN_Config__c LIMIT 1].Id;
        controller.removeRow();
        System.assertEquals(1, ([SELECT Id FROM DEN_Config__c]).size());
    }
}