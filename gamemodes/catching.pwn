/*		
 *		SAMP Gaudyniø Sistema
 *		SAMP Catching System
 *		by .static
 *		v1.0
 */

#include <a_samp>
#include <zcmd>
#include <sscanf2>

// --------------------- [ DEFINES ] --------------------- // 

#define C_RED 								0xf94848ff	// Raudona spalva
#define C_GREEN								0x79d44cff	// Þalia spalva

#define EVENT_PLAYERS_TEAM					14
#define PLAYERS_TO_START_EVENT				2		// Þaidëjø kiekis, kad gaudynës prasidëtø automatiðkai.
#define SECONDS_TO_START_EVENT				30		// Po kiek sekundþiø prasidës event, susirinkus pakankamai þaidëjø.
#define EVENT_VIRTUAL_WORLD					451
#define CATCHING_EVENT_TIMER_INTERVAL		500		// Timer'io pasikartojimo laikas.
#define MINIMUM_DISTANCE_RECIEVE_SCORE		300		// Minimalus atstumas tarp þaidëjo ir gaudytojo, jog þaidëjas gautø taðkus.
#define CATCHING_COOLDOWN_TIME				3		// Laikas sekundëmis, kuris laikinai sustabdo gaudymus po þaidëjo pagavimo. 
#define PLAYER_SCORE_CUT_ON_CATCH			6		// Dalis taðkø (þaidëjo taðkai padalinti ið nurodyto skaièiaus), kurie atiteks gaudytojui pagavus þaidëjà.
#define DISTANCE_TO_CATCH_PLAYER			6.0		

main()
{
	print("Gaudyniø sistema veikia");
}

// --------------------- [ GLOBALS ] --------------------- // 

new
	bool:g_isEventStarted = false,
	bool:g_isEventJoinable = false,
	g_eventTime,
	g_eventCurrentTime,
	g_eventTimer,
	g_eventMaxPlayers,
	g_eventCurrentPlayers,
	g_eventVehicle,
	g_catchingCooldown,
	g_eventCatcher;


new 
	g_secondTimer;


new 
	bool:g_playerInEvent[MAX_PLAYERS],
	g_playerEventVehicle[MAX_PLAYERS],
	g_playerEventScore[MAX_PLAYERS];


// --------------------- [ LIB INCLUDES ] --------------------- // 

#include "lib/event_ui.pwn"
#include "lib/utils.pwn"

// --------------------- [ PUBLICS ] --------------------- // 

public OnGameModeInit()
{
	AddPlayerClass(1, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0);
	CreateCatchingEventTD();
	EnableVehicleFriendlyFire();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	g_eventCurrentPlayers = 0;
	g_eventCatcher = INVALID_PLAYER_ID;
	return 1;
}

public OnPlayerConnect(playerid)
{
	CreateCatchingEventPlayerTD(playerid);
	g_playerInEvent[playerid] = false;
	g_playerEventVehicle[playerid] = 0;
	g_playerEventScore[playerid] = 0;
	SetPlayerTeam(playerid, NO_TEAM);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(g_playerInEvent[playerid])
		LeaveEventForPlayer(playerid);
	
	return 1;
}


forward OnCatchingEventGoing();
public OnCatchingEventGoing()
{
	if(g_isEventStarted)
	{
		if(!g_isEventJoinable)
		{
			if(g_catchingCooldown < 1)
			{
				new Float:catcherPos[3];
				GetVehiclePos(g_playerEventVehicle[g_eventCatcher], catcherPos[0], catcherPos[1], catcherPos[2]);
				for(new i = 0; i <= GetPlayerPoolSize(); i++)
				{
					if(g_playerInEvent[i] && i != g_eventCatcher)
					{
						new Float:_playerPos[3];
						GetVehiclePos(g_playerEventVehicle[i], _playerPos[0], _playerPos[1], _playerPos[2]);
						if(GetDistance(catcherPos[0], catcherPos[1], catcherPos[2], _playerPos[0], _playerPos[1], _playerPos[2]) < DISTANCE_TO_CATCH_PLAYER)
						{
							new scoreBonus = g_playerEventScore[i] / PLAYER_SCORE_CUT_ON_CATCH;
							g_playerEventScore[g_eventCatcher] += scoreBonus;
							g_playerEventScore[i] -= scoreBonus;

							new string[32];
							format(string, sizeof string, "~n~~n~~n~~g~+%i tasku!", scoreBonus);
							GameTextForPlayer(g_eventCatcher, string, 2000, 3);

							format(string, sizeof string, "~n~~n~~n~~r~-%i tasku!", scoreBonus);
							GameTextForPlayer(i, string, 2000, 3);

							UnsetPlayerCatcher(g_eventCatcher);
							SetPlayerCatcher(i);
							g_catchingCooldown = CATCHING_COOLDOWN_TIME;
							break;
						}
					}
				}
			}
		}
	}
	else
		KillTimer(g_eventTimer);

	return 1;
}

