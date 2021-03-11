/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included


#define PLUGIN_AUTHOR "tomkul777"
#define FORUM_URL "forum.pl"

////////////////////////////////////////////////////////////
/////////////////////////// DATA ///////////////////////////
////////////////////////////////////////////////////////////

#define CS_TEAM_NONE        	0   	/**< No team yet. */
#define CS_TEAM_SPECTATOR   	1  		/**< Spectators. */
#define CS_TEAM_T       		2 		/**< Terrorists. */
#define CS_TEAM_CT      		3 		/**< Counter-Terrorists. */ 

#define SPECMODE_NONE    		0
#define SPECMODE_FIRSTPERSON	4
#define SPECMODE_3RDPERSON		5
#define SPECMODE_FREELOOK		6

#define EF_BONEMERGE 			(1 << 0)
#define EF_NOSHADOWS 			(1 << 4)
#define EF_PARENT_ANIMATES 		(1 << 9)
#define EF_NORECEIVESHADOWS 	(1 << 6)




////////////////////////////////////////////////////////////
//////////////////////// CUSTOM DATA ///////////////////////
////////////////////////////////////////////////////////////

#define JB_PREFIX " \x04[JB]\x01"

#define LENGTH_1 				(1 << 0)
#define LENGTH_2				(1 << 1)
#define LENGTH_4 				(1 << 2)
#define LENGTH_8 				(1 << 3)
#define LENGTH_16 				(1 << 4)
#define LENGTH_32 				(1 << 5)
#define LENGTH_64 				(1 << 6)
#define LENGTH_128 				(1 << 7)
#define LENGTH_256 				(1 << 8)

enum DayMode
{
	None = 0,
	WarmUp = 1,
	Normal = 2,
	RandomGame = 3,
	Game = 4
}

enum DamageMode
{
	v = 0,
	TvCT = 1,
	TvT = 2,
	CTvCT = 3,
	TvT_CTvCT = 4,
	TvTvCTvCT = 5
}




////////////////////////////////////////////////////////////
///////////////////////// FORWARDS /////////////////////////
////////////////////////////////////////////////////////////

// Called after day calculation
forward void OnDayChanged(int _day);

// Called after day mode calculation
forward void OnDayModeChanged(DayMode _dayMode);

// Called when _simon changed
forward void OnSimonChanged(int _simon);

// Called when _client got freeday
forward void OnAddFreeDay(int _client);

// Called when _client lost freeday
forward void OnRemoveFreeDay(int _client);

// Called when _client came rebel
forward void OnAddRebel(int _client);

// Called when _client is no longer rebel
forward void OnRemoveRebel(int _client);




// Called when game with _gameID started
forward void OnGameStart(int _gameID);

// Called when game with _gameID ended
forward void OnGameEnd(int _gameID);




////////////////////////////////////////////////////////////
///////////////////////// NATIVES //////////////////////////
////////////////////////////////////////////////////////////

// Returns day
native int JB_GetDay();

/*
 * Returns name of day of the week for a given day
 *
 * @param _dayNumber			 	  		day
 * @param _dayName							returned day name
 * @param _dayNameLength					_dayName array length
 */
native void JB_GetDayName(int _day, char[] _dayName, int _dayNameLength);

// Returns day mode
native DayMode JB_GetDayMode();

// Sets day mode to _dayMode
native void JB_SetDayMode(DayMode _dayMode);

/*
 * Returns name of day mode for a given day mode
 *
 * @param _dayMode			 	  			day mode
 * @param _dayModeName						returned day mode name
 * @param _dayModeNameLength				_dayModeName array length
 */
native void JB_GetDayModeName(DayMode _dayMode, char[] _dayModeName, int _dayModeNameLength);

// Returns remaining god mode time for warm up
native int JB_GetWarmUpGodModeTime();

// Returns simon (0 if not exist)
native int JB_GetSimon();

/*
 * Checks if _client can be a simon
 *
 * @param _client			 	  			client
 * @return 									can be added simon to a client
 */
native bool JB_CanBeSimon(int _client);

/*
 * Adds simon to a _client if possible
 *
 * @param _client			 	  			client
 */
native bool JB_AddSimon(int _client);




// Returns random prisoner(with repetition or not) (0 if no client)
native int JB_GetRandomPrisoner(bool _canRepeat);

// Resets repetitions
native void JB_ResetRepetitions();




// Adds division of _color (format "rrr ggg bbb") to _client if possible
native bool JB_AddDivision(int _client, char[] _color);

// Removes division from a _client if possible
native bool JB_RemoveDivision(int _client);

