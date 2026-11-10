@IsTest
private class ShipmentTriggerTest {
    @TestSetup static void setup() {
        Account a = new Account(Name = 'Test Co'); insert a;
        Order__c o = new Order__c(Customer__c = a.Id, Order_Number__c = 'ORD-T1',
                                  Region__c = 'NA', Status__c = 'Shipped');
        insert o;
        insert new Shipment__c(Order__c = o.Id, Tracking_Number__c = 'TRK-T1', Status__c = 'In Transit',
                               ETA__c = Date.today().addDays(-1));
    }
    @IsTest static void delayCreatesOneCase() {
        Shipment__c s = [SELECT Id, Status__c FROM Shipment__c LIMIT 1];
        Test.startTest();
        s.Status__c = 'Delayed'; update s;
        update s;                      // second update must NOT create another case
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Shipment__c = :s.Id]);
    }
    @IsTest static void batchFlagsOverdue() {
        Test.startTest(); Database.executeBatch(new OverdueShipmentBatch(), 200); Test.stopTest();
        System.assertEquals('Delayed', [SELECT Status__c FROM Shipment__c LIMIT 1].Status__c);
    }
}