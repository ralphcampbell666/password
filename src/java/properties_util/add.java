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
public class add 
{
    /* 
    Add a value just under the label specified or 
    if no label is specified then add to the end of the file
   */
    public static boolean properties_file(File props_file,String label, String key, String value)
    {
        boolean return_boolean = true;
        boolean label_found = false;
        ArrayList<String> lines = new ArrayList();
        String newLine = System.getProperty("line.separator");
        try
        {
            FileReader fr = new FileReader(props_file);   //reads the file 
            BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
            String line;  
            while((line = br.readLine())!=null)  
            {  
                if(label.equalsIgnoreCase(""))
                {
                    //just add to the end
                    label_found = false;
                    lines.add(line);
                }
                else
                {
                    if(line.startsWith(label))
                    {
                        label_found = true;
                        lines.add(line);
                        //insert new value
                        lines.add(key + "=" + value);
                    }
                    else
                    {
                        lines.add(line);
                    }
                }
            } 
            if(!label_found)
            {
                //add value to end of the file
                lines.add(key + "=" + value);
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
            System.out.println("Exception in add.properties_file=" + e);
            return_boolean = false;
        } 
        return return_boolean;
    }    
}
