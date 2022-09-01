#include <multicolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

//\\//\\//\\//\\// MODULES \\//\\//\\//\\//\\
#if !defined STANDALONE_BUILD
#include "VIP/show_damage.sp"
#include "VIP/welcome_message.sp"
#include "VIP/multi_jump.sp"
#endif
//\\//\\//\\//\\// END MODULES \\//\\//\\//\\//\\

//\\//\\//\\//\\// CONVARS \\//\\//\\//\\//\\
ConVar g_cvShowDmgOnlyVip;
ConVar g_cvShowVipJoinInfo;
ConVar g_cvVipDoubleJump;
//\\//\\//\\//\\// END CONVARS \\//\\//\\//\\//\\

//\\//\\//\\//\\// GLOBALS \\//\\//\\//\\//\\
int    g_iJumps[MAXPLAYERS + 1];
int    g_iJumpMax;
int    g_fLastButtons[MAXPLAYERS + 1];
int    g_fLastFlags[MAXPLAYERS + 1];
int    clientlevel[MAXPLAYERS + 1];
float  g_flBoost      = 250.0;
// bool   g_bDoubleJump  = true;
//\\//\\//\\//\\// END GLOBALS \\//\\//\\//\\//\\

//\\//\\//\\//\\// HANDLES \\//\\//\\//\\//\\
Handle g_cvJumpBoost  = INVALID_HANDLE;
Handle g_cvJumpMax    = INVALID_HANDLE;
//Handle g_cvJumpEnable = INVALID_HANDLE;
//Handle g_cvJumpKnife  = INVALID_HANDLE;
//\\//\\//\\//\\// END HANDLES \\//\\//\\//\\//\\


public Plugin myinfo =
{
	name        = "VIP",
	author      = "SennyK",
	description = "VIP CSGO",
	version     = "1.1",
	url         = "https://github.com/SennyK22/VIP"
};

public void OnPluginStart()
{
	HookEvent("player_hurt", player_hurt, EventHookMode_Post);
	// HookEvent("player_jump", doublejump_event, EventHookMode_Post);

	g_cvShowDmgOnlyVip  = CreateConVar("sk_showdmgforvip", "0", "Pokazywanie zadanego dmg tylko dla VIPa, 1 - Włączone 0 - Wyłączone");
	g_cvShowVipJoinInfo = CreateConVar("sk_showinfovipjoin", "1", "Pokazywanie wiadomości o wejściu VIPa na serwer, 1 - Włączone 0 - Wyłączone");
	g_cvVipDoubleJump   = CreateConVar("sk_vipdoublejump", "1", "VIP ma multijump'a, 1 - Włączone 0 - Wyłączone");
	g_cvJumpMax         = CreateConVar("sk_doublejumpmax", "1", "Maksymalna liczba skoków w multijump", _, true, 1.0, true, 5.0);
	g_cvJumpBoost  		= CreateConVar("sk_doublejumpboost", "260.0", "Wartość o ile dostaniemy boost jumpa", _, true, 260.0, true, 500.0);
	//g_cvJumpKnife  		= CreateConVar("csgo_doublejump_knife", "1", "disable(0) / enable(1) double-jumping only on Knife Level for AR (GunGame)", _, true, 0.0, true, 1.0);
	//g_cvJumpEnable 		= CreateConVar("csgo_doublejump_enabled", "1", "disable(0) / enable(1) double-jumping", _);
	
	HookConVarChange(g_cvJumpBoost, convar_ChangeBoost);
	HookConVarChange(g_cvJumpMax, convar_ChangeMax);
	//HookConVarChange(g_cvJumpEnable, convar_ChangeEnable);
	// g_bDoubleJump = GetConVarBool(g_cvJumpEnable);
	g_flBoost  = GetConVarFloat(g_cvJumpBoost);
	g_iJumpMax = GetConVarInt(g_cvJumpMax);
	HookEventEx("player_spawn", OnPlayerSpawn, EventHookMode_Post);

	AutoExecConfig(true, "SennyK_VIP");
}