use "collections"

primitive Data
	fun size():USize => 1024*1024*4

actor Producer

	let target:Consumer tag
	
	fun _tag():USize => 1

	new create(target':Consumer tag) =>
		target = target'
		produce()

	be produce() =>
		for i in Range[U32](0, 20) do
			let msg = "x".mul(Data.size())
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "produced %d bytes of data, count = %d\n".cstring(), Data.size(), i)
			target.receive(consume msg)
		end
	

actor Consumer

	fun _tag():USize => 2

	be receive(dataIso: Any iso) =>
		try
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "begin consuming %d bytes of data\n".cstring(), (dataIso as String iso).size())
			@sleep[U32](U32(1))
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "end consuming %d bytes of data\n".cstring(), (dataIso as String iso).size())
		end

actor Main
	new create(env: Env) =>
		Producer(Consumer)

	// "ponynoblock" so we have less system messages to see in the analysis visualization
	// "ponyminthreads" ensures we don't drop down to just one scheduler
	// thread; if we do the producer will get scheduled behind the
	// consumer and not get a chance to run in order to garbage collect
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyminthreads = 2
		rto.ponynoblock = true


