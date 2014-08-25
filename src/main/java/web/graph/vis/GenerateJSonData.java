package web.graph.vis;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.csvreader.CsvReader;

public class GenerateJSonData {
	static String option = "out";
	
	public static void WriteSiteLinks(int numOfNodes, String linkFile, String matrixDir) throws IOException{
		double [][] weights = new double[numOfNodes][numOfNodes];
		for(int i=0; i<numOfNodes; i++){
			for(int j=0; j<numOfNodes; j++){
				weights[i][j] = 0;
			}
		}
		
		String[] parts = linkFile.split("-");
		String date = parts[1];
		String matrixFile = matrixDir+option+"links-"+date+".json";
		
		// Generate Matrix Json file
		BufferedReader bf = new BufferedReader(new FileReader(linkFile));
		String line;
		while((line = bf.readLine()) != null){
			String[] groups = line.split("[,\\s+]");
			int source = Integer.parseInt(groups[0]);
			int target = Integer.parseInt(groups[1]);
			int weight = Integer.parseInt(groups[2]);
			if(source != target) {
				if(option.equals("out")){
					weights[source-1][target-1] = Math.log10(weight+1);
				}else if(option.equals("in")){
					weights[target-1][source-1] = Math.log10(weight+1);
				}
			}
		}
		bf.close();
		
		for(int i=0; i<numOfNodes; i++){
			boolean flag = false;
			for(int j=0; j<numOfNodes; j++){
				if(weights[i][j]!=0)
					flag = true;
			}
			if(flag == false){
				weights[i][i] = 0.5;
			}
		}
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
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		String nodeDir = "src/main/webapp/data/prefix.csv";
		String linkDir = "src/main/webapp/data/sitelinks/";
		String matrixDir = "src/main/webapp/data/matrixlinks/";
		// Get number of nodes
		int numOfNodes = 0;
		CsvReader reader = new CsvReader(nodeDir);
		reader.readHeaders();
		while(reader.readRecord()){
			numOfNodes++;
		}
		
		File folder = new File(linkDir);
		if(folder.isDirectory()){
			for (File file : folder.listFiles()) {
				if(!file.getName().startsWith("sitelinks"))
					continue;
				WriteSiteLinks(numOfNodes, linkDir+file.getName(), matrixDir);
			}
		}
		
	}

}
