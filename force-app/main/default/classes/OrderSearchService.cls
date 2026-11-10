public with sharing class OrderSearchService {
    // SOSL: search a text term across several objects at once
    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> search(String term) {
        String searchTerm = term + '*';                       // wildcard; min 2 chars
        return [FIND :searchTerm IN ALL FIELDS RETURNING

                Order__c(Id, Name, Order_Number__c, Status__c),
                Shipment__c(Id, Tracking_Number__c, Status__c),
                Contact(Id, Name, Email)];
    }
}
