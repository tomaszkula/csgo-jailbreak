#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Games"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

ArrayList gameNames = null;
ArrayList gameTimes = null;
int currentGame = -1;
int gameTime = 0;
Handle gameTimer = null;
GlobalForward onGameStart = null;
GlobalForward onGameEnd = null;

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char [] error, int err_max)
{
	CreateNative("JB_RegisterGame", RegisterGame);
	CreateNative("JB_GetGamesCount", GetGamesCount);
	CreateNative("JB_GetGameName", GetGameName);
	CreateNative("JB_GetCurrentGame", GetCurrentGame);
	CreateNative("JB_GetCurrentGameTime", GetCurrentGameTime);
	CreateNative("JB_StartGame", StartGame);
	CreateNative("JB_EndGame", EndGame);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	
	gameNames = new ArrayList(4, 0);
	gameTimes = new ArrayList(4, 0);
	
	onGameStart = CreateGlobalForward("OnGameStart", ET_Event, Param_Cell);
	onGameEnd = CreateGlobalForward("OnGameEnd", ET_Event, Param_Cell);
}

public void OnDayModeChanged(DayMode _dayMode)
{
	if(_dayMode != RandomGame)
	{
		return;
	}
	
	int _gameID = GetRandomInt(0, sizeof(gameNames) - 1);
	JB_StartGame(_gameID);
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	JB_EndGame();
	currentGame = -1;
	return Plugin_Continue;
}

public Action GameTimer(Handle _timer)
{
	if(--gameTime <= 0)
	{
		JB_EndGame();
	}
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int RegisterGame(Handle plugin, int argc)
{
	char _gameName[LENGTH_64];
	GetNativeString(1, _gameName, sizeof(_gameName));
	int _gameTime = GetNativeCell(2);
	
	gameNames.PushString(_gameName);
	gameTimes.Push(_gameTime);
	return gameNames.Length - 1;
}

public int GetGamesCount(Handle plugin, int argc)
{
	return gameNames.Length;
}

public int GetGameName(Handle plugin, int argc)
{
	int _gameID = GetNativeCell(1);
	if(_gameID < 0 || _gameID >= gameNames.Length)
	{
		return false;
	}
	
	int _gameNameLength = GetNativeCell(3);
	char _gameName[LENGTH_64];
	gameNames.GetString(_gameID, _gameName, sizeof(_gameName));
	SetNativeString(2, _gameName, _gameNameLength);
	return true;
}

public int GetCurrentGame(Handle plugin, int argc)
{
	return currentGame;
}

public int GetCurrentGameTime(Handle plugin, int argc)
{
	return gameTime;
}

public int StartGame(Handle plugin, int argc)
{
	int _gameID = GetNativeCell(1);
	if(_gameID < 0 || _gameID >= gameNames.Length)
	{
		return;
	}
	
	currentGame = _gameID;
	
	gameTime = gameTimes.Get(_gameID);
	gameTimer = CreateTimer(1.0, GameTimer, _, TIMER_REPEAT);
	
	JB_SetDayMode(Game);
	
	Call_StartForward(onGameStart);
	Call_PushCell(_gameID);
	Call_Finish();
}

public int EndGame(Handle plugin, int argc)
{
	int _gameID = currentGame;
	if(_gameID < 0 || _gameID >= gameNames.Length)
	{
		return;
	}
	
	if(gameTimer != INVALID_HANDLE)
	{
		KillTimer(gameTimer);
		gameTimer = INVALID_HANDLE;
	}
	gameTime = 0;
	
	Call_StartForward(onGameEnd);
	Call_PushCell(_gameID);
	Call_Finish();
}