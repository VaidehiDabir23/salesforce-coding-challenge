//This class contains the unit tests for the methods of class OrderNPSService 
@isTest
public class OrderNPSServiceTest{

    @testSetup
    static void createOrders(){
        List<Order> orders = new List<Order>();
        
        Contact con = new Contact(LastName='Test Record', Email = 'test@email.com');
        insert con; 
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        for(Integer i=0; i<10; i++){
            Order record = new Order(Status='Draft', BillToContactId=con.Id, AccountId = acc.Id, EffectiveDate = Date.Today());
            orders.add(record);
        }
        insert orders;
    }
    //This method tests the happy scenario
    @isTest
    static void testSendOrderDataToNPS(){
        List<Id> orderIds = new List<Id>();
        for(Order record : [SELECT Id FROM Order Limit 4]){
            orderIds.add(record.Id);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NPSHttpCalloutMock());
        
        OrderNPSService.sendOrderDataToNPS(orderIds);
        
        Test.stopTest();
        List<Error_Log__c> logList = [SELECT Record_Id__c, Error_Message__c, Stack_Trace__c, Line_Number__c, Method_Name__c FROM Error_Log__c  WHERE Record_Id__c  IN:orderIds];
        
        for(Error_Log__c err: logList){
            System.debug('Error log : '+err);
        }
        
        System.assertEquals(6, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size());
        System.assertEquals(4, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size());
        System.assertEquals(0, [SELECT Record_Id__c, Type__c FROM Error_Log__c].size());
        
    }
    
    //This method tests the flow when no record is retrieved by retrieveOrdersMap() i.e. all the incoming orders are already sent to NPS
    @isTest
    static void testAlreadyProcessedOrders(){
        
        List<Order> orders = [SELECT Id FROM Order];
        List<Id> orderIds = new List<Id>();
        for(Order record : orders){
            record.Sent_to_NPS__c = true;
            orderIds.add(record.Id);
        }
        update orders;

        OrderNPSService.sendOrderDataToNPS(orderIds);

        System.assertEquals(0, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size());
        System.assertEquals(10, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size());
        System.assertEquals(0, [SELECT Record_Id__c, Type__c FROM Error_Log__c].size() );
    }

    //This method tests the scenario when callout exception occurs
    @isTest
    static void testSendOrderDataToNPSException(){
        List<Id> orderIds = new List<Id>();
        for(Order record : [SELECT Id FROM Order]){
            orderIds.add(record.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new NPSHttpCalloutMock());
        
        OrderNPSService.sendOrderDataToNPS(orderIds);
        
        
        System.assertEquals(10, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size()); 
        System.assertEquals(0, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size()); 
        System.assertEquals(10, [SELECT Record_Id__c, Type__c FROM Error_Log__c WHERE Type__c = 'Exception' ].size() );
        
    }
    
    
    
    //This test method is written to test the handleResponse method separately in case of status code 200
    @isTest
    static void testHandleResponseCode200(){
        
        List<Id> orderIds = new List<Id>();
        for(Order record : [SELECT Id FROM Order limit 6]){
            orderIds.add(record.Id);
        }
        
        Map<Id, Order> orderMap = OrderNPSService.retrieveOrdersMap(orderIds);
        
        OrderNPSService.handleResponse(new NPSHttpCalloutMock().respondWithCode(new HTTPRequest(), 200), orderMap );
        
        System.assertEquals(4, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size());
        System.assertEquals(6, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size());
        System.assertEquals(0, [SELECT Record_Id__c, Type__c FROM Error_Log__c ].size() );
    }
    
    //This test method is written to test the handleResponse method separately in case of status code 400
    @isTest
    static void testHandleResponseCode400(){
        
        List<Id> orderIds = new List<Id>();
        for(Order record : [SELECT Id FROM Order limit 7]){
            orderIds.add(record.Id);
        }
        
        Map<Id, Order> orderMap = OrderNPSService.retrieveOrdersMap(orderIds);
        
        OrderNPSService.handleResponse(new NPSHttpCalloutMock().respondWithCode(new HTTPRequest(), 400), orderMap );
       
        System.assertEquals(10, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size()); 
        System.assertEquals(0, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size()); 
        System.assertEquals(7, [SELECT Record_Id__c, Type__c FROM Error_Log__c WHERE Type__c = 'Failed Response' ].size() );
    }
    
    //This test method is written to test the handleResponse method separately in case of status code 500
    @isTest
    static void testHandleResponseCode500(){
        
        List<Id> orderIds = new List<Id>();
        for(Order record : [SELECT Id FROM Order LIMIT  3]){
            orderIds.add(record.Id);
        }
        
        Map<Id, Order> orderMap = OrderNPSService.retrieveOrdersMap(orderIds);
        
        OrderNPSService.handleResponse(new NPSHttpCalloutMock().respondWithCode(new HTTPRequest(), 500), orderMap );
        
        System.assertEquals(10, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size());
        
        System.assertEquals(10, [SELECT Id FROM Order WHERE Sent_to_NPS__c = false].size()); 
        System.assertEquals(0, [SELECT Id FROM Order WHERE Sent_to_NPS__c = true].size()); 
        System.assertEquals(3, [SELECT Record_Id__c, Type__c FROM Error_Log__c WHERE Type__c = 'Failed Response' ].size() );
        
    }
    
    
    
    
}