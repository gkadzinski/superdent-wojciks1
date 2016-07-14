public class DEN_HoursConverterController {
    public Integer integerValue {get;set;}
    
    public String getstringValue() {
        return getStringValue(integerValue);
    }
    
    public static String getStringValue(Integer intVal) {
        String hours = String.valueOf(intVal/60);
        String minutes = String.valueOf(Math.mod(intVal,60));
        
        return addLeadingZeros(hours) + ':' + addLeadingZeros(minutes);
    }
    
    public static String addLeadingZeros(String str) {
        return str.leftPad(2).replace(' ', '0');
    }
    
    public static String getPeriodString(Integer startTime, Integer endTime) {
        return getStringValue(startTime) + ' - ' + getStringValue(endTime);
    }
    
    public static Time getStartTime(String timePeriod) {
        List<String> startTime = timePeriod.split(' - ')[0].split(':');
        Integer hours = Integer.valueOf(startTime[0]);
        Integer minutes = Integer.valueOf(startTime[1]);
        return Time.newInstance(hours, minutes, 0, 0);
    }
}