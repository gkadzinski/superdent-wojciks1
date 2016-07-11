public with sharing class DEN_CalendarMonthController {
    public static final List<String> WEEKDAYS = new List<String> {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
	
    private List<DEN_Config__c> userConfig {get; set;}
    public Id dentistId {get; set;}
    public Date displayedMonth {get; set;}
    public Integer selectedDay {get; set;}
    
    public DEN_CalendarMonthController() {
        displayedMonth = Date.today().toStartOfMonth();
	}
    
    public String getDentistName() {
        return (dentistId == null ? null : [SELECT Id, Name, Username FROM User WHERE Id =: dentistId].Name);
    }
    
    public String getActualMonthName() {
        return DEN_DateUtil.getActualMonthName(displayedMonth);
    }
    
    public List<TimeWrapper> getAllTimeSlots() {
        List<TimeWrapper> result = new List<TimeWrapper>();
        List<Integer> availableTimePeriod = getAvailableSlots();
        Boolean available;
        for (Integer i=0; i<24; i++) {
            available = false;
            Integer startTime = i*60;
            Integer endTime = (i + 1)*60;
            if (availableTimePeriod.size() > 0) {
                for (Integer idx=0; idx<availableTimePeriod.size(); idx+=2) {
                    If (startTime >= availableTimePeriod[idx] && endTime <= availableTimePeriod[idx + 1]) {
                        available = true;
                    }
                }
            }
            String timePeriod = DEN_HoursConverterController.getPeriodString(startTime, endTime);
            result.add(new TimeWrapper(timePeriod, available));
        }
        return result;
    }
    
	public List<CalendarWrapper> getCalendarDays() {        
        userConfig = [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId];
		List<CalendarWrapper> result = getLeadingDays(DEN_DateUtil.getWeekdayFrom(displayedMonth));
		for (Integer day=0; day<DEN_DateUtil.getDaysInMonthCount(displayedMonth); day++) {
            Boolean available = false;
			String dayOfWeek = DEN_DateUtil.getWeekdayFrom(displayedMonth, day + 1);
            if (displayedMonth.addDays(day) >= Date.today()) {
                for (DEN_Config__c config : userConfig) {
                    if ((config.Weekday__c != null && config.Weekday__c.equals(dayOfWeek.toUpperCase())) || (config.Date__c != null && config.Date__c == displayedMonth.addDays(day))) {
                        available = true;
                        break;
                    }
                }
            }
			result.add(new CalendarWrapper(dayOfWeek, day +1, available));
		}
		return result;
	}
	
	private List<CalendarWrapper> getLeadingDays(String dayUntil) {
        List<CalendarWrapper> retList = new List<CalendarWrapper>();
		for (Integer i=0; i<WEEKDAYS.size(); i++) {
            if (WEEKDAYS[i].equals(dayUntil)) {
                break;
            }
			retList.add(new CalendarWrapper(WEEKDAYS[i], null, false));
        }
		return retList;
	}
	
	private List<Integer> getAvailableSlots() {
        List<Integer> result = new List<Integer>();
        if (dentistId != null && selectedDay != null) {
            Date selDate = DEN_DateUtil.getDateFrom(displayedMonth, selectedDay);
            String selDateWeekDay = DEN_DateUtil.getWeekdayFrom(selDate);
            Boolean dateConfig = false;
            for (DEN_Config__c config : userConfig) {
                if (config.Date__c != null && config.Date__c == selDate) {
                    dateConfig = true;
                    result.add(Integer.valueOf(config.StartingHour__c));
                    result.add(Integer.valueOf(config.EndingHour__c));
                }
            }
            if (!dateConfig) {
                result.clear();
                for (DEN_Config__c config : userConfig) {
                    if (config.Weekday__c != null && config.Weekday__c.equals(selDateWeekDay.toUpperCase())) {
						result.add(Integer.valueOf(config.StartingHour__c));
                        result.add(Integer.valueOf(config.EndingHour__c));
                    }
                }
            }
        }
        return result;
    }

	public PageReference nextMonth() {
        displayedMonth = displayedMonth.addMonths(1);
		return null;
	}

	public PageReference previousMonth() {
        displayedMonth = displayedMonth.addMonths(-1);
		return null;
	}

	public class CalendarWrapper {
		public String dayOfWeek {get; set;}
		public Integer day {get; set;}
        public Boolean available {get; set;}
		public CalendarWrapper(String dayOfWeek, Integer day, Boolean available) {
			this.dayOfWeek = dayOfWeek;
			this.day = day;
            this.available = available;
		}
	}
    
    public class TimeWrapper {
        public String timePeriod {get; set;}
        public Boolean available {get; set;}
        public TimeWrapper(String timePeriod, Boolean available) {
            this.timePeriod = timePeriod;
            this.available = available;
        }
    }

}