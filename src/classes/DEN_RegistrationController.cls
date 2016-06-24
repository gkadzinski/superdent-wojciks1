public with sharing class DEN_RegistrationController {
    private static final String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    private static final String FILTERED_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c =: dentistType';
    private static final String FILTERED_DATE = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null AND Id IN :availableDentists';
    private static final String FILTERED_DENTISTS_DATE = 'SELECT Id, Name, Type__c FROM User WHERE Type__c =: dentistType AND Id IN :availableDentists';
    private static final List<DEN_Config__c> ALL_CONFIG = [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c, Dentist__c FROM DEN_Config__c];
    
    private List<Id> availableDentists {get; set;}
    public String dentistType {get; set;}
    public Id dentistId {get; set;}
    public DEN_Appointment__c appointment {get; set;}
    
    public DEN_RegistrationController() {
        appointment = new DEN_Appointment__c();
    }
    
    public ApexPages.StandardSetController dentistSetCon {
        get {
			return dentistSetCon == null ? new ApexPages.StandardSetController(Database.getQueryLocator(ALL_DENTISTS)) : dentistSetCon;
        }
        set;
    }
    
    public PageReference filterTypes() {
        availableDentists = (appointment.Date__c == null ? null : getAvailableDentists(appointment.Date__c));
        dentistSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(getQueryString()));
        return null;
    }
    
    public List<User> getDentists() {
        return (List<User>)dentistSetCon.getRecords();
    }
    
    public List<SelectOption> getDentistTypes() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('ANY', '--Any--'));
        for (Schema.PicklistEntry item : User.Type__c.getDescribe().getPicklistValues()) {
            result.add(new SelectOption(item.value, item.label));
        }
        return result;
    }
    
    private List<Id> getAvailableDentists(Date filteredDate) {
        Set<Id> availableDentists = new Set<Id>();
        String selWeekDay = DEN_DateUtil.getWeekdayFrom(filteredDate);
        if (filteredDate >= Date.today()) {
            for (DEN_Config__c config : ALL_CONFIG) {
                if ((config.Date__c != null && config.Date__c == filteredDate) ||
                    (config.Weekday__c != null && config.Weekday__c.equals(selWeekDay.toUpperCase()))) {
                        availableDentists.add(config.Dentist__c);
                    }
            }
        }
        return new List<Id>(availableDentists);
    }
    
    private String getQueryString() {
        if ('ANY'.equals(dentistType)) {
        	return appointment.Date__c == null ? ALL_DENTISTS : FILTERED_DATE;
        }
        else {
            return appointment.Date__c == null ? FILTERED_DENTISTS : FILTERED_DENTISTS_DATE;
    	}
    }
}