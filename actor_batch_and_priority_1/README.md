### Sender Overloading 1

Video: [Before the fix](https://github.com/KittyMac/pony.problems/raw/master/actor_batch_and_priority_1/before_change.mp4)

Video: [After the fix](https://github.com/KittyMac/pony.problems/raw/master/actor_batch_and_priority_1/after_change.mp4)

Not all actors are created equal, so let's not treat them as such.

### Batch Size

By default, the ponyrt gives all actors a batch size of 100. The batch size controls several important factors in the overall health of your actor network.

1. Batch size determines when an actor will become overloaded
2. Overloaded actors can cause other actors to mute, stalling your network
3. In some places overloading is critical, as it helps dampen mailbox bloat
4. Batch size determines maximum the number of messages an actor can process in one "run"

Strategically raising or lowering the batch size of individual actors are key points in your network can have a dramatic effect in the performance of your pony code. While it would be nice of the ponyrt could figure out the optimal batch sizes for different actors in your network, a reasonable first step would be to allow the pony programmer the ability to override the batch size of each actor.


### Actor Priority

When an actor finishes one run of batch sized message processing, but still has more messages in its queue, the scheduler will reschedule the actor immediately if there are no other actors waiting to run on that scheduler thread. If another actor is waiting, however, the current actor goes to the back of the queue.

Some actors will be clear bottlenecks in our actor network. While increasing batch size on bottleneck actors will help keep your network from muting, and increased batch size won't lead to faster processing for a node that's already being overloaded. This is where actor priorities can help!

Each actor can be assigned its own priority value.  The default priority is 0. Setting a negative priority is allowed. When the actor finishes a run and needs to be rescheduled, the scheduler will now compare the priority value of the current actor to the next actor. If the current actor has a higher priority than the next actor, it will be rescheduled immediately while the next actor will be placed in the global queue (to be picked up by another scheduler who, hopefully, has less priority actors).