forward OnSecondPassed();
public OnSecondPassed()
{
	if(g_isEventStarted)
	{
		if(!g_isEventJoinable)
		{
			if(g_eventTime > 0)
			{
				g_eventCurrentTime--;
				if(g_eventCurrentTime <= 0)
				{
					EndCatchingEvent();
					return 1;
				}
			}

			if(g_catchingCooldown > 0)
			{
				g_catchingCooldown--;
			}
			else
			{
				new Float:catcherPos[3];
				GetPlayerPos(g_eventCatcher, catcherPos[0], catcherPos[1], catcherPos[2]);
				for(new i = 0; i <= GetPlayerPoolSize(); i++)
				{
					if(g_playerInEvent[i] && IsPlayerConnected(i))
					{
						new Float:vRot[3];
						GetVehicleRotation(g_playerEventVehicle[i], vRot[0], vRot[1], vRot[2]);
						if(vRot[0] > 140 || vRot[0] < -140 || vRot[1] > 140 || vRot[1] < -140)
							SetVehicleZAngle(g_playerEventVehicle[i], vRot[2]);

						new Float:pvHealth;
						GetVehicleHealth(g_playerEventVehicle[i], pvHealth);
						if(pvHealth < 700)
							SetVehicleHealth(g_playerEventVehicle[i], 999);

						if(i != g_eventCatcher)
						{
							new Float:_playerPos[3];
							GetPlayerPos(i, _playerPos[0], _playerPos[1], _playerPos[2]);
							new distance = GetDistance(_playerPos[0], _playerPos[1], _playerPos[2], catcherPos[0], catcherPos[1], catcherPos[2]);
							
							if(distance < MINIMUM_DISTANCE_RECIEVE_SCORE)
							{
								g_playerEventScore[i] += (MINIMUM_DISTANCE_RECIEVE_SCORE - distance) / 10;
							}
						}
						
						UpdateCatchingEventPlayerTD(i);
					}
				}
			}
		}
		else
		{
			g_eventCurrentTime--;

			if(g_eventCurrentTime <= 0 && g_eventCurrentPlayers >= PLAYERS_TO_START_EVENT)
				StartCatchingEvent();
			else if(g_eventCurrentPlayers < PLAYERS_TO_START_EVENT)
				g_eventCurrentTime = SECONDS_TO_START_EVENT;
		}

		UpdateCatchingEventTD();
	}
	else
		KillTimer(g_secondTimer);
	return 1;
}

// --------------------- [ FUNCTIONS ] --------------------- // 

LeaveEventForPlayer(playerid)
{
	if(g_playerEventVehicle[playerid] > 0)
		DestroyVehicle(g_playerEventVehicle[playerid]);

	g_playerInEvent[playerid] = false;
	g_playerEventScore[playerid] = 0;
	SetPlayerTeam(playerid, NO_TEAM);
	SetPlayerVirtualWorld(playerid, 0);
	DisableRemoteVehicleCollisions(playerid, 0);

	HideCatchingEventTD(playerid);

	g_eventCurrentPlayers--;

	if(g_isEventStarted && g_eventCurrentPlayers < 2)
		EndCatchingEvent();

	return 1;
}

UnsetPlayerCatcher(playerid)
{
	g_eventCatcher = INVALID_PLAYER_ID;

	if(!IsPlayerInVehicle(playerid, g_playerEventVehicle[playerid]))
		PutPlayerInVehicle(playerid, g_playerEventVehicle[playerid], 0);

	ChangeVehicleColor(g_playerEventVehicle[playerid], 1, 1);
	return 1;
}

SetPlayerCatcher(playerid)
{
	g_eventCatcher = playerid;
	SendClientMessage(playerid, C_GREEN, "Dabar tu gaudai!");

	if(!IsPlayerInVehicle(playerid, g_playerEventVehicle[playerid]))
		PutPlayerInVehicle(playerid, g_playerEventVehicle[playerid], 0);

	ChangeVehicleColor(g_playerEventVehicle[playerid], 3, 3);
	return 1;
}

StartCatchingEvent()
{
	g_isEventJoinable = false;
	g_eventCurrentTime = g_eventTime;

	for(new i = 0; i <= GetPlayerPoolSize(); i++)
	{
		if(g_playerInEvent[i])
		{
			GameTextForPlayer(i, "~n~~n~~n~~w~GAUDYNES ~g~PRASIDEJO~w~!!!", 3000, 3);
			DisableRemoteVehicleCollisions(i, 0);
		}
	}

	new randomPlayerCounter = random(g_eventCurrentPlayers);
	new randomPlayer = -1;
	
	for(new i = 0; i <= GetPlayerPoolSize() && randomPlayer == -1; i++)
	{
		if(g_playerInEvent[i] && IsPlayerConnected(i))
		{
			if(randomPlayerCounter == 0)
				randomPlayer = i;
			randomPlayerCounter--;
		}
	}

	SetPlayerCatcher(randomPlayer);
	
	SendClientMessageToAll(C_GREEN, "Gaudynës prasidëjo!");

	return 1;
}

EndCatchingEvent()
{
	g_isEventStarted = false;

    SendClientMessageToAll(C_GREEN, "Gaudynës baigësi! Daugiausiai taðkø surinkæ þaidëjai:");

	new topPlayers[3], size;
	GetTopThreeEventPlayers(topPlayers, size);

    for(new i = 0; i < size; i++)
    {
    	new tempString[64];
    	format(tempString, sizeof tempString, "• %i. %s surinko %i taðkø!", i+1, GetPlayerNameEx(i), g_playerEventScore[topPlayers[i]]);
    	SendClientMessageToAll(C_GREEN, tempString);
    }

	for(new i = 0; i <= GetPlayerPoolSize(); i++)
	{
		if(IsPlayerConnected(i) && g_playerInEvent[i])
			LeaveEventForPlayer(i);
	}

	KillTimer(g_eventTimer);
	KillTimer(g_secondTimer);
	return 1;
}

GetTopThreeEventPlayers(topPlayers[], &size)
{
	new eventPlayers[MAX_PLAYERS];
	size = 0;

	for(new i = 0; i <= GetPlayerPoolSize(); i++)
	{
		if(IsPlayerConnected(i) && g_playerInEvent[i])
		{
			eventPlayers[size] = i;
			size++;
		}
	}


	if(size == 1)
	{
		topPlayers[0] = eventPlayers[0];
	}
	else if(size == 2)
	{
		if(g_playerEventScore[eventPlayers[0]] > g_playerEventScore[eventPlayers[1]])
		{
			topPlayers[0] = eventPlayers[0];
			topPlayers[1] = eventPlayers[1];
		}
		else
		{
			topPlayers[0] = eventPlayers[1];
			topPlayers[1] = eventPlayers[0];
		}
	}
	else
	{
		topPlayers[0] = MAX_PLAYERS-1;
		topPlayers[1] = MAX_PLAYERS-1;
		topPlayers[2] = MAX_PLAYERS-1;

		for (new i = 0; i < size; i++) 
		{ 
			new score = g_playerEventScore[eventPlayers[i]];
			if (score >= g_playerEventScore[topPlayers[0]]) 
			{ 
				topPlayers[2] = topPlayers[1]; 
				topPlayers[1] = topPlayers[0]; 
				topPlayers[0] = eventPlayers[i]; 
			} 
			else if (score >= g_playerEventScore[topPlayers[1]]) 
			{ 
				topPlayers[2] = topPlayers[1]; 
				topPlayers[1] = eventPlayers[i]; 
			} 
			else if (score >= g_playerEventScore[topPlayers[2]]) 
				topPlayers[2] = eventPlayers[i]; 
		} 
	}

	if(size > 3)
    	size = 3;
	return 1;
}

