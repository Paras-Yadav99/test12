public class ReturnFilterQuery {
     public static String buildFilterQuery(String objectName, Map<String, Object> filters) {
        List<String> conditions = new List<String>();

        for (String field : filters.keySet()) {
            Object value = filters.get(field);
            if (value != null) {
                if (value instanceof String) {
                    conditions.add(field + ' = \'' + String.escapeSingleQuotes(String.valueOf(value)) + '\'');
                } else if (value instanceof List<String>) {
                    List<String> stringValues = (List<String>)value;
                    conditions.add(field + ' IN (\'' + String.join(stringValues, '\',\'') + '\')');
                } else if (value instanceof Date) {
                    Date dateValue = (Date)value;
                    conditions.add(field + ' = ' + dateValue.year() + '-' + dateValue.month() + '-' + dateValue.day());
                } else if (value instanceof Boolean) {
                    Boolean boolValue = (Boolean)value;
                    conditions.add(field + ' = ' + boolValue);
                }
            }
        }

        return 'SELECT Id FROM ' + objectName + (conditions.isEmpty() ? '' : ' WHERE ' + String.join(conditions, ' AND '));
    }

}