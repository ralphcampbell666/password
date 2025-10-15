
package support;

import java.io.File;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;

/**
 *
 * @author rcampbell
 */
public class string_utils 
{
    private static SimpleDateFormat date_time_picker_format = new SimpleDateFormat("HH:mm MM/dd/yyyy"); //10:42 / 24-Jan-20   
    private static SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
    
    public static String convert_timestamp_to_timestamp_string(Timestamp in_timestamp)
    {
        String return_string = "";        
        try
        {
            return_string = timestamp_format.format(in_timestamp); 
        }
        catch(Exception e)
        {
            return_string = "";
        }
        return return_string;
    }
    public static String timestamp_to_date_time_picker_string(Timestamp in_timestamp)
    {
        String return_string = "";        
        try
        {
            return_string = timestamp_format.format(in_timestamp); 
        }
        catch(Exception e)
        {
            return_string = "";
        }
        return return_string;
    }
    public static String check_for_null(String value)
    {
        String return_value = "";
        try
        {
            if(value != null && !value.isEmpty() && !value.equalsIgnoreCase("null"))
            {
                return_value = value;
            }
            else
            {
                return_value = "";
            }
        }
        catch(Exception e)
        {
            return_value = "";
        }
        return return_value.trim();
    } 
    public static String check_tz_name(String value)
    {
        String return_value = "GMT"; //+00:00
        try
        {
            if(value != null && !value.isEmpty())
            {
                return_value = value;
            }
            else
            {
                return_value = "GMT";
            }
        }
        catch(Exception e)
        {
            return_value = "GMT";
        }
        return return_value.trim();
    } 
    public static String check_tz_time(String value)
    {
        String return_value = "+00:00"; //+00:00
        try
        {
            if(value != null && !value.isEmpty())
            {
                return_value = value;
            }
            else
            {
                return_value = "+00:00";
            }
        }
        catch(Exception e)
        {
            return_value = "+00:00";
        }
        return return_value.trim();
    } 
    public static String clean_up_email_address(String in_email_address)
    {
        String return_string = ""; 
        //Microsoft Outlook <MicrosoftExchange329e71ec88ae4615bbc36ab6ce41109e@xasystems1.onmicrosoft.com>
        if(in_email_address.contains("<"))
        {
            String temp1[] = in_email_address.split("<");
            String temp2[] = temp1[1].split(">");
            return_string = temp2[0];                    
        } 
        else
        {
            return_string = in_email_address; 
        }
        return return_string;
    }
    public static boolean is_valid_file_path(String path) 
    {
        File f = new File(path);
        try 
        {
           f.getCanonicalPath();
           return true;
        }
        catch (IOException e) 
        {
           return false;
        }
    }
    public static String random_string(int Size) 
    {  
        // function to generate a random string of length n 
        String AlphaNumericString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "0123456789" + "abcdefghijklmnopqrstuvxyz";
        // create StringBuffer size of AlphaNumericString 
        StringBuilder sb = new StringBuilder(Size);
        for (int i = 0; i < Size; i++) 
        {
            // generate a random number between 
            // 0 to AlphaNumericString variable length 
            int index = (int) (AlphaNumericString.length() * Math.random());
            // add Character one by one in end of sb 
            sb.append(AlphaNumericString.charAt(index)); 
        }    
        return sb.toString();
    }
    public static HashMap<String,String> process_request_parameters(String input)
    {
        String q = "id=" + input;
        String url = "https://example.com?q=" + URLEncoder.encode(q, StandardCharsets.UTF_8);
        q = URLDecoder.decode(q, StandardCharsets.UTF_8);
        HashMap return_hashmap = new HashMap();
        String temp[] = input.split("&");
        for(String pair: temp)
        {
            String p_split[] = pair.split("=");
            return_hashmap.put(p_split[0], p_split[1]);
        }
        return return_hashmap;
    }
}
