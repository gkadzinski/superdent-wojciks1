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
}