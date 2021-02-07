package interealmGames.cli.errors;

/**
 * Indicates that a required command line argument is missing.
 */
class OverwriteCommandError extends CliError 
{
	static public var CODE = 201;
	static public var TYPE = "COMMAND_OVERWRITTEN";
	
	public function new(command:String, ?parent:String) 
	{
		var location = ""; // top level
		// Command $command being overwritten
		if(parent != null) {
			location = ' for "$parent"';
		}
		super(
			OverwriteCommandError.TYPE,
			'Command "$command" being overwritten$location',
			OverwriteCommandError.CODE
		);
	}
}
