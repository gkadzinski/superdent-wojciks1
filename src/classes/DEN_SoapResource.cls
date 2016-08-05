global class DEN_SoapResource {
    webservice static List<DentistsResponse> getDentists() {
        List<DentistsResponse> result = new List<DentistsResponse>();
        try {
            for (User dentist : Database.query(DEN_IntegrationUtils.ALL_DENTISTS)) {
                result.add(new DentistsResponse(dentist));
            }
        } catch (Exception e) {
            result = new List<DentistsResponse>{e.getMessage()};
        }
        return result;
    }
    
    webservice static List<DentistDayAvailabilityResponse> getDentistDayAvailability(String dentist) {
        List<DentistDayAvailabilityResponse> result = new List<DentistDayAvailabilityResponse>();
        try {
            for (DEN_IntegrationUtils.ConfigWrapper config : DEN_IntegrationUtils.setDentistDayAvailabilityResult((Id)dentist)) {
                result.add(new DentistDayAvailabilityResponse(config));
            }
        } catch (Exception e) {
            result = new List<DentistsResponse>{e.getMessage()};
        }
        return result;
    }
    
    webservice static List<DentistTimeAvailabilityResponse> getDentistTimeAvailability(String dentist, Integer year, Integer month, Integer day) {
        List<DentistTimeAvailabilityResponse> result = new List<DentistTimeAvailabilityResponse>();
        try {
        	DEN_IntegrationUtils.ValidateResult validationResult = DEN_IntegrationUtils.validateDateInput(year, month, day);
            if (validationResult.status) {
                Date requestDate = Date.newInstance(year, month, day);
                for (String timePeriod : DEN_IntegrationUtils.getAvailableTime(DEN_IntegrationUtils.getAvailableConfig(requestDate, (Id)dentist))) {
                    result.add(new DentistTimeAvailabilityResponse(timePeriod));
                }
            } else {
                result = new List<DentistTimeAvailabilityResponse>{validationResult.error};
            }
        } catch (Exception e) {
            result = new List<DentistTimeAvailabilityResponse>{e.getMessage()};
        }
        return result;
    }
	
    global class DentistsResponse {
        webservice Id dentistId;
        webservice String dentistName;
        webservice String message;
        
        public DentistsResponse(User dentist) {
            this.dentistId = dentist.Id;
            this.dentistName = dentist.Name;
        }
        
        DentistsResponse(String msg) {
            this.message = msg;
        }
    }
    
    global class DentistDayAvailabilityResponse {
        webservice String timePeriod;
        webservice Date configDate;
        webservice String weekDay;
        webservice String message;
        
        public DentistDayAvailabilityResponse(DEN_IntegrationUtils.ConfigWrapper item) {
            this.timePeriod = item.timePeriod;
            this.configDate = item.configDate;
            this.weekDay = item.weekDay;
        }
        
        DentistDayAvailabilityResponse(String msg) {
            this.message = msg;
        }
    }
    
    global class DentistTimeAvailabilityResponse {
        webservice String response;
        
        public DentistTimeAvailabilityResponse(String response) {
            this.response = response;
        }
    }
}