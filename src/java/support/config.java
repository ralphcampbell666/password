package support;

import java.io.File;
import java.util.LinkedHashMap;

/**
 *
 * @author ralph
 */
public class config {
    public static LinkedHashMap get_config(String context_dir)
    {
        LinkedHashMap source_linked_has_map = new LinkedHashMap(); 
        File config_file = new File(context_dir + "/WEB-INF/config.properties");
        try
        {
            if (config_file.exists()) 
            {
                source_linked_has_map = properties_util.read.properties_file(config_file);
            }
            else
            {
                System.out.println("Did not find a config file. New install? in config.get_config: Can't find " + config_file.getAbsolutePath());
            }
        }
        catch (Exception exc)
        {
            System.out.println("in config.get_config:" +  exc);
        } 
        //logger.debug("End config.get_config");
        return source_linked_has_map;
    }
}
