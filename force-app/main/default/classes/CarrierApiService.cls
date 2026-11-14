public with sharing class CarrierApiService {
    public class TrackingResponse {
        public String trackingNumber;
        public String status;
        public String eta;
    }

    public static TrackingResponse getTracking(String trackingNumber) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Carrier_API/tracking/'
                        + EncodingUtil.urlEncode(trackingNumber, 'UTF-8'));
        req.setMethod('GET');
        req.setTimeout(20000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Carrier API error ' + res.getStatusCode());
        }
        return (TrackingResponse) JSON.deserialize(res.getBody(), TrackingResponse.class);
    }
}