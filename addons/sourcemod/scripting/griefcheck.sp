#include <sourcemod>
#include <riptext>

/**
 * Grief Check Plugin
 * Checks if players are known griefers based on a predefined list.
 */
public Plugin myinfo =
{
    name = "Grief Check",
    author = "Dave McDowell",
    description = "Detects known griefers among players in Left 4 Dead 2.",
    version = "1.0",
    url = "https://github.com/davemcdowell/I-Hate-Griefers"
};

/**
 * Initiates the plugin by fetching the griefer list from a remote URL.
 * 
 * @noreturn
 */
public void OnPluginStart()
{
    HTTPRequest request = new HTTPRequest(kGriefersListURL);
    request.Get(OnGrieferListFetched); 
}

/**
 * Callback for handling the HTTP response containing the griefer list.
 *
 * @param HTTPResponse      The HTTP response object containing data.
 * @noreturn
 */
void OnGrieferListFetched(HTTPResponse response)
{
    if (response.Status == HTTPStatus_OK) 
    {
        JSONObject listData = view_as<JSONObject>(response.Data);

        JSONObjectKeys keys = listData.Keys();
        char steamID[20]; // Maximum length of Steam IDs 'STEAM_X:Y:Z' format

        while (keys.ReadKey(steamID)) {
            g_Griefers.insertLast(steamID);
        }

        delete keys;

        LogMessage("Griefers list fetched and updated.");
    }
    else
    {
        LogError("Failed to fetch the griefer list. HTTP status: %s", response);
        return;
    }
}

/**
 * Hook triggered when a player spawns, checks if the player is a known griefer.
 * 
 * @param int       The client index of the spawning player.
 * @return Action
 */
public Action OnPlayerSpawn(int client)
{
    // Get the player's Steam ID
    const char[] steamID = GetClientAuthString(client);

    // Check if the Steam ID is in the griefer list
    if (IsSteamIDInGriefersList(steamID))
    {
        // Get the player's name
        const char[] playerName = GetClientName(client);

        // Display a message for matched players
        PrintToChat(client, "%s was found on the griefer list!", playerName);
    }

    return Plugin_Continue;
}

/**
 * Checks whether the given Steam ID is in the griefer list.
 *
 * @param const char[]    The Steam ID to check.
 * @return bool           True if the Steam ID is in the list, otherwise false.
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
