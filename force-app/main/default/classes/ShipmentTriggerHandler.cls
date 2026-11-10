public with sharing class ShipmentTriggerHandler {
    public static void handle(List<Shipment__c> newList, Map<Id, Shipment__c> oldMap) {
        List<Shipment__c> delayed = new List<Shipment__c>();
        for (Shipment__c s : newList) {
            Shipment__c old = (oldMap == null) ? null : oldMap.get(s.Id);
            if (s.Status__c == 'Delayed' && (old == null || old.Status__c != 'Delayed')) {
                delayed.add(s);                       // only NEW delays, avoids duplicate cases
            }
        }
        if (!delayed.isEmpty()) {
            CaseAutomationService.createDelayCases(delayed);
        }
    }
}