public class DEN_configController {	
    //used in VF - selectRadio
    public String configType {get;set;}
    //used in VF, Weekday picklist
    public String weekdaySelected {get;set;}    
    //used in VF, StartingHour picklist
    public String startHselected {get;set;}       
    //used in VF, EndingHour picklist
    public String endHselected {get;set;}
    //used in VF, date picker
    public Date dateSelected {get;set;}
    //holds userid from global variable, used to save in DEN_Config__c as Dentist__c
    public Id user = userinfo.getUserId();
    //populate collection with records already existing in DEN_Config__c
    List<DEN_Config__c> existingConfigList = [SELECT Id,Name,Weekday__c,StartingHour__c,EndingHour__c,Dentist__c,Date__c                                               
                                              FROM DEN_Config__c 
                                              WHERE Dentist__c=:user
                                              ORDER BY Weekday__c,Date__c,StartingHour__c];
    //make a copy of list above, and modify items in further processes
    List<DEN_Config__c> configList = new List<DEN_Config__c>(existingConfigList);
    
    //method returns a list of config types used in VF selectRadio
    public List<SelectOption> getConfigTypeItems() {
        List<SelectOption> configOptions = new List<SelectOption>();
        configOptions.add(new SelectOption('WDAY','Weekday'));
        configOptions.add(new SelectOption('DAY','Specific Date'));
        return configOptions;
    }
    
    //method returns a list of picklist values for Weekday__c
    public List<SelectOption> getWeekdays() {
        List<SelectOption> weekdaysList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResults = DEN_Config__c.Weekday__c.getDescribe();
        List<Schema.PicklistEntry> pickListResults = fieldResults.getPicklistValues();
        for (Schema.PicklistEntry value: pickListResults) {
            weekdaysList.add(new SelectOption(value.getLabel(),value.getValue()));
        }        
        return weekdaysList;
    }   
    
    //method returns a list of picklist values for StartingHour__c
    public List<SelectOption> getStartHours() {
        List<SelectOption> startHourList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResults = DEN_Config__c.StartingHour__c.getDescribe();
        List<Schema.PicklistEntry> pickListResults = fieldResults.getPicklistValues();
        for (Schema.PicklistEntry value: pickListResults) {
            startHourList.add(new SelectOption(value.getLabel(),value.getValue()));
        }        
        return startHourList;
    }
    
    //method returns a list of picklist values for EndingHour__c
    public List<SelectOption> getEndHours() {
        List<SelectOption> endHourList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResults = DEN_Config__c.EndingHour__c.getDescribe();
        List<Schema.PicklistEntry> pickListResults = fieldResults.getPicklistValues();
        for (Schema.PicklistEntry value: pickListResults) {
            endHourList.add(new SelectOption(value.getLabel(),value.getValue()));
        }        
        return endHourList;
    }
    
    //getter method to populate pageBlockTable with Summary by Weekday data
    public List<DEN_Config__c> getConfigWeekDay() {
        return populateSummary('WeekDay');
    }        
    
    //getter method to populate pageBlockTable with Summary by Date data
    public List<DEN_Config__c> getConfigDate () {
        return populateSummary('Date');
    }
    
    //return list of DEN_Config__c object based on parameter which is config type
    private List<DEN_Config__c> populateSummary(String type) {        
        List<DEN_Config__c> configResult = new List<DEN_Config__c>();
        for (DEN_Config__c config: configList) {
            if (config.Weekday__c != null && type=='WeekDay') {
                configResult.add(config);
            }
            if (config.Date__c != null && type=='Date') {
                configResult.add(config);
            }            
        }    
        return configResult;
    }
    
    //when Add button is used on Config page, new item is added to configList collection displayed in summary
    public void addToSummary () { 
        if (configType!=null || (configType=='DAY' && dateSelected!=null)) {
	        if (configType=='WDAY') dateSelected = null;
    	    if (configType=='DAY') weekdaySelected = null;
    		configList.add(new DEN_Config__c(Weekday__c=weekdaySelected,
                   	    	                StartingHour__c=startHselected,
                    	                    EndingHour__c=endHselected,
                            	            Dentist__c=user,
                                	        Date__c=dateSelected));            
        }
    }
    
    //list is populated with Config records that have to be inserted as new DEN_Config__c records
    public List<DEN_Config__c> configToAdd {
        get {
            List<DEN_Config__c> configToAdd = new List<DEN_Config__c>();
            for (DEN_Config__c conActual: configList) {
                Boolean add = true;
                for (DEN_Config__c conBefore: existingConfigList) {
                    if (conActual==conBefore) {
                        add=false;                    
                        break;
                    }
                }
                if (add) {
                    configToAdd.add(conActual);
                }
            }            
            return configToAdd;        	    
        }
		set;        
    }
    
    //save method used on VF page    
    public void save() {
        try {
            insert configToAdd;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Config SAVED successfully'));
        }
        catch (Exception e) {
            system.debug('exception: '+e);
        }
    }
}