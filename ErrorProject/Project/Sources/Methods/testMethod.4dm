//%attributes = {}

// This method has several compile errors for testing

// Error 1: Undeclared variable usage
$myValue:=100
$result:=$myValue+$undeclaredVar

// Error 2: Type mismatch - assigning text to integer
var $count : Integer
$count:="hello"

// Error 3: Syntax error - missing closing parenthesis
var $text : Text
$text:=String(42

// Error 4: Unknown command
UNKNOWN_COMMAND("test")

// Error 5: Wrong number of parameters
var $date : Date
$date:=Current date("extra param")
