trigger UpdateGameScore on Goal__c (after insert, after update, after delete) {
    
    Integer score1 = 0;
    Integer score2 = 0;
    List<Game__c> gamesToUpdate;
    List<Goal__c> goals;
    Set<ID> gameIds = new Set<ID>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Goal__c updatedGoal: Trigger.new) { 
            gameIds.add(updatedGoal.Game__c);
        }
    }
    
    if(Trigger.isDelete) {
        for(Goal__c updatedGoal: Trigger.old) { 
            gameIds.add(updatedGoal.Game__c);
        }
    }

    try {
    	gamesToUpdate = [
        	SELECT
	            Id,
	            Player_1__c,
	            Player_1_Score__c,
	            Player_2__c,
	            Player_2_Score__c,
            	Period__c,
            	Clock_Minute__c,
            	Clock_Second__c
	        FROM Game__c
	        WHERE Id IN : gameIds
	    ];
    } catch (QueryException ex) {
        throw new WNHC_Query_Exception(gameIds, 'UpdateGameScore.apxt');
    }
    
    try {
    	goals = [
	        SELECT
	            Game__c,
	            Scorer__c,
            	Period__c,
            	Clock_Minute__c,
            	Clock_Second__c
	        FROM Goal__c
	        WHERE Game__c IN : gameIds
	    ];
    } catch (QueryException ex) {
        throw new WNHC_Query_Exception(gameIds, 'UpdateGameScore.apxt');
    }
    
    for(Game__c game : gamesToUpdate) {
        
        score1 = 0;
        score2 = 0;
        
        for(Goal__c goal : goals) {
            if(goal.Game__c != game.Id) continue;
            if(goal.Scorer__c == game.Player_1__c) {
                score1++;
            } else {
                score2++;
            }
            
            // update game time here, since Process Builder game time update
        	// was causing bulk insert tests to fail:
        
        	if(game.Period__c < goal.Period__c) { 
            	game.Period__c = goal.Period__c;
                game.Clock_Minute__c = goal.Clock_Minute__c;
                game.Clock_Second__c = goal.Clock_Second__c;
            } else {
                if(game.Clock_Minute__c > goal.Clock_Minute__c) {
                    game.Clock_Minute__c = goal.Clock_Minute__c;
                	game.Clock_Second__c = goal.Clock_Second__c;
                } else {
                    if(game.Clock_Minute__c == goal.Clock_Minute__c && game.Clock_Second__c > goal.Clock_Second__c) {
                        game.Clock_Second__c = goal.Clock_Second__c;
                    }
                }
            }
            
        }
        
        game.Player_1_Score__c = score1;
        game.Player_2_Score__c = score2;
    }
    
    try {
        update gamesToUpdate;
    } catch (DMLException ex) {
        throw new WNHC_DML_Exception(gamesToUpdate, 'UpdateGameScore.apxt');
    }
}