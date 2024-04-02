@IsTest
private class ReturnFilterQueryTest {
    @IsTest
    static void testBuildFilterQuery() {
        // Test case 1: Verify query with single filter condition
        Map<String, Object> filters1 = new Map<String, Object>{
            'Name' => 'John'
        };
        String query1 = ReturnFilterQuery.buildFilterQuery('Account', filters1);
        System.assertEquals('SELECT Id FROM Account WHERE Name = \'John\'', query1);

        // Test case 2: Verify query with multiple filter conditions
        Map<String, Object> filters2 = new Map<String, Object>{
            'Status' => 'Active',
            'Type' => 'Customer'
        };
        String query2 = ReturnFilterQuery.buildFilterQuery('Contact', filters2);
        System.assertEquals('SELECT Id FROM Contact WHERE Status = \'Active\' AND Type = \'Customer\'', query2);

        // Test case 3: Verify query with IN clause for string values
        Map<String, Object> filters3 = new Map<String, Object>{
            'Category' => new List<String>{'A', 'B', 'C'}
        };
        String query3 = ReturnFilterQuery.buildFilterQuery('Product', filters3);
        System.assertEquals('SELECT Id FROM Product WHERE Category IN (\'A\',\'B\',\'C\')', query3);

        // Test case 4: Verify query with Date field
        Date dateValue = Date.newInstance(2023, 5, 23);
        Map<String, Object> filters4 = new Map<String, Object>{
            'CreatedDate' => dateValue
        };
        String query4 = ReturnFilterQuery.buildFilterQuery('Case', filters4);
        System.assertEquals('SELECT Id FROM Case WHERE CreatedDate = 2023-5-23', query4);

        // Test case 5: Verify query with Boolean field
        Map<String, Object> filters5 = new Map<String, Object>{
            'IsDeleted' => true
        };
        String query5 = ReturnFilterQuery.buildFilterQuery('Account', filters5);
        System.assertEquals('SELECT Id FROM Account WHERE IsDeleted = true', query5);
    }
}