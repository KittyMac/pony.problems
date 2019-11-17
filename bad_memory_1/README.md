
### Bad Memory 1

When an actor allocates memory and then shares it with another actor, the other actor just references the memory from the original actor and doesn't copy the memory (good).  When the other actor is done referencing the original memory, it sends a message to the originating actor to let it know it is not referencing the memory anymore.

Due to the way the garbage collector is fenced (it only runs when an actor allocated more memory than the ```next_gc``` value specifies), a producer which generates a bunch of messages and then goes quiet while those messages are processed will not free any memory even though the consuming actor may have finished with it.

To combat this, I introduced a heap_is_dirty flag on a actor which can be set when an event happens which we know should result in the GC being run in the future. That flag is then sent to the ```ponyint_heap_startgc()``` method to bypass the uses vs next_gc check.

Note that this still requires the producing actor actually gets a chance to run before the GC can happen, which can be problematic if the producer is rescheduled behind the consumer.

