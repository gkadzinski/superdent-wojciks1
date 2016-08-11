@RestResource(urlMapping = '/superDent/*')
global with sharing class DEN_RestResource {
    private static String REST_ERROR_INCORRECT_URI = 'Check the URI for errors';
    private static String REST_ERROR_MISSING_PARAMETERS = 'There are missing required parameters in the URI';

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
                    if (DEN_IntegrationUtils.validateDateInput(reqYear, reqMonth, reqDay)) {
                        Date requestDate = Date.newInstance(reqYear, reqMonth, reqDay);
                        setResponse(DEN_IntegrationUtils.getAvailableTime(DEN_IntegrationUtils.getAvailableConfig(requestDate, dentistId)));
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
    global static void createAppointment(Id dentistId, String contactFirst, String contactLast, String contactEmail, String contactPhone, Integer year, Integer month, Integer day, Integer appointmentHour, Integer appointmentTime) {
        try {
            setResponse(DEN_IntegrationUtils.createAppointment(dentistId, contactFirst, contactLast, contactEmail, contactPhone, year, month, day, appointmentHour, appointmentTime));
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
    
    global class BaseResponse {
        public Boolean success;
        public String message;
        public Object response;
        
        public BaseResponse(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public BaseResponse(Boolean success, Object response) {
            this.success = success;
            this.response = response;
        }
    }
}