@isTest global class APICalloutMock implements HttpCalloutMock {
 
    // Mock an API response for a game with the following details:
    // Period: 2
    // Game Clock: 6:28
    // Score: Player1 (2) - Player2 (4)
    
    global HTTPResponse respond(HTTPRequest req) {
        
	    System.assertEquals('GET', req.getMethod());
        
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"complete":0,"gameon":1,"period":2,"minute":4,"second":12,"shots1":4,"shots2":24,"goals":[{"scorer":"player2","period":1,"minute":0,"second":2},{"scorer":"player1","period":1,"minute":2,"second":49},{"scorer":"player2","period":1,"minute":5,"second":34},{"scorer":"player2","period":1,"minute":5,"second":57},{"scorer":"player2","period":2,"minute":6,"second":51},{"scorer":"player1","period":2,"minute":6,"second":40}],"penalties":[]}');
		res.setStatusCode(200);
		return res;
    }
}