# Salesforce Senior Coding Challenge

Thank you for shortlisting my profile for this round of interview! I really feel that the task was well-thought. Overall it was fun for me.

### Considerations while testing the code:

* Please assign permission set 'NPS Integration Permission Set' in the package to the user with which the testing is being done.
* While changing the status of the opportunity to fulfilled, please check the value of the 'Sent to NPS?' field on order. It should be false or unchecked to make the callout to the NPS system. For this reason, it is currently kept editable for the user assigned with the permission set 'NPS Integration Permission Set'. 

### Limitations/Assumptions:

* The order record is always updated with a flag 'Sent to NPS?' that indicates if the record details are already sent to NPS. This is done to avoid sending duplicate emails to the customers. The assumption here is that once the record is fulfilled, some feature will stop allowing changes to its status. 
* This assumption leads to a limitation which says that if the order status is 'fulfilled' for the first time, the record will be sent to the NPS system by making the callout. However, if after that the status is changed to some other value and again updated to 'Fulfilled', it won't be sent to the NPS for the second time. 


