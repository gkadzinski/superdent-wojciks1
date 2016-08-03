global class DEN_SoapResource {
    webservice static DEN_IntegrationUtils.BaseResponse getDentists() {
        return addResponse(Database.query(DEN_IntegrationUtils.ALL_DENTISTS));
    }
    
    webservice static DEN_IntegrationUtils.BaseResponse getDentistDayAvailability(String dentist) {
        try {
            Id dentistId = dentist;
            return addResponse(DEN_IntegrationUtils.setDentistDayAvailabilityResult(dentistId));
        } catch (Exception e) {
            return addError(e.getMessage());
        }
    }
    
    private static DEN_IntegrationUtils.BaseResponse addResponse(Object obj) {
        return new DEN_IntegrationUtils.BaseResponse(true, obj);
    }
    
    private static DEN_IntegrationUtils.BaseResponse addError(String msg) {
        return new DEN_IntegrationUtils.BaseResponse(false, msg);
    }
}