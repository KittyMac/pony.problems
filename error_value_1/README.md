## Retrieve the source location where an error occurred

While developing it can be extremely helpful to quickly pinpoint exactly where the error originated from. To accomodate this, you can now use the ```__error_loc``` token to retrieve a C string suitable for printing to the cosole for runtime errors. The choice of C string is for performance; if you want you can convert the C string to a Pony string when you receive the error.

Example:

```
use "random"

primitive ErrorCodes
	fun red():U32 => 42
	fun blue():U32 => 17

actor Main

	new create(env:Env) =>
		try
		    randomError(env)?
		else
			let stderr = @pony_os_stderr[Pointer[U8]]()
			@fprintf[I32](stderr, "Error code was %d\n%s\n".cstring(), __error_code, __error_loc)
		end

	fun ref randomError(env:Env)? =>
		match (@arc4random[U32]() % 6)
		| 0 => error ErrorCodes.red()
		| 1 => error ErrorCodes.blue()
		| 2 => error 99
		| 3 => error None
		| 4 => error
		else
			env.out.print("success!")
		end
```

and the output is:

```
Error code was 17
Error called in main.pony on line 21:10
		| 1 => error ErrorCodes.blue()
		       ^
```

## Errors can optionally include a U32 value

There was some discussion recently on Zulip regarding pony error's lack of information. Unlike exceptions in other languages, calling error in pony simply pops you out of the enclosing try, with no further information as to what caused the error.  This changes keeps error as it is syntactically, but allows the pony developer to optionally include a U32 value (either a literal or as the result of an expression.  The error value can be retrieved with the new ```__error_code``` value, and should only be considered valid in the ```else``` block of the ```try```.

Example:


```
use "random"
use "collections"

primitive ErrorCodes
	fun red():U32 => 42
	fun blue():U32 => 17

actor Main

	new create(env:Env) =>
		for _ in Range[U32](0, 20) do
			try
			    randomError(env)?
			else
				match __error_code
				| ErrorCodes.red() => env.out.print("sorry, we encountered the red error")
				| ErrorCodes.blue() => env.out.print("sorry, we encountered the blue error")
				else
					env.out.print("unrecognized error code: " + __error_code.string())
				end
			end
		end

	fun ref randomError(env:Env)? =>
		match (@arc4random[U32]() % 6)
		| 0 => error ErrorCodes.red()
		| 1 => error ErrorCodes.blue()
		| 2 => error 99
		| 3 => error None
		| 4 => error
		else
			env.out.print("success!")
		end
```
