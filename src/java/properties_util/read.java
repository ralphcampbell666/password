package properties_util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.LinkedHashMap;

/**
 *
 * @author Campbellr_2
 */
public class read 
{
    public static LinkedHashMap properties_file(File props_file)
    {
        LinkedHashMap props_hash = new LinkedHashMap();        
        try
        {
            FileReader fr = new FileReader(props_file);   //reads the file 
            BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
            String line;  
            while((line = br.readLine())!=null)  
            {  
                if(line.startsWith("//") || line.startsWith("#"))
                {
                    props_hash.put(line,"");
                }
                else 
                {
                    if(line.startsWith("["))
                    {
                        props_hash.put(line,"");
                    }
                    else
                    {
                        String temp[] = line.split("=");
                        if(temp.length == 2) //just a value
                        {
                            props_hash.put(temp[0],temp[1]);
                        }
                    }
                }
            } 
            fr.close();    //closes the stream and release the resources 
        }
        catch(Exception e)
        {
            System.out.println("Exception in read.properties_file=" + e);
        }        
        return props_hash;
    }
}
