public class APIGame {
    
    public Integer period { get; set; }
	public Integer minute { get; set; }
	public Integer second { get; set; }
	public List<APIGoal> goals { get; set; } 

	public class APIGoal {
		public String scorer { get; set; }
		public Integer period { get; set; }
		public Integer minute { get; set; }
		public Integer second { get; set; }
	}
}