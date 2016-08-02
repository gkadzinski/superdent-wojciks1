@RestResource(urlMapping = '/superDent/*')
global with sharing class DEN_RestResource {
    private static String REST_ERROR_INCORRECT_URI = 'Check the URI for errors';
    private static String REST_ERROR_DATE_IN_PAST = 'Requested date is in the past';
    private static String REST_ERROR_MISSING_DATE_PARAM_VALUES = 'Values for date parameters should not be empty';
    private static String REST_ERROR_TIME_PARAMETER = 'Time parameter is empty or invalid';
    private static String REST_ERROR_EMPTY_PARAM_DENTIST = 'dentistId parameter is empty';
    private static String REST_ERROR_EMPTY_CONTACT_PARAM = 'Contact parameter is not provided, check: contactFirst, contactLast, contactPhone';
    private static String REST_ERROR_EMPTY_PARAM = 'Please provide all fields for appointment';
    private static String REST_ERROR_MISSING_PARAMETERS = 'There are missing required parameters in the URI';
    private static String APOINTMENT_STATUS_REJECTED = 'Odrzucona';
    private static String REST_ERROR_WRONG_MONTH = 'Month parameter is not valid, should be between 1 and 12';
    private static String REST_ERROR_WRONG_DAY = 'Day number exceeds the number of days in given month/year';
    private static String REST_ERROR_INCORRECT_EMAIL = 'email parameter is empty or invalid';
    private static String REST_ERROR_APPOINTMENT_NOT_AVAILABLE = 'this time for appointment is not available';

    @HttpGet
    global static void getDentistData() {
        RestRequest request = RestContext.request;
        String requestString = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        try {
            if ('getDentists'.equals(requestString)) {
                setResponse([SELECT Id, Name, Type__c FROM User WHERE Type__c != null]);    
            } else if ('getDentistDayAvailability'.equals(requestString)) {
                if (request.params.containsKey('dentistId')) {
                    List<ConfigWrapper> result = new List<ConfigWrapper>();
                    Id dentistId = request.params.get('dentistId');
                    for (DEN_Config__c config : getConfigFor(dentistId)) {
                        result.add(new ConfigWrapper(config));
                    }
                    setResponse(result);
                } else {
                    setError(REST_ERROR_MISSING_PARAMETERS);
                }
            } else if ('getDentistTimeAvailability'.equals(requestString)) {
                if (request.params.containsKey('dentistId') && request.params.containsKey('year') && request.params.containsKey('month') && request.params.containsKey('day')) {
                    Id dentistId = request.params.get('dentistId');
                    Integer reqYear = Integer.valueOf(request.params.get('year'));
                    Integer reqMonth = Integer.valueOf(request.params.get('month'));
                    Integer reqDay = Integer.valueOf(request.params.get('day'));
                    if (validateDateInput(reqYear, reqMonth, reqDay)) {
                        Date requestDate = Date.newInstance(reqYear, reqMonth, reqDay);
                        setResponse(getAvailableTime(getAvailableConfig(requestDate, dentistId)));
                    }
                } else {
                    setError(REST_ERROR_MISSING_PARAMETERS);
                }
            } else {
                setError(REST_ERROR_INCORRECT_URI);
            }
        } catch (Exception e) {
            setError(e.getMessage());
        }
    }
    
    @HttpPost
    global static void createAppointment(Id dentistId, String contactFirst, String contactLast, String contactEmail, String contactPhone, Integer year, Integer month, Integer day, Integer appointmentTime) {
        try {
            if (validateDateInput(year, month, day)) {
                if (appointmentTime > 23 || appointmentTime < 0) {
                    setError(REST_ERROR_TIME_PARAMETER);
                } else if (dentistID == null) {
                    setError(REST_ERROR_EMPTY_PARAM_DENTIST);
                } else if (String.isBlank(contactFirst) || String.isBlank(contactLast) || String.isBlank(contactPhone)) {
                    setError(REST_ERROR_EMPTY_CONTACT_PARAM);
                } else if (String.isBlank(contactEmail) || !validateEmail(contactEmail)) {
                    setError(REST_ERROR_INCORRECT_EMAIL);
                } else if (verifyAppointmentTime(dentistId, DateTime.newInstance(Date.newInstance(year, month, day), Time.newInstance(appointmentTime, 0, 0, 0)))) {
                    setError(REST_ERROR_APPOINTMENT_NOT_AVAILABLE);
                } else {
                    Date requestDate = Date.newInstance(year, month, day);
                    DEN_Appointment__c appointment = new DEN_Appointment__c();
                    String email = contactEmail;
                    List<Contact> contactsMatched = [SELECT Id, Name, FirstName, LastName, Phone, Email FROM Contact WHERE Email =: email];
                    if (contactsMatched.isEmpty()) {
                        Contact contact = new Contact();
                        contact.FirstName = contactFirst;
                        contact.LastName = contactLast;
                        contact.Email = contactEmail;
                        contact.Phone = contactPhone;
                        insert contact;
                        appointment.Patient__c = contact.Id;
                    } else {
                        contactsMatched[0].FirstName = contactFirst;
                        contactsMatched[0].LastName = contactLast;
                        contactsMatched[0].Phone = contactPhone;
                        update contactsMatched[0];
                        appointment.Patient__c = contactsMatched[0].Id;
                    }
                    appointment.Status__c = DEN_RegistrationController.getDefaultStatus();
                    appointment.Dentist__c = dentistId;
                    appointment.OwnerId = appointment.Dentist__c;
                    appointment.Telephone__c = contactPhone;
                    appointment.Date__c = requestDate;
                    appointment.DateTime__c = DateTime.newInstance(appointment.Date__c, Time.newInstance(appointmentTime, 0, 0, 0));
                    insert appointment;
                    setResponse(appointment);
                } 
            }
        } catch (Exception e) {
            setError(e.getMessage());
        }
    }
    /*
     {
"dentistId" : "00558000000VkA5AAK",
"contactFirst" : "marian",
"contactLast" : "brando",
"contactEmail" : "testRest@rest.pl",
"contactPhone" : "23234234",
"year" : 2016,
"month" : 8,
"day" : 9,
"appointmentTime" : 4
}
	*/
    private static Boolean validateEmail(String email) {
        Boolean result = false;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Matcher myMatcher = Pattern.compile(emailRegex).matcher(email);
        if (myMatcher.matches()) {
            result = true;
        }
        return result;
    }
    
    private static Boolean validateDateInput(Integer year, Integer month, Integer day) {
        Date givenDate = Date.newInstance(year, month, day);
        if (year == null || month == null || day == null) {
            setError(REST_ERROR_MISSING_DATE_PARAM_VALUES);
            return false;
        } else if (month > 12 || month <= 0) {
            setError(REST_ERROR_WRONG_MONTH);
            return false;
        } else if (day > Date.daysInMonth(year, month)) {
            setError(REST_ERROR_WRONG_DAY);
            return false;
        } else if (givenDate < Date.today()) {
            setError(REST_ERROR_DATE_IN_PAST);
            return false;
        } else {
            return true;
        }
    }
    
    private static Boolean verifyAppointmentTime(Id dentistId, DateTime appointmentTime) {
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
    
    private static List<DEN_Config__c> getConfigFor(Id dentistId) {
        return [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId];
    }
    
    private static void setError(String msg) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(new BaseResponse(false, msg)));
    }
    
    private static void setResponse(Object obj) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(new BaseResponse(true, obj)));
    }    
    
    public class BaseResponse {
        public Boolean status;
        public String message;
        public Object response;
        
        public BaseResponse(Boolean status, String message) {
            this.status = status;
            this.message = message;
        }
        
        public BaseResponse(Boolean status, Object response) {
            this.status = status;
            this.response = response;
        }
    }
    
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
}