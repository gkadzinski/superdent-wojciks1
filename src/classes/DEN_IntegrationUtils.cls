public class DEN_IntegrationUtils {
    public static String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    public static String APOINTMENT_STATUS_REJECTED = 'Odrzucona';
    private static String REST_ERROR_MISSING_DATE_PARAM_VALUES = 'Values for date parameters should not be empty';
    private static String REST_ERROR_WRONG_MONTH = 'Month parameter is not valid, should be between 1 and 12';
    private static String REST_ERROR_WRONG_DAY = 'Day number exceeds the number of days in given month/year';
    private static String REST_ERROR_DATE_IN_PAST = 'Requested date is in the past';
    
    public class ConfigWrapper {
        public String timePeriod {get; set;}
        public String weekday {get; set;}
        public Date configDate {get; set;}
        public ConfigWrapper(DEN_Config__c config) {
            this.timePeriod = DEN_HoursConverterController.getPeriodString(Integer.valueOf(config.StartingHour__c), Integer.valueOf(config.EndingHour__c));
            this.weekday = config.Weekday__c;
            this.configDate = config.Date__c;
        }
    }
    
    public class ValidateResult {
        public Boolean status {get; set;}
        public String error {get; set;}
        
        public ValidateResult(Boolean status, String error) {
            this.status = status;
            this.error = error;
        }
    }
    
    private static List<DEN_Config__c> getConfigFor(Id dentistId) {
        return [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId];
    }
    
    public static List<ConfigWrapper> setDentistDayAvailabilityResult(Id dentistId) {
        List<ConfigWrapper> result = new List<ConfigWrapper>();
        for (DEN_Config__c config : getConfigFor(dentistId)) {
            result.add(new ConfigWrapper(config));
        }
        return result;
    }
    
    public static List<String> getAvailableTime(List<Integer> avSlots) {
        List<String> result = new List<String>();
        for (Integer i=0; i<24; i++) {
            Integer startTime = i*60;
            Integer endTime = (i + 1)*60;
            if (!avSlots.isEmpty()) {
                for (Integer idx=0; idx<avSlots.size(); idx+=2) {
                    If (startTime >= avSlots[idx] && endTime <= avSlots[idx + 1]) {
                        result.add(DEN_HoursConverterController.getPeriodString(startTime, endTime));
                    }
                }
            }
        }
        return result;
    }
    
    public static List<Integer> getAvailableConfig(Date requestDate, ID dentistId) {
        List<Integer> result = new List<Integer>();
        List<Integer> resultsToRemove = new List<Integer>();
        String selDateWeekDay = DEN_DateUtil.getWeekdayFrom(requestDate);
        Boolean dateConfig = false;
        for (DEN_Config__c config : [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId]) {
            if (config.Date__c != null && config.Date__c == requestDate) {
                dateConfig = true;
                result.add(Integer.valueOf(config.StartingHour__c));
                result.add(Integer.valueOf(config.EndingHour__c));
            }
        }
        if (!dateConfig) {
            result.clear();
            for (DEN_Config__c config : [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId]) {
                if (config.Weekday__c != null && config.Weekday__c.equalsIgnoreCase(selDateWeekDay)) {
                    result.add(Integer.valueOf(config.StartingHour__c));
                    result.add(Integer.valueOf(config.EndingHour__c));
                }
            }
        }
        List<DEN_Appointment__c> slotsWithVisits = [SELECT DateTime__c FROM DEN_Appointment__c WHERE Date__c =: requestDate and Dentist__c =: dentistId and Status__c !=: APOINTMENT_STATUS_REJECTED];
        if (!slotsWithVisits.isEmpty()) {
            for (DEN_Appointment__c appointment : slotsWithVisits) {
                resultsToRemove.add(appointment.DateTime__c.hour()*60);
            }
        }
        return DEN_CalendarMonthController.getMultipleElementLimitedResults(result, resultsToRemove);
    }
    
    public static Boolean verifyAppointmentTime(Id dentistId, DateTime appointmentTime) {
        Boolean result = true;
        List<String> avList = getAvailableTime(getAvailableConfig(appointmentTime.date(), dentistId));
        if (avList.isEmpty()) {
            return true;
        } else {
            for (String appointmentPeriod : avList) {
                Integer startTime = appointmentTime.hour() * 60;
                Integer endTime = startTime + 60;
                if (appointmentPeriod.equals(DEN_HoursConverterController.getPeriodString(startTime, endTime))) {
                    return false;
                }
            }    
        }
        return result;
    }
    
    public static Boolean ValidateResult(String email) {
        Boolean result = false;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Matcher myMatcher = Pattern.compile(emailRegex).matcher(email);
        if (myMatcher.matches()) {
            result = true;
        }
        return result;
    }
    
    public static ValidateResult validateDateInput(Integer year, Integer month, Integer day) {
        Date givenDate = Date.newInstance(year, month, day);
        if (year == null || month == null || day == null) {
            return new ValidateResult(false, REST_ERROR_MISSING_DATE_PARAM_VALUES);
        } else if (month > 12 || month <= 0) {
            return new ValidateResult(false, REST_ERROR_WRONG_MONTH);
        } else if (day > Date.daysInMonth(year, month)) {
            return new ValidateResult(false, REST_ERROR_WRONG_DAY);
        } else if (givenDate < Date.today()) {
            return new ValidateResult(false, REST_ERROR_DATE_IN_PAST);
        } else {
            return new ValidateResult(true, '');
        }
    }
}