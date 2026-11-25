@IsTest
private class AgentLogCaseActionTest {
    @TestSetup
    static void setup() {
        Account a = new Account(Name = 'Test Co');
        insert a;
        Contact c = new Contact(LastName = 'Doe', Email = 'jane@test.com', AccountId = a.Id);
        insert c;
        insert new Order__c(Customer__c = a.Id, Contact__c = c.Id, Order_Number__c = 'ORD-L1',
                            Region__c = 'NA', Status__c = 'Shipped');
    }

    private static AgentLogCaseAction.Request req(String num, String email, String type) {
        AgentLogCaseAction.Request r = new AgentLogCaseAction.Request();
        r.orderNumber = num;
        r.customerEmail = email;
        r.issueType = type;
        r.issueDescription = 'Test description';
        return r;
    }

    @IsTest
    static void createsReturnCase() {
        List<AgentLogCaseAction.Result> res = AgentLogCaseAction.logCase(
            new List<AgentLogCaseAction.Request>{ req('ORD-L1', 'jane@test.com', 'Return/Refund') });
        System.assertEquals(true, res[0].created);
        System.assertNotEquals(null, res[0].caseNumber);
        System.assertEquals('Return/Refund', [SELECT Type FROM Case LIMIT 1].Type);
    }

    @IsTest
    static void createsDeliveryCase() {
        List<AgentLogCaseAction.Result> res = AgentLogCaseAction.logCase(
            new List<AgentLogCaseAction.Request>{ req('ORD-L1', 'jane@test.com', 'Delivery Issue') });
        System.assertEquals(true, res[0].created);
        System.assertEquals('Delivery Issue', [SELECT Type FROM Case LIMIT 1].Type);
    }

    @IsTest
    static void wrongEmailCreatesNothing() {
        List<AgentLogCaseAction.Result> res = AgentLogCaseAction.logCase(
            new List<AgentLogCaseAction.Request>{ req('ORD-L1', 'wrong@test.com', 'Delivery Issue') });
        System.assertEquals(false, res[0].created);
        System.assertEquals(0, [SELECT COUNT() FROM Case]);
    }
}
