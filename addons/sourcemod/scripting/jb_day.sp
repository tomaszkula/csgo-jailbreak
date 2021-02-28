#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Day"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

int day = 0;
GlobalForward onDayChanged = null;

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
	CreateNative("JB_GetDay", GetDay);
	CreateNative("JB_GetDayName", GetDayName);
}

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart_Post);
	
	onDayChanged = CreateGlobalForward("OnDayChanged", ET_Event, Param_Cell);
}

public void OnMapStart()
{
	setDay(-1);
}

public Action Event_RoundStart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	setDay(day + 1);
}

void setDay(int _day)
{
	day = _day;
	
	Call_StartForward(onDayChanged);
	Call_PushCell(_day);
	Call_Finish();
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int GetDay(Handle plugin, int argc)
{
	return day;
}

public int GetDayName(Handle plugin, int argc)
{
	int _day = GetNativeCell(1);
	int _dayNameLength = GetNativeCell(3);
	
	char _dayName[LENGTH_32];
	switch(_day % 7)
	{
		case 0: _dayName = "Niedziela";
		case 1: _dayName = "Poniedziałek";
		case 2: _dayName = "Wtorek";
		case 3: _dayName = "Środa";
		case 4: _dayName = "Czwartek";
		case 5: _dayName = "Piątek";
		case 6: _dayName = "Sobota";
	}
	
	SetNativeString(2, _dayName, _dayNameLength);
}