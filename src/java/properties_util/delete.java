package properties_util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;

/**
 *
 * @author Campbellr_2
 */
public class delete 
{
    public static boolean properties_file(File props_file,String key)
    {
        boolean return_boolean = true;
        ArrayList<String> lines = new ArrayList();
        String newLine = System.getProperty("line.separator");
        try
        {
            FileReader fr = new FileReader(props_file);   //reads the file 
            BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
            String line;  
            while((line = br.readLine())!=null)  
            {  
                if(line.contains("=") && !line.startsWith("[") && !line.startsWith("//")) //is a key line
                {
                    String temp[] = line.split("=");
                    String pair_key = "";
                    String pair_value = "";
                    if(temp.length == 2) //key pair
                    {
                        pair_key = temp[0];
                        pair_value = temp[1];
                    }
                    else
                    {
                        pair_key = temp[0];
                    }
                    if(pair_key.equalsIgnoreCase(key))
                    {
                        //do nothing to delete this key pair
                    }
                    else
                    {
                        lines.add(line);
                    }
                }
                else
                {
                    lines.add(line);
                }     
            } 
            fr.close();    //closes the stream and release the resources 
            
            //write the updated file out
            FileWriter fw = new FileWriter(props_file);
            for(int a = 0; a < lines.size(); a++)
            {
                fw.write(lines.get(a) + newLine);
            }
            fw.close();            
        }
        catch(Exception e)
        {
            System.out.println("Exception in delete.properties_file=" + e);
            return_boolean = false;
        } 
        return return_boolean;
    }    
}
