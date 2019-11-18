use "collections"

primitive Data
	fun size():USize => 1024*1024*4

actor Producer

	let target:Consumer tag
	
	var count:U32
	var maxCount:U32
	
	fun _tag():USize => 1
	
	fun _freed(wasRemote:Bool) =>
		// When we've freed memory which was shared with another actor, produce more data
		if wasRemote then
			produceLimited()
		end

	new create(target':Consumer tag) =>
		target = target'
		
		count = 0
		maxCount = 30
		
		let testBefore = false
		
		
		if testBefore then
			// Produce unlimited simulates a producer which is loading chunks of data as fast as possible from
			// a source. The only reliance it has on the pony runtime to keep it in check from overloading the
			// actor network is the built in muting mechanism.  Since the default batch size is 100, we would
			// need to produce more than that to get the producer to "mute".  However, muting is not ideal as
			// a muted actor will not run, and if a muted actor doesn't run it won't garbage collect.
			//
			// For our little demo here, we set the max produce size to 60.  We could set it to 200 to view
			// how everything works when it gets muted, but that's a different problem.  This problem looks
			// at what we can do to AVOID relying on the actor muting mechanisms
			produceUnlimited()
		else
			
			// Instead of producing as fast as possible, or using other heavy-handed mechanisms for reduciing
			// the producer speed (such as timers or gratuitous, hand-coded callbacks), let's utilize the
			// new _free() method.  This method will get called whenever the garbage collector for this
			// actor actively freed memory, and it provides a parameter to let us know if the memory
			// being freed had been shared with another actor.
			//
			// Note we can "prime the pump" by producing a few extra chunks of data here, this ensures
			// we get concurrency
			produceLimited()
			produceLimited()
			produceLimited()
		end
		
		
	
	
	be produceUnlimited() =>
		count = count + 1
		if count < maxCount then
			let msg = "x".mul(Data.size())
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "produced %d bytes of data, count = %d\n".cstring(), Data.size(), count)
			target.receive(consume msg)
			
			produceUnlimited()
		end
	
	
	be produceLimited() =>
		count = count + 1
		if count < maxCount then
			let msg = "x".mul(Data.size())
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "produced %d bytes of data, count = %d\n".cstring(), Data.size(), count)
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


