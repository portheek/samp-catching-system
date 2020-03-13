static Text:TD_CatchingEvent[2];
static PlayerText:PTD_CatchingEvent[MAX_PLAYERS];


ShowCatchingEventTD(playerid)
{
	UpdateCatchingEventPlayerTD(playerid);
	
	for(new i = 0; i < sizeof TD_CatchingEvent; i++)
		TextDrawShowForPlayer(playerid, TD_CatchingEvent[i]);

	PlayerTextDrawShow(playerid, PTD_CatchingEvent[playerid]);

	return 1;
}

UpdateCatchingEventTD()
{
	new 	
		string[216];


	if(g_isEventJoinable) // Jei event dar nepradëtas, bet vyksta
	{
		new eventTimeString[12];
		if(g_eventTime == 0)
			eventTimeString = "Neribotas";
		else
			format(eventTimeString, sizeof eventTimeString, "%02d:%02d", g_eventTime / 60, g_eventTime % 60);

		format(string, sizeof string,
			"~w~Gaudo: ~g~Niekas~n~\
			~w~Zaidzia: ~g~%i~n~\
			~w~Laikas: ~g~%s~n~",
			g_eventCurrentPlayers,
			eventTimeString
		);

		new tempString[64];
		if(PLAYERS_TO_START_EVENT - g_eventCurrentPlayers > 0)
			format(tempString, sizeof tempString, "~r~Laukiama zaideju: %i", PLAYERS_TO_START_EVENT - g_eventCurrentPlayers);
		else
			format(tempString, sizeof tempString, "~y~Zaidimas prasides uz %i sek", g_eventCurrentTime);

		strcat(string, tempString);
		TextDrawSetString(TD_CatchingEvent[0], string);
		return 1;
	}

	new 
		eventCatcherString[MAX_PLAYER_NAME],
		eventTimeString[12];


	if(g_eventCatcher == INVALID_PLAYER_ID)
		eventCatcherString = "Niekas";
	else 
		GetPlayerName(g_eventCatcher, eventCatcherString, MAX_PLAYER_NAME);

	if(g_eventTime == 0)
		eventTimeString = "Neribotas";
	else
		format(eventTimeString, sizeof eventTimeString, "%02d:%02d", g_eventCurrentTime / 60, g_eventCurrentTime % 60);

	format(string, sizeof string,
		"~w~Gaudo: ~g~%s~n~\
		~w~Zaidzia: ~g~%i~n~\
		~w~Laikas: ~g~%s~n~~n~",
		eventCatcherString,
		g_eventCurrentPlayers,
		eventTimeString
	);


	new topPlayers[3], size;
	GetTopThreeEventPlayers(topPlayers, size);

    for(new i = 0; i < size; i++)
    {
    	new tempString[64], pName[MAX_PLAYER_NAME];
    	GetPlayerName(topPlayers[i], pName, MAX_PLAYER_NAME);
    	format(tempString, sizeof tempString, "~g~%i.~w~ %s ~g~%i T.~n~", i+1, pName, g_playerEventScore[topPlayers[i]]);
    	strcat(string, tempString);
    }
	

    TextDrawSetString(TD_CatchingEvent[0], string);
	return 1;
}

UpdateCatchingEventPlayerTD(playerid)
{
	new 	
		string[48];

	format(string, sizeof string,
		"Gaudynes~n~\
		Jusu Taskai: ~g~%i",
		g_playerEventScore[playerid]
	);


	PlayerTextDrawSetString(playerid, PTD_CatchingEvent[playerid], string);
	return 1;
}

HideCatchingEventTD(playerid)
{
	for(new i = 0; i < sizeof TD_CatchingEvent; i++)
		TextDrawHideForPlayer(playerid, TD_CatchingEvent[i]);

	PlayerTextDrawHide(playerid, PTD_CatchingEvent[playerid]);

	return 1;
}



CreateCatchingEventTD()
{
	TD_CatchingEvent[0] = TextDrawCreate(20.000000, 167.000000, "~w~Gaudo: ~g~.static~n~~w~Zaidzia: ~g~4~n~~w~Laikas ~g~04:21");
	TextDrawLetterSize(TD_CatchingEvent[0], 0.203333, 1.031703);
	TextDrawAlignment(TD_CatchingEvent[0], 1);
	TextDrawColor(TD_CatchingEvent[0], -1);
	TextDrawSetShadow(TD_CatchingEvent[0], 1);
	TextDrawSetOutline(TD_CatchingEvent[0], 0);
	TextDrawBackgroundColor(TD_CatchingEvent[0], 255);
	TextDrawFont(TD_CatchingEvent[0], 2);
	TextDrawSetProportional(TD_CatchingEvent[0], 1);
	TextDrawSetShadow(TD_CatchingEvent[0], 1);

	TD_CatchingEvent[1] = TextDrawCreate(22.000000, 165.000000, "box");
	TextDrawLetterSize(TD_CatchingEvent[1], 0.000000, -0.166667);
	TextDrawTextSize(TD_CatchingEvent[1], 131.333374, 0.000000);
	TextDrawAlignment(TD_CatchingEvent[1], 1);
	TextDrawColor(TD_CatchingEvent[1], -1);
	TextDrawUseBox(TD_CatchingEvent[1], 1);
	TextDrawBoxColor(TD_CatchingEvent[1], 8388863);
	TextDrawSetShadow(TD_CatchingEvent[1], 0);
	TextDrawSetOutline(TD_CatchingEvent[1], 0);
	TextDrawBackgroundColor(TD_CatchingEvent[1], 255);
	TextDrawFont(TD_CatchingEvent[1], 1);
	TextDrawSetProportional(TD_CatchingEvent[1], 1);
	TextDrawSetShadow(TD_CatchingEvent[1], 0);

	return 1;
}

CreateCatchingEventPlayerTD(playerid)
{
	PTD_CatchingEvent[playerid] = CreatePlayerTextDraw(playerid, 20.000000, 137.000000, "Gaudynes~n~Jusu Taskai: ~g~55400");
	PlayerTextDrawLetterSize(playerid, PTD_CatchingEvent[playerid], 0.247666, 1.309629);
	PlayerTextDrawAlignment(playerid, PTD_CatchingEvent[playerid], 1);
	PlayerTextDrawColor(playerid, PTD_CatchingEvent[playerid], -1);
	PlayerTextDrawSetShadow(playerid, PTD_CatchingEvent[playerid], 1);
	PlayerTextDrawSetOutline(playerid, PTD_CatchingEvent[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PTD_CatchingEvent[playerid], 255);
	PlayerTextDrawFont(playerid, PTD_CatchingEvent[playerid], 2);
	PlayerTextDrawSetProportional(playerid, PTD_CatchingEvent[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PTD_CatchingEvent[playerid], 1);
	return 1;
}


