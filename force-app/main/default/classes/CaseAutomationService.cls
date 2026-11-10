public with sharing class CaseAutomationService {
    public static void createDelayCases(List<Shipment__c> shipments) {
        Set<Id> orderIds = new Set<Id>();
        for (Shipment__c s : shipments) { orderIds.add(s.Order__c); }
        Map<Id, Order__c> orders = new Map<Id, Order__c>(
            [SELECT Id, Customer__c, Contact__c, Region__c
             FROM Order__c WHERE Id IN :orderIds]);          // 1 query
        List<Case> cases = new List<Case>();
        for (Shipment__c s : shipments) {
            Order__c o = orders.get(s.Order__c);
            cases.add(new Case(
                Subject   = 'Shipment delayed: ' + s.Tracking_Number__c,
                Type      = 'Delivery Issue',
                Origin    = 'System',
                Priority  = 'High',
                AccountId = o.Customer__c,
                ContactId = o.Contact__c,
                Region__c = o.Region__c,
                Order__c  = o.Id,
                Shipment__c = s.Id));
        }
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;      // fire the routing rule from Phase 4
        Database.insert(cases, dmo);                         // 1 DML for all records
    }
}