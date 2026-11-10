trigger ShipmentTrigger on Shipment__c (after insert, after update) {
    ShipmentTriggerHandler.handle(Trigger.new, Trigger.oldMap);
}