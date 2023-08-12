@isTest
public class ErrorLogHandlerTest{

    //This data is created here only to pass record Ids of any object to the ErrorLogHandler methods since it can't be null
    @testSetup
    static void createRecordsForIds(){
        Account acc = new Account(Name = 'Test Account');
        insert acc; 
    }

    @isTest
    static void testLogErrorException(){
        try{
            Integer y = 0/0;
         }catch(Exception ex){
             List<Id> idList = new List<Id>();
             idList.add( [SELECT Id FROM Account].get(0).Id);
             ErrorLogHandler.logError('ErrorLogHandlerTest','testLogErrorException', idList , ex);
             System.assertEquals(1, [SELECT Record_Id__c, Type__c FROM Error_Log__c WHERE Type__c = 'Exception' ].size() );
         }  
    }
    
    @isTest
    static void testLogErrorResponse(){
        HttpResponse response = new NPSHttpCalloutMock().respondWithCode(new HTTPRequest(), 400);
        List<Id> idList = new List<Id>();
        idList.add( [SELECT Id FROM Account].get(0).Id);
        ErrorLogHandler.logError('ErrorLogHandlerTest','testLogErrorResponse', idList , response);
        System.assertEquals(1, [SELECT Record_Id__c, Type__c FROM Error_Log__c WHERE Type__c = 'Failed Response' ].size() );
    }
    
}