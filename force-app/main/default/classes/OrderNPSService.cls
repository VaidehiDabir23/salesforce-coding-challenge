//This is class encapsulates functionality to send order data to an external service called NPS.
public With Sharing class OrderNPSService {

    //This method sequentially executes chunks of code that make a callout to NPS. 
    @InvocableMethod(label = 'Send Order Data to NPS' callout=true)
    public static void sendOrderDataToNPS(List<Id> orderIds) {
        Map<Id, Order> retrievedOrdersMap = retrieveOrdersMap(orderIds);
        
        if (!retrievedOrdersMap.isEmpty()) {
            String requestBody = buildRequestBody(retrievedOrdersMap);
            sendRequestToNPS(requestBody, retrievedOrdersMap);  
        } 
    }

    //This method returns the orders that are not previously sent to the NPS by accepting their Ids as parameter. 
    public static Map<Id, Order> retrieveOrdersMap(List<Id> orderIds) {
        try{
            return new Map<Id, Order>([SELECT Id, BillToContact.Email, OrderNumber 
                                       FROM Order 
                                       WHERE Id IN :orderIds AND Sent_to_NPS__c = false]);
        }catch(Exception ex){
            ErrorLogHandler.logError('OrderNPSService','retrieveOrders', orderIds, ex); 
        }
        return null;
    }

    //This method creates json serialized string for the orders passed to it in the form of map data structure. 
    public static String buildRequestBody(Map<Id, Order> retrievedOrdersMap) {
        List<Map<String, Object>> requestMapList = new List<Map<String, Object>>();
        
            for (Order order : retrievedOrdersMap.values()) {
                Map<String, Object> orderMap = new Map<String, Object>();
                orderMap.put('sfId', order.Id);
                orderMap.put('orderNumber', order.OrderNumber);
                orderMap.put('customerEmail', order.BillToContact.Email);
                requestMapList.add(orderMap);
            }
        
        try{
            return JSON.serialize(requestMapList);
        }catch(JSONException ex){
            ErrorLogHandler.logError('OrderNPSService','buildRequestBody',  new List<Id>(retrievedOrdersMap.keySet()), ex);
        }catch(Exception ex){
            ErrorLogHandler.logError('OrderNPSService','buildRequestBody',  new List<Id>(retrievedOrdersMap.keySet()), ex);
        } 
        return null;  
    }

    //This method actually makes a callout to the NPS system and post the data.
    public static void sendRequestToNPS(String requestBody, Map<Id, Order> retrievedOrdersMap) {
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Basic_Apex_Callout/orders');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
    
            HttpResponse response = http.send(request);
            
            handleResponse(response, retrievedOrdersMap);
            
        }catch(CalloutException ex){
            ErrorLogHandler.logError('OrderNPSService','sendRequestToNPS', new List<Id>(retrievedOrdersMap.keySet()), ex);
        }catch(Exception ex){
            ErrorLogHandler.logError('OrderNPSService','sendRequestToNPS', new List<Id>(retrievedOrdersMap.keySet()), ex);
        }    
    }

    //This method updates order record if response is successful and logs the error in case of failed response.
    public static void handleResponse(HttpResponse response, Map<Id, Order> retrievedOrdersMap) {
        if (response.getStatusCode() != 200) {
            ErrorLogHandler.logError('OrderNPSService','handleResponse',  new List<Id>(retrievedOrdersMap.keySet()), response);
        } else {
            updateOrders(retrievedOrdersMap);
        }
    }

    //This method has the responsibility to update the order records.
    public static void updateOrders(Map<Id, Order> retrievedOrdersMap) {
        List<Order> ordersToUpdate = new List<Order>();
        for (Order order : retrievedOrdersMap.values()) {
            order.Sent_to_NPS__c = true;
            ordersToUpdate.add(order);
        }
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
    
}