// confirm errors work on multiple threads
use "random"
use "collections"


actor ErrorA
	be makeError() =>
		try
		    error 1
		else
			let stderr = @pony_os_stderr[Pointer[U8]]()
			if __error_code != 1 then
				@fprintf[I32](stderr, "ErrorA code was %d\n%s\n".cstring(), __error_code, __error_loc)
			end
		end
	

actor ErrorB
	be makeError() =>
		try
		    error 2
		else
			let stderr = @pony_os_stderr[Pointer[U8]]()
			if __error_code != 2 then
				@fprintf[I32](stderr, "ErrorB code was %d\n%s\n".cstring(), __error_code, __error_loc)
			end
		end

actor ErrorC
	be makeError() =>
		try
		    error 3
		else
			let stderr = @pony_os_stderr[Pointer[U8]]()
			if __error_code != 3 then
				@fprintf[I32](stderr, "ErrorB code was %d\n%s\n".cstring(), __error_code, __error_loc)
			end
		end
	

actor Main

	new create(env:Env) =>
		let a = ErrorA
		let b = ErrorB
		let c = ErrorC
		for _ in Range[USize](0,100_000) do
			a.makeError()
			b.makeError()
			c.makeError()
		end