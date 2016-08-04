global class DEN_SoapResource {
    webservice static List<DentistsResponse> getDentists() {
        List<DentistsResponse> result = new List<DentistsResponse>();
        try {
            for (User dentist : Database.query(DEN_IntegrationUtils.ALL_DENTISTS)) {
                result.add(new DentistsResponse(dentist));
            }
            return result;
        } catch (Exception e) {
            result.clear();
            result.add(new DentistsResponse(e.getMessage()));
            return result;
        }
    }
    
    webservice static List<DentistDayAvailabilityResponse> getDentistDayAvailability(String dentist) {
        List<DentistDayAvailabilityResponse> result = new List<DentistDayAvailabilityResponse>();
        try {
            Id dentistId = dentist;
            for (DEN_IntegrationUtils.ConfigWrapper config : DEN_IntegrationUtils.setDentistDayAvailabilityResult(dentistId)) {
                result.add(new DentistDayAvailabilityResponse(config));
            }
            return result;
        } catch (Exception e) {
            result.clear();
            result.add(new DentistDayAvailabilityResponse(e.getMessage()));
            return result;
        }
    }
    
    webservice static List<DentistTimeAvailabilityResponse> getDentistTimeAvailability(String dentist, Integer year, Integer month, Integer day) {
        List<DentistTimeAvailabilityResponse> result = new List<DentistTimeAvailabilityResponse>();
        try {
            Id dentistId = dentist;
            if (DEN_IntegrationUtils.validateDateInput(year, month, day).status) {
                Date requestDate = Date.newInstance(year, month, day);
                for (String timePeriod : DEN_IntegrationUtils.getAvailableTime(DEN_IntegrationUtils.getAvailableConfig(requestDate, dentistId))) {
                    result.add(new DentistTimeAvailabilityResponse(timePeriod));
                }
                return result;
            } else {
                String error = DEN_IntegrationUtils.validateDateInput(year, month, day).error;
                result.add(new DentistTimeAvailabilityResponse(error));
                return result;
            }
        } catch (Exception e) {
            result.clear();
            result.add(new DentistTimeAvailabilityResponse(e.getMessage()));
            return result;
        }
    }
	
    global class DentistsResponse {
        webservice Id dentistId;
        webservice String dentistName;
        webservice String message;
        
        global DentistsResponse(User dentist) {
            this.dentistId = dentist.Id;
            this.dentistName = dentist.Name;
        }
        
        global DentistsResponse(String msg) {
            this.message = msg;
        }
    }
    
    global class DentistDayAvailabilityResponse {
        webservice String timePeriod;
        webservice Date configDate;
        webservice String weekDay;
        webservice String message;
        
        global DentistDayAvailabilityResponse(DEN_IntegrationUtils.ConfigWrapper item) {
            this.timePeriod = item.timePeriod;
            this.configDate = item.configDate;
            this.weekDay = item.weekDay;
        }
        
        global DentistDayAvailabilityResponse(String msg) {
            this.message = msg;
        }
    }
    
    global class DentistTimeAvailabilityResponse {
        webservice String response;
        
        global DentistTimeAvailabilityResponse(String response) {
            this.response = response;
        }
    }
}