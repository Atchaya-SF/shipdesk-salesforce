@IsTest
private class ShipmentWebhookTest {
    @TestSetup
    static void setup() {
        Account a = new Account(Name = 'Test Co');
        insert a;
        Order__c o = new Order__c(Customer__c = a.Id, Order_Number__c = 'ORD-W1',
                                  Region__c = 'NA', Status__c = 'Shipped');
        insert o;
        insert new Shipment__c(Order__c = o.Id, Tracking_Number__c = 'TRK-W1', Status__c = 'In Transit');
    }

    private static String call(String jsonBody) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/shipments/v1/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        return ShipmentWebhook.receive();
    }

    @IsTest
    static void updatesShipmentAndCreatesCase() {
        String result = call('{"trackingNumber":"TRK-W1","status":"Delayed","eta":"2026-11-20"}');
        System.assertEquals('OK', result);
        System.assertEquals('Delayed', [SELECT Status__c FROM Shipment__c WHERE Tracking_Number__c = 'TRK-W1'].Status__c);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @IsTest
    static void unknownTrackingReturns404() {
        call('{"trackingNumber":"NOPE","status":"Delayed"}');
        System.assertEquals(404, RestContext.response.statusCode);
    }

    @IsTest
    static void badJsonReturns400AndLogs() {
        call('not json');
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(1, [SELECT COUNT() FROM Integration_Log__c]);
    }
}