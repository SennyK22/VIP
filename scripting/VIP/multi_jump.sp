public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon)
{
	DoubleJump(client);
	return Plugin_Handled;
}

/*public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client          = GetClientOfUserId(GetEventInt(event, "userid"));
	clientlevel[client] = 0;
	if (GetConVarInt(g_cvJumpKnife) == 1)
	{
		if (LastLevel(client) == true)
		{
			clientlevel[client] = 1;
		}
	}
}*/

void DoubleJump(int client)
{
	int fCurFlags = GetEntityFlags(client), fCurButtons = GetClientButtons(client);

	if (g_fLastFlags[client] & FL_ONGROUND)
	{
		if (!(fCurFlags & FL_ONGROUND) && !(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP)
		{
			OriginalJump(client);
		}
	}
	else if (fCurFlags & FL_ONGROUND)
	{
		Landed(client);
	}
	else if (!(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP)
	{
		ReJump(client);
	}
	g_fLastFlags[client]   = fCurFlags;
	g_fLastButtons[client] = fCurButtons;
}

void OriginalJump(int client)
{
	g_iJumps[client]++;
	LogMessage("original jump");
}

void Landed(int client)
{
	g_iJumps[client] = 0;
	LogMessage("landed %d", g_iJumps);
}

void ReJump(int client)
{
	if (g_cvVipDoubleJump)
	{
		if (!CheckCommandAccess(client, "", ADMFLAG_RESERVATION, true))
		{
			Plugin_Handled;
		}
		if (1 <= g_iJumps[client] <= g_iJumpMax)
		{
			g_iJumps[client]++;
			float vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
			vVel[2] = g_flBoost;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			LogMessage("rejump");
		}
		LogMessage("i chuj");
	}
}

public void convar_ChangeBoost(Handle convar, const char[] oldVal, const char[] newVal)
{
	g_flBoost = StringToFloat(newVal);
}

//public void convar_ChangeEnable(Handle convar, const char[] oldVal, const char[] newVal)
//{
//}

public void convar_ChangeMax(Handle convar, const char[] oldVal, const char[] newVal)
{
	g_iJumpMax = StringToInt(newVal);
}

public bool LastLevel(int client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		int weapon_count = 0;
		for (int i = 0; i <= 4; i++)
		{
			int wpn = GetPlayerWeaponSlot(client, i);
			if (wpn != -1)
			{
				weapon_count++;
			}
		}
		if (weapon_count == 1)
		{
			// hat nur das Messer!
			return true;
		}
		else
		{
			// noch weitere Waffen!
			return false;
		}
	}
	return false;
}

public bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
	{
		return false;
	}
	return true;
}