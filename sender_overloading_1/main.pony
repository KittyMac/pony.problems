use "collections"
use "random"
use "time"

primitive Data
	fun size():USize => 1024*1024*4

actor Producer
	"""
	Producer generates a chunk of data and sends it to the Separator.  The separator splits the data into smaller pieces and send all of the pieces to the Pool. The Pool distributes the data to the Workers. The Workers then send the modified
	message to a single Consumer. In this scenario, the Workers should dynamically adjust to a lower priority and the Consumer
	should dynamically adjust to the higher priority.
	"""

	let target:Separator tag
	let rand: Rand
	
	var count:U32
	var maxCount:U32
	
	fun _tag():USize => 1
	
	fun _freed(wasRemote:Bool) =>
		// When we've freed memory which was shared with another actor, produce more data
		if wasRemote then
			produce()
		end

	new create(target':Separator tag) =>
		target = target'
		
		count = 0
		maxCount = 10
		
	    (_, let t2: I64) = Time.now()
	    let tsc: U64 = @ponyint_cpu_tick[U64]()
		rand = Rand(tsc, t2.u64())
		
		produce()
		produce()
		produce()
	
	be produce() =>
		count = count + 1
		if count < maxCount then
			let msg = recover iso String(Data.size()) end
			
			// Fill the message with randomly sized strings, separated by new lines.
			while msg.size() < Data.size() do
				let lineSize = 128 + rand.int(4096 * 6).usize()
				msg.append("x".mul(lineSize))
				msg.push('\n')
			end
			
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "produced %d bytes of data, count = %d\n".cstring(), Data.size(), count)
			target.receive(consume msg)
		end

actor Separator
	let target:Pool tag
	
	fun _tag():USize => 2
	
	new create(target':Pool tag) =>
		target = target'
	
	be receive(stringIso: String iso) =>
		let string:String val = consume stringIso
		let lines: Array[String] = string.split()
		
		for line in lines.values() do
			target.receive(line.clone())
		end


actor Pool

	let numberOfWorkers:USize
	let workers:Array[Worker]
	let rand: Rand
	
	fun _tag():USize => 3
	
	new create(consumer:Consumer tag) =>
		
		numberOfWorkers = 50
		
		workers = Array[Worker](numberOfWorkers)
		for i in Range[USize](0, numberOfWorkers) do
			workers.push(Worker(consumer))
		end
		
	    (_, let t2: I64) = Time.now()
	    let tsc: U64 = @ponyint_cpu_tick[U64]()
		rand = Rand(tsc, t2.u64())

	be receive(dataIso: Any iso) =>
		let workerIdx = rand.int(numberOfWorkers.u64()).usize()
		try
			workers(workerIdx)?.receive(consume dataIso)
		end

actor Worker

	let target:Consumer tag

	fun _tag():USize => 4
	
	new create(target':Consumer tag) =>
		target = target'
		

	be receive(dataIso: Any iso) =>
		@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "worker working...\n".cstring())
		@sleep[U32](U32(1))
		target.receive(consume dataIso)


actor Consumer

	fun _tag():USize => 5

	be receive(dataIso: Any iso) =>
		@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "consumed!\n".cstring())

actor Main
	new create(env: Env) =>
		Producer(
			Separator(
				Pool(
					Consumer
				)
			)
		)

	// "ponynoblock" so we have less system messages to see in the analysis visualization
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponynoscale = true
		rto.ponynoblock = true
		rto.ponygcinitial = 0
		rto.ponygcfactor = 1.0


