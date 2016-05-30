public class DEN_ConfigController {	        
    public String configType {get;set;}      
    public Id rowId {get;set;}    
    public List<SelectOption> startHours {get;set;}
    public List<SelectOption> endHours {get;set;}
    public Id dentistId = UserInfo.getUserId();      
    public DEN_Config__c config {get;set;}
    private static final String configTypeWeekday = 'WDAY';
    private static final String configTypeDate = 'DAY';                           
    private List<DEN_Config__c> configSummary {
        get {
        	List<DEN_Config__c> configList = [SELECT Id,Name,Weekday__c,StartingHour__c,EndingHour__c,Dentist__c,Date__c                                               
                         					FROM DEN_Config__c 
                         					WHERE Dentist__c=:dentistId
                         					ORDER BY Weekday__c,Date__c,StartingHour__c];            
            return configList;
    	}
        set;
    }    
    
    public List<SelectOption> getConfigTypeItems() {
        List<SelectOption> configOptions = new List<SelectOption>();
        configOptions.add(new SelectOption(configTypeWeekday,'Weekday'));
        configOptions.add(new SelectOption(configTypeDate,'Specific Date'));
        return configOptions;
    }
    
    public DEN_ConfigController() {                  
        configType=configTypeWeekday;        
        startHours=populateHourPicklist(DEN_Config__c.StartingHour__c);
        endHours=populateHourPicklist(DEN_Config__c.EndingHour__c);    
        config = new DEN_Config__c();         
    }                
    
    private static String convertToString(Decimal decimalHourValue) {
        Integer hourValue = Integer.valueOf(decimalHourValue);
        String minutesResult;
        String hoursResult;
        Integer minutes = math.mod(hourValue,60);
        Integer hours = hourValue/60;        
        if (minutes<10) {
            minutesResult = '0'+String.valueOf(minutes);
        } else {
            minutesResult = String.valueOf(minutes);
        }
        if (hours<10) {
            hoursResult = '0'+String.valueOf(hours);
        } else {
            hoursResult = String.valueOf(hours);
        }
        String result = hoursResult + ':' + minutesResult;  
        return result;
    }
    
    private List<SelectOption> populateHourPicklist(Schema.SObjectField field) {
        List<SelectOption> result = new List<SelectOption>();
        //24 hours required
        for (integer i=0;i<=24;i++) {
            String label=i+':00';
            String value=String.valueOf(i*60);
            result.add(new SelectOption(value,label));
        }
        if (field==DEN_Config__c.StartingHour__c) {
            result.remove(24);
        }
        if (field==DEN_Config__c.EndingHour__c) {
            result.remove(0);
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
        for (DEN_Config__c configItem: configSummary) {
            if (configTypeWeekday.equals(type) && configItem.Weekday__c != null) {
                configResult.add(configItem);
            }
            if (configTypeDate.equals(type) && configItem.Date__c != null) {
                configResult.add(configItem);
            }            
        }    
        return configResult;
    }
        
    public PageReference addToSummary() {  
        system.debug('configbefore: '+config);
        if (configTypeDate.equals(configType) && config.Date__c==null) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify date in \'Select Date\' field'));                        
        } else if (configTypeWeekday.equals(configType) && String.isBlank(config.Weekday__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify Weekday field'));                        
        } else if (config.StartingHour__c==null || config.EndingHour__c==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify Starting/Ending hours'));                        
        } else {               
	        if (configTypeWeekday.equals(configType)) config.Date__c = null;
    	    if (configTypeDate.equals(configType)) config.Weekday__c = null;                        
            config.Dentist__c=dentistId;            
            system.debug('configafter: '+config);            
            try {                
                insert config;                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record added'));                
                config = new DEN_Config__c();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insertion Error: '+e));
            }    		
        }        
        return null;
    }                     
                        
    public PageReference removeRow() {       
        for (DEN_Config__c configItem: configSummary) {            
            if (rowId.equals(configItem.Id)) {
                try {                    
                	delete configItem;    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record removed'));                      
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deletion Error: '+e));
                }
			break;                
            }                
        }        
        return null;
    }
}