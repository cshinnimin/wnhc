public class TestDataFactory {
    
/*
	Although best practice seemed to dictate pulling test data in from static resource files, I continue getting the error
	"System.StringException: Unknown field: Icon Link" on the very first Test.loadData attempt for the Team__c object,
	even though I have verified that "Icon Link" is definitely the name of the field, and that this same file works fine
	when loading data in the Data Import Wizard. One particilar answer to this problem for other users was to remove a
	Byte Order Mark	character being inserted in to the CSV by Excel, however I used a Linux Text Editor to create the CSV
	file, and I verified with a hex editor that no such BOM character is present in the file, so I have ruled this out.
    Rather than spin my wheels for the purpose of the demo, I will instead create and insert some sObjects dynamically.
     
    public static void initialize() {

		System.debug('trying it');        
        List<sObject> testTeams = Test.loadData(Team__c.sObjectType, 'testTeams');
        System.debug('made it');        
        List<sObject> testParticipants = Test.loadData(Participant__c.sObjectType, 'testParticipants');
        List<sObject> testTournaments = Test.loadData(Tournament__c.sObjectType, 'testTournaments');
        List<sObject> testStandings = Test.loadData(Standing__c.sObjectType, 'testStandings');
        List<sObject> testGames = Test.loadData(Game__c.sObjectType, 'testGames');

        // Verify that all 15 test games were created
		System.assert(testGames.size() == 15);
        
	    Tournament__c tournament = (Tournament__c)testTournaments[0];
	    System.debug(tournament.Name__c);
        
        insert testTeams;
        insert testParticipants;
        insert testTournaments;
        insert testStandings;
        insert testGames;
    }
*/
	
    public static void initialize() {
        
        Tournament__c tournament = new Tournament__c(
        	Name__c = 'Test Tournament',
            Start_Date_and_Time__c = DateTime.newInstance(2020, 1, 1, 9, 0, 0),
            End_Date_and_Time__c = DateTime.newInstance(2020, 1, 5, 13, 0, 0)
        );
        insert tournament;
        
        List<Team__c> teams = new List<Team__c>{};
        Team__c team1 = new Team__c(Name__c = 'Team USA');
        Team__c team2 = new Team__c(Name__c = 'Team Sweden');
        teams.add(team1);
        teams.add(team2);
        insert teams;
            
        List<Participant__c> participants = new List<Participant__c>{};
        Participant__c participant1 = new Participant__c(Name__c = 'American Alice', Team__c = team1.Id);
        Participant__c participant2 = new Participant__c(Name__c = 'Swedish Sven', Team__c = team2.Id);
        participants.add(participant1);
        participants.add(participant2);
        insert participants;
        
        List<Standing__c> standings = new List<Standing__c>{};
		Standing__c standing1 = new Standing__c(Tournament__c = tournament.Id, Participant__c = participant1.Id);
        Standing__c standing2 = new Standing__c(Tournament__c = tournament.Id, Participant__c = participant2.Id);
        standings.add(standing1);
        standings.add(standing2);
        insert standings;
        
        List<Game__c> games = new List<Game__c>{};
        Game__c game1 = new Game__c(
        	Player_1__c = participant1.Id,
            Player_2__c = participant2.Id,
            Tournament__c = tournament.Id,
            Game_Date_and_Time__c = DateTime.newInstance(2020, 1, 2),
            WNHC_Game_Id__c = 1
        );
        games.add(game1);
        insert games;
        
    }
}