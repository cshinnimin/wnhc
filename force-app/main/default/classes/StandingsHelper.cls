public class StandingsHelper {
    
    @InvocableMethod(label='Update Standings' description='Updates standings for a tournament.')
    public static void updateStandings(List<Tournament__c> tournaments) {
        
        Set<Id> tournamentIds = (new Map<Id,Tournament__c>(tournaments)).keySet();
        
        List<Standing__c> standings;
        List<Game__c> games;
        
        try {
        	standings = [
				SELECT
					Tournament__c,
					Participant__c,
					GP__c,
					W__c,
					L__c,
					GF__c,
					GA__c
	            FROM Standing__c
				WHERE Tournament__c IN : tournamentIds
	        ];
        } catch (QueryException ex) {
        	throw new WNHC_Query_Exception(tournamentIds, 'StandingsHelper.apxc');
    	}
        
        try {
        	games = [
				SELECT
					Player_1__c,
					Player_1_Score__c,
					Player_2__c,
					Player_2_Score__c,
					Winner__c,
					Loser__c,
	            	Tournament__c
				FROM Game__c  
	            WHERE Tournament__c IN : tournamentIds
	        ];
        } catch (QueryException ex) {
        	throw new WNHC_Query_Exception(tournamentIds, 'StandingsHelper.apxc');
    	}
        
		for(Standing__c standing : standings) {
            
			Integer gp = 0;
			Integer w = 0;
			Integer l = 0;
			Integer gf = 0;
			Integer ga = 0;
            
			for(Game__c game : games) {
				if(game.Tournament__c != standing.Tournament__c) continue;  
                if(game.Winner__c == standing.Participant__c) {
                    // a game won by the participant
                    gp++;
                    w++;
                    if(game.Player_1__c == standing.Participant__c) {
						gf += game.Player_1_Score__c.intValue(); // ? not sure why Player_1_Score__c is a Decimal ?
						ga += game.Player_2_Score__c.intValue();                        
					} else {
						ga += game.Player_1_Score__c.intValue();
						gf += game.Player_2_Score__c.intValue();
					}
                }
				if(game.Loser__c == standing.Participant__c) {
					// a game lost by the participant 
					gp++;
                    l++;
                    if(game.Player_1__c == standing.Participant__c) {
						gf += game.Player_1_Score__c.intValue(); // ? not sure why Player_1_Score__c is a Decimal ?
						ga += game.Player_2_Score__c.intValue();                        
					} else {
						ga += game.Player_1_Score__c.intValue();
						gf += game.Player_2_Score__c.intValue();
					}
                }
            }
            
            standing.GP__c = gp;
            standing.W__c = w;
            standing.L__c = l;
            standing.GF__c = gf;
            standing.GA__c = ga;
        }
		
        try {
        	update standings;
        } catch (DMLException ex) {
        	throw new WNHC_DML_Exception(standings, 'StandingsHelper.apxc');
    	}
    }

}