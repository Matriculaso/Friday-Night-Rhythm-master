package;

class CharactersData
{
	public static var characterNames:Map<String, String>;
	public static final characterWithoutAntialiasing = [
		'bf-pixel',
		'gf-pixel',
		'senpai',
		'senpai-angry',
		'spirit',
		'dizzle-spirit',
		'bf-dizzle-pixel'
	];
	public static var characterDead:Map<String, String>;

	public static function init()
	{
		characterNames = new Map<String, String>();
		{
			characterNames['bf'] = 'Boyfriend';
			characterNames['gf'] = 'Girlfriend';
			characterNames['dad'] = 'Daddy Dearest';

			characterNames['spooky'] = 'Skid & Pump';
			characterNames['monster'] = 'Monster';

			characterNames['pico'] = 'Pico';

			characterNames['bf-car'] = 'Boyfriend';
			characterNames['gf-car'] = 'Girlfriend';
			characterNames['mom-car'] = 'Mommy Murderer';
			characterNames['mom'] = 'Mommy Murderer';

			characterNames['bf-christmas'] = 'Boyfriend';
			characterNames['gf-christmas'] = 'Girlfriend';
			characterNames['parents-christmas'] = 'Daddy & Mommy';
			characterNames['monster-christmas'] = 'Monster';

			characterNames['bf-pixel'] = 'Boyfriend';
			characterNames['gf-pixel'] = 'Girlfriend';
			characterNames['senpai'] = 'Senpai';
			characterNames['senpai-angry'] = 'Senpai';
			characterNames['spirit'] = '???Senpai???';
		}
		characterDead = new Map<String, String>();
		{
			characterDead['bf-car'] = 'bf';
			characterDead['bf-christmas'] = 'bf';
		}
	}

	public static function getCharDead(char:String):String
	{
		if (characterDead.exists(char))
			return characterDead[char];
		else
			return char;
	}
}
