global class DEN_SoapResource {
    webservice static List<DentistsResponse> getDentists() {
        List<DentistsResponse> result = new List<DentistsResponse>();
        try {
            for (User dentist : Database.query(DEN_IntegrationUtils.ALL_DENTISTS)) {
                result.add(new DentistsResponse(dentist));
            }
        } catch (Exception e) {
            DEN_IntegrationUtils.setError(e.getMessage());
        }
        return result;
    }
    
    webservice static List<DentistDayAvailabilityResponse> getDentistDayAvailability(String dentist) {
        List<DentistDayAvailabilityResponse> result = new List<DentistDayAvailabilityResponse>();
        try {
            Id dentistId = dentist;
            for (DEN_IntegrationUtils.ConfigWrapper config : DEN_IntegrationUtils.setDentistDayAvailabilityResult(dentistId)) {
                result.add(new DentistDayAvailabilityResponse(config));
            }
        } catch (Exception e) {
            DEN_IntegrationUtils.setError(e.getMessage());
        }
        return result;
    }
    
    webservice static List<DentistTimeAvailabilityResponse> getDentistTimeAvailability(String dentist, Integer year, Integer month, Integer day) {
        List<DentistTimeAvailabilityResponse> result = new List<DentistTimeAvailabilityResponse>();
        try {
            if (DEN_IntegrationUtils.validateDateInput(year, month, day)) {
                Date requestDate = Date.newInstance(year, month, day);
                for (String timePeriod : DEN_IntegrationUtils.getAvailableTime(DEN_IntegrationUtils.getAvailableConfig(requestDate, (Id)dentist))) {
                    result.add(new DentistTimeAvailabilityResponse(timePeriod));
                }
            }
        } catch (Exception e) {
            DEN_IntegrationUtils.setError(e.getMessage());
        }
        return result;
    }
    
    webservice static AppointmentResponse createAppointment(Id dentistId, String contactFirst, String contactLast, String contactEmail, String contactPhone, Integer year, Integer month, Integer day, Integer appointmentTime) {
        AppointmentResponse result = new AppointmentResponse();
        try {
            result = new AppointmentResponse(DEN_IntegrationUtils.createAppointment(dentistId, contactFirst, contactLast, contactEmail, contactPhone, year, month, day, appointmentTime));
        } catch (Exception e) {
            DEN_IntegrationUtils.setError(e.getMessage());
        }
        return result;
    }
	
    global class DentistsResponse {
        webservice Id dentistId;
        webservice String dentistName;
        
        public DentistsResponse(User dentist) {
            this.dentistId = dentist.Id;
            this.dentistName = dentist.Name;
        }
    }
    
    global class DentistDayAvailabilityResponse {
        webservice String timePeriod;
        webservice Date configDate;
        webservice String weekDay;
        
        public DentistDayAvailabilityResponse(DEN_IntegrationUtils.ConfigWrapper item) {
            this.timePeriod = item.timePeriod;
            this.configDate = item.configDate;
            this.weekDay = item.weekDay;
        }
    }
    
    global class DentistTimeAvailabilityResponse {
        webservice String response;
        
        public DentistTimeAvailabilityResponse(String response) {
            this.response = response;
        }
    }
    
    global class AppointmentResponse {
        webservice String response;
        
        public AppointmentResponse(DEN_Appointment__c appointment) {
            this.response = appointment.Id;
        }
        
        AppointmentResponse() {
            
        }
    }
}