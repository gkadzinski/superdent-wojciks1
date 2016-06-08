public class DEN_RegistrationController {
    private static final String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    private static final String FILTERED_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c =: dentistType';
    public String dentistType {get;set;}
    public List<User> dentistList {get;set;}
    public Id dentistId {get;set;}    
    
    public ApexPages.StandardSetController dentistSetCon {
        get {
            if (dentistSetCon == null) {
                dentistSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(ALL_DENTISTS));
            }
            return dentistSetCon;
        }
        set;
    }
    
    public PageReference filterTypes() {
        dentistList = null;
        if (!dentistType.equals('ANY')) {
            dentistSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(FILTERED_DENTISTS));
        }
        else {
            dentistSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(ALL_DENTISTS));
        }
        getDentists();        
        return null;
    }
    
    public List<User> getDentists() {
        return dentistList = (List<User>)dentistSetCon.getRecords();
    }
    
    public List<SelectOption> getDentistTypes() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('ANY', '--Any--'));
        for (Schema.PicklistEntry item: User.Type__c.getDescribe().getPicklistValues()) {
            result.add(new SelectOption(item.value, item.label));
        }
        return result;
    }
}