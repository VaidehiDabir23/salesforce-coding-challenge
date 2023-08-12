//This class is written to create the custom error handling object record.
public class ErrorLogHandler{
    
    //This method logs error when the error is caused by Exception.
    public static void logError(String className, String methodName,  List<Id> recordIds, Exception ex) {
        List<Error_Log__c> loggerList = new List<Error_Log__c>();
        for(Id recordId : recordIds){
            Error_Log__c logger = new Error_Log__c();
            logger.Class_Name__c = className;
            logger.Method_Name__c = methodName;
            logger.Type__c = 'Exception';
            logger.Error_Message__c = ex.getMessage();
            logger.Stack_Trace__c = ex.getStackTraceString();
            logger.Line_Number__c = ex.getLineNumber();
            logger.Record_Id__c = recordId;
            loggerList.add(logger); 
        }
        insert loggerList;
    }
    
    //This method logs error when the error is caused by a failed or unsuccessful response from NPS.
     public static void logError(String className, String methodName,  List<Id> recordIds, HttpResponse response) {
        List<Error_Log__c> loggerList = new List<Error_Log__c>();
        for(Id recordId : recordIds){
            Error_Log__c logger = new Error_Log__c();
            logger.Class_Name__c = className;
            logger.Method_Name__c = methodName;
            logger.Type__c = 'Failed Response';
            logger.Response_Body__c = response.getBody();
            logger.Response_Code__c = response.getStatusCode();
            logger.Record_Id__c = recordId;
            loggerList.add(logger);
        }
        insert loggerList;
    }
}