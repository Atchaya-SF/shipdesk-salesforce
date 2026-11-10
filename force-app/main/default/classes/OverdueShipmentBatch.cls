public with sharing class OverdueShipmentBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c FROM Shipment__c
            WHERE ETA__c < TODAY AND Status__c IN ('In Transit', 'Out for Delivery')]);
    }
    public void execute(Database.BatchableContext bc, List<Shipment__c> scope) {
        for (Shipment__c s : scope) { s.Status__c = 'Delayed'; }
        update scope;                                         // fires ShipmentTrigger -> creates cases
    }
    public void finish(Database.BatchableContext bc) { /* optional: email a summary */ }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new OverdueShipmentBatch(), 200);
    }
}