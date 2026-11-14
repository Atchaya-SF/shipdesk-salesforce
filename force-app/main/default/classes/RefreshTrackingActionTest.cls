
@IsTest
private class RefreshTrackingActionTest {

    @IsTest
    static void testRefreshShipment() {

        // 1. Enable integration
        Integration_Settings__c settings =
            new Integration_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                Sync_Enabled__c = true
            );
        insert settings;

        // 2. Create parent Order
        Order__c testOrder = new Order__c();
        insert testOrder;

        // 3. Create Shipment and link to Order
        Shipment__c shipment = new Shipment__c(
            Tracking_Number__c = 'TRK-T1',
            Order__c = testOrder.Id
        );
        insert shipment;

        // 4. Mock external API
        Test.setMock(
            HttpCalloutMock.class,
            new CarrierApiMock()
        );

        Test.startTest();

        // 5. Execute Apex action
        RefreshTrackingAction.refresh(
            new List<Id>{shipment.Id}
        );

        Test.stopTest();

        // 6. Verify Shipment update
        Shipment__c updatedShipment = [
            SELECT Status__c, ETA__c, Last_Synced__c
            FROM Shipment__c
            WHERE Id = :shipment.Id
        ];

        System.assertEquals(
            'Delivered',
            updatedShipment.Status__c
        );

        System.assertEquals(
            Date.newInstance(2026, 11, 12),
            updatedShipment.ETA__c
        );

        System.assertNotEquals(
            null,
            updatedShipment.Last_Synced__c
        );
    }
}
