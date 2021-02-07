package interealmGames.cli.errors;

import interealmGames.common.errors.Error;

/**
 * Indicates that an invalid or unknown command has been given by the user
 */
class CliError extends Error 
{
	/*
	 * 100s - User Input errors
	 * 200s - Internal Errors
	 * < 100 or > 499 - Application Specific Errors
	 */
	public var code:Int;
	
	public function new(type:String, message:String, code:Int) 
	{
		super(type, message);
		this.code = code;
	}
}
