public with sharing class DEN_CalendarMonthController {
    public static final List<String> WEEKDAYS = new List<String> {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
	
    private DateTime dateGiven;
    public Date displayedMonth {
        get;
        set {
            displayedMonth = value;
            dateGiven = DateTime.newInstance(displayedMonth, Time.newInstance(0, 0, 0, 0));
        }
    }
    public Id dentistId {get; set;}
    private List<DEN_Config__c> userConfig {get; set;}

	public DEN_CalendarMonthController() {
        displayedMonth = Date.today().toStartOfMonth();
	}

	public Integer getDaysInMonthCount() {
		return Date.daysInMonth(displayedMonth.year(), displayedMonth.month());
	}

	public String getFirstDayOfMonth() {
		return dateGiven.format('EEE');
	}
    
    public String getActualMonthName() {
        return dateGiven.format('MMM YY');
    }

	public List<CalendarWrapper> getCalendarDays() {
        userConfig = [SELECT Id, Name, Weekday__c, Date__c, StartingHour__c, EndingHour__c FROM DEN_Config__c WHERE Dentist__c =: dentistId];
		List<CalendarWrapper> result = getLeadingDays(getFirstDayOfMonth());
		for (Integer day=0; day<getDaysInMonthCount(); day++) {
            Boolean available = false;
			String dayOfWeek = DateTime.newInstance(Date.newInstance(displayedMonth.year(), displayedMonth.month(), day +1), Time.newInstance(0, 0, 0, 0)).format('EEE');
            if (displayedMonth.addDays(day) > Date.today()) {
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

	public List<CalendarWrapper> getLeadingDays(String dayUntil) {
        List<CalendarWrapper> retList = new List<CalendarWrapper>();
		for (Integer i=0; i<WEEKDAYS.size(); i++) {
            if (WEEKDAYS[i].equals(dayUntil)) {
                break;
            }
			retList.add(new CalendarWrapper(WEEKDAYS[i], null, false));
        }
		return retList;
	}
}