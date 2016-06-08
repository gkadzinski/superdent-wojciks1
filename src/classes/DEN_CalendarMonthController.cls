public with sharing class DEN_CalendarMonthController {
	public Date displayedMonth {get;set;}	

	public DEN_CalendarMonthController() {
		displayedMonth = Date.today().toStartOfMonth();
	}

	public Integer getNumberDays() {
		return Date.daysInMonth(displayedMonth.year(), displayedMonth.month());
	}

	public String getFirstDayOfMonth() {
		return DateTime.newInstance(displayedMonth, Time.newInstance(0, 0, 0, 0)).format('EEE');
	}
    
    public String getActualMonthName() {
        return DateTime.newInstance(displayedMonth, Time.newInstance(0, 0, 0, 0)).format('MMM YY');
    }

	public List<CalendarWrapper> getCalendarDays() {
		List<CalendarWrapper> result = new List<CalendarWrapper>();
		if (getFirstDayOfMonth().equals('Tue')) {
			addLeadingDays(result, 1);
		}
		if (getFirstDayOfMonth().equals('Wed')) {
			addLeadingDays(result, 2);
		}
		if (getFirstDayOfMonth().equals('Thu')) {
			addLeadingDays(result, 3);
		}
		if (getFirstDayOfMonth().equals('Fri')) {
			addLeadingDays(result, 4);
		}
		if (getFirstDayOfMonth().equals('Sun')) {
			addLeadingDays(result, 5);
		}        
		if (getFirstDayOfMonth().equals('Sat')) {
			addLeadingDays(result, 6);
		}
		for (Integer day=1; day<=getNumberDays(); day++) {
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
		public String dayOfWeek {get;set;}
		public Integer day {get;set;}	
		public CalendarWrapper(String dayOfWeek, Integer day) {
			this.dayOfWeek = dayOfWeek;
			this.day = day;
		}
		public CalendarWrapper(String dayOfWeek) {
			this.dayOfWeek = dayOfWeek;
		}
	}

	public List<CalendarWrapper> addLeadingDays(List<CalendarWrapper> listToAdd, Integer days) {		
        List<String> weekDays = new List<String> {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sun', 'Sat'};
		for (Integer i=0; i<days; i++) {
			listToAdd.add(new CalendarWrapper(weekDays[i]));
        }
		return listToAdd;
	}	
}