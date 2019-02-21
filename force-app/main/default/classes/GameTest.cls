@isTest public class GameTest {
    
    @testSetup static void setup() {
        TestDataFactory.initialize();
    }
    
    @isTest static void testUpdateGameScoreTrigger() {
        
        // A set of tests to make sure the triggers and processes related to updating the Player 1 Score and Player 2 Score fields
        // are working properly. A newly created game in the "Scheduled" status should have null values for scores. Once game is
        // set to "In Progress", zeroes should be defaulted in for scores. When a Goal object is added, the appropriate score should be
        // incremented. When a Goal object is deleted, the appropriate score should be decremented.
        
        // test UpdateGameScore trigger on creation and deletion of a goal
        Game__c game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c LIMIT 1];
        System.assert(game.Player_1_Score__c == null); // initial score null when status = "Scheduled"
        System.assert(game.Player_2_Score__c == null); // initial score null when status = "Scheduled"
        
        game.Status__c = 'In Progress';
        update game; // update the game, then re-select from database to retrieve updates as result of trigger
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Player_1_Score__c == 0); // initial score 0 when status = "In Progress"
        System.assert(game.Player_2_Score__c == 0); // initial score 0 when status = "In Progress"
        
        Goal__c goal = new Goal__c(
        	Game__c = game.Id,
            Scorer__c = game.Player_1__c,
            Period__c = 1,
            Clock_Minute__c = 6,
            Clock_Second__c = 30
        );
        insert goal; // add a goal to the game for player 1
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Player_1_Score__c == 1); // P1 score incremented to 1 by trigger
        System.assert(game.Player_2_Score__c == 0); // P2 remains at 0
        
        delete goal; // delete the goal
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Player_1_Score__c == 0); // P1 score decremented to 0 by trigger
        System.assert(game.Player_2_Score__c == 0); // P2 remains at 0
    }
    
    @isTest static void testGameCreationDuringTournamentWindow() {
        
		// A game should not be allowed to be created unless its start date and time fall within the tournament window.
		
        List<Game__c> games;
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
		List<Participant__c> participants = [SELECT Id FROM Participant__c LIMIT 2];
        
        // create a game that begins BEFORE the tournament starts
        Game__c game = new Game__c(
        	Player_1__c = participants[0].Id,
            Player_2__c = participants[1].Id,
            Tournament__c = tournament.Id,
            Game_Date_and_Time__c = DateTime.newInstance(2019, 12, 31, 9, 0, 0)
        );
        try {
        	insert game;
        } catch (DmlException ex) {
            // expecting a DmlException!
        }
        games = [SELECT Id FROM Game__c];
        System.assert(games.size() == 1); // should not have added any games
        
        
        // create a game that begins AFTER the tournament ends
        game = new Game__c(
        	Player_1__c = participants[0].Id,
            Player_2__c = participants[1].Id,
            Tournament__c = tournament.Id,
            Game_Date_and_Time__c = DateTime.newInstance(2020, 1, 5, 14, 0, 0)
        );
        try {
        	insert game;
        } catch (DmlException ex) {
            // expecting a DmlException!
        }
        games = [SELECT Id FROM Game__c];
        System.assert(games.size() == 1); // should not have added any games
        
        
        // create a game that begins DURING the tournament
        game = new Game__c(
        	Player_1__c = participants[0].Id,
            Player_2__c = participants[1].Id,
            Tournament__c = tournament.Id,
            Game_Date_and_Time__c = DateTime.newInstance(2020, 1, 1, 10, 0, 0)
        );
        insert game; // NOT expecting a DmlException... want it to be thrown if there is a problem
        games = [SELECT Id FROM Game__c];
        System.assert(games.size() == 2); // should have added the game
    }
    
    @isTest static void testGameCannotEndInATie() {
        
        // The NES Ice Hockey video game can never end in a tie. Therefore we should not be able to complete a game
        // (change status to "Completed") with the score tied. Once a tie is broken, we should be able to then complete
        // the game.
        
        // select the game from the Test Data Factory and place the game "In Progress"
        Game__c game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c LIMIT 1];
        game.Status__c = 'In Progress';
        update game;
		
        // add one goal for each player
        List<Goal__c> goals = new List<Goal__c>{};
        Goal__c goal1 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_1__c, Period__c = 1, Clock_Minute__c = 6, Clock_Second__c = 30);
        Goal__c goal2 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_2__c, Period__c = 2, Clock_Minute__c = 6, Clock_Second__c = 30);
        goals.add(goal1);
        goals.add(goal2);
        insert goals;
        
        // try to end the game, this should fail because the game is tied
        game.Status__c = 'Completed';
        try {
        	update game;
        } catch (DmlException ex) {
            // expecting a DmlException!
        }
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Status__c == 'In Progress'); // verify this game is still "In Progress"
        
        // add a goal for player 1, making the score 2-1
        Goal__c goal3 = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_1__c, Period__c = 3, Clock_Minute__c = 6, Clock_Second__c = 30);
        insert goal3;
        
        // pull the game again to get the score which should now be 2-1, then complete the game
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        game.Status__c = 'Completed';
        update game; // NOT expecting a DmlException... want it to be thrown if there is a problem
        
        game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Status__c == 'Completed'); // verify this game is now "Completed"
    }
    
    @isTest static void testBulkGoalInsert() {
        
        // Maximum score for either player in a game is 99, since Player 1 Score and Player 2 score attributes are 2 digit Integers
        // (designed this way because it would be impossible for either to score this many in a game with 7 minute periods), so we 
        // will bulk test entering 99 goals for each player at the same time to test the quality of the code to ensure the governor
        // limits are not exceeded.
        
        List<Goal__c> goalsToInsert = new List<Goal__c>{};
        
         // select the game from the Test Data Factory and place the game "In Progress"
        Game__c game = [SELECT Id, Status__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c FROM Game__c LIMIT 1];
        game.Status__c = 'In Progress';
        update game;
        
        Goal__c goal;
        Integer minute = 7;
        Integer second = 0;
        
        // add 99 goals for Player 1
        for(Integer i = 0; i < 99; i++) {
            if(second == 0) {
                second = 60;
                minute--;
            }
            second--;
            goal = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_1__c, Period__c = 1, Clock_Minute__c = minute, Clock_Second__c = second);
            goalsToInsert.add(goal);
        }
        
        // add 99 goals for Player 2
        for(Integer i = 0; i < 99; i++) {
            if(second == 0) {
                second = 60;
                minute--;
            }
            second--;
            goal = new Goal__c(Game__c = game.Id, Scorer__c = game.Player_2__c, Period__c = 1, Clock_Minute__c = minute, Clock_Second__c = second);
            goalsToInsert.add(goal);
        }
        
        insert goalsToInsert; // no try/catch since we are testing the ability of the system NOT to create a DmlException here
    }
    
}