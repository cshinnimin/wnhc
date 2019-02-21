@isTest public class StandingTest {
    
    @testSetup static void setup() {
        TestDataFactory.initialize();
    }
    
    @isTest static void testUpdateStandingsAfterGame() {
        
        // A test to ensure GP, W, L, GF, GA etc in Standing__c object gets updated when Game__c object gets status changed to "Completed"
        // or status changed BACK to "In Progress" or "Scheduled".
        
        // select the game from the Test Data Factory and place the game "In Progress"
        Game__c game = [SELECT Id, Tournament__c, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c LIMIT 1];
        game.Status__c = 'In Progress';
        update game;
        
        // add goals to make the game 2-1
        List<Goal__c> goals = new List<Goal__c>{};
        Goal__c goal1 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_1__c, Period__c = 1, Clock_Minute__c = 6, Clock_Second__c = 30);
        Goal__c goal2 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_2__c, Period__c = 2, Clock_Minute__c = 6, Clock_Second__c = 30);
        Goal__c goal3 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_2__c, Period__c = 3, Clock_Minute__c = 6, Clock_Second__c = 30);
        goals.add(goal1);
        goals.add(goal2);
        goals.add(goal3);
        insert goals;
        
        // complete game, triggering standings update:
        game.Status__c = 'Completed';
        update game;
        
        List<Standing__c> standings = [SELECT Id, Participant__c, GP__c, W__c, L__c, GF__c, GA__c, PTS__c FROM Standing__c WHERE Tournament__c =: game.Tournament__c ORDER BY PTS__c DESC];
        System.assert(standings[0].PTS__c == 2); // make sure P2 winner gets PTS added
        System.assert(standings[0].W__c == 1); // make sure P2 winner gets W added
        System.assert(standings[0].GF__c == 2); // make sure P2 winner gets 2 GF added
        System.assert(standings[0].GA__c == 1); // make sure P2 winner gets 1 GA against
        System.assert(standings[1].PTS__c == 0); // make sure P1 loser gets 0 PTS
        System.assert(standings[1].L__c == 1); // make sure P1 loser gets L added
        System.assert(standings[1].GF__c == 1); // make sure P1 loser gets 1 GF added
        System.assert(standings[1].GA__c == 2); // make sure P1 loser gets 2 GA added
        
        System.assert(standings[0].Participant__c == game.Player_2__c); // ensure P2 winner ends up on top of standings
        System.assert(standings[1].Participant__c == game.Player_1__c); // ensure P1 loser ends up on bottom
        
        // make sure standings "undone" after game status changed away from "Completed":
        game.Status__c = 'In Progress';
        update game;
		standings = [SELECT Id, Participant__c, GP__c, W__c, L__c, GF__c, GA__c, PTS__c FROM Standing__c WHERE Tournament__c =: game.Tournament__c ORDER BY PTS__c DESC];        
        System.assert(standings[0].PTS__c == 0); 
    }

}