@isTest public class APITest {
    
    // A test to ensure the API response is properly parsed and the correct workflow occurs after receiving the response.
    // See the APICalloutMock.apxc file for details of the mocked API response.
    
	@testSetup static void setup() {
		TestDataFactory.initialize();
    }
    
    @isTest static void testUpdateGamesFromAPI() {
        
        // A test to ensure that the APIHelper.updateGamesFromAPI() method functions correctly based on the data it receives from the WNHC API.
        // The method should be able to parse the JSON information, insert the 6 goals, and then update the period and clock time correctly.
        // The last goal entered in the mocked information is at 6:28 of the second period, but the game clock time specified in the API is 
        // 4:12 of the second period, so the process should make sure that it updates the period and time AFTER the goals are inserted, to
        // override any potential conflict with the trigger that updates the game clock after goals are inserted.

        Game__c game = [SELECT Id, Status__c, Period__c, Clock_Minute__c, Clock_Second__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c, WNHC_Game_Id__c FROM Game__c LIMIT 1];
        game.Status__c = 'In Progress';
        update game;
        List<Game__c> games = new List<Game__c>{ game };
        
		Test.startTest(); // start asynchronous process
        Test.setMock(HttpCalloutMock.class, new APICalloutMock()); // Set mock callout class
		APIHelper.updateGamesFromAPI(games);
        Test.stopTest(); // end asynchronous process, proceed to System.assert() statements
        
        game = [SELECT Id, Status__c, Period__c, Clock_Minute__c, Clock_Second__c, Player_1__c, Player_1_Score__c, Player_2__c, Player_2_Score__c, WNHC_Game_Id__c FROM Game__c WHERE Id =: game.Id];
        System.assert(game.Player_1_Score__c == 2); // P1 should have 2 goals as per mocked data
        System.assert(game.Player_2_Score__c == 4); // P2 should have 4 goals as per mocked data
        System.assert(game.Period__c == 2); // Period should be 2 as per mocked data
        System.assert(game.Clock_Minute__c == 4); // Clock Minute should be 4 as per mocked data
        System.assert(game.Clock_Second__c == 12); // Clock Second should be 12 as per mocked data
    }
}