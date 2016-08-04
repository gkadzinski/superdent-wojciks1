global class DEN_IntegrationUtils {
    global static String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    
    global class ConfigWrapper {
        public String timePeriod {get; set;}
        public String weekday {get; set;}
        public Date configDate {get; set;}
        public ConfigWrapper(DEN_Config__c config) {
            this.timePeriod = DEN_HoursConverterController.getPeriodString(Integer.valueOf(config.StartingHour__c), Integer.valueOf(config.EndingHour__c));
            this.weekday = config.Weekday__c;
            this.configDate = config.Date__c;
        }
    }
    
    private static List<DEN_Config__c> getConfigFor(Id dentistId) {
        return [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId];
    }
    
    global static List<DEN_IntegrationUtils.ConfigWrapper> setDentistDayAvailabilityResult(Id dentistId) {
        List<DEN_IntegrationUtils.ConfigWrapper> result = new List<DEN_IntegrationUtils.ConfigWrapper>();
        for (DEN_Config__c config : DEN_IntegrationUtils.getConfigFor(dentistId)) {
            result.add(new DEN_IntegrationUtils.ConfigWrapper(config));
        }
        return result;
    }
}