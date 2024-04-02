public class removeLastChar {
    
    public static String removeChars(String str, integer numberOfCharactersToRemove) {
        if(string.isnotBlank(str)) {
            return str.substring(0, str.length() - numberOfCharactersToRemove);
        }
        return null;
    }
}