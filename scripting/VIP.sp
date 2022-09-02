#include <cstrike>
#include <multicolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

ConVar g_cvShowDmgOnlyVip;
ConVar g_cvShowVipJoinInfo;
ConVar g_cvVipFlag;
ConVar g_cvDoubleJump;
ConVar g_cvFreeGrenades;

int g_iFreeVIP            = 0;
int g_iRounds             = 0;
int g_iWeaponMenuReceived = 0;

public Plugin myinfo =
{
	name        = "VIP",
	author      = "SennyK",
	description = "VIP CSGO",
	version     = "1.2",
	url         = "https://github.com/SennyK22/VIP"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_vip", cmd_vip);
	RegConsoleCmd("sm_buyvip", cmd_buyvip);
	RegConsoleCmd("sm_infovip", cmd_infovip);
	RegConsoleCmd("sm_vipinfo", cmd_infovip);
	RegConsoleCmd("sm_weapons", cmd_weaponMenu);
	HookEvent("player_hurt", player_hurt, EventHookMode_Post);
	HookEvent("round_start", onRoundStart);
	HookEvent("player_spawn", onPlayerSpawn);

	g_cvShowDmgOnlyVip  = CreateConVar("sk_showdmgforvip", "0", "Pokazywanie zadanego dmg tylko dla VIPa, 1 - Włączone 0 - Wyłączone");
	g_cvShowVipJoinInfo = CreateConVar("sk_showinfovipjoin", "1", "Pokazywanie wiadomości o wejściu VIPa na serwer, 1 - Włączone 0 - Wyłączone");
	g_cvVipFlag         = CreateConVar("vip_flag", "a", "Required flag for the Vip player (Leave empty so all the players will have VIP).");
	g_cvDoubleJump      = CreateConVar("double_jump", "1", "Is the VIP player supposed to have a double jump?");
	g_cvFreeGrenades    = CreateConVar("free_grenades", "1", "Is the VIP player supposed to have a free grenades?");

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

	char s_name[64];
	GetClientName(client, s_name, sizeof(s_name));

	if (isPlayerVip(client))
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
				if (!isPlayerVip(attacker))
				{
					LogMessage("brak vipa?");
					return Plugin_Handled;
				}
				LogMessage("jest vip..");
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

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon)
{
	if (isPlayerVip(client) && IsPlayerAlive(client) && g_cvDoubleJump.BoolValue)
	{
		static int g_fLastButtons[MAXPLAYERS + 1], g_fLastFlags[MAXPLAYERS + 1], g_iJumps[MAXPLAYERS + 1], fCurFlags, fCurButtons;
		fCurFlags   = GetEntityFlags(client);
		fCurButtons = GetClientButtons(client);
		if (g_fLastFlags[client] & FL_ONGROUND && !(fCurFlags & FL_ONGROUND) && !(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) g_iJumps[client]++;
		else if (fCurFlags & FL_ONGROUND) g_iJumps[client] = 0;
		else if (!(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP && g_iJumps[client] == 1)
		{
			g_iJumps[client]++;
			float vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
			vVel[2] = 370.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
		}

		g_fLastFlags[client]   = fCurFlags;
		g_fLastButtons[client] = fCurButtons;
	}
	return Plugin_Continue;
}

public Action cmd_vip(int client, int args)
{
	Menu vipMenu = new Menu(vipMenu_Handler);
	vipMenu.SetTitle("VIP");
	vipMenu.AddItem("1", "Kup VIP'a");
	vipMenu.AddItem("1", "Co daje VIP?");
	// vipMenu.AddItem("3", "Wytestuj VIP'a");
	vipMenu.AddItem("4", "Informacje o autorze");
	vipMenu.Display(client, 0);

	return Plugin_Handled;
}

public int vipMenu_Handler(Menu vipMenu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		vipMenu.GetItem(itemNum, item, sizeof(item));

		if (StrEqual(item, "1"))
			ClientCommand(client, "sm_buyvip");

		else if (StrEqual(item, "2"))
			ClientCommand(client, "sm_infovip");

		else if (StrEqual(item, "3"))
			ClientCommand(client, "sm_freevip");

		else if (StrEqual(item, "4"))
			ClientCommand(client, "sm_autorinfo");

		else if (action == MenuAction_End)
			delete vipMenu;
	}
	return 0;
}

public Action cmd_buyvip(int client, int args)
{
	PrintToChat(client, "dsada");
	Menu buyVipMenu = new Menu(buyVipMenu_Handler);
	buyVipMenu.SetTitle("VIP");
	buyVipMenu.AddItem("30", "VIP 30 dni - 10 zł");
	buyVipMenu.AddItem("15", "VIP 15 dni - 5 zł");
	buyVipMenu.AddItem("7", "VIP 7 dni - 3 zł");
	buyVipMenu.ExitButton = true;
	buyVipMenu.Display(client, 0);

	return Plugin_Handled;
}

public int buyVipMenu_Handler(Menu buyVipMenu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		GetMenuItem(buyVipMenu, itemNum, item, sizeof(item));

		if (StrEqual(item, "30"))
			PrintToChat(client, "VIP na 30 dni");
		if (StrEqual(item, "15"))
			PrintToChat(client, "VIP na 15 dni");
		if (StrEqual(item, "7"))
			PrintToChat(client, "VIP na 7 dni");
	}
	else
	{
		CloseHandle(buyVipMenu);
	}
	return 0;
}

public Action cmd_infovip(int client, int args)
{
	PrintToChat(client, "Co posiada VIP?");
	if (g_cvShowVipJoinInfo)
		PrintToChat(client, "Pokazywanie zadanych obrażeń");
	if (g_cvShowVipJoinInfo)
		PrintToChat(client, "Powiadomienie wszystkich o wejściu VIP'a");
	if (g_cvDoubleJump)
		PrintToChat(client, "Podwójny skok");

	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iRounds = 0;
}

public Action onRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iRounds = g_iRounds + 1;
	return Plugin_Handled;
}

public Action onPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (isPlayerVip(client))
	{
		if (canShowWeaponsMenu(g_iRounds))
			primaryWeaponMenu(client);
		if (g_cvFreeGrenades)
			prepareGiftGrenades(client);
	}

	return Plugin_Handled;
}

public Action cmd_weaponMenu(int client, int args)
{
	int iRound = g_iRounds - 1;
	if (canShowWeaponsMenu(iRound))
	{
		primaryWeaponMenu(client);
	}
	else {
		PrintHintText(client, "Menu wyboru broni włączone dopiero od 4 rundy! %d", g_iRounds);
	}

	return Plugin_Handled;
}

public Action primaryWeaponMenu(int client)
{
	if (isPlayerVip(client))
	{
		if (g_iWeaponMenuReceived == 0)
		{
			if (client > 0 && IsClientConnected(client) && IsClientInGame(client) && canShowWeaponsMenu(g_iRounds))
			{
				int iRoundTime = GameRules_GetProp("m_iRoundTime");
				LogMessage("Halo: %d :olaH", iRoundTime);

				Menu primaryMenu = new Menu(primaryMenu_Handler);

				primaryMenu.SetTitle("Wybierz swoją broń!");
				primaryMenu.AddItem("1", "AK-47");
				primaryMenu.AddItem("2", "M4A1");
				primaryMenu.AddItem("3", "M4A1-S");
				primaryMenu.AddItem("4", "AWP");
				primaryMenu.AddItem("5", "SCOUT");

				primaryMenu.Display(client, 0);
			}
		}
		else {
			PrintCenterText(client, "Menu wyboru broni dostępne tylko raz na rundę! %d", g_iWeaponMenuReceived);
		}
	}

	return Plugin_Handled;
}

public int primaryMenu_Handler(Menu primaryMenu_Handler, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		g_iWeaponMenuReceived = 1;

		char item[32];
		primaryMenu_Handler.GetItem(itemNum, item, sizeof(item));

		removePlayerWeapons(client);
		GivePlayerItem(client, "weapon_knife");

		if (StrEqual(item, "1"))
			GivePlayerItem(client, "weapon_ak47");

		else if (StrEqual(item, "2"))
			GivePlayerItem(client, "weapon_m4a1");

		else if (StrEqual(item, "3"))
			GivePlayerItem(client, "weapon_m4a1_silencer");

		else if (StrEqual(item, "4"))
			GivePlayerItem(client, "weapon_awp");

		else if (StrEqual(item, "5"))
			GivePlayerItem(client, "weapon_ssg08");

		else if (action == MenuAction_End)
			delete primaryMenu_Handler;

		secondaryWeaponMenu(client);
	}
	return 0;
}

