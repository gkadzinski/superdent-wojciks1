@RestResource(urlMapping = '/superDent/*')
global with sharing class DEN_RestResource {
    private static String REST_ERROR_INCORRECT_URI = 'Check the URI for errors';
    private static String REST_ERROR_INCORRECT_DATE = 'Requested date is in the past';
    private static String REST_ERROR_INCORRECT_DATE_PARAM = 'Data parameters are not valid';

	@HttpGet
    global static void getDentistData() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestString = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        if ('getDentists'.equals(requestString)) {
            List<User> dentistList = [SELECT Id, Name, Type__c FROM User WHERE Type__c != null];
            try {
            	response = addContentToResponse(new BaseResponse(true, dentistList));    
            } catch (Exception e) {
                response = addContentToResponse(new BaseResponse(false, e.getMessage()));
            }
        } else if ('getDentistDayAvailability'.equals(requestString)) {
            List<ConfigWrapper> result = new List<ConfigWrapper>();
            try {
                Id dentistId = request.params.get('dentistId');
                for (DEN_Config__c config : [SELECT Date__c, Weekday__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId]) {
                    result.add(new ConfigWrapper(config));
                }
                response = addContentToResponse(new BaseResponse(true, result));
            } catch (Exception e) {
                response = addContentToResponse(new BaseResponse(false, e.getMessage()));
            }
        } else if ('getDentistTimeAvailability'.equals(requestString)) {
            try {
                Id dentistId = request.params.get('dentistId');
                Integer reqYear = Integer.valueOf(request.params.get('year'));
                Integer reqMonth = Integer.valueOf(request.params.get('month'));
                Integer reqDay = Integer.valueOf(request.params.get('day'));
                Date requestDate = Date.newInstance(reqYear, reqMonth, reqDay);
                if (reqYear > 2099 || reqMonth > 12 || reqMonth ==0 || reqDay ==0 || reqDay > 31) {
                    response = addContentToResponse(new BaseResponse(false, REST_ERROR_INCORRECT_DATE_PARAM));
                } else if (requestDate < Date.today()) {
                    response = addContentToResponse(new BaseResponse(false, REST_ERROR_INCORRECT_DATE));
                } else {
                    response = addContentToResponse(new BaseResponse(true, getTimeSlots(getAvailableSlots(requestDate, dentistId))));
                }
            } catch (Exception e) {
                response = addContentToResponse(new BaseResponse(false, e.getMessage()));
            }
        } else {
            response = addContentToResponse(new BaseResponse(false, REST_ERROR_INCORRECT_URI));
        }
    }
    
    public static RestResponse addContentToResponse(BaseResponse br) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(br));
        return RestContext.response;
    }
    
    public static List<String> getTimeSlots(List<Integer> avSlots) {
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
    
    public static List<Integer> getAvailableSlots(Date requestDate, ID dentistId) {
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
                if (config.Weekday__c != null && config.Weekday__c.equals(selDateWeekDay.toUpperCase())) {
                    result.add(Integer.valueOf(config.StartingHour__c));
                    result.add(Integer.valueOf(config.EndingHour__c));
                }
            }
        }
        List<DEN_Appointment__c> slotsWithVisits = [SELECT DateTime__c FROM DEN_Appointment__c WHERE Date__c =: requestDate and Dentist__c =: dentistId and Status__c != 'Odrzucona'];
        if (!slotsWithVisits.isEmpty()) {
            for (DEN_Appointment__c appointment : slotsWithVisits) {
                resultsToRemove.add(appointment.DateTime__c.hour()*60);
            }
        }
        return DEN_CalendarMonthController.getMultipleElementLimitedResults(result, resultsToRemove);
    }
    
    public class BaseResponse {
        public Boolean status;
        public String message;
        public Object response;
        
        public BaseResponse() {
        }
        
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