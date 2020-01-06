actor Test
	new async() =>
		@fprintf[I32](@pony_os_stderr[Pointer[U8]](), "  async create\n".cstring())
	
	new syncWithError()? =>
		@fprintf[I32](@pony_os_stderr[Pointer[U8]](), "  sync create with error\n".cstring())
		error
	
	new syncSuccess()? =>
		@fprintf[I32](@pony_os_stderr[Pointer[U8]](), "  sync create success\n".cstring())
		if false then
			error
		end
		

actor Main
	new create(env: Env) =>
		
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "before\n".cstring())
		try
			Test.syncWithError()?
		else
			@fprintf[I32](@pony_os_stderr[Pointer[U8]](), "  caught error!\n".cstring())
		end
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "after\n".cstring())
		
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "before\n".cstring())
		try
			Test.syncSuccess()?
		else
			@fprintf[I32](@pony_os_stderr[Pointer[U8]](), "  caught error!\n".cstring())
		end
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "after\n".cstring())
		
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "before\n".cstring())
		Test.async()
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "after\n".cstring())