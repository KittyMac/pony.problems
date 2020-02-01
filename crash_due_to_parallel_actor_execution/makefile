all: stock1 test1

stock1:
	@echo "\n\n"
	@echo "Test: Stock pony w/ --ponynoblock (currently crashes)\n"
	ponyc -V=0 -o ./build/
	-./build/crash_due_to_parallel_actor_execution pingers=28 --ponynoblock --ponynoscale

test1:
	@echo "\n\n"
	@echo "Test: Latest pony master with patch to print out parallel access\n"
	/Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -o ./build/
	-./build/crash_due_to_parallel_actor_execution --ponynoblock --ponynoscale

