public class DEN_AppointmentExtension {
    private static final String OWNER_LIST = 'SELECT Id, Name, Patient__c, Dentist__c, Dentist__r.Type__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c';
    private static final String DENTIST_LIST = 'SELECT Id, Name, Patient__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c WHERE Dentist__c =: loggedUserId';
    private static final String OWNER_LIST_DENTIST = 'SELECT Id, Name, Patient__c, Dentist__c, Dentist__r.Type__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c WHERE Dentist__c =: filteredDentist';
    private static final String DENTIST_LIST_CLIENT = 'SELECT Id, Name, Patient__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c WHERE Dentist__c =: loggedUserId AND Patient__c =: filteredClient';
    
    public Boolean ownerLogged {get; set;}
    private Id loggedUserId {get; set;}
    public String filteredDentistType {get; set;}
    public String filteredStatus {get; set;}
    public Id filteredDentist {get; set;}
    public Id filteredClient {get; set;}
    public Id filteredType {get; set;}
    
    
    public DEN_AppointmentExtension(ApexPages.StandardController stdController) {
		loggedUserId = UserInfo.getUserId();
        ownerLogged = checkLoggedUserRights(loggedUserId);
    }
	
    public List<SelectOption> getDentistTypes() {
        List<SelectOption> result = listInit();
        return result = addPicklistValues(result, User.Type__c);
    }
    
    public List<SelectOption> getDentists() {
        List<SelectOption> result = listInit();
        for (User dentist : [SELECT Id, Name FROM User WHERE Type__c != null]) {
            result.add(new SelectOption(dentist.Id, dentist.Name));
        }
        return result;
    }
    
    public List<SelectOption> getClients() {
        List<SelectOption> result = listInit();
        for (Contact contact : [SELECT Id, Name FROM Contact WHERE Id IN (SELECT Patient__c FROM DEN_Appointment__c)]) {
            result.add(new SelectOption(contact.Id, contact.Name));
        }
        return result;
    }
    
    public List<SelectOption> getAppointmentTypes() {
        List<SelectOption> result = listInit();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType='DEN_Appointment__c']) {
            result.add(new SelectOption(rt.Id, rt.Name));
        }
        return result;
    }
    
    public List<SelectOption> getStatuses() {
        List<SelectOption> result = listInit();
        return result = addPickListValues(result, DEN_Appointment__c.Status__c);
    }
    
    private List<SelectOption> listInit() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('ANY', '--Any--'));
        return result;
    }
    
    private List<SelectOption> addPicklistValues(List<SelectOption> result, SobjectField field) {
        for (Schema.PicklistEntry item : field.getDescribe().getPicklistValues()) {
            result.add(new SelectOption(item.value, item.label));
        }
        return result;
    }
    
    private static List<Id> getOwners() {
        List<Id> ownerIds = new List<Id>();
        //only for testing
        ownerIds.add('00558000000VkA5AAK');
        //GK: 00558000000VkDYAA0
        //SW: 00558000000VkA5AAK
        return ownerIds;
    }
    
    private static Boolean checkLoggedUserRights(Id loggedUserId) {
        Boolean result = false;
        List<Id> ownerIds = getOwners();
        if (!ownerIds.isEmpty()) {
            for (Id userElement : ownerIds) {
                if (userElement.equals(loggedUserId)) {
                    result = true;
                    break;
                }
            }    
        }
        return result;
    }
    
    public ApexPages.StandardSetController appointmentSetCon {
        get {
            return appointmentSetCon == null ? new ApexPages.StandardSetController(Database.getQueryLocator(ownerLogged ? OWNER_LIST : DENTIST_LIST)) : appointmentSetCon;
        }
        set;
    }
    
    public List<DEN_Appointment__c> getAppointments() {
		return (List<DEN_Appointment__c>) appointmentSetCon.getRecords();
    }
    
    public PageReference applyFilter() {
        appointmentSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(getQueryString()));
        return null;
    }
    
    private String getQueryString() {
        return 'SELECT Id, Name, Patient__c, Dentist__c, Dentist__r.Type__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c LIMIT 2';
    }
}