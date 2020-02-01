This is the "message-ubench" from pony examples.

There are a few changes to recreate the scenario I first encountered the crash:

1. the default number of pingers is set to the number of cpus (for me that number is 28)
2. the default report-count is set to 8
3. inside send_pings() added a call to create an actor ```EmptyActorTest(42)```
4. the definition for that actor:

```
actor EmptyActorTest		
	new create(payload: I64) =>
		None
```

Running the example with ponynoblock enabled is key to getting the crash.  But the issue isn't the crash, the issue is ponyint\_actor\_run() is running for the same pony_actor_t at the same time on two different schedulers.  When that happens, one of them reaches the end of ponyint\_actor\_run() first and deletes the actor while the other is still executing, causing the crash.

To easily see when the same actor is being run multiple times at the same time, you can use the actor.h and actor.c included.  They add a simple bool running to actor.h, and set it to true when inside ponyint\_actor\_run() and false at each exit point.  If ponyint\_actor\_run() executes and running is true, it prints a '.' to the console.

Here is the output of the makefile when run here.  As you can see, the first one (using stock pony installed with brew), crashes very quickly.

The second one with the protection against the parallel execution doesn't crash, and prints the . for each time it probably would have.

I'm running on a 28 core / 64 GB Mac OS Majave. I haven't tried replicating the issue on any other system (but I can if you can't reproduce it).


````
beast:crash_due_to_parallel_actor_execution rjbowli$ 


Test: Stock pony w/ --ponynoblock (currently crashes)

ponyc -V=0 -o ./build/
./build/crash_due_to_parallel_actor_execution pingers=28 --ponynoblock --ponynoscale
# pingers 28, report-interval 10, report-count 8, initial-pings 5
time,run-ns,rate
make: *** [stock1] Segmentation fault: 11



Test: Latest pony master with patch to print out parallel access

/Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -o ./build/
./build/crash_due_to_parallel_actor_execution --ponynoblock --ponynoscale
# pingers 28, report-interval 10, report-count 8, initial-pings 5
time,run-ns,rate
...........1580590833.109674000,1001857000,10207098
.....................1580590834.111674000,1001879000,8965915
.....................................1580590835.107628000,995759000,10027110
....................1580590836.106609000,998867000,9990524
............................1580590837.105868000,999145000,10044990
..........................................1580590838.107047000,1001055000,9941838
.................1580590839.105926000,998769000,9942779
....1580590840.102947000,996928000,9671387
beast:crash_due_to_parallel_actor_execution rjbowli$
````