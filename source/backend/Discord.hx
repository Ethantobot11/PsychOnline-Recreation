package backend;

import online.states.RoomState;
import online.backend.Waiter;
import haxe.crypto.Md5;
import online.GameClient;
import Sys.sleep;
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private inline static final _defaultID:String = "1185697129717583982";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordRichPresence = #if (hxdiscord_rpc > "1.2.4") new DiscordRichPresence(); #else DiscordRichPresence.create(); #end

	/*static function onRequest(req:DiscordRichPresence) {
		Discord.Respond(req.userId, !GameClient.room.state.isPrivate ? DiscordActivityJoinRequestReply_Yes : DiscordActivityJoinRequestReply_No);
	}*/

	static function onJoin(secret:String) {
		Waiter.put(() -> {
			GameClient.joinRoom(secret, (err) -> {
				if (err != null) {
					return;
				}

				Waiter.put(() -> {
					FlxG.switchState(() -> new RoomState());
				});
			});
		});
	}

	public static function check()
	{
		if(ClientPrefs.data.discordRPC) initialize();
		else if(isInitialized) shutdown();
	}
	
	public static function start() {
		if (!isInitialized && ClientPrefs.data.discordRPC)
			initialize();

		Application.current.window.onClose.add(function() {
			if (isInitialized)
				shutdown();
		});
	}

	public dynamic static function shutdown() {
		isInitialized = false;
		Discord.Shutdown();
	}
	
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		final user = cast(request[0].username, String);
		final discriminator = cast(request[0].discriminator, String);

		var message = '(Discord) Connected to User ';

		if (discriminator != '0') // Old discriminators
			message += '($user#$discriminator)';
		else // New Discord IDs/Discriminator system
			message += '($user)';

		trace(message);
		changePresence("In the Menus", null);
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('Discord: Error ($errorCode: ${cast(message, String)})');
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('Discord: Disconnected ($errorCode: ${cast(message, String)})');
	}

	public static function initialize()
	{
		final discordHandlers:DiscordEventHandlers = #if (hxdiscord_rpc > "1.2.4") new DiscordEventHandlers(); #else DiscordEventHandlers.create(); #end
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), #if (hxdiscord_rpc > "1.2.4") false #else 1 #end, null);

		if(!isInitialized) trace("Discord Client initialized");

		online.backend.Thread.run(() -> {
			while (true) {
				if (isInitialized) {
					#if DISCORD_DISABLE_IO_THREAD
					Discord.UpdateConnection();
					#end
					Discord.RunCallbacks();
				}
				// Wait 1 second until the next loop...
				Sys.sleep(1.0);
			}
		});
		isInitialized = true;
	}


	static var state:String = null;

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, ?largeImageKey:String = 'icon')
	{
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.details = details;
		presence.state = DiscordClient.state = state;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = "Engine Version: " + states.MainMenuState.psychEngineVersion + "*";
		presence.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		updateOnlinePresence();

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	public static function updateOnlinePresence() {
		if (GameClient.isConnected()) {
			if (!GameClient.room.state.isPrivate) {
				presence.partyId = GameClient.rpcClientRoomID;
				presence.joinSecret = GameClient.getRoomSecret(true);
				presence.state = "In a Public Room";
			}
			else {
				presence.partyId = null;
				presence.joinSecret = null;
				presence.state = "In a Private Room";
			}
			presence.partySize = GameClient.getPlayerCount();
			presence.partyMax = 2;
		}
		else {
			presence.partyId = null;
			presence.joinSecret = null;
			presence.partySize = 0;
			presence.partyMax = 0;
			presence.state = state;
		}
		//DiscordRpc.presence(presence);
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}
	
	public static function resetClientID()
		clientID = _defaultID;

	private static function set_clientID(newID:String) {
		var change:Bool = (clientID != newID);
		clientID = newID;

		if (change && isInitialized) {
			shutdown();
			initialize();

			Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
		}
		return newID;
	}

	#if MODS_ALLOWED
	public static function loadModRPC()
	{
		var pack:Dynamic = Mods.getPack();
		if(pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
		{
			clientID = pack.discordRPC;
			//trace('Changing clientID! $clientID, $_defaultID');
		}
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changeDiscordPresence", changePresence);

		Lua_helper.add_callback(lua, "changeDiscordClientID", function(?newID:String) {
			if(newID == null) newID = _defaultID;
			clientID = newID;
		});
	}
	#end
}
