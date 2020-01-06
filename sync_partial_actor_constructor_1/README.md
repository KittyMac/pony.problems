### Synchronous/Partial Actor Constructors 1

Recent discussion on Zulip (RFC channel, synchronous actor constructors) postulates that actor constructors could be called synchronously.  In addition, if an actor constructor was called synchronously it could be partial (ie it can throw a pony error).

This is implemented on my [my fork of Pony](https://github.com/KittyMac/ponyc/tree/roc_master).  Normal actor constructors are called asynchronosly, partial actor constructors are called synchronously.