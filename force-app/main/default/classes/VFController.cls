public class VFController {
	
    private final Game__c game;
    public VFController(ApexPages.StandardController stdController) {
        this.game = (Game__c) stdController.getRecord();
    }
    
    public PageReference autoRun() {
 
        String theId = ApexPages.currentPage().getParameters().get('id');
 
        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }
 
        for(Game__c g : [SELECT Id, Player_1__c, Player_2__c, WNHC_Game_Id__c FROM Game__c WHERE Id =: theId LIMIT 1]) {
         	List<Game__c> games = new List<Game__c>();
			games.add(g);
			APIHelper.updateGamesFromAPI(games);   
        }
 
        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}