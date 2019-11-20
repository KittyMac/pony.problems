### Load Balancing 1

Video: [Before the fix](https://github.com/KittyMac/pony.problems/raw/master/load_balancing_1/before_change.mp4)

Video: [After the fix](https://github.com/KittyMac/pony.problems/raw/master/load_balancing_1/after_change.mp4)

In Pony there is currently no mechanism exposed to the pony code to allow for load balancing. Let's say we have a pool of 50 actors and one producer actor which feeds them. The work they perform is variably sized, so even beyond the variability of the scheduler it is very likely that some actors will have less of a workload queued up than others.  If the producer sends a message to an overloaded actor in the pool, then the producer will mute unnecessarily.

I cheaped out and simply exposed a FFI call. It returns the total number of messages in the supplied actor's mailbox.  Simply run through them all and find the one with the least for simple load balancing.

````
let num_messages = @ponyint_actor_num_messages[USize](worker)
````