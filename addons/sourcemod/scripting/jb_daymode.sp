#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Day Mode"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

DayMode dayMode = None;
GlobalForward onDayModeChanged = null;

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
	CreateNative("JB_GetDayMode", GetDayMode);
	CreateNative("JB_SetDayMode", SetDayMode);
	CreateNative("JB_GetDayModeName", GetDayModeName);
}

public void OnPluginStart()
{
	onDayModeChanged = CreateGlobalForward("OnDayModeChanged", ET_Event, Param_Cell);
}

public void OnDayChanged(int _day)
{
	if(_day < 0)
	{
		setDayMode(None);
	}
	else if(_day == 0)
	{
		setDayMode(WarmUp);
	}
	else if(_day % 7 == 6 || _day % 7 == 0)
	{
		setDayMode(RandomGame);
	}
	else
	{
		setDayMode(Normal);
	}
}

void setDayMode(DayMode _dayMode)
{
	dayMode = _dayMode;
	
	Call_StartForward(onDayModeChanged);
	Call_PushCell(_dayMode);
	Call_Finish();
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public any GetDayMode(Handle plugin, int argc)
{
	return dayMode;
}

public int SetDayMode(Handle plugin, int argc)
{
	DayMode _dayMode = GetNativeCell(1);
	setDayMode(_dayMode);
}

public int GetDayModeName(Handle plugin, int argc)
{
	char _dayModeName[LENGTH_32];
	
	DayMode _dayMode = GetNativeCell(1);
	int _dayModeNameLength = GetNativeCell(3);
	switch(_dayMode)
	{
		case None: _dayModeName = "BRAK";
		case WarmUp: _dayModeName = "ROZGRZEWKA";
		case Normal: _dayModeName = "NORMALNY";
		case RandomGame: _dayModeName = "ZABAWA";
		case Game: _dayModeName = "ZABAWA";
	}
	
	SetNativeString(2, _dayModeName, _dayModeNameLength);
}