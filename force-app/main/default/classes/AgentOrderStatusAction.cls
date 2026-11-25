public without sharing class AgentOrderStatusAction {

    public class Request {
        @InvocableVariable(label='Order Number' description='The order number exactly as the customer typed it, for example ORD-1001' required=true)
        public String orderNumber;
        @InvocableVariable(label='Customer Email' description='The email address on the order exactly as the customer typed it' required=true)
        public String customerEmail;
    }

    public class Result {
        @InvocableVariable(label='Found' description='True only if the order number and email match an order')
        public Boolean found;
        @InvocableVariable(label='Order Status' description='Current status of the order')
        public String orderStatus;
        @InvocableVariable(label='Tracking Number' description='Tracking number of the latest shipment')
        public String trackingNumber;
        @InvocableVariable(label='Shipment Status' description='Status of the latest shipment')
        public String shipmentStatus;
        @InvocableVariable(label='ETA' description='Estimated delivery date as YYYY-MM-DD, or Not available')
        public String eta;
    }

    @InvocableMethod(label='Get Order Status' description='Verifies the order number and email, then returns the order status and the latest shipment details.')
    public static List<Result> getStatus(List<Request> requests) {
        Set<String> numbers = new Set<String>();
        for (Request r : requests) {
            if (r.orderNumber != null) {
                numbers.add(r.orderNumber.trim());
            }
        }

        Map<String, Order__c> ordersByNumber = new Map<String, Order__c>();
        Set<Id> orderIds = new Set<Id>();
        for (Order__c o : [SELECT Id, Order_Number__c, Status__c, Contact__r.Email
                           FROM Order__c WHERE Order_Number__c IN :numbers]) {
            ordersByNumber.put(o.Order_Number__c.toUpperCase(), o);
            orderIds.add(o.Id);
        }

        Map<Id, Shipment__c> latestShipment = new Map<Id, Shipment__c>();
        for (Shipment__c s : [SELECT Order__c, Tracking_Number__c, Status__c, ETA__c
                              FROM Shipment__c WHERE Order__c IN :orderIds
                              ORDER BY CreatedDate ASC]) {
            latestShipment.put(s.Order__c, s);
        }

        List<Result> results = new List<Result>();
        for (Request r : requests) {
            Result res = new Result();
            res.found = false;
            Order__c o = (r.orderNumber == null) ? null : ordersByNumber.get(r.orderNumber.trim().toUpperCase());
            if (o != null && o.Contact__r != null && o.Contact__r.Email != null && r.customerEmail != null
                && o.Contact__r.Email.equalsIgnoreCase(r.customerEmail.trim())) {
                res.found = true;
                res.orderStatus = o.Status__c;
                Shipment__c s = latestShipment.get(o.Id);
                if (s != null) {
                    res.trackingNumber = s.Tracking_Number__c;
                    res.shipmentStatus = s.Status__c;
                    res.eta = (s.ETA__c == null) ? 'Not available' : String.valueOf(s.ETA__c);
                } else {
                    res.trackingNumber = 'Not available';
                    res.shipmentStatus = 'No shipment created yet';
                    res.eta = 'Not available';
                }
            }
            results.add(res);
        }
        return results;
    }
}
