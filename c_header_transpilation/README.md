### CPU Count 1

The Pony runtime makes several assumptions based on the number of CPU hardware cores available. It stands to reason that a Pony programmer might want to have easy access to that number in order to make smarter decisions. For example, if you want to spawn a pool of actors to maximize parallel processing gains, how many actors should you spawn?

This change adds cpu_count to the pony Env object. Pony programmers can then do whatever they want with that value.