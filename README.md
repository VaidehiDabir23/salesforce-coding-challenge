# Salesforce Senior Coding Challenge

Thank you for shortlisting my profile for this round of interview! I really feel that the task was well-thought. Overall it was fun for me. I look forward to meeting you and having a discussion on the overall solution. 

### Issues during deployment:
* While deploying using package.XML in this package, an error is thrown: Missing metadata type definition in registry for id 'externalcredential'. I tried fixing this issue, but got no success. Please Download the zip folder from the Repo and deploy using workbench. 
* Therefore, to make deployment happen, I have added a ZIP file named 'Salesforce coding challenge.zip' here which can directly be deployed to the org using workbench. 


### Post deployment Steps:
* Update 'External Credential Principal Access' in the NPS Integration Permission Set.
* In External Credentials>Principals> Add Authentication parameters Username : tmondo and Password : Noy84LRpYvMZuETB
* Assign permission set 'NPS Integration Permission Set' in the package to the user with which the testing is being done.

### For Testing purpose:

* While changing the status of the opportunity to fulfilled, please check the value of the 'Sent to NPS?' field on order. It should be false or unchecked to make the callout to the NPS system. For this reason, it is currently kept editable for the user assigned with the permission set 'NPS Integration Permission Set'. 
* Order layout: Remove required attribute for the 'contract' field and add 'Bill to contact' field.  
* Give the System Admin access of all the fields of Error_log__c object to enable the admin to look into the errors by querying the object.

### Limitations/Assumptions:

* The order record is always updated with a flag 'Sent to NPS?' that indicates if the record details are already sent to NPS. This is done to avoid sending duplicate emails to the customers. The assumption here is that once the record is fulfilled, some feature will stop allowing changes to its status. 
* This assumption leads to a limitation that if the order status is 'fulfilled' for the first time, the record will be sent to the NPS system by making the callout. However, if after that the status is changed to some other value and again updated to 'Fulfilled', it won't be sent to the NPS for the second time.


