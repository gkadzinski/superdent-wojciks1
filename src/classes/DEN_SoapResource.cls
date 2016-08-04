global class DEN_SoapResource {
    webservice static DentistsResponse getDentists() {
        return new DentistsResponse(true, Database.query(DEN_IntegrationUtils.ALL_DENTISTS));
    }
    
    webservice static DentistTimeAvailabilityResponse getDentistTimeAvailability(String dentist) {
        try {
            Id dentistId = dentist;
            return new DentistTimeAvailabilityResponse(true, DEN_IntegrationUtils.setDentistDayAvailabilityResult(dentistId));
        } catch (Exception e) {
            return new DentistTimeAvailabilityResponse(false, e.getMessage());
        }
    }
	
    global class DentistsResponse {
        webservice Boolean status;
        webservice List<User> response;
        
        global DentistsResponse(Boolean status, List<User> response) {
            this.status = status;
            this.response = response;
        }
    }
    
    global class DentistTimeAvailabilityResponse {
        webservice Boolean status;
        webservice String message;
        webservice List<DEN_IntegrationUtils.ConfigWrapper> response;
        
        global DentistTimeAvailabilityResponse(Boolean status, List<DEN_IntegrationUtils.ConfigWrapper> response) {
            this.status = status;
            this.response = response;
        }
        
        global DentistTimeAvailabilityResponse(Boolean status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}