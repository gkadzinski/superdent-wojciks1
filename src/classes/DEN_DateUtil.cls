public class DEN_DateUtil {
    public static String getWeekdayFrom(Date selDate) {
        return getDateTime(selDate).format('EEE');
    }
    
    public static String getWeekdayFrom(Date displayedMonth, Integer day) {
        return getDateTime(getDateFrom(selDate, day)).format('EEE');
    }
    
    public static DateTime getDateTime(Date selDate) {
        return DateTime.newInstance(selDate, Time.newInstance(0, 0, 0, 0));
    }
    
    public static Integer getDaysInMonthCount(Date displayedMonth) {
        return Date.daysInMonth(displayedMonth.year(), displayedMonth.month());
    }
    
    public static String getActualMonthName(Date displayedMonth){
    	return getDateTime(displayedMonth).format('MMM YY');
    }
    
    public static Date getDateFrom(Date displayedMonth, Integer day){
    	return Date.newInstance(displayedMonth.year(), displayedMonth.month(), day);
    }
    
    
}