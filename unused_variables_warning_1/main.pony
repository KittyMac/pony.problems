use "collections"
use "assert"
use "backpressure"
use "bureaucracy"
use "capsicum"
use "cli"
use "debug"
use "files"
use "format"
use "ini"
use "itertools"
use "json"
use "logger"
use "math"
use "net"
use "process"
use "promises"
use "random"
use "signals"
use "strings"
use "term"
use "time"


actor Main

	// This should not be an error, as interfaces would depend on this
	fun _make():(String,Bool) =>
		("hello", true)

	new create(env:Env) =>
		var x:I64 = 4
		var y:I64 = 2

		// While this is defined, its not actually referenced anywhere; let's throw a compiler error for it.
		var unusedVar:I64 = 8
		let unusedLet:I64 = 8
		
		x = y + y
