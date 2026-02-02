//%attributes = {}

// compileProject - Compiles a 4D project and outputs detailed error information
//
// This method reads the project path from a settings file and compiles that project.
// Create a file named "compile_settings.json" in the CompilerProject folder with:
// { "projectPath": "/full/path/to/Project/MyProject.4DProject" }

var $settingsFile : 4D.File
var $settings : Object
var $projectPath : Text
var $projectFile : 4D.File
var $projectFolder : 4D.Folder
var $result : Object
var $options : Object
var $error : Object
var $output : Text
var $i : Integer

// Read settings file to get the project path
var $base:=Folder(fk database folder)
$base:=Folder($base.platformPath; fk platform path)


// Verify the project file exists
$projectFile:=$base.parent.file("ErrorProject/Project/ErrorProject.4DProject")


If (Not($projectFile.exists))
	ALERT("ERROR: Project file not found: "+$projectPath)
	return 
End if 

$projectFolder:=$projectFile.parent.parent  // Go up from Project folder

// Setup compilation options
$options:=New object
$options.targets:=[]
$options.generateSymbols:=False
$options.generateSyntaxFile:=True
$options.generateTypingMethods:=False

// Look for components in the target project
var $components : Collection:=New collection
var $componentsFolder : 4D.Folder:=$projectFolder.folder("Components")
If ($componentsFolder.exists)
	$components:=$componentsFolder.folders().filter(Formula($1.value.extension=".4dbase"))
End if 

// Find component project files
var $projectFiles : Collection:=$components.flatMap(Formula($1.value.files(fk recursive).filter(Formula($1.value.extension=".4DProject"))))
var $zFiles : Collection:=$components.flatMap(Formula($1.value.files(fk recursive).filter(Formula($1.value.extension=".4DZ"))))
var $projectNames : Collection:=$projectFiles.map(Formula($1.value.parent.parent.name))
$zFiles:=$zFiles.filter(Formula(Not($projectNames.includes($1.value.parent.name))))
$options.components:=$projectFiles.combine($zFiles)

// Compile the project
$result:=Compile project($projectFile; $options)

// Format the output
$output:="=== COMPILATION RESULT ===\n"
$output+="Project: "+$projectPath+"\n"
$output+="========================\n\n"

If ($result.success)
	$output+="SUCCESS: Project compiled without errors!\n"
Else 
	$output+="FAILED: Found "+String($result.errors.length)+" error(s)\n\n"
	
	For ($i; 0; $result.errors.length-1)
		$error:=$result.errors[$i]
		$output+="--- Error #"+String($i+1)+" ---\n"
		$output+="Message: "+String($error.message)+"\n"
		$output+="Type: "+Choose($error.isError; "ERROR"; "WARNING")+"\n"
		
		If ($error.code#Null)
			$output+="Code Type: "+String($error.code.type)+"\n"
			If (Length(String($error.code.className))>0)
				$output+="Class: "+String($error.code.className)+"\n"
			End if 
			If (Length(String($error.code.functionName))>0)
				$output+="Function: "+String($error.code.functionName)+"\n"
			End if 
			If (Length(String($error.code.methodName))>0)
				$output+="Method: "+String($error.code.methodName)+"\n"
			End if 
			$output+="Path: "+String($error.code.path)+"\n"
		End if 
		
		$output+="Line in function: "+String($error.line)+"\n"
		$output+="Line in file: "+String($error.lineInFile)+"\n"
		$output+="\n"
	End for 
End if 

$output+="========================\n"
$output+="JSON Result:\n"
$output+=JSON Stringify($result; *)+"\n"

ALERT($output)
