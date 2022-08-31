#include <multicolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

ConVar g_cvShowDmgOnlyVip;
// ConVar g_cvShowVipJoinInfo;
public Plugin myinfo =
{
	name        = "VIP",
	author      = "SennyK",
	description = "VIP CSGO",
	version     = "1.0.0",
	url         = "https://github.com/SennyK22/VIP"
};

public void OnPluginStart()
{
	HookEvent("player_hurt", player_hurt, EventHookMode_Post);

	g_cvShowDmgOnlyVip = CreateConVar("sm_showdmgforvip", "0", "Pokazywanie zadanego dmg tylko dla VIPa, 1 - Włączone 0 - Wyłączone");
	// g_cvShowVipJoinInfo = CreateConVar("sm_showinfovipjoin", "1", "Pokazywanie wiadomości o wejściu VIPa na serwer?, 1 - Włączone 0 - Wyłączone");
	//  g_cvVipLeftMessage = CreateConVar("sm_vipleftserver", "wyszedł z serwera!", "Postać wiadomości: GRACZ wyszedł z serwera!");

	AutoExecConfig(true, "SennyK_VIP");
}

public void OnClientPostAdminCheck(int client)
{
	CreateTimer(10.0, Timer_Welcome, client);
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

			C_PrintToChatAll("{gold}✯VIP✯ %s {default}wbił na serwer!", s_name);
			// SetHudTextParams(0.1, 0.4, 4.0, 204, 204, 0, 200, 1);    // red
			// ShowHudText(i, -1, "✯VIP✯ %s wbił na serwer!", s_name);
		}
	}

	return Plugin_Handled;
}

public Action player_hurt(Handle event, const char[] name, bool dontBroadcast)
{
	int  userid = GetEventInt(event, "userid");
	int  client = GetClientOfUserId(userid);

	if (client > 0 && IsClientConnected(client) && IsClientInGame(client))
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (attacker > 0 && IsClientConnected(attacker) && IsClientInGame(attacker))
		{
			if (g_cvShowDmgOnlyVip)
			{
				LogMessage("Włączonby tryb tylko dla VIPów");
				if (!CheckCommandAccess(attacker, "", ADMFLAG_RESERVATION, true))
				{
					LogMessage("Gracz nie ma VIPa");
					return Plugin_Handled;
					LogMessage("To sie powinno nie wykonać");
				}
				LogMessage("a to tak");
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