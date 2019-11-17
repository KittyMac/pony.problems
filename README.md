# pony.problems
A gathering place for my notes regarding pony runtime issues I have found and fixed.

### A note about methodology

For issues I have recorded here, I have taken pains to ensure that they exhibit themselves on vanilla pony.  However, in order to visualize what exactly the ponyrt is doing I have a small amount of code added on top of vanilla pony. This code simply records actor information to a temp file for specific actor events (for example, when an actor begins a run by entering ponyint_actor_run() an event is generated). I can then play back these events in a graphing tool I wrote specifically for this purpose.  Each of the issues recorded here should have a "before_change.mp4" and an "after_change.mp4" video showing the results of that visualization.

To understand what is going on in the visuals:

1. Each node of the graph (the white circle) is a unique actor
2. Each actor can be "tagged" in the pony code by providing a ```fun _tag():USize => 2``` method. The number returned by the tag method is the big number in the middle of the node. In the more simplistic examples, "1" means producer and "2" means consumer.
3. Beneath the actor you will see something like "5 of 100"; this means that 5 messages are currently queued in its mailbox and it has a message batch size of 100.
4. Beneath the actor you will also see something like "80 MB"; this is the currently size of the actor's heap.
3. If the actor is grey it is not currently scheduled
4. If the actor is blue it is actively running
5. If the text below the actor is orange then the actor is currently overloaded
6. If the text below the actor is red then the actor is currently underpressure
7. If the actor has a red outline then the actor is currently muted
8. Messages sent from one actor to another will travel along the line connecting the two actors as smaller circles
9. If the message circle is black then it is an application message (ie you calling a behaviour on another actor)
10. If the message circle is white then it is a system message. The pony runtime uses system messages to facilite certain features of the runtime, such as sharing data between actor heaps and distributed garbage collection.


## Issues

### Bad Memory 1

When an actor allocates memory and then shares it with another actor, the other actor just references the memory from the original actor and doesn't copy the memory (good).  When the other actor is done referencing the original memory, it sends a message to the originating actor to let it know it is not referencing the memory anymore.

Due to the way the garbage collector is fenced (it only runs when an actor allocated more memory than the ```next_gc``` value specifies), a producer which generates a bunch of messages and then goes quiet while those messages are processed will not free any memory even though the consuming actor may have finished with it.

To combat this, I introduced a heap_is_dirty flag on a actor which can be set when an event happens which we know should result in the GC being run in the future. That flag is then sent to the ```ponyint_heap_startgc()``` method to bypass the uses vs next_gc check.

Note that this still requires the producing actor actually gets a chance to run before the GC can happen, which can be problematic if the producer is rescheduled behind the consumer.

### Mailbox Overload 1

When a fast producer is paired with a slow consumer, the current pony mechanism for not overloading the consumer looks like this:

1. The producer can spam as many messages at the consumer as it wants.
2. During the consumer's run phase, if it cannot process all of its queued messages in one "batch", then the consumer sets itself to be "overloaded".  
3. Actor batch size is hardcoded to 100 and is the same for all actors.
4. If an actor sends a message to an overloaded actor, it may choose to "mute" itself.
5. An actor will only mute itself if the consumer is overloaded but the producer itself is NOT overloaded. This makes the muting system in "chains of actors" very inefficient, as if an actor at the end of the chain gets overloaded, the actors in other parts of the chain will get overloaded as well. The overloaded actors in the chain won't mute, causing producers at the begining of the chain to run and explode the mail boxes of the actors in the chain.
6. When an overloaded actor is no longer overloaded (as defined as emptying its queue by processing less than batch size messages), it then tells all actors who were muted because of it to unmute.

There are several non-obvious flaws to this method which can take new pony users by surprise.  They are:

1. Since the size of actor mailboxs is an unknown quantity outside of the anals of the runtime, the actors will appear to be "doing work" but there will be an explosion of memory usage (as messages are being produced but getting jammed up in other actor mailboxes).
2. If a fast producer is producing messages of large size (say, a file reader which reads 100 MB chunks of the file at a time), the producer can produce many, many, many messages prior to the slow consumer finishing processing the 100 batch size messages before it decides to flag itself as being overloaded.

One attempted solution is simply to allow the developer to override the "batch" size on a per actor basis. If we can set the consumer's batch size to something small, then in theory the consumer will cause the producer to mute sooner rather than later, thus keeping the amount of memory tied up on actor mailboxes to a minimum. While good in theory, since actors won't mute themselves when they are overloaded a small batch size still results in explosion of mailbox size.

The obvious solution would be to explicitly code the producer such that it receives a callback from the consumer when its done with the data. However, this is an exponentially compounding problem to handle at the user-level-pony code when considering the consumer might just transform the data and pass it to another consumer, and so on and so forth.

It would be ideal if the runtime could tell the producer when their message has been fully utilized. But wait, it can!  A producing actor receives garbage collection callbacks from other actors already.  If we simply provide a mechanism for the actor to know when it has cleaned up previously shared data, then we can use that to trigger the production of more data.

This was implemented using the following override in actor:

````
actor Producer
  fun _freed(wasRemote:Bool) =>
	  // When we've freed memory which was previously shared with another actor, produce more data
	  if wasRemote then
		  produceMore()
	  end
````