@RestResource(urlMapping = '/superDent/*')
global with sharing class DEN_RestResource {
    private static String REST_ERROR_INCORRECT_URI = 'Check the URI for errors';
    private static String REST_ERROR_DATE_IN_PAST = 'Requested date is in the past';
    private static String REST_ERROR_MISSING_DATE_PARAM_VALUES = 'Values for date parameters should not be empty';
    private static String REST_ERROR_TIME_PARAMETER = 'Time parameter is empty or invalid';
    private static String REST_ERROR_EMPTY_PARAM_DENTIST = 'dentistId parameter is empty or invalid';
    private static String REST_ERROR_EMPTY_CONTACT_PARAM = 'Contact parameter is not provided, check: contactFirst, contactLast, contactPhone';
    private static String REST_ERROR_EMPTY_PARAM = 'Please provide all fields for appointment';
    private static String REST_ERROR_MISSING_PARAMETERS = 'There are missing required parameters in the URI';
    private static String REST_ERROR_WRONG_MONTH = 'Month parameter is not valid, should be between 1 and 12';
    private static String REST_ERROR_WRONG_DAY = 'Day number exceeds the number of days in given month/year';
    private static String REST_ERROR_INCORRECT_EMAIL = 'email parameter is empty or invalid';
    private static String REST_ERROR_APPOINTMENT_NOT_AVAILABLE = 'this time for appointment is not available';

    @HttpGet
    global static void getDentistData() {
        RestRequest request = RestContext.request;
        Map<String, String> params = request.params;
        String action = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        try {
            if ('getDentists'.equals(action)) {
                setResponse(Database.query(DEN_IntegrationUtils.ALL_DENTISTS));
            } else if ('getDentistDayAvailability'.equals(action)) {
                if (params.containsKey('dentistId')) {
                    Id dentistId = params.get('dentistId');
                    setResponse(DEN_IntegrationUtils.setDentistDayAvailabilityResult(dentistId));
                } else {
                    setError(REST_ERROR_MISSING_PARAMETERS);
                }
            } else if ('getDentistTimeAvailability'.equals(action)) {
                if (params.containsKey('dentistId') && params.containsKey('year') && params.containsKey('month') && params.containsKey('day')) {
                    Id dentistId = params.get('dentistId');
                    Integer reqYear = Integer.valueOf(params.get('year'));
                    Integer reqMonth = Integer.valueOf(params.get('month'));
                    Integer reqDay = Integer.valueOf(params.get('day'));
                    if (DEN_IntegrationUtils.validateDateInput(reqYear, reqMonth, reqDay).status) {
                        Date requestDate = Date.newInstance(reqYear, reqMonth, reqDay);
                        setResponse(DEN_IntegrationUtils.getAvailableTime(DEN_IntegrationUtils.getAvailableConfig(requestDate, dentistId)));
                    } else {
                        setError(DEN_IntegrationUtils.validateDateInput(reqYear, reqMonth, reqDay).error);
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
            if (DEN_IntegrationUtils.validateDateInput(year, month, day).status) {
                if (appointmentTime > 23 || appointmentTime < 0) {
                    setError(REST_ERROR_TIME_PARAMETER);
                } else if (dentistID == null) {
                    setError(REST_ERROR_EMPTY_PARAM_DENTIST);
                } else if (String.isBlank(contactFirst) || String.isBlank(contactLast) || String.isBlank(contactPhone)) {
                    setError(REST_ERROR_EMPTY_CONTACT_PARAM);
                } else if (String.isBlank(contactEmail) || !DEN_IntegrationUtils.validateEmail(contactEmail)) {
                    setError(REST_ERROR_INCORRECT_EMAIL);
                } else if (DEN_IntegrationUtils.verifyAppointmentTime(dentistId, DEN_DateUtil.getDateTime(year, month, day, appointmentTime))) {
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
}