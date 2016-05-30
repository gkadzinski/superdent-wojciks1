public class myHoursController {    
    public Integer integerValue {get;set;}
    public String getstringValue() {
        String minutesResult;
        String hoursResult;
        Integer minutes = math.mod(integerValue,60);
        Integer hours = integerValue/60;
        if (minutes<10) {
            minutesResult = '0'+String.valueOf(minutes);
        } else {
            minutesResult = String.valueOf(minutes);
        }
        if (hours<10) {
            hoursResult = '0'+String.valueOf(hours);
        } else {
            hoursResult = String.valueOf(hours);
        }
        String result = hoursResult + ':' + minutesResult;  
        return result;        
    }    
}