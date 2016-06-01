public class DEN_ConfigController {	        
    private static final String WEEKDAY = 'WDAY';
    private static final String SPECIFIC_DATE = 'DAY';
    
    public DEN_Config__c config {get;set;}
    public Id rowId {get;set;}
    public String configType {get;set;}
    public List<SelectOption> startHours {get;set;}
    public List<SelectOption> endHours {get;set;}
    
    public DEN_ConfigController() {
        config = new DEN_Config__c();
        config.Dentist__c = UserInfo.getUserId();
        
        configType = WEEKDAY;
        startHours = populateHourPicklist(DEN_Config__c.StartingHour__c);
        endHours = populateHourPicklist(DEN_Config__c.EndingHour__c);
    }
    
    public List<SelectOption> getConfigTypeItems() {
        List<SelectOption> configOptions = new List<SelectOption>();
        configOptions.add(new SelectOption(WEEKDAY, 'Weekday'));
        configOptions.add(new SelectOption(SPECIFIC_DATE, 'Specific Date'));
        return configOptions;
    }
    
    public List<DEN_Config__c> getWeekDayConfig() {
        return populateSummary(WEEKDAY);
    }        
        
    public List<DEN_Config__c> getSpecificDateConfig() {
        return populateSummary(SPECIFIC_DATE);
    }
    
    private List<SelectOption> populateHourPicklist(Schema.SObjectField field) {
        List<SelectOption> result = new List<SelectOption>();
        for (Integer i=0; i<=24; i++) {
        	Integer minutes = i*60;
            String label = DEN_HoursConverterController.getStringValue(minutes);
            String value = String.valueOf(minutes);
            result.add(new SelectOption(value, label));
        }
        if (DEN_Config__c.StartingHour__c == field) {
            result.remove(result.size()-1);
        }
        if (DEN_Config__c.EndingHour__c == field) {
            result.remove(0);
        }
        return result;
    }                
    
    private List<DEN_Config__c> getAllConfigSummary() {
    	return [SELECT Id, Name, Weekday__c, StartingHour__c, EndingHour__c, Dentist__c, Date__c                                               
				FROM DEN_Config__c 
				WHERE Dentist__c =: UserInfo.getUserId()
				ORDER BY Weekday__c, Date__c, StartingHour__c];
    }
    
    
    private List<DEN_Config__c> populateSummary(String configType) {        
        List<DEN_Config__c> configResult = new List<DEN_Config__c>();
        for (DEN_Config__c configItem : getAllConfigSummary()) {
            if (WEEKDAY.equals(configType)) {
                configResult.add(configItem);
            }
            if (SPECIFIC_DATE.equals(configType)) {
                configResult.add(configItem);
            }
        }
        return configResult;
    }
        
    public PageReference addToSummary() {  
        if (SPECIFIC_DATE.equals(configType) && config.Date__c==null) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please specify date in \'Select Date\' field'));
            return null;                        
        } 
        if (WEEKDAY.equals(configType) && String.isBlank(config.Weekday__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please specify Weekday field'));
            return null;                        
        } 
        if (config.StartingHour__c==null || config.EndingHour__c==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please specify Starting/Ending hours'));
            return null;                        
        }
        
        if (WEEKDAY.equals(configType)) config.Date__c = null;
		if (SPECIFIC_DATE.equals(configType)) config.Weekday__c = null;   
		                     
		insert config;                
		config = new DEN_Config__c();
		
        return null;
    }
    
    public PageReference removeRow() {
    	delete ([SELECT Id FROM DEN_Config__c WHERE Id =: rowId]);
        return null;
    }
}