// Checks is _client divided
native bool JB_IsDivided(int _client);




// Checks can _client be healed
native bool JB_CanHeal(int _client, int _health);

// Heals _client to _health if possible
native bool JB_Heal(int _client, int _health);




// Checks can _client be revived
native bool JB_CanBeRevived(int _client);

// Revives _client if possible
native bool JB_Revive(int _client);




// Adds freeday for _client
native void JB_AddFreeDay(int _client);

// Adds freeday for _client next day
native void JB_AddFreeDayNextDay(int _client);

// Removes freeday from client
native void JB_RemoveFreeDay(int _client);

// Checks has _client a freeday
native bool JB_HasFreeDay(int _client);

// Checks has _client a freeday next day
native bool JB_HasFreeDayNextDay(int _client);




// Adds rebel to a _client if possible
native bool JB_AddRebel(int _client);

// Removes rebel from a _client if possible
native bool JB_RemoveRebel(int _client);

// Checks is _client a rebel
native bool JB_IsRebel(int _client);



// Opens cells
native void JB_OpenCells();

// Returns cell buttons count to bind
native int JB_GetCellButtonsCount();

// Returns cell buttons to bind
native void JB_GetCellButtons(int[] _buttons, int _buttonsCount);

// Binds cell button on _buttonSlot with _button
native void JB_SetCellButton(int _buttonSlot, int _button);




// Checks is _client a VIP
native bool JB_IsVip(int _client);

// Checks is _client a SuperVIP
native bool JB_IsSuperVip(int _client);




native int JB_RegisterGame(char[] _gameName, int _gameTime);
native int JB_GetGamesCount();
native bool JB_GetGameName(int _gameID, char[] _gameName, int _gameNameLength);
native int JB_GetCurrentGame();
native int JB_GetCurrentGameTime();
native void JB_StartGame(int _gameID);
native void JB_EndGame();

native void JB_SetDamageMode(DamageMode _damageMode);
native void JB_PlayCountdownSound(int _number);




////////////////////////////////////////////////////////////
///////////////////////// STOCKS ///////////////////////////
////////////////////////////////////////////////////////////

/*
 * Returns number of prisoners
 *
 * @param _onlyAlive     					should count only alive prisoners
 * @return              					number of prisoners
 */
stock int JB_GetPrisonersCount(bool _onlyAlive = false)
{
	int _prisonersCount = 0;
	if(_onlyAlive) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T)
			{
				continue;
			}
			
			_prisonersCount++;
		}
	}
	else
	{
		_prisonersCount = GetTeamClientCount(CS_TEAM_T);
	}
	
	return _prisonersCount;
}

/*
 * Returns number of wardens
 *
 * @param _onlyAlive     					should count only alive wardens
 * @return              					number of wardens
 */
stock int JB_GetWardensCount(bool _onlyAlive = false)
{
	int _wardensCount = 0;
	if(_onlyAlive) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
			{
				continue;
			}
			
			_wardensCount++;
		}
	}
	else
	{
		_wardensCount = GetTeamClientCount(CS_TEAM_CT);
	}
	
	return _wardensCount;
}

stock bool JB_TRDontHitSelf(int _entity, int _mask, any _data)
{
	return (_entity >= 1 && _entity <= MaxClients && IsClientInGame(_entity) && _entity != _data); 
}

stock void JB_TraceClientViewPosition(int _client, float _pos[3])
{
	float _clientEyePosition[3], _clientEyeAngles[3];
	GetClientEyePosition(_client, _clientEyePosition);
	GetClientEyeAngles(_client, _clientEyeAngles);
    
	Handle _tr = TR_TraceRayFilterEx(_clientEyePosition, _clientEyeAngles, MASK_VISIBLE, RayType_Infinite, JB_TRDontHitSelf, _client);
	TR_GetEndPosition(_pos, _tr);
	CloseHandle(_tr);
}

stock int JB_TraceClientViewEntity(int _client)
{
    float _clientEyePosition[3], _clientEyeAngles[3];
    GetClientEyePosition(_client, _clientEyePosition);
    GetClientEyeAngles(_client, _clientEyeAngles);
    
    Handle _tr = TR_TraceRayFilterEx(_clientEyePosition, _clientEyeAngles, MASK_VISIBLE, RayType_Infinite, JB_TRDontHitSelf, _client);
    int _entity = TR_GetEntityIndex(_tr);
    CloseHandle(_tr);
    return _entity;
}

stock int JB_RenderDynamicGlow(int _client, char[] _color)
{
	char _clientModel[LENGTH_256];
	GetClientModel(_client, _clientModel, sizeof(_clientModel));
	
	int _dynamicGlow = CreateEntityByName("prop_dynamic_glow");
	DispatchKeyValue(_dynamicGlow, "model", _clientModel);
	DispatchKeyValue(_dynamicGlow, "disablereceiveshadows", "1");
	DispatchKeyValue(_dynamicGlow, "disableshadows", "1");
	DispatchKeyValue(_dynamicGlow, "solid", "0");
	DispatchKeyValue(_dynamicGlow, "spawnflags", "256");
	DispatchKeyValue(_dynamicGlow, "renderamt", "0");
	SetEntProp(_dynamicGlow, Prop_Send, "m_CollisionGroup", 0);
	DispatchSpawn(_dynamicGlow);
	
	int _fEffects = GetEntProp(_dynamicGlow, Prop_Send, "m_fEffects");
	SetEntProp(_dynamicGlow, Prop_Send, "m_fEffects", _fEffects | EF_BONEMERGE | EF_NOSHADOWS | EF_NORECEIVESHADOWS | EF_PARENT_ANIMATES);
	
	SetEntPropEnt(_dynamicGlow, Prop_Send, "m_hOwnerEntity", _client); 
	SetEntProp(_dynamicGlow, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(_dynamicGlow, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(_dynamicGlow, Prop_Send, "m_flGlowMaxDist", 10000.0);
	
	SetVariantString("!activator");
	AcceptEntityInput(_dynamicGlow, "SetParent", _client, _dynamicGlow);
	
	SetVariantString("primary");
	AcceptEntityInput(_dynamicGlow, "SetParentAttachment", _client, _dynamicGlow);
    
	SetVariantString(_color);
	AcceptEntityInput(_dynamicGlow, "SetGlowColor", _client, _dynamicGlow);
	
	return _dynamicGlow;
}

stock Action SDKHookCB_SetTransmit(int _entity, int _client)
{
	int _entityOwner = GetEntPropEnt(_entity, Prop_Data, "m_hOwnerEntity");
	
	int _specMode = GetEntProp(_client, Prop_Send, "m_iObserverMode");
	if(_specMode == SPECMODE_FIRSTPERSON)
	{
		int _target = GetEntPropEnt(_client, Prop_Send, "m_hObserverTarget");
		if(_target == _entityOwner)
		{
			return Plugin_Handled;
		}
	}
	else
	{
		if(_client == _entityOwner)
		{
			return Plugin_Handled;
		}
	}
		
	return Plugin_Continue;
}

stock void DownloadFromFile(char[] _filePath)
{
	Handle _file = OpenFile(_filePath, "r");
	if (_file == INVALID_HANDLE)
	{
        return;
    }
	
	char _buffer[LENGTH_256];
	while(!IsEndOfFile(_file) && ReadFileLine(_file, _buffer, sizeof(_buffer)))
	{
		TrimString(_buffer);
		if (_buffer[0] == ';' || _buffer[0] == '/' || _buffer[0] == '\n' ||
			strlen(_buffer) == 0)
		{
			continue;
		}
		
		AddFileToDownloadsTable(_buffer);
	} 
	CloseHandle(_file);
}

stock bool JB_CreateDirectories(const char[] path, int mode, bool use_valve_fs = false, const char[] valve_path_id = "DEFAULT_WRITE_PATH") {
	char partialPathBuffer[PLATFORM_MAX_PATH];
	
	int currentSplit = 0;
	while (currentSplit < strlen(path)) {
		int subSplit = FindCharInString(path[currentSplit], '/', false);
		
		if (subSplit == -1) {
			// subsplit the remaining portion of the string
			subSplit = strlen(path[currentSplit]);
		}
		
		currentSplit += subSplit + 1; // subsplit + forward slash
		strcopy(partialPathBuffer, currentSplit + 1, path); // currentsplit + null
		
		if (!DirExists(partialPathBuffer, use_valve_fs, valve_path_id)
				&& !CreateDirectory(partialPathBuffer, mode, use_valve_fs, valve_path_id)) {
			return false;
		}
	}
	return true;
}

// Permutes _array of _length
stock void JB_Permute(int[] _array, int _length)
{
	int _random = 0, _temp = 0;
	for (int i = 0; i < _length - 1; i++)
	{
		_random = GetRandomInt(0, _length - 1 - i);
		
		_temp = _array[_random];
		_array[_random] = _array[_length - 1 - i];
		_array[_length - 1 - i] = _temp;
	}
}