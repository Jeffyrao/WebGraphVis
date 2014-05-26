package web.graph.vis.wordcount;

public class WordCount {
	public static int NUM_INTERVALS = 12;
	public String word;
	public String count[] = new String[NUM_INTERVALS];
	 
	public WordCount(String word){
		this.word = word;
		for(int i=0; i<NUM_INTERVALS; i++){
			this.count[i] = "0";
		}
	}
	
	public WordCount(String word, String[] count){
		this.word = word;
		this.count = count;
	}
	
	public String getWord() {
		return word;
	}

	public String[] getCount() {
		return count;
	}
	
	public void setCount(int interval, String count){
		this.count[interval] = count;
	}
}
