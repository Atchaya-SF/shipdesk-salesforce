public without sharing class AgentLogCaseAction {

    public class Request {
        @InvocableVariable(label='Order Number' description='The order number exactly as the customer typed it, for example ORD-1001' required=true)
        public String orderNumber;
        @InvocableVariable(label='Customer Email' description='The email address on the order exactly as the customer typed it' required=true)
        public String customerEmail;
        @InvocableVariable(label='Issue Type' description='Exactly Delivery Issue for a late, missing or damaged parcel, or exactly Return/Refund for a return' required=true)
        public String issueType;
        @InvocableVariable(label='Issue Description' description='One sentence describing the problem in the customer words' required=true)
        public String issueDescription;
    }

    public class Result {
        @InvocableVariable(label='Created' description='True only if a case was created')
        public Boolean created;
        @InvocableVariable(label='Case Number' description='The number of the case that was created')
        public String caseNumber;
    }

    @InvocableMethod(label='Log Delay Or Return Case' description='Verifies the order number and email, then creates a delivery issue or return case and returns the case number.')
    public static List<Result> logCase(List<Request> requests) {
        Set<String> numbers = new Set<String>();
        for (Request r : requests) {
            if (r.orderNumber != null) {
                numbers.add(r.orderNumber.trim());
            }
        }

        Map<String, Order__c> byNumber = new Map<String, Order__c>();
        for (Order__c o : [SELECT Id, Order_Number__c, Customer__c, Contact__c, Region__c, Contact__r.Email
                           FROM Order__c WHERE Order_Number__c IN :numbers]) {
            byNumber.put(o.Order_Number__c.toUpperCase(), o);
        }

        Map<String, Id> rtIds = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType
                              WHERE SObjectType = 'Case' AND DeveloperName IN ('Delivery_Issue', 'Return_Request')]) {
            rtIds.put(rt.DeveloperName, rt.Id);
        }

        List<Result> results = new List<Result>();
        List<Case> toInsert = new List<Case>();
        List<Integer> positions = new List<Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request r = requests[i];
            Result res = new Result();
            res.created = false;
            results.add(res);

            Order__c o = (r.orderNumber == null) ? null : byNumber.get(r.orderNumber.trim().toUpperCase());
            if (o != null && o.Contact__r != null && o.Contact__r.Email != null && r.customerEmail != null
                && o.Contact__r.Email.equalsIgnoreCase(r.customerEmail.trim())) {
                Boolean isReturn = (r.issueType == 'Return/Refund');
                Case c = new Case(
                    Subject = (isReturn ? 'Return/Refund' : 'Delivery Issue') + ' reported via ShipDesk Assistant - ' + o.Order_Number__c,
                    Type = isReturn ? 'Return/Refund' : 'Delivery Issue',
                    Status = 'New',
                    Origin = 'Web',
                    Priority = 'Medium',
                    Description = r.issueDescription,
                    Order__c = o.Id,
                    AccountId = o.Customer__c,
                    ContactId = o.Contact__c,
                    Region__c = o.Region__c);
                Id rtId = rtIds.get(isReturn ? 'Return_Request' : 'Delivery_Issue');
                if (rtId != null) {
                    c.RecordTypeId = rtId;
                }
                toInsert.add(c);
                positions.add(i);
            }
        }

        if (!toInsert.isEmpty()) {
            try {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                Database.insert(toInsert, dmo);

                Set<Id> newIds = new Set<Id>();
                for (Case c : toInsert) {
                    newIds.add(c.Id);
                }
                Map<Id, Case> inserted = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN :newIds]);
                for (Integer k = 0; k < toInsert.size(); k++) {
                    Result res = results[positions[k]];
                    res.created = true;
                    res.caseNumber = inserted.get(toInsert[k].Id).CaseNumber;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'AgentLogCaseAction failed: ' + e.getMessage());
            }
        }
        return results;
    }
}
