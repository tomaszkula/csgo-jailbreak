#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Cells"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

const int BUTTONS_COUNT = 3;
char cellsPath[] = "configs/tomkul777/jailbreak/cells";
char kvKey[] = "slot";
char kvValue[] = "entity";

char filePath[LENGTH_256];
int buttons[BUTTONS_COUNT];
KeyValues kv = null;

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
	CreateNative("JB_OpenCells", OpenCells);
	CreateNative("JB_GetCellButtonsCount", GetCellButtonsCount);
	CreateNative("JB_GetCellButtons", GetCellButtons);
	CreateNative("JB_SetCellButton", SetCellButton);
}

public void OnPluginStart()
{
	char _dirPath[LENGTH_256];
	BuildPath(Path_SM, _dirPath, sizeof(_dirPath), "%s", cellsPath);
	if(!DirExists(_dirPath))
	{
		JB_CreateDirectories(_dirPath, 511);
	}
}

public void OnMapStart()
{
	char _mapName[LENGTH_64];
	GetCurrentMap(_mapName, sizeof(_mapName));
	
	
	BuildPath(Path_SM, filePath, sizeof(filePath), "%s/%s.cfg", cellsPath, _mapName);
	
	kv = CreateKeyValues("cells");
	if(FileToKeyValues(kv, filePath))
	{
		for (int i = 0; i < BUTTONS_COUNT; i++)
		{
			char _key[LENGTH_16];
			Format(_key, sizeof(_key), "%s%i", kvKey, i);
			
			if(KvJumpToKey(kv, _key))
			{
				buttons[i] = KvGetNum(kv, kvValue, -1);
			}
			else
			{
				buttons[i] = -1;
			}
			KvGoBack(kv);
		}
		KvRewind(kv);
	}
	else
	{
		for (int i = 0; i < BUTTONS_COUNT; i++)
		{
			buttons[i] = -1;
		}
	}
}

public void OnGameStart(int _gameID)
{
	JB_OpenCells();
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int OpenCells(Handle plugin, int argc)
{
	for (int i = 0; i < BUTTONS_COUNT; i++)
	{
		if(!IsValidEntity(buttons[i]))
		{
			continue;
		}
		
		AcceptEntityInput(buttons[i], "Press");
	}
}

public int GetCellButtonsCount(Handle plugin, int argc)
{
	return BUTTONS_COUNT;
}

public int GetCellButtons(Handle plugin, int argc)
{
	int _buttonsCount = GetNativeCell(2);
	SetNativeArray(1, buttons, _buttonsCount);
}

public int SetCellButton(Handle plugin, int argc)
{
	int _buttonSlot = GetNativeCell(1);
	int _button = GetNativeCell(2);
	if(_buttonSlot < 0 || _buttonSlot >= BUTTONS_COUNT)
	{
		return;
	}
	
	buttons[_buttonSlot] = _button;
	
	char _key[LENGTH_16];
	Format(_key, sizeof(_key), "%s%i", kvKey, _buttonSlot);
	if(KvJumpToKey(kv, _key, true))
	{
		KvSetNum(kv, kvValue, _button);
		KvRewind(kv);
		kv.ExportToFile(filePath);
	}
}