#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] HUD"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

char msgNone[] =
	"[ Forum | %s ]\n"
	..."[ JAILBREAK MOD by %s ]";
	
char msgWarmUp[] =
	"[ %i Dzień | %s ]\n"
	..."[ Typ Dnia | %s ]\n"
	..."\n"
	..."[ Więźniowie | %i / %i ]\n"
	..."[ Strażnicy | %i / %i ]\n"
	..."\n"
	..."%s";
	
char msgNormal[] =
	"[ %i Dzień | %s ]\n"
	..."[ Typ Dnia | %s ]\n"
	..."\n"
	..."[ Więźniowie | %i / %i ]\n"
	..."[ Strażnicy | %i / %i ]\n"
	..."\n"
	..."%s";

char msgGame[] =
	"[ %i Dzień | %s ]\n"
	..."[ Typ Dnia | %s ]\n"
	..."\n"
	..."%s";

Handle mainHUD = null;
int day = 0;
char dayName[LENGTH_32] = "";
DayMode dayMode = None;
char dayModeName[LENGTH_32] = "";
char fullMsg[LENGTH_256] = "";

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	mainHUD = CreateHudSynchronizer();
}

public void OnMapStart()
{
	CreateTimer(1.0, DisplayMainHUD, _, TIMER_REPEAT);
}

public void OnDayChanged(int _day)
{
	day = _day;
	JB_GetDayName(_day, dayName, sizeof(dayName));
}

public void OnDayModeChanged(DayMode _dayMode)
{
	dayMode = _dayMode;
	JB_GetDayModeName(_dayMode, dayModeName, sizeof(dayModeName));
}

public Action DisplayMainHUD(Handle _timer)
{
	if(dayMode == None)
	{
		Format(fullMsg, sizeof(fullMsg), msgNone,
			FORUM_URL, PLUGIN_AUTHOR);
	}
	else if(dayMode == WarmUp)
	{
		int _godModeTime = JB_GetWarmUpGodModeTime();
		char _godModeTimeInfo[LENGTH_32];
		if(_godModeTime > 0)
		{
			Format(_godModeTimeInfo, sizeof(_godModeTimeInfo), "[ NIEŚMIERTELNOŚĆ | %is ]", _godModeTime);
		}
		else
		{
			Format(_godModeTimeInfo, sizeof(_godModeTimeInfo), "[ BRAK NIEŚMIERTELNOŚCI ]");
		}
		
		Format(fullMsg, sizeof(fullMsg), msgWarmUp,
			day, dayName, dayModeName, JB_GetPrisonersCount(true), JB_GetPrisonersCount(), JB_GetWardensCount(true), JB_GetWardensCount(), _godModeTimeInfo);
	}
	else if(dayMode == Normal)
	{
		int _simon = JB_GetSimon();
		char _simonInfo[LENGTH_64];
		if(_simon == 0)
		{
			Format(_simonInfo, sizeof(_simonInfo), "[ BRAK PROWADZĄCEGO ]");
		}
		else
		{
			char _simonName[LENGTH_64];
			GetClientName(_simon, _simonName, sizeof(_simonName));
			Format(_simonInfo, sizeof(_simonInfo), "[ PROWADZĄCY : %s ]", _simonName);
		}
		
		Format(fullMsg, sizeof(fullMsg), msgNormal,
			day, dayName, dayModeName, JB_GetPrisonersCount(true), JB_GetPrisonersCount(), JB_GetWardensCount(true), JB_GetWardensCount(), _simonInfo);
	}
	else
	{
		int _gameID = JB_GetCurrentGame();
		char _gameName[LENGTH_64];
		JB_GetGameName(_gameID, _gameName, sizeof(_gameName));
		
		int _gameTime = JB_GetCurrentGameTime();
		char _gameInfo[LENGTH_64];
		if(_gameTime > 0)
		{
			Format(_gameInfo, sizeof(_gameInfo), "[ %is ][ %s ]", _gameTime, _gameName);
		}
		else
		{
			Format(_gameInfo, sizeof(_gameInfo), "[ %s ]", _gameName);
		}
		Format(fullMsg, sizeof(fullMsg), msgGame,
			day, dayName, dayModeName, _gameInfo);
	}
	
	SetHudTextParams(0.16, 0.03, 1.5, 255, 255, 110, 0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
		{
			continue;
		}
		
		ShowSyncHudText(i, mainHUD, fullMsg);
	}
}