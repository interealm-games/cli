package interealmGames.cli.errors;

/**
 * Indicates that a required command line argument is missing.
 */
class MissingArgumentError extends CliError 
{
	static public var CODE = 101;
	static public var TYPE = "MISSING_ARGUMENT";
	
	public function new() 
	{
		super(
			MissingArgumentError.TYPE,
			"No argument was provided.",
			MissingArgumentError.CODE
		);
	}
}
