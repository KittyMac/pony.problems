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