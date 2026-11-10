@IsTest
private class OrderSearchServiceTest {
    @IsTest
    static void searchReturnsOrders() {
        Account a = new Account(Name = 'Test Co');
        insert a;
        Order__c o = new Order__c(Customer__c = a.Id, Order_Number__c = 'ORD-T3',
                                  Region__c = 'NA', Status__c = 'New');
        insert o;
        Test.setFixedSearchResults(new List<Id>{ o.Id });
        Test.startTest();
        List<List<SObject>> res = OrderSearchService.search('ORD');
        Test.stopTest();
        System.assertEquals(3, res.size());
        System.assertEquals(1, res[0].size());
    }
}