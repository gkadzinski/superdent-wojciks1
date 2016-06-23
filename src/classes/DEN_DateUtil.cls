public class DEN_DateUtil {
    public static String getWeekdayFrom(Date selDate) {
        return getDateTime(selDate).format('EEE');
    }
    
    public static DateTime getDateTime(Date selDate) {
        return DateTime.newInstance(selDate, Time.newInstance(0, 0, 0, 0));
    }
}