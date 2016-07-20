public class DEN_AppointmentExtension {
    private static final String OWNER_LIST = 'SELECT Id, Name, Patient__c, Dentist__c, Dentist__r.Type__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c';
    private static final String DENTIST_LIST = 'SELECT Id, Name, Patient__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c WHERE Dentist__c =: loggedUserId';
    
    public Boolean ownerLogged {get; set;}
    private Id loggedUserId {get; set;}
    public String filteredDentistType {get; set;}
    public String filteredStatus {get; set;}
    public String filteredDentist {get; set;}
    public String filteredClient {get; set;}
    public String filteredType {get; set;}
    
    
    public DEN_AppointmentExtension(ApexPages.StandardController stdController) {
    	//GK: proponowana nazwa: userId
		loggedUserId = UserInfo.getUserId();
		//GK: isUserOwner, zmienne boolowskie oznaczamy isXXX, hasXXX
		//GK: lepiej tak sprawdzac, nie po petli
        ownerLogged = UserInfo.getProfileId().equals([SELECT Id FROM Profile WHERE Name =: 'DEN_Owner']);//checkLoggedUserRights(loggedUserId);
    }
	
    public ApexPages.StandardSetController appointmentSetCon {
        get {
            return appointmentSetCon == null ? new ApexPages.StandardSetController(Database.getQueryLocator(ownerLogged ? OWNER_LIST : DENTIST_LIST)) : appointmentSetCon;
        }
        set;
    }
    
    public List<SelectOption> getDentistTypes() {
        return addPicklistValues(listInit(), User.Type__c);
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
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'DEN_Appointment__c']) {
            result.add(new SelectOption(rt.Id, rt.Name));
        }
        return result;
    }
    
    public List<SelectOption> getStatuses() {
        return addPickListValues(listInit(), DEN_Appointment__c.Status__c);
    }
    
    public List<AppointmentWrapper> getAppointments() {
        List<AppointmentWrapper> result = new List<AppointmentWrapper>();
        for (DEN_Appointment__c appointment : (List<DEN_Appointment__c>) appointmentSetCon.getRecords()) {
        	//GK: zly pomysl; szybkie uderzenie w limity gwarantowane, w tej petli jest podwojny select dla kazdej wizyty!
            result.add(new AppointmentWrapper(appointment, getLinkDisplayed(appointment.Id), getApprovalLink(appointment.Id)));
        }
		return result;
    }
    
    public PageReference applyFilter() {
        appointmentSetCon = new ApexPages.StandardSetController(Database.query(getQueryString()));
        return null;
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
        //only for testing, normally should take all users with profile = DEN_Owner
        ownerIds.add('00558000000VkA5AAK');
        //GK: 00558000000VkDYAA0
        //SW: 00558000000VkA5AAK
        return ownerIds;
    }
    
    private String getQueryString() {
        Boolean filterActive = false;
        if (String.isNotBlank(getFilterString(ownerLogged))) {
            filterActive = true;
        }
        String result = 'SELECT Id, Name, Patient__c, Dentist__c, Dentist__r.Type__c, DateTime__c, Status__c, RecordTypeId FROM DEN_Appointment__c';
        if (!ownerLogged) {
            result = result + ' WHERE Dentist__c =: loggedUserId' + getFilterString(ownerLogged);
        } else {
            if (filterActive) {
                result = result + ' WHERE' + getFilterString(ownerLogged).replaceFirst(' AND', '');
            }
        }
        return result;
    }
    
    private String getFilterString(Boolean owner) {
        String result = '';
        result += 'ANY'.equals(filteredStatus) ? '' : ' AND Status__c =: filteredStatus';
        result += 'ANY'.equals(filteredClient) ? '' : ' AND Patient__c =: filteredClient';
        result += 'ANY'.equals(filteredType) ? '' : ' AND RecordTypeId =: filteredType';
        if (owner) {
        	result += 'ANY'.equals(filteredDentistType) ? '' : ' AND Dentist__r.Type__c =: filteredDentistType';
        	result += 'ANY'.equals(filteredDentist) ? '' : ' AND Dentist__c =: filteredDentist';
        }
        return result;
    }
    
    private String getApprovalLink(Id appointment) {
        Id retId;
        for (ProcessInstanceWorkitem item : [SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: appointment]) {
            retId = item.Id;
        }
        //GK: https://eu6.salesforce.com <-- to bedzie inne jak wejdziesz na innego orga z kodem. Musisz poczytac jak takie rzeczy sie obsluguje
        //GK: reszta adresu nadaje na jakis final static String 
        return 'https://eu6.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + retId;
    }
    
    private Boolean getLinkDisplayed(Id appointment) {
        List<ProcessInstanceWorkitem> taskList = [SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: appointment];
        if (taskList.isEmpty()) {
            return false;
        } else {
            return taskList[0].ActorId == loggedUserId;
        }
    }
    
    public class AppointmentWrapper {
        public DEN_Appointment__c appointment {get; set;}
        public Boolean displayLink {get; set;}
        public String linkUrl {get; set;}
        public AppointmentWrapper(DEN_Appointment__c appointment, Boolean displayLink, String linkUrl) {
            this.appointment = appointment;
            this.displayLink = displayLink;
            this.linkUrl = linkUrl;
        }
    }
}