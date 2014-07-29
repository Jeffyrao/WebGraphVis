package web.graph.vis;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class GenerateGeoCityData {
	static String option = "out";
	
	public static void main(String[] args) throws IOException{
		int numOfNodes = 31;
		double[][] weights = new double[numOfNodes][numOfNodes];
		String linkFile = "src/main/webapp/data/geocities-data.csv";
		// Generate Matrix Json file
		BufferedReader bf = new BufferedReader(new FileReader(linkFile));
		String line;
		int source = 0;
		while((line = bf.readLine()) != null){
			String[] groups = line.split(",");
			for(int target=0; target<groups.length; target++){
				int weight = Integer.parseInt(groups[target]);
				if(option.equals("in")){
					weights[target][source] = Math.log10(weight+1);
				}else{
					weights[source][target] = Math.log10(weight+1);
				}
				
			}
			source++;
		}
		
		String matrixFile = "src/main/webapp/data/geocities-"+option+"link.json";
		BufferedWriter writer = new BufferedWriter(new FileWriter(matrixFile));
		writer.write("[\n");
		int last_node = 1;
		for(int i=0; i<numOfNodes; i++){
			writer.write("  [");
			for(int j=0; j<numOfNodes; j++){
				if(j!=numOfNodes-1){
					writer.write(weights[i][j]+",");
				}else{
					if(i!=numOfNodes-1) {
						writer.write(weights[i][j]+"],\n");
					}else {
						writer.write(weights[i][j]+"]\n");
					}
					
				}
			}
		}
		writer.write("]");
		writer.close();
	}
}
