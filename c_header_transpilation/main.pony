actor Main
	new create(env: Env) =>
    @srand(42)
    @printf("My not-so-random numbers are %d, %d, %d and %d\n".cstring(), @rand() % 100, @rand() % 100, @rand() % 100, @rand() % 100)
    @printf("My version of sqlite is the string %s\n".cstring(), Sqlite.version().cstring())    

 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponynoscale = true
		rto.ponynoblock = true


