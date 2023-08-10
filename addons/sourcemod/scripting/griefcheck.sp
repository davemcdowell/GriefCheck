#include <sourcemod>
#include <riptext>

/**
 * Plugin public information.
 */
public Plugin myinfo =
{
	name = "Grief Check",
	author = "MoxXi",
	description = "Left 4 Dead 2 server plugin for checking if players are known griefers.",
	version = "1.0",
	url = "https://github.com/davemcdowell/I-Hate-Griefers"
};

const char[] kGriefersListURL = "https://raw.githubusercontent.com/davemcdowell/L4D2-Griefers/main/ingest";
Array<const char[]> g_Griefers;

/**
 * OnPluginStart kicks off our http request
 * with the provided list url
 * 
 * @noreturn
 */
public void OnPluginStart()
{
    HTTPRequest request = new HTTPRequest(kGriefersListURL);
    request.Get(OnResponseReceived); 
}

/**
 * Callback for handling http response, builds an array
 * of griefers on success.
 *
 * @param HTTPResponse      http status code
 * @noreturn
 */
void OnResponseReceived(HTTPResponse response)
{
    if (response.Status == HTTPStatus_OK) 
    {
        JSONObject listData = view_as<JSONObject>(response.Data);

        JSONObjectKeys keys = listData.Keys();
        char key[20]; // Maximum length of Steam IDs 'STEAM_X:Y:Z' format (20 chars)

        while (keys.ReadKey(key)) {
            g_Griefers.insertLast(key);
        }

        delete keys;

        LogMessage("Griefers list fetched and updated.");
    }
    else
    {
        LogError("Failed to fetch griefers list. HTTP status: %s", response);
        return;
    }
}

/**
 * OnPlayerSpawn hook, we check the given 
 * client index of the spawning player against 
 * the griefers list. 
 *
 * On a succesful match the plugin announces via
 * in-game chat that the given player is a griefer
 *
 * @param int       client index
 * @return Action
 */
public Action OnPlayerSpawn(int client)
{
    // get the player's steamID
    const char[] steamID = GetClientAuthString(client);

    // check if their ID is in our given list
    if (IsSteamIDInGriefersList(steamID))
    {
        // get the player's name
        const char[] playerName = GetClientName(client);

        // display message for matched player
        PrintToChat(client, "%s was found on the griefers list!", playerName);
    }

    return Plugin_Continue;
}

/**
 * Checks whether the given steamID is in our array.
 *
 * @param const char[]	steamID
 * @return bool          
 */
public bool IsSteamIDInGriefersList(const char[] steamID)
{
    for (int i = 0; i < g_Griefers.length; i++)
    {
        if (StrEqual(steamID, g_Griefers[i]))
        {
            return true;
        }
    }
    return false;
}
