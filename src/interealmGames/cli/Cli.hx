package interealmGames.cli;

using StringTools;
using interealmGames.common.StringToolsExtension;

import interealmGames.cli.errors.CliError;
import interealmGames.cli.errors.InvalidCommandError;
import interealmGames.cli.errors.MissingArgumentError;
import interealmGames.cli.errors.MissingOptionError;
import interealmGames.cli.errors.OverwriteCommandError;
import interealmGames.common.commandLine.CommandLine;
import interealmGames.common.commandLine.CommandLineValues;
import interealmGames.common.commandLine.OptionSet;
import interealmGames.common.commandLine.OptionType;

enum CommandType {
	CLI;
	LAMBDA;
	METHOD;
}

class Cli {
	private var command:String = null; // the parent to commands handled by this class
	private var commands: Map<String, CommandType> = new Map();
	private var subCommands: Map<String, Cli> = new Map();
	private var methodCommands: Map<String, String> = new Map();
	private var lambdaCommands: Map<String, Array<String> -> OptionSet -> Void> = new Map();
	private var descriptions: Map<String, String> = new Map();
	private var longFlags: Array<String> = [];
	private var shortFlags: Array<String> = [];
	

	public function new(?command:String) {
		if(command != null) {
			this.command = command;
		}
	}

	private function end(?response:Dynamic):Void {
		var isError = false;
		if (response != null) {
			if(Std.is(response, String)) {
				Sys.println(response);
			} else if(Std.is(response, CliError)) {
				Sys.println("Error: " + response.toString());
				isError = true;
			}
		}

		Sys.exit(isError ? response.code : 0);
	}

	private function noArguments(options:OptionSet) {
		this.end(new MissingArgumentError());
	}

	private function register(
		command:String,
		callback:Dynamic,
		?description:String
	):Void {
		if(this.commands.exists(command)) {
			this.end(new OverwriteCommandError(command, this.command));
		}

		if(Std.is(callback, String)) {
			this.registerMethod(command, callback, description);
		} else if(Reflect.isFunction(callback)) {
			this.registerCallback(command, callback, description);
		} else if(Std.is(callback, Cli)) {
			this.registerSubCommand(command, callback, description);
		} else {
			this.end(new InvalidCommandError(command));
		}
	}

	private function registerCallback(
		command:String,
		callback:Array<String> -> OptionSet -> Void,
		?description:String
	): Void {
		this.commands[command] = CommandType.LAMBDA;
		this.lambdaCommands[command] = callback;
		this.setDescription(command, description);
	}

	private function registerMethod(
		command:String,
		callback:String,
		?description:String
	):Void {
		// check if method exists
		this.commands[command] = CommandType.METHOD;
		this.methodCommands[command] = callback;
		this.setDescription(command, description);
	}

	private function registerSubCommand(
		command:String,
		callback:Cli,
		?description:String
	):Void {
		this.commands[command] = CommandType.CLI;
		this.subCommands[command] = callback;
		this.setDescription(command, description);
	}

	private function registerFlag(flagType: OptionType, flag:String):Void {
		switch(flagType) {
			case OptionType.SHORT:
				this.shortFlags.push(flag);
			case OptionType.LONG:
				this.longFlags.push(flag);
		}
	}

	public function run(?executableName:String, ?commandLine:String) {
		if(executableName == null) {
			executableName = Sys.programPath();
		}

		if(commandLine == null) {
			commandLine = CommandLine.getCommand();
		}

		commandLine =
			StringTools.replaceOnce(
				commandLine,
				executableName,
				''
			).trim();

		this.runCommand(commandLine);
	}

	public function runCommand(?commandLine:String):Void {
		var commandLineValues: CommandLineValues = CommandLine.process(
			longFlags,
			shortFlags,
			commandLine
		);
		// on failure
		if(commandLineValues.arguments.length == 0) {
			this.noArguments(commandLineValues.options);
		}

		var command = commandLineValues.arguments[0];

		if(!this.commands.exists(command)) {
			this.end(new InvalidCommandError(command));
		} else {
			switch(this.commands[command]) {
				case CommandType.CLI:
					commandLine =
						StringTools.replaceOnce(
							commandLine,
							command + ' ',
							''
						);
					this.subCommands[command].runCommand(commandLine);
				case CommandType.LAMBDA:
					this.lambdaCommands[command](
						commandLineValues.arguments.slice(1),
						commandLineValues.options
					);
				case CommandType.METHOD:
					var methodName = this.methodCommands[command];
					var method = cast Reflect.field(this, methodName);
					Reflect.callMethod(this, method, [
						commandLineValues.arguments.slice(1),
						commandLineValues.options
					]);
			}
		}
	}

	private function setDescription(command:String, ?description:String):Void {
		if (description != null) {
			this.descriptions[command] = description;
		}
	}
}
