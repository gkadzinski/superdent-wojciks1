public class DEN_ConfigController {	        
    public String configType {get;set;}    
    public String weekdaySelected {get;set;}        
    public String startHselected {get;set;}           
    public String endHselected {get;set;}    
    public Date dateSelected {get;set;}  
    public List<SelectOption> weekdays {get;set;}
    public List<SelectOption> startHours {get;set;}
    public List<SelectOption> endHours {get;set;}
    public Id dentistId = UserInfo.getUserId();    
    private static final String configTypeWeekday = 'WDAY';
    private static final String configTypeDate = 'DAY';                       
    private Set<DEN_Config__c> configAdded = new Set<DEN_Config__c>();
    private Set<DEN_Config__c> configRemoved = new Set<DEN_Config__c>();
    private List<DEN_Config__c> configSummary {get;set;}
    
    public List<SelectOption> getConfigTypeItems() {
        List<SelectOption> configOptions = new List<SelectOption>();
        configOptions.add(new SelectOption(configTypeWeekday,'Weekday'));
        configOptions.add(new SelectOption(configTypeDate,'Specific Date'));
        return configOptions;
    }
    
    public DEN_ConfigController() {                  
        configType=configTypeWeekday;
        weekdays=populatePickList(DEN_Config__c.Weekday__c);
        startHours=populatePickList(DEN_Config__c.StartingHour__c);
        endHours=populatePickList(DEN_Config__c.EndingHour__c);
        configSummary = [SELECT Id,Name,Weekday__c,StartingHour__c,EndingHour__c,Dentist__c,Date__c                                               
                         FROM DEN_Config__c 
                         WHERE Dentist__c=:dentistId
                         ORDER BY Weekday__c,Date__c,StartingHour__c];
    }                
    
    private List<SelectOption> populatePicklist(Schema.SObjectField field) {
        List<SelectOption> result = new List<SelectOption>();
        for (Schema.PicklistEntry value: field.getDescribe().getPicklistValues()) {
            result.add(new SelectOption(value.getValue(),value.getLabel()));
        }
        return result;
    }
        
    public List<DEN_Config__c> getConfigWeekDay() {
        return populateSummary(configTypeWeekday);
    }        
        
    public List<DEN_Config__c> getConfigDate() {
        return populateSummary(configTypeDate);
    }
        
    private List<DEN_Config__c> populateSummary(String type) {        
        List<DEN_Config__c> configResult = new List<DEN_Config__c>();
        for (DEN_Config__c config: configSummary) {
            if (configTypeWeekday.equals(type) && config.Weekday__c != null) {
                configResult.add(config);
            }
            if (configTypeDate.equals(type) && config.Date__c != null) {
                configResult.add(config);
            }            
        }    
        return configResult;
    }
        
    public PageReference addToSummary() {         
        if (configTypeDate.equals(configType) && dateSelected==null) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify date in \'Select Date\' field'));                        
        } if (configTypeWeekday.equals(configType) && String.isBlank(weekdaySelected)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify Weekday field'));                        
        } if (String.isBlank(startHselected) || String.isBlank(endHselected)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify Starting/Ending hours'));                        
        } else {                         
	        if (configTypeWeekday.equals(configType)) dateSelected = null;
    	    if (configTypeDate.equals(configType)) weekdaySelected = null;
            DEN_Config__c config = new DEN_Config__c(Weekday__c=weekdaySelected,
                   	    	                StartingHour__c=startHselected,
                    	                    EndingHour__c=endHselected,
                            	            Dentist__c=dentistId,
                                	        Date__c=dateSelected);
    		configSummary.add(config);                          
            configAdded.add(config);
        }              
        return null;
    }        
     
    public PageReference cancel() {
        return ApexPages.currentPage().setRedirect(true);                
    }
    
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        try {
            insert (new List<DEN_Config__c>(configAdded));
            try {
                delete (new List<DEN_Config__c>(configRemoved));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Config SAVED successfully'));            
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e));                
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Changes reverted'));            
            }            
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e));
        }        
        configAdded.clear();
        configRemoved.clear();
        return null;
    }
    
    public String rowWeekDay {get;set;}
    public String rowStartH {get;set;}
    public String rowEndH {get;set;}
    public String rowDate {get;set;}
    
    private Date stringToDate(String s) {
        if (String.isNotBlank(s)) {
            Integer y = Integer.valueOf(s.substring(0,4));
            Integer m = Integer.valueOf(s.substring(5, 7));
            Integer d = Integer.valueOf(s.substring(8, 10));                    
            return date.newInstance(y, m, d);            
        } else return null;
    }        
    
    public PageReference removeRow() {                
        Integer idx=0;                
        for (DEN_Config__c config: configSummary) {                       
            if (String.isBlank(rowWeekDay) && config.StartingHour__c==rowStartH && config.EndingHour__c==rowEndH && config.Date__c==stringToDate(rowDate)) {
                configSummary.remove(idx);
                configRemoved.add(config);
                break;
            }
            if (String.isBlank(rowDate) && config.StartingHour__c==rowStartH && config.EndingHour__c==rowEndH && config.Weekday__c==rowWeekDay) {
                configSummary.remove(idx);
                configRemoved.add(config);
                break;
            }
            idx++;
        }        
        return null;
    }
}