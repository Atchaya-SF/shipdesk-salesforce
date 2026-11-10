@IsTest
private class OverdueShipmentBatchTest {
    @TestSetup
    static void setup() {
        Account a = new Account(Name = 'Test Co');
        insert a;
        Order__c o = new Order__c(Customer__c = a.Id, Order_Number__c = 'ORD-T2',
                                  Region__c = 'NA', Status__c = 'Shipped');
        insert o;
        insert new Shipment__c(Order__c = o.Id, Tracking_Number__c = 'TRK-T2',
                               Status__c = 'In Transit', ETA__c = Date.today().addDays(-1));
    }

    @IsTest
    static void batchFlagsOverdue() {
        Test.startTest();
        Database.executeBatch(new OverdueShipmentBatch(), 200);
        Test.stopTest();
        System.assertEquals('Delayed', [SELECT Status__c FROM Shipment__c LIMIT 1].Status__c);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @IsTest
    static void schedulerRuns() {
        Test.startTest();
        String jobId = System.schedule('Test Overdue Job', '0 0 1 * * ?', new OverdueShipmentBatch());
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}