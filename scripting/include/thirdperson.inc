#if defined _thirdperson_included_
  #endinput
#endif
#define _thirdperson_included_
 

native bool IsPlayerInTP(int client);
native any TogglePlayerTP(int client);

//public SharedPlugin __pl_thirdperson = {
//
//	name = "thirdperson",
//	file = "thirdperson.smx",
//#if defined REQUIRE_PLUGIN
//	required = 1,
//#else
//	required = 0,
//#endif
//};

#if !defined REQUIRE_PLUGIN
public void __pl_thirdperson_SetNTVOptional() {

	MarkNativeAsOptional("IsPlayerInTP");
	MarkNativeAsOptional("TogglePlayerTP");
}
#endif