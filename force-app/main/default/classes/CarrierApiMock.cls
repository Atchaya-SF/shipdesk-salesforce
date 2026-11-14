@IsTest
global class CarrierApiMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"trackingNumber":"TRK-T1","status":"Delivered","eta":"2026-11-12"}');
        return res;
    }
}
// In the test method: Test.setMock(HttpCalloutMock.class, new CarrierApiMock());