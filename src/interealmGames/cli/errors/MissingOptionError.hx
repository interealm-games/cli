package interealmGames.cli.errors;

/**
 * Indicates that an application command was not given by the user
 */
class MissingOptionError extends CliError 
{
	static public var CODE = 102;
	static public var TYPE = "MISSING_OPTION";
	
	public function new(optionName:String) 
	{
		super(
			MissingOptionError.TYPE,
			'No argument for "$optionName" was.',
			MissingOptionError.CODE
		);
	}
}
