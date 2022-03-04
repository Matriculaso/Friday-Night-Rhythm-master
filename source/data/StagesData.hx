package;

class StagesData
{
	public static var stageNames:Map<String, String>;

	public static function init():Void
	{
		stageNames = new Map<String, String>();

		stageNames['stage'] = 'The Stage';
		stageNames['spooky'] = 'Girlfriend’s House';
		stageNames['philly'] = 'Newgrounds Office Roof';
		stageNames['limo'] = 'The Limousine';
		stageNames['mall'] = 'The Mall';
		stageNames['mallEvil'] = 'The Mall??';
		stageNames['school'] = 'Dating Simulator';
		stageNames['schoolEvil'] = 'Dating Simulator??';
	}
}