public Action secondaryWeaponMenu(int client)
{
	if (isPlayerVip(client))
	{
		if (client > 0 && IsClientConnected(client) && IsClientInGame(client) && canShowWeaponsMenu(g_iRounds))
		{
			int iRoundTime = GameRules_GetProp("m_iRoundTime");
			LogMessage("Halo: %d :olaH", iRoundTime);

			Menu secondaryMenu = new Menu(secondaryMenu_Handler);

			secondaryMenu.SetTitle("Wybierz swój pistolet!");
			secondaryMenu.AddItem("1", "Deagle");
			secondaryMenu.AddItem("2", "Five-Seven");
			secondaryMenu.AddItem("3", "Tec-9");
			secondaryMenu.AddItem("4", "P250");
			secondaryMenu.AddItem("5", "R8 Revolver");
			secondaryMenu.AddItem("6", "CZ75");
			secondaryMenu.AddItem("7", "Dwie beretty");

			secondaryMenu.Display(client, 0);
		}
	}

	return Plugin_Handled;
}

public int secondaryMenu_Handler(Menu secondaryMenu_Handler, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		secondaryMenu_Handler.GetItem(itemNum, item, sizeof(item));

		if (StrEqual(item, "1"))
			GivePlayerItem(client, "weapon_deagle");

		else if (StrEqual(item, "2"))
			GivePlayerItem(client, "weapon_fiveseven");

		else if (StrEqual(item, "3"))
			GivePlayerItem(client, "weapon_tec9");

		else if (StrEqual(item, "4"))
			GivePlayerItem(client, "weapon_p250");

		else if (StrEqual(item, "5"))
			GivePlayerItem(client, "weapon_revolver");

		else if (StrEqual(item, "6"))
			GivePlayerItem(client, "weapon_cz75a");

		else if (StrEqual(item, "7"))
			GivePlayerItem(client, "weapon_elite");

		else if (action == MenuAction_End)
			delete secondaryMenu_Handler;
	}
	return 0;
}

public Action prepareGiftGrenades(int client)
{
	if (client > 0 && IsClientConnected(client) && IsClientInGame(client))
	{
		char name[64];
		GetClientName(client, name, sizeof(name));
		LogMessage("%s dostał granaty", name);
		GivePlayerItem(client, "weapon_hegrenade");
		GivePlayerItem(client, "weapon_smokegrenade");
		GivePlayerItem(client, "weapon_flashbang");
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			GivePlayerItem(client, "weapon_incgrenade");
			GivePlayerItem(client, "item_defuser");
		}
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			GivePlayerItem(client, "weapon_molotov");
		}
	}

	return Plugin_Handled;
}

public Action cmd_autorinfo(int client, int args)
{
	PrintToChat(client, "Autorem pluginu jest SennyK! https://github.com/SennyK22");
	char strModel[150];
	GetEntPropString(4, Prop_Data, "m_ModelName", strModel, sizeof(strModel));

	return Plugin_Handled;
}

stock bool canShowWeaponsMenu(int iNowRound)
{
	bool check = false;
	if (iNowRound > 3 && iNowRound < 16)
	{
		check = true;
	}
	else if (iNowRound > 19)
	{
		check = true;
	}
	return check;
}

stock void removePlayerWeapons(int client)
{
	int iSlot;
	for (int i = 0; i <= 2; i++)
	{
		while ((iSlot = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, iSlot);
			AcceptEntityInput(iSlot, "Kill");
		}
	}
}

stock bool isPlayerVip(int client)
{
	char flag[10];
	g_cvVipFlag.GetString(flag, sizeof(flag));

	if (GetUserFlagBits(client) & ReadFlagString(flag) || GetAdminFlag(GetUserAdmin(client), Admin_Root) || g_iFreeVIP)
		return true;
	return false;
}