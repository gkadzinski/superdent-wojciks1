public with sharing class DEN_CalendarMonthController {
	public static final List<String> WEEKDAYS = new List<String> {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sun', 'Sat'};
	
	private DateTime dateGiven;
	public Date displayedMonth {get;
								set {
										displayedMonth = value;
										dateGiven = DateTime.newInstance(displayedMonth, Time.newInstance(0, 0, 0, 0));
									}
								}

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
		List<CalendarWrapper> result = getLeadingDays(getFirstDayOfMonth());
		for (Integer day=1; day<=getDaysInMonthCount(); day++) {
			String dayOfWeek = DateTime.newInstance(Date.newInstance(displayedMonth.year(), displayedMonth.month(), day), Time.newInstance(0, 0, 0, 0)).format('EEE');
			result.add(new CalendarWrapper(dayOfWeek, day));
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
		
		public CalendarWrapper(String dayOfWeek, Integer day) {
			this.dayOfWeek = dayOfWeek;
			this.day = day;
		}
		
		public CalendarWrapper(String dayOfWeek) {
			CalendarWrapper(dayOfWeek, null);
		}
	}

	public List<CalendarWrapper> getLeadingDays(String dayUntil) {
		List<CalendarWrapper> retList = new List<CalendarWrapper>();
		for (Integer i=0; i<WEEKDAYS; i++) {
			if (WEEKDAYS[i].equals(dayUntil)){
				break;
			}
			retList.add(new CalendarWrapper(WEEKDAYS[i]));
        }
		return retList;
	}
}