# pony.problems
A gathering place for my notes regarding pony runtime issues I have found and fixed.


## Issues

* **[Bad Memory 1](https://github.com/KittyMac/pony.problems/tree/master/bad_memory_1)**  
  *Freeing memory shared between actors as soon as possible*
* **[Mailbox Overload 1](https://github.com/KittyMac/pony.problems/tree/master/mailbox_overload_1)**  
  *Mechanism for empowering producing actors to only provide as much data as the system can conveniently handle (ie prevent overloads and actor muting before it happens)*
* **[CPU Count 1](https://github.com/KittyMac/pony.problems/tree/master/cpu_count_1)**  
  *Adds cpu_count as a value on env object so the Pony programmer can use core count to make smarter decisions*
* **[Sender Overloading 1](https://github.com/KittyMac/pony.problems/tree/master/sender_overloading_1)**  
  *If an actor sends a message to another actor's queue and that queue would then have more messages than the batch size, set the overloaded flag on the receiving actor*



## A note about methodology

For issues I have recorded here, I have taken pains to ensure that they exhibit themselves on vanilla pony.  However, in order to visualize what exactly the ponyrt is doing I have a small amount of code added on top of vanilla pony. This code simply records actor information to a temp file for specific actor events (for example, when an actor begins a run by entering ```ponyint_actor_run()``` an event is generated). I can then play back these events in a graphing tool I wrote specifically for this purpose.  Each of the issues recorded here should have a ```before_change.mp4``` and an ```after_change.mp4``` video showing the results of that visualization.

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

