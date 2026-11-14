@RestResource(urlMapping='/shipments/v1/*')
global without sharing class ShipmentWebhook {
    global class Payload {
        public String trackingNumber;
        public String status;
        public String eta;
    }

    @HttpPost
    global static String receive() {
        RestResponse res = RestContext.response;
        try {
            String raw = RestContext.request.requestBody.toString();
            Payload p = (Payload) JSON.deserialize(raw, Payload.class);

            List<Shipment__c> found = [SELECT Id FROM Shipment__c
                                       WHERE Tracking_Number__c = :p.trackingNumber LIMIT 1];
            if (found.isEmpty()) {
                res.statusCode = 404;
                return 'Unknown tracking number';
            }

            Shipment__c s = found[0];
            s.Status__c = p.status;
            s.Last_Synced__c = System.now();
            if (p.eta != null) {
                s.ETA__c = Date.valueOf(p.eta);
            }
            update s;
            return 'OK';
        } catch (Exception e) {
            res.statusCode = 400;
            insert new Integration_Log__c(Direction__c = 'Inbound', Endpoint__c = '/shipments/v1',
                                          Status_Code__c = 400, Message__c = e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
}