public class DEN_HoursConverterController {    
    public Integer integerValue {get;set;}
    
    public String getStringValue() {
        String hours = String.valueOf(integerValue/60);
        String minutes = String.valueOf(Math.mod(integerValue, 60));
        
        return addLeadingZeros(hours) + ':' + addLeadingZeros(minutes);        
    }
    
    private String addLeadingZeros(String str){
    	return str.leftPad(2).replace(' ', '0');
    }
}