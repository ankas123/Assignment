# Assignment
IOS assignment
To compile this project properly 
1. Download Audiokit from link http://audiokit.io/downloads/
2. Unzip the file "AudioKit.framework" and Add the library to External Binaries in Under - > General tab  of the Recorder Settings page. Note the value that is shown after " in " the file is linked ex "AudioKit.framework ...in .../AudioKit-iOS" copy ".../AudioKit-iOS" 
3. Goto Build Settings ->  Search Framework Search path . If it doesnt show click on "all" from "Basic Customized all " tab that is present on the top left corner
4. Paste the copied value  ex "../AudioKit-iOS" under the Framework search path.
5. Compile the project.
