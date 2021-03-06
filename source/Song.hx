package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Sys;

using StringTools;


typedef SwagSong =
{
	var song:String;
	var artist:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var keyAmmount:Int;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var keyAmmount:Int = 4;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var player3:String = 'none';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public function new(song, notes, bpm )
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(?song:String, difficulty:String):SwagSong
	{
		try
		{
			var songFile = '$song/$difficulty';
			
			trace('Loading song file: assets/songs/$songFile');
			
			var rawJson = Assets.getText('songs/$song/$difficulty.funkin');

			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
	
			return parseJSONshit(rawJson);
		}
		catch(ex)
		{
			trace(ex);
			return null; // you suck and it returned null
		}
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	} 
}
