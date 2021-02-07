package interealmGames.cli.errors;

/**
 * Indicates that an invalid or unknown command has been given by the user
 */
class InvalidCommandError extends CliError 
{
	static public var CODE = 103;
	static public var TYPE = "INVALID_COMMAND";
	
	public function new(command:String) 
	{
		super(
			InvalidCommandError.TYPE,
			'Unknown Command "$command"',
			InvalidCommandError.CODE
		);
	}
}
