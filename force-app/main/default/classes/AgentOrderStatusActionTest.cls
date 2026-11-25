@IsTest
private class AgentOrderStatusActionTest {
    @TestSetup
    static void setup() {
        Account a = new Account(Name = 'Test Co');
        insert a;
        Contact c = new Contact(LastName = 'Doe', Email = 'jane@test.com', AccountId = a.Id);
        insert c;
        Order__c o = new Order__c(Customer__c = a.Id, Contact__c = c.Id, Order_Number__c = 'ORD-A1',
                                  Region__c = 'NA', Status__c = 'Shipped');
        insert o;
        insert new Shipment__c(Order__c = o.Id, Tracking_Number__c = 'TRK-A1', Status__c = 'In Transit',
                               ETA__c = Date.today().addDays(3));
    }

    private static AgentOrderStatusAction.Request req(String num, String email) {
        AgentOrderStatusAction.Request r = new AgentOrderStatusAction.Request();
        r.orderNumber = num;
        r.customerEmail = email;
        return r;
    }

    @IsTest
    static void matchReturnsDetails() {
        List<AgentOrderStatusAction.Result> res = AgentOrderStatusAction.getStatus(
            new List<AgentOrderStatusAction.Request>{ req('ORD-A1', 'JANE@test.com') });
        System.assertEquals(true, res[0].found);
        System.assertEquals('Shipped', res[0].orderStatus);
        System.assertEquals('TRK-A1', res[0].trackingNumber);
        System.assertEquals('In Transit', res[0].shipmentStatus);
    }

    @IsTest
    static void wrongEmailReturnsNotFound() {
        List<AgentOrderStatusAction.Result> res = AgentOrderStatusAction.getStatus(
            new List<AgentOrderStatusAction.Request>{ req('ORD-A1', 'wrong@test.com') });
        System.assertEquals(false, res[0].found);
        System.assertEquals(null, res[0].trackingNumber);
    }

    @IsTest
    static void unknownOrderReturnsNotFound() {
        List<AgentOrderStatusAction.Result> res = AgentOrderStatusAction.getStatus(
            new List<AgentOrderStatusAction.Request>{ req('NOPE', 'jane@test.com') });
        System.assertEquals(false, res[0].found);
    }
}
