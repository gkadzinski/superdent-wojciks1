public with sharing class DEN_RegistrationController {
    private static final String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    private static final String FILTERED_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c =: dentistType';
    
    public String dentistType {get; set;}
    public Id dentistId {get; set;}
    
    public ApexPages.StandardSetController dentistSetCon {
        get {
			return dentistSetCon == null ? new ApexPages.StandardSetController(Database.getQueryLocator(ALL_DENTISTS)) : dentistSetCon;
        }
        set;
    }
    
    public PageReference filterTypes() {
        dentistSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(!'ANY'.equals(dentistType) ? FILTERED_DENTISTS : ALL_DENTISTS));
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
}