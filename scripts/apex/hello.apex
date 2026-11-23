// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//Database.executeBatch(new OverdueShipmentBatch(), 200);

List<Case> cs = new List<Case>();
String[] regions = new String[]{'NA','EMEA','APAC'};
String[] origins = new String[]{'Email','Web','System'};
String[] prios = new String[]{'Low','Medium','High'};
for (Integer i = 0; i < 9; i++) {
    cs.add(new Case(Subject = 'Demo case ' + i,
                    Region__c = regions[Math.mod(i, 3)],
                    Origin = origins[Math.mod(i, 3)],
                    Priority = prios[Math.mod(i, 3)],
                    Type = 'Delivery Issue',
                    Status = 'New'));
}
insert cs;

List<Shipment__c> ss = [SELECT Id FROM Shipment__c ORDER BY Name LIMIT 2];
for (Integer i = 0; i < cs.size(); i++) {
    if (i < 3) {
        cs[i].SLA_Due__c = System.now().addDays(-1);
    }
    if (i < ss.size()) {
        cs[i].Shipment__c = ss[i].Id;
    }
}
update cs;

if (!ss.isEmpty()) {
    for (Shipment__c s : ss) {
        s.Status__c = 'Delayed';
    }
    ss[0].Carrier__c = 'DHL';
    if (ss.size() > 1) {
        ss[1].Carrier__c = 'UPS';
    }
    update ss;
}

//Shipment__c s = [SELECT Id FROM Shipment__c LIMIT 1];
//RefreshTrackingAction.refresh(new List<Id>{ s.Id });
//System.debug([SELECT Tracking_Number__c, Status__c, ETA__c, Last_Synced__c FROM Shipment__c WHERE Id = :s.Id]);