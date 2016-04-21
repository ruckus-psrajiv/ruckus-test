public with sharing class ApplicationUtility {
	public static String mStrRegex = null;
	
	private static void initLimits() {
		if(mStrRegex == null) {
			//SerialNumberCriteria__c lSNC = SerialNumberCriteria__c.getValues('REGEX');
			//mStrRegex = lSNC.Value__c;
			mStrRegex = '^' + Label.SerialNumberPattern + '$';
		}
	}
	
	public static Boolean isSerialNumerValid(String argStrSerialNo) {
		initLimits();
		
		if(	argStrSerialNo != null &&
			(Pattern.matches(mStrRegex, argStrSerialNo))) {
		    return true;
		}
		
		return false;		
	}
	
	public void testMethod(){
		system.debug('Test Method');
	}
}