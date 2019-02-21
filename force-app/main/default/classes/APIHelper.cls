public class APIHelper {
    
    public static final String API_Location = 'http://24.67.188.126:3000/livegames/';
    
    private static APIGame calloutGetGame(String WNHC_Game_Id) {
        
        // Private method to perform the API callout based on the WNHC_Game_Id provided
        
		Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = API_Location + WNHC_Game_Id;
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        APIGame apiGame = (APIGame) JSON.deserialize(response.getBody(), APIGame.class);
        
        return APIGame;
    } 
    
    @InvocableMethod(label='Update Games' description='Updates games via the WNHC API.')
    public static void updateGamesFromAPI(List<Game__c> games) {
      
        APIGame apiGame;
        Boolean goal_exists = false;
        Http httpProtocol = new Http();
        
        Set<Id> gameIds = (new Map<Id,Game__c>(games)).keySet();
        
        List<Goal__c> goals;
        List<Goal__c> goalsToInsert = new List<Goal__c>{};
        
        try {
        	goals = [
	            SELECT
	            	Game__c,
	            	Scorer__c,
	            	Period__c,
	            	Clock_Minute__c,
	            	Clock_Second__c,
	            	Game__r.WNHC_Game_Id__c
    	        FROM Goal__c
            	WHERE Game__c IN : gameIds
        	];
        } catch (QueryException ex) {
        	throw new WNHC_Query_Exception(gameIds, 'GamesHelper.apxc');
    	}
        
        for(Game__c game : games) {
            
            apiGame = calloutGetGame(String.valueOf(game.WNHC_Game_Id__c));
            
            for(APIGame.APIGoal apiGoal : apiGame.goals) {

                game.Period__c = apiGame.period;
                game.Clock_Minute__c = apiGame.minute;
                game.Clock_Second__c = apiGame.second;
                
                goal_exists = false;
                for(Goal__c goal : goals) { 
                    if(goal.Game__r.WNHC_Game_Id__c != game.WNHC_Game_Id__c) continue;
                    if(goal.Period__c == apiGoal.period && goal.Clock_Minute__c == apiGoal.minute && goal.Clock_Second__c == apiGoal.second) {
                        goal_exists = true;
                        break;
                    }
                }
                
                if(!goal_exists) {
                    // new goal has been scored
                    Id scorer;
                    if(apiGoal.scorer == 'player1') {
                        scorer = game.Player_1__c;
                    } else {
                        scorer = game.Player_2__c;
                    }
                    
                    Goal__c newGoal = new Goal__c(
                        Game__c = game.Id,
                        Scorer__c = scorer,
                        Period__c = apiGoal.period,
                        Clock_Minute__c = apiGoal.minute,
                        Clock_Second__c = apiGoal.second
                    );
                    
                    goalsToInsert.add(newGoal);
                }
            }
        }
        
        try {
        	insert goalsToInsert;
        } catch (DMLException ex) {
            System.debug(ex);
        	throw new WNHC_DML_Exception(goalsToInsert, 'GamesHelper.apxc');
    	}
            
        try {
            update games;
        } catch (DMLException ex) {
        	throw new WNHC_DML_Exception(games, 'GamesHelper.apxc');
    	}
    }
    
	
}