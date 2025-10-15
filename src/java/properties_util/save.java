package properties_util;

import java.io.File;
import java.io.FileWriter;
import java.util.LinkedHashMap;
import java.util.Set;

/**
 *
 * @author Campbellr_2
 */
public class save 
{
    public static boolean linked_hash_map(File props_file,LinkedHashMap map)
    {
        boolean return_boolean = true;
        String newLine = System.getProperty("line.separator");
        try
        {
            FileWriter fw = new FileWriter(props_file);
            
            Set<String> keys = map.keySet();
            for(String k:keys)
            {
                if(k.startsWith("//") || k.startsWith("#") || k.startsWith(" "))
                {
                    fw.write(k + newLine);
                }
                else 
                {
                    if(k.startsWith("["))
                    {
                        fw.write(k + newLine);
                    }
                    else
                    {
                        fw.write(k + "=" + map.get(k) + newLine);

                    }
                }                    
            }
            fw.close();           
        }
        catch(Exception e)
        {
            System.out.println("Exception in save.linked_hash_map=" + e);
            return_boolean = false;
        } 
        return return_boolean;
    }    
}
