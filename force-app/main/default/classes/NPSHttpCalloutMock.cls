@isTest
global class NPSHttpCalloutMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest request) {
      //This is the default response when no particular status code is mentioned
      HTTPResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('SUCCESS');
      response.setStatusCode(200);
      return response;
   }
    
   //This method is written to return the response with the status code passed as a parameter
   global HTTPResponse  respondWithCode(HTTPRequest request, Integer statusCode) {
      HTTPResponse response = respond(request);
         
      if(statusCode == 400){
         response.setBody('BAD_PAYLOAD');
         response.setStatusCode(400);
      }
      else if(statusCode == 500){
         response.setBody('SERVER_ERROR');
         response.setStatusCode(500);
      }
      return response; 
   }

}