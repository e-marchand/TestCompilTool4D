// Class: BrokenClass
// This class has compile errors for testing

Class constructor
	// Error: undeclared property used
	This.name:="Test"
	This.count:=0

Function doSomething()
	// Error: variable not declared
	$localVar:=This.name

	// Error: type mismatch
	var $number : Integer
	$number:=This.name

	// Error: calling non-existent function
	This.nonExistentMethod()
