public class DEN_IntegrationUtils {
    public static String ALL_DENTISTS = 'SELECT Id, Name, Type__c FROM User WHERE Type__c != null';
    public static String APOINTMENT_STATUS_REJECTED = 'Odrzucona';
    private static String ERROR_MISSING_DATE_PARAM_VALUES = 'Values for date parameters should not be empty';
    private static String ERROR_WRONG_MONTH = 'Month parameter is not valid, should be between 1 and 12';
    private static String ERROR_WRONG_DAY = 'Day number exceeds the number of days in given month/year';
    private static String ERROR_DATE_IN_PAST = 'Requested date is in the past';
    private static String ERROR_INCORRECT_EMAIL = 'provided email is incorrect';
    private static String ERROR_APPOINTMENT_NOT_AVAILABLE = 'this time for appointment is not available';
    private static String ERROR_TIME_PARAMETER = 'Time parameter is empty or invalid';
    private static String ERROR_EMPTY_PARAM_DENTIST = 'dentistId parameter is empty or invalid';
    private static String ERROR_EMPTY_CONTACT_PARAM = 'Contact parameter is not provided, check: contactFirst, contactLast, contactPhone';
    
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
    
    public class DenException extends Exception {}
    
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
        List<String> avList = getAvailableTime(getAvailableConfig(appointmentTime.date(), dentistId));
        for (String appointmentPeriod : avList) {
            Integer startTime = appointmentTime.hour() * 60;
            Integer endTime = startTime + 60;
            if (appointmentPeriod.equals(DEN_HoursConverterController.getPeriodString(startTime, endTime))) {
                return true;
            }
        }
        throw new DenException(ERROR_APPOINTMENT_NOT_AVAILABLE);
    }
    
    private Static Boolean validateAppointmentInputData(Id dentistId, String contactFirst, String contactLast, String contactEmail, String contactPhone, Integer year, Integer month, Integer day, Integer appointmentTime) {
        if (validateDentistId(dentistId) && verifyAppointmentTime(dentistId, DEN_DateUtil.getDateTime(year, month, day, appointmentTime)) && validateContactString(contactFirst) && validateContactString(contactLast) && validateEmail(contactEmail) && validateDateInput(year, month, day) && validateAppointmentTime(appointmentTime)) {
            return true;
        } else {
            return false;
        }
    }
    
    public static Boolean validateEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Matcher myMatcher = Pattern.compile(emailRegex).matcher(email);
        if (myMatcher.matches()) {
            return true;
        } else {
            throw new DenException(ERROR_INCORRECT_EMAIL);
        }
    }
    
    private static Boolean validateAppointmentTime(Integer timeValue) {
        if (timeValue >= 0 && timeValue <= 23) {
            return true;
        } else {
            throw new DenException(ERROR_TIME_PARAMETER);
        }
    }
    
    private static Boolean validateDentistId(Id dentist) {
        if (dentist == null) {
            throw new DenException(ERROR_EMPTY_PARAM_DENTIST);
        } else {
            return true;
        }
    }
    
    private static Boolean validateContactString(String inputString) {
        if (String.isEmpty(inputString)) {
            throw new DenException(ERROR_EMPTY_CONTACT_PARAM);
        } else {
            return true;
        }
    }
    
    public static Boolean validateDateInput(Integer year, Integer month, Integer day) {
        Date givenDate = Date.newInstance(year, month, day);
        if (year == null || month == null || day == null) {
            throw new DenException(ERROR_MISSING_DATE_PARAM_VALUES);
        } else if (month > 12 || month <= 0) {
            throw new DenException(ERROR_WRONG_MONTH);
        } else if (day > Date.daysInMonth(year, month)) {
            throw new DenException(ERROR_WRONG_DAY);
        } else if (givenDate < Date.today()) {
            throw new DenException(ERROR_DATE_IN_PAST);
        } else {
            return true;
        }
    }
    
    private static Id processContactData(String contactFirst, String contactLast, String contactEmail, String contactPhone) {
        Id result;
        String email = contactEmail;
        List<Contact> contactsMatched = [SELECT Id, Name, FirstName, LastName, Phone, Email FROM Contact WHERE Email =: email];
        if (contactsMatched.isEmpty()) {
            Contact contact = new Contact();
            contact.FirstName = contactFirst;
            contact.LastName = contactLast;
            contact.Email = contactEmail;
            contact.Phone = contactPhone;
            insert contact;
            result = contact.Id;
        } else {
            contactsMatched[0].FirstName = contactFirst;
            contactsMatched[0].LastName = contactLast;
            contactsMatched[0].Phone = contactPhone;
            update contactsMatched[0];
            result = contactsMatched[0].Id;
        }
        return result;
    }
    
    public static DEN_Appointment__c createAppointment(Id dentistId, String contactFirst, String contactLast, String contactEmail, String contactPhone, Integer year, Integer month, Integer day, Integer appointmentTime) {
        DEN_Appointment__c appointment = new DEN_Appointment__c();
        if (validateAppointmentInputData(dentistId, contactFirst, contactLast, contactEmail, contactPhone, year, month, day, appointmentTime)) {
            Date requestDate = Date.newInstance(year, month, day);
            appointment.Patient__c = processContactData(contactFirst, contactLast, contactEmail, contactPhone);
            appointment.Status__c = DEN_RegistrationController.getDefaultStatus();
            appointment.Dentist__c = dentistId;
            appointment.OwnerId = appointment.Dentist__c;
            appointment.Telephone__c = contactPhone;
            appointment.Date__c = requestDate;
            appointment.DateTime__c = DateTime.newInstance(appointment.Date__c, Time.newInstance(appointmentTime, 0, 0, 0));
            insert appointment;
        }
        return appointment;
    }
    
    public static void setError(String msg) {
        throw new DenException(msg);
    }    
}