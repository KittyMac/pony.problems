use "collections"
use "random"
use "time"

primitive Data
	fun size():USize => 1024*1024*16

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
		maxCount = 20
		
	    (_, let t2: I64) = Time.now()
	    let tsc: U64 = @ponyint_cpu_tick[U64]()
		rand = Rand(tsc, t2.u64())
		
		produce()
	
	be produce() =>
		count = count + 1
		if count < maxCount then
			let msg = recover iso String(Data.size()) end
			
			// Fill the message with randomly sized strings of "xzzxz", separated by new lines.
			// Simulates packed data which needs to be extracted and processed individually
			while msg.size() < Data.size() do
				let lineSize = 128 + rand.int(512).usize()
				msg.append("xzzxz".mul(lineSize))
				msg.push('\n')
			end
			
			try
				msg.pop()?
			end
			
			@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "produced %d bytes of data, count = %d\n".cstring(), Data.size(), count)
			target.receive(consume msg)
		elseif count == maxCount then
			target.receive("".clone())
		end

actor Separator
	let target:Pool tag
	
	fun _tag():USize => 2
	//fun _batch():USize => 5_000_000
	//fun _priority():USize => 10
	
	new create(target':Pool tag) =>
		target = target'
	
	be receive(stringIso: String iso) =>
		let string:String val = consume stringIso

		if string.size() == 0 then
			target.receive(string.clone())
			return
		end
		
		let lines: Array[String] = string.split()
		
		for line in lines.values() do
			target.receive(line.clone())
		end


actor Pool

	let numberOfWorkers:USize
	let workers:Array[Worker]
	let rand: Rand
	
	fun _tag():USize => 3
	//fun _batch():USize => 5_000_000
	//fun _priority():USize => 5
	
	new create(consumer:Consumer tag) =>
		
		numberOfWorkers = 4
		
		workers = Array[Worker](numberOfWorkers)
		for i in Range[USize](0, numberOfWorkers) do
			workers.push(Worker(consumer))
		end
		
	    (_, let t2: I64) = Time.now()
	    let tsc: U64 = @ponyint_cpu_tick[U64]()
		rand = Rand(tsc, t2.u64())

	be receive(stringIso: String iso) =>
		let workerIdx = rand.int(numberOfWorkers.u64()).usize()
		try
			workers(workerIdx)?.receive(consume stringIso)
		end

actor Worker

	let target:Consumer tag

	fun _tag():USize => 4
	//fun _batch():USize => 200
	//fun _priority():USize => -1
	
	new create(target':Consumer tag) =>
		target = target'
		

	be receive(stringIso: String iso) =>
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "worker working...\n".cstring())
		
		// simulate work; just switch all of the "x" to "y", leave the "z" as "z"
		for i in Range[USize](0, stringIso.size()) do
			try
				let c = stringIso(i)?
				if c == 'x' then
					stringIso(i)? = 'y'
				end
			end
		end
		target.receive(consume stringIso)


actor Consumer

	var numberOfX:USize
	var numberOfY:USize
	var numberOfZ:USize

	fun _tag():USize => 5
	
	new create() =>
		numberOfX = 0
		numberOfY = 0
		numberOfZ = 0
	
	be receive(stringIso: String iso) =>
		
		if stringIso.size() == 0 then
			@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "done! X: %d   Y: %d   Z: %d\n".cstring(), numberOfX, numberOfY, numberOfZ)
			return
		end
		
		@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "consumed!\n".cstring())
		try
			for i in Range[USize](0, stringIso.size()) do
				let c = stringIso(i)?
				if c == 'x' then
					numberOfX = numberOfX + 1
				end
				if c == 'y' then
					numberOfY = numberOfY + 1
				end
				if c == 'z' then
					numberOfZ = numberOfZ + 1
				end
			end
		end

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


