public with sharing class RefreshTrackingAction {
    @InvocableMethod(label='Refresh Shipment Tracking' callout=true)
    public static void refresh(List<Id> shipmentIds) {
        Integration_Settings__c cfg = Integration_Settings__c.getOrgDefaults();
        if (cfg.Sync_Enabled__c == false) {
            return;
        }

        List<Shipment__c> rows = [SELECT Id, Tracking_Number__c
                                  FROM Shipment__c WHERE Id IN :shipmentIds];
        for (Shipment__c s : rows) {
            CarrierApiService.TrackingResponse r = CarrierApiService.getTracking(s.Tracking_Number__c);
            s.Status__c = r.status;
            s.Last_Synced__c = System.now();
            if (r.eta != null) {
                s.ETA__c = Date.valueOf(r.eta);
            }
        }
        update rows;
    }
}