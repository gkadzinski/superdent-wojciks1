public class DEN_DateUtil {
    public static String getWeekdayFrom(Date selDate) {
        return getDateTime(selDate).format('EEE');
    }
    
    public static String getWeekdayFrom(Date displayedMonth, Integer day) {
        return getDateTime(getDateFrom(displayedMonth, day)).format('EEE');
    }
    
    public static DateTime getDateTime(Date selDate) {
        return DateTime.newInstance(selDate, Time.newInstance(0, 0, 0, 0));
    }
    
    public static DateTime getDateTime(Integer year, Integer month, Integer day, Integer hour, Integer minutes) {
        return DateTime.newInstance(Date.newInstance(year, month, day), Time.newInstance(hour, minutes, 0, 0));
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
    
    public static String getDateTimeSuffix(DateTime dt) {
        Date mydate = dt.date();
        String dPrefix = mydate.year() + DEN_HoursConverterController.addLeadingZeros(String.valueOf(mydate.month())) + DEN_HoursConverterController.addLeadingZeros(String.valueOf(mydate.day()));
        String dSuffix = DEN_HoursConverterController.addLeadingZeros(String.valueOf(dt.hour())) + DEN_HoursConverterController.addLeadingZeros(String.valueOf(dt.minute()));
        return dPrefix + '_' + dSuffix;
    }
}