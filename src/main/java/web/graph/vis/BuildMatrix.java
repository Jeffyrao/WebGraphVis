package web.graph.vis;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import com.csvreader.CsvReader;

public class BuildMatrix {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		String nodeDir = "src/main/webapp/data/nodes.csv";
		String linkDir = "src/main/webapp/data/links.csv";
		String matrixDir = "src/main/webapp/data/matrix.json";
		
		// Get number of nodes
		int numOfNodes = 0;
		CsvReader reader = new CsvReader(nodeDir);
		reader.readHeaders();
		while(reader.readRecord()){
			numOfNodes++;
		}
		// Generate Matrix Json file
		reader = new CsvReader(linkDir);
		reader.readHeaders();
		BufferedWriter writer = new BufferedWriter(new FileWriter(matrixDir));
		writer.write("[\n");
		int last_node = 1;
		Map<Integer,String> links = new TreeMap<Integer,String>();
		while(reader.readRecord()){
			int curr_node = Integer.parseInt(reader.get("Source"));
			int target_node = Integer.parseInt(reader.get("Target"));
			String weight = reader.get("Weight");
			
			if(curr_node == last_node){
				links.put(target_node, weight);
			}else{
				for(int i=last_node; i<curr_node;i++){
					writer.write("  [");
					if(i==last_node){
						for(int j=1; j<numOfNodes; j++){
							if(links.containsKey(j)){
								writer.write(links.get(j)+",");
							}else{
								writer.write("0,");
							}
						}
						if(links.containsKey(numOfNodes)){
							writer.write(links.get(numOfNodes)+"],\n");
						}else{
							writer.write("0],\n");
						}
					}else{
						for(int j=1; j<numOfNodes; j++){
							writer.write("0,");
						}
						writer.write("0],\n");
					}
				}
				links.clear();
				links.put(target_node, weight);
			}
			last_node = curr_node;
		}
		for(int i= last_node; i<=numOfNodes; i++){
			writer.write("  [");
			if(i==last_node){
				for(int j=1; j<numOfNodes; j++){
					if(links.containsKey(j)){
						writer.write(links.get(j)+",");
					}else{
						writer.write("0,");
					}
				}
				if(links.containsKey(numOfNodes)){
					writer.write(links.get(numOfNodes)+"]\n");
				}else{
					writer.write("0]\n");
				}
			}else{
				for(int j=1; j<numOfNodes; j++){
					writer.write("0,");
				}
				writer.write("0]\n");
			}
		}
		writer.write("]");
		writer.close();
		reader.close();
	}

}
