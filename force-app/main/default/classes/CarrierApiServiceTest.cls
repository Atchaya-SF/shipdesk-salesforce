
@IsTest
private class CarrierApiServiceTest {

    @IsTest
    static void testGetTracking() {

        Test.setMock(
            HttpCalloutMock.class,
            new CarrierApiMock()
        );

        Test.startTest();

        CarrierApiService.TrackingResponse result =
            CarrierApiService.getTracking('TRK-T1');

        Test.stopTest();

        System.assertEquals('TRK-T1', result.trackingNumber);
        System.assertEquals('Delivered', result.status);
        System.assertEquals('2026-11-12', result.eta);
    }
}
