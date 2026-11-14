// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//Database.executeBatch(new OverdueShipmentBatch(), 200);

CarrierApiService.TrackingResponse result =
    CarrierApiService.getTracking('TRK-1001');

System.debug('Tracking Number: ' + result.trackingNumber);
System.debug('Status: ' + result.status);
System.debug('ETA: ' + result.eta);

//Shipment__c s = [SELECT Id FROM Shipment__c LIMIT 1];
//RefreshTrackingAction.refresh(new List<Id>{ s.Id });
//System.debug([SELECT Tracking_Number__c, Status__c, ETA__c, Last_Synced__c FROM Shipment__c WHERE Id = :s.Id]);