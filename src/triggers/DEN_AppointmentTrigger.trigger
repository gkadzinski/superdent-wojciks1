trigger DEN_AppointmentTrigger on DEN_Appointment__c (before insert) {
    List<User> dentistList = [SELECT Id, FirstName, LastName FROM User WHERE Type__c != null];
    List<Contact> patientList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != null];
    for (DEN_Appointment__c appointment : Trigger.new) {
        appointment.Name = getAppointmentName(appointment.Dentist__c, appointment.Patient__c, appointment.DateTime__c);
    }
    
    private String getAppointmentName(Id dentist, Id patient, DateTime dt) {
        User matchedDentist = new User();
        Contact matchedContact = new Contact();
        for (User den : dentistList) {
            if (den.Id.equals(dentist)) {
                matchedDentist = den;
                break;
            }
        }
        for (Contact con : patientList) {
            if (con.Id.equals(patient)) {
                matchedContact = con;
                break;
            }
        }
        return DEN_StringUtil.getInitials(matchedDentist) + '_' + DEN_StringUtil.getInitials(matchedContact) + '_' + DEN_DateUtil.getDateTimeSuffix(dt);
    }
}