package web.graph.vis;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

import com.csvreader.CsvReader;

public class BuildIncomingMatrix {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		String nodeDir = "src/main/webapp/data/prefix.csv";
		String linkDir = "src/main/webapp/data/sitelinks.csv";
		String matrixDir = "src/main/webapp/data/inlink_matrix.json";
		// Get number of nodes
		int numOfNodes = 0;
		CsvReader reader = new CsvReader(nodeDir);
		reader.readHeaders();
		while(reader.readRecord()){
			numOfNodes++;
		}
		
		double [][] weights = new double[numOfNodes][numOfNodes];
		for(int i=0; i<numOfNodes; i++){
			for(int j=0; j<numOfNodes; j++){
				weights[i][j] = 0;
			}
		}
		
		// Generate Matrix Json file
		reader = new CsvReader(linkDir);
		reader.readHeaders();
		while(reader.readRecord()){
			int source_node = Integer.parseInt(reader.get("Source"));
			int target_node = Integer.parseInt(reader.get("Target"));
			double weight = Double.valueOf(reader.get("Weight"));
			weights[target_node-1][source_node-1] = weight;
		}
		
		BufferedWriter writer = new BufferedWriter(new FileWriter(matrixDir));
		writer.write("[\n");
		int last_node = 1;
		for(int i=0; i<numOfNodes; i++){
			writer.write("  [");
			for(int j=0; j<numOfNodes; j++){
				if(j!=numOfNodes-1){
					writer.write(weights[i][j]+",");
				}else{
					writer.write(weights[i][j]+"],\n");
				}
			}
		}
		writer.write("]");
		writer.close();
	}

}