// --------------------- [ COMMANDS ] --------------------- // 

CMD:gaudynes(playerid, params[])
{
	if(g_isEventStarted)
		return SendClientMessage(playerid, C_RED, "[!] Gaudynës jau pradëtos!");

	new 
		vehicleid, eventPlayers, eventTime;

	if(sscanf(params, "iii", vehicleid, eventPlayers, eventTime))
		return SendClientMessage(playerid, C_RED, "[!] /gaudynes [transporto_id] [þaidëjai] [laikas(sekundës)]");

	if(vehicleid < 400 || vehicleid > 611 || eventPlayers < 0 || eventTime < 0)
		return SendClientMessage(playerid, C_RED, "[!] Nurodytos reikðmës negalimos!");

	new
		string[86],
		eventTimeString[15] = "Iki sustabdymo",
		eventPlayersString[10] = "Neribotas";

	if(eventPlayers > 0)
		format(eventPlayersString, sizeof eventPlayersString, "%i", eventPlayers);

	if(eventTime > 0)
		format(eventTimeString, sizeof eventTimeString, "%02d:%02d", eventTime / 60, eventTime % 60);

	format(string, sizeof string, "[~] Gaudyniø event! Trukmë: %s, Vietø skaièius: %s. /prisijungti", 
		eventTimeString, eventPlayersString);
	SendClientMessageToAll(C_GREEN, string);

	g_isEventStarted = true;
	g_isEventJoinable = true;
	g_eventTime = eventTime;
	g_eventCurrentTime = SECONDS_TO_START_EVENT;
	g_eventMaxPlayers = eventPlayers;
	g_eventCurrentPlayers = 0;
	g_eventVehicle = vehicleid;
	g_eventCatcher = INVALID_PLAYER_ID;

	g_eventTimer = SetTimer("OnCatchingEventGoing", CATCHING_EVENT_TIMER_INTERVAL, true);
	g_secondTimer = SetTimer("OnSecondPassed", 1000, true);
	return 1;

}

CMD:baigti(playerid)
{
	if(!g_isEventStarted)
		return SendClientMessage(playerid, C_RED, "[!] Gaudynës nëra pradëtos!");

	EndCatchingEvent();
	return 1;
}

CMD:pradeti(playerid)
{
	StartCatchingEvent();
	SendClientMessageToAll(C_GREEN, "Gaudynës pradëtos!");
	return 1;
}

CMD:prisijungti(playerid)
{
	if(!g_isEventStarted)
		return SendClientMessage(playerid, C_RED, "[!] Gaudynës nevyksta!");

	if(g_playerInEvent[playerid])
		return SendClientMessage(playerid, C_RED, "[!] Jûs jau dalyvaujate! /palikti");

	if(g_eventCurrentPlayers >= g_eventMaxPlayers && g_eventMaxPlayers > 0)
		return SendClientMessage(playerid, C_RED, "[!] Visos vietos jau uþimtos!");

	if(!g_isEventJoinable)
		return SendClientMessage(playerid, C_RED, "[!] Gaudynës jau pradëtos.");

	g_playerInEvent[playerid] = true;
	g_playerEventScore[playerid] = 0;
	g_eventCurrentPlayers++;
	SetPlayerTeam(playerid, EVENT_PLAYERS_TEAM);
	SetPlayerVirtualWorld(playerid, EVENT_VIRTUAL_WORLD);

	g_playerEventVehicle[playerid] = CreateVehicle(g_eventVehicle, 1200.6508,-1333.0132,13.1714, 0.0, 1, 1, 0);
	SetVehicleVirtualWorld(g_playerEventVehicle[playerid], EVENT_VIRTUAL_WORLD);
	PutPlayerInVehicle(playerid, g_playerEventVehicle[playerid], 0);
	DisableRemoteVehicleCollisions(playerid, 1);

	ShowCatchingEventTD(playerid);
	return 1;
}

CMD:palikti(playerid)
{
	if(!g_isEventStarted)
		return SendClientMessage(playerid, C_RED, "[!] Gaudynës nevyksta!");

	if(!g_playerInEvent[playerid])
		return SendClientMessage(playerid, C_RED, "[!] Jûs nedalyvaujate gaudynëse!");

	LeaveEventForPlayer(playerid);
	return 1;
}
