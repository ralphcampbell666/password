package support;

import java.security.SecureRandom;
import java.util.Random;

/**
 *
 * @author ralph
 */
public class generate_password 
{
    private static final String UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
    private static final String NUMBERS = "0123456789";
    private static final String SPECIAL_CHARACTERS = "!@#$%^&*()-_=+[]{}|;:,.<>?";
    private static final String ALL_CHARACTERS = UPPER_CASE + LOWER_CASE + NUMBERS + SPECIAL_CHARACTERS;
    
    public static String for_length(int length) 
    {
        String password = new Random().ints(length, 33, 122).collect(StringBuilder::new,StringBuilder::appendCodePoint, StringBuilder::append).toString();
        password = password.replace("=", "-"); //cant have a "=" in properties files
        password = password.replace("\"", "-"); //cant have a "=" in properties files
        return password;
    }
    
    public static String generatePassword(int length) 
    {
        StringBuilder passwordBuilder = new StringBuilder();
        Random random = new SecureRandom();

        // Create lists for each character set to ensure at least one character from each set.
        //List<Character> upperCaseChars = new ArrayList<>();
        //List<Character> lowerCaseChars = new ArrayList<>();
        //List<Character> numberChars = new ArrayList<>();
        //List<Character> specialChars = new ArrayList<>();

        // Add one character from each set to the password.
        passwordBuilder.append(getRandomCharacter(UPPER_CASE, random));
        passwordBuilder.append(getRandomCharacter(LOWER_CASE, random));
        passwordBuilder.append(getRandomCharacter(NUMBERS, random));
        passwordBuilder.append(getRandomCharacter(SPECIAL_CHARACTERS, random));

        // Fill the rest of the password with random characters from all sets.
        for (int i = 4; i < length; i++) 
        {
            char randomChar = getRandomCharacter(ALL_CHARACTERS, random);
            passwordBuilder.append(randomChar);
        }

        // Shuffle the password to randomize the order of characters.
        for (int i = 0; i < length; i++) 
        {
            int randomIndex = random.nextInt(length);
            char temp = passwordBuilder.charAt(i);
            passwordBuilder.setCharAt(i, passwordBuilder.charAt(randomIndex));
            passwordBuilder.setCharAt(randomIndex, temp);
        }
        return passwordBuilder.toString();
    }

    private static char getRandomCharacter(String characterSet, Random random) 
    {
        int index = random.nextInt(characterSet.length());
        return characterSet.charAt(index);
    }

}
