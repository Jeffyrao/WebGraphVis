package web.graph.vis;

public class Node {
	private String id;
	private String name;
	private String pagerank;
	private String url;
	private String party;
	private String committee;
	private String state;
	private String district;
	
	
	public Node(String id, String name, String pagerank, String url,
			String party, String committee, String state, String district) {
		this.id = id;
		this.name = name;
		this.pagerank = pagerank;
		this.url = url;
		this.party = party;
		this.committee = committee;
		this.state = state;
		this.district = district;
	}

	public String getId() {
		return id;
	}
	public String getName() {
		return name;
	}
	public String getPagerank() {
		return pagerank;
	}
	public String getUrl() {
		return url;
	}
	public String getParty() {
		return party;
	}
	public String getCommittee() {
		return committee;
	}
	public String getState() {
		return state;
	}
	public String getDistrict() {
		return district;
	}
	
}
