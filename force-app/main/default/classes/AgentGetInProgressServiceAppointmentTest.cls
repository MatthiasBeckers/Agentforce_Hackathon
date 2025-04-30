@IsTest
private class AgentGetInProgressServiceAppointmentTest {
    @TestSetup
    static void makeData(){
        // Create test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@test.com',
            Username = 'test.user' + DateTime.now().getTime() + '@test.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u;

        // Create ServiceResource
        ServiceResource sr = new ServiceResource(
            RelatedRecordId = u.Id,
            Name = 'Test Resource',
            IsActive = true,
            ResourceType = 'T'
        );
        insert sr;

        // Create Case
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert c;

        // Create WorkOrder
        WorkOrder wo = new WorkOrder(
            CaseId = c.Id,
            Status = 'New'
        );
        insert wo;

        // Create ServiceAppointment
        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            EarliestStartTime = DateTime.now(),
            DueDate = DateTime.now().addDays(1),
            Status = 'In Progress',
            SchedStartTime = DateTime.now(),
            SchedEndTime = DateTime.now().addHours(1)
        );
        insert sa;

        // Create AssignedResource
        AssignedResource ar = new AssignedResource(
            ServiceResourceId = sr.Id,
            ServiceAppointmentId = sa.Id
        );
        insert ar;
    }

    @IsTest
    static void testSuccessfulPath() {
        User u = [SELECT Id FROM User WHERE Email = 'test@test.com' LIMIT 1];
        List<Id> userIds = new List<Id>();
        userIds.add(u.Id);
        
        List<AgentGetInProgressServiceAppointment.InputVariables> inputList = new List<AgentGetInProgressServiceAppointment.InputVariables>();
        AgentGetInProgressServiceAppointment.InputVariables input = new AgentGetInProgressServiceAppointment.InputVariables();
        input.userIds = userIds;
        inputList.add(input);
        Test.startTest();
        List<String> result = 
            AgentGetInProgressServiceAppointment.getCurrentServiceAppointment(inputList);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        
    }

}