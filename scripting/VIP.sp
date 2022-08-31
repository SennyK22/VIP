#include <multicolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

ConVar g_cvShowDmgOnlyVip;
ConVar g_cvShowVipJoinInfo;
//ConVar g_cvVipDoubleJump;

int    g_iJumps[MAXPLAYERS + 1];
int    g_iJumpMax;
int    g_fLastButtons[MAXPLAYERS + 1];
int    g_fLastFlags[MAXPLAYERS + 1];
int    clientlevel[MAXPLAYERS + 1];
Handle g_cvJumpBoost  = INVALID_HANDLE;
Handle g_cvJumpEnable = INVALID_HANDLE;
Handle g_cvJumpMax    = INVALID_HANDLE;
Handle g_cvJumpKnife  = INVALID_HANDLE;
//bool   g_bDoubleJump  = true;
float  g_flBoost      = 250.0;

public Plugin myinfo =
{
	name        = "VIP",
	author      = "SennyK",
	description = "VIP CSGO",
	version     = "1.0.1",
	url         = "https://github.com/SennyK22/VIP"
};

public void OnPluginStart()
{
	HookEvent("player_hurt", player_hurt, EventHookMode_Post);
	// HookEvent("player_jump", doublejump_event, EventHookMode_Post);

	g_cvShowDmgOnlyVip  = CreateConVar("sk_showdmgforvip", "0", "Pokazywanie zadanego dmg tylko dla VIPa, 1 - Włączone 0 - Wyłączone");
	g_cvShowVipJoinInfo = CreateConVar("sk_showinfovipjoin", "1", "Pokazywanie wiadomości o wejściu VIPa na serwer, 1 - Włączone 0 - Wyłączone");
	//g_cvVipDoubleJump   = CreateConVar("sk_vipdoublejump", "1", "VIP ma multijump'a, 1 - Włączone 0 - Wyłączone");
	g_cvJumpMax    		= CreateConVar("sk_doublejumpmax", "1", "Maksymalna liczba skoków w multijump", _, true, 1.0, true, 5.0);


	g_cvJumpKnife  = CreateConVar("csgo_doublejump_knife", "1", "disable(0) / enable(1) double-jumping only on Knife Level for AR (GunGame)", _, true, 0.0, true, 1.0);
	g_cvJumpEnable = CreateConVar("csgo_doublejump_enabled", "1", "disable(0) / enable(1) double-jumping", _);
	g_cvJumpBoost  = CreateConVar("csgo_doublejump_boost", "300.0", "The amount of vertical boost to apply to double jumps", _, true, 260.0, true, 500.0);
	
	HookConVarChange(g_cvJumpBoost, convar_ChangeBoost);
	HookConVarChange(g_cvJumpEnable, convar_ChangeEnable);
	HookConVarChange(g_cvJumpMax, convar_ChangeMax);
	//g_bDoubleJump = GetConVarBool(g_cvJumpEnable);
	g_flBoost     = GetConVarFloat(g_cvJumpBoost);
	g_iJumpMax    = GetConVarInt(g_cvJumpMax);
	HookEventEx("player_spawn", OnPlayerSpawn, EventHookMode_Post);

	AutoExecConfig(true, "SennyK_VIP");
}

public void OnClientPostAdminCheck(int client)
{
	CreateTimer(10.0, Timer_Welcome, client);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon)
{
	DoubleJump(client);
	return Plugin_Handled;
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
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
}

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
	LogMessage("%b", 1 <= g_iJumps[client] <= g_iJumpMax);
	LogMessage("%b", g_iJumps[client]);
	LogMessage("%b", g_iJumpMax);
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

public void convar_ChangeBoost(Handle convar, const char[] oldVal, const char[] newVal)
{
	g_flBoost = StringToFloat(newVal);
}

public void convar_ChangeEnable(Handle convar, const char[] oldVal, const char[] newVal)
{
}

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

public Action Timer_Welcome(Handle timer, any client)
{
	if (!IsClientConnected(client))
		return Plugin_Continue;

	int flags = GetUserFlagBits(client);

	char s_name[64];
	GetClientName(client, s_name, sizeof(s_name));

	if (flags & ADMFLAG_RESERVATION)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i)) continue;

			if (g_cvShowVipJoinInfo)
				C_PrintToChatAll("{gold}✯VIP✯ %s {default}wbił na serwer!", s_name);
			// SetHudTextParams(0.1, 0.4, 4.0, 204, 204, 0, 200, 1);    // red
			// ShowHudText(i, -1, "✯VIP✯ %s wbił na serwer!", s_name);
		}
	}

	return Plugin_Handled;
}

public Action player_hurt(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	if (client > 0 && IsClientConnected(client) && IsClientInGame(client))
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (attacker > 0 && IsClientConnected(attacker) && IsClientInGame(attacker))
		{
			if (g_cvShowDmgOnlyVip)
			{
				if (!CheckCommandAccess(attacker, "", ADMFLAG_RESERVATION, true))
				{
					return Plugin_Handled;
				}
			}

			int i_dmg = GetEventInt(event, "dmg_health");

			float RandomX[] = { 0.25, 0.28, 0.31, 0.34, 0.37, 0.40, 0.43 };
			int   randX     = GetRandomInt(0, 6);
			float RandomY[] = { 0.31, 0.34, 0.37, 0.40, 0.43, 0.46, 0.49 };
			int   randY     = GetRandomInt(0, 6);

			SetHudTextParams(RandomX[randX], RandomY[randY], 1.3, 255, 0, 0, 200, 1);    // red
			ShowHudText(attacker, -1, "%d", i_dmg);
		}
	}
	return Plugin_Handled;
}