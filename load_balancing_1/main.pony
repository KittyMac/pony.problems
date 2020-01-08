use "collections"
use "random"
use "time"

primitive Data
	fun size():USize => 1024*1024*16

actor Producer

	let target:Pool tag
	
	var count:U32
	var maxCount:U32
	
	fun _tag():USize => 1
	
	new create(target':Pool tag) =>
		target = target'
		
		count = 0
		maxCount = 20
		
		produce()
	
	be produce() =>
		count = count + 1
		if count < maxCount then
			target.receive("".clone())
			produce()
		end

actor Pool

	let numberOfWorkers:USize
	let workers:Array[Worker]
	let rand: Rand
	
	fun _tag():USize => 3
	
	new create() =>
		
		numberOfWorkers = 4
		
		workers = Array[Worker](numberOfWorkers)
		for _ in Range[USize](0, numberOfWorkers) do
			workers.push(Worker)
		end
		
	    (_, let t2: I64) = Time.now()
	    let tsc: U64 = @ponyint_cpu_tick[U64]()
		rand = Rand(tsc, t2.u64())
	
	
	fun ref sendToWorkerBalanced(stringIso: String iso) =>
		try
			var minMailboxSize:USize = 9999999
			var minWorkerIdx:USize = 9999999
			for i in Range[USize](0, numberOfWorkers) do
				let worker = workers(i)?
				let num_messages = @ponyint_actor_num_messages[USize](worker)
				if num_messages < minMailboxSize then
					minMailboxSize = num_messages
					minWorkerIdx = i
				end
			end

			workers(minWorkerIdx)?.receive(consume stringIso)
		end
	
	fun ref sendToWorkerRandom(stringIso: String iso) =>
		let workerIdx = rand.int(numberOfWorkers.u64()).usize()
		try
			workers(workerIdx)?.receive(consume stringIso)
		end
	
	be receive(stringIso: String iso) =>
		sendToWorkerBalanced(consume stringIso)
		//sendToWorkerRandom(consume stringIso)

actor Worker

	fun _tag():USize => 4
	fun _priority():USize => -1
	
	be receive(stringIso: String iso) =>
		@sleep[U32](USize(1))
		

actor Main
	new create(env: Env) =>
		Producer(Pool)

	// "ponynoblock" so we have less system messages to see in the analysis visualization
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyanalysis = true
		rto.ponynoscale = true
		rto.ponynoblock = true
		rto.ponygcinitial = 0
		rto.ponygcfactor = 1.0


