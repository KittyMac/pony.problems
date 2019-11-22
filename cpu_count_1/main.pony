actor Main
	new create(env: Env) =>
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "%d cores available\n".cstring(), env.cpu_count)

 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyminthreads = 2
		rto.ponynoblock = true


