T1PdFitT1_wrapper.m Users Guide (Basic),
This should be used in conjunction with the T1PdFitT1.m README, this code REQUIRES all dependencies from that code base
Speak to Hayden Lydick at hlydick@mdanderson.org for help with this function
T1PdFitT1_wrapper.m is a input file parser that is designed to quickly generate T1 maps for a larger cohort study

function prototype:

	[t1, pd]= T1PdFitT1_wrapper(path);

	Inputs: 
		path: the filepath to the input textfile
			example in MATLAB: 
				path1 = "C:\input.txt"
				[t1, pd]= T1PdFitT1_wrapper(path1);
	Output: 
		t1: T1 Map of the last entry in the input textfile in a x by y by z array (sanity check)
		pd: PD Map of the last entry in the input textfile in a x by y by z array (sanity check)

Goals of the program: 
1) Have the user write text (.txt) input files that only needs to be written once and can then be run overnight without user intervention 
2) Avoid the menial task of loading images into local memory over and over again for a large cohort
3) Provide output files for the users to be able to track any issues with the software and error track to confirm data accuracy	
4) Provide a filepath blind structure to all allow for the simulaneous processing of maps in one area of memory, while saving the resulting images in another connected drive or filepath 
5) Save the resulting T1Maps as viewable dicoms for easy transfer while still preserving the necessary metadata of the format
6) Save a textfile based output file that will define what computation was performed and if there were any issues
	the textfile containing the output will be labeled as your input file's name _output (EX: input.txt -> input_output.txt) in the same folder as the input file, it will not delete the original input file
Authors Notes: The wrapper function works best when used in conjunction with good file management techniques
	You will be passing explicit file paths to this function ANY mistakes in copying or syntax of the input file and I cannot guarantee correct functionality

Input File Style: 
File type: text file (.txt)
	any name of the input file is fine, be sure to remember that matlab requires file ending (.txt ect..) in paths 
	so a text file named 'example' will need to be addressed as C:\example.txt 

Syntax: An example input file has been provided and explained here: 
----- Example Starts Here-----
START
FLIP_ANGLES = 2,5,10,15,20
MRN = 2111112
TR = 7.1
PD_PATH = R:\2111112\PD_MapL
T1_PATH = R:\2111112\T1_Map_HBL
ANGLE_PATHS = R:\2111112\t1_map_2deg,R:\2111112\t1_map_5deg,R:\2111112\t1_map_10deg,R:\2111112\t1_map_15deg,R:\2111112\t1_map_20deg
STOP
###
START
FLIP_ANGLES = 2,5,10,15,20
MRN = 2111113
TR = HEADER
ANGLE_PATHS = R:\2111113\t1_map_2deg,R:\2111113\t1_map_5deg,R:\2111113\t1_map_10deg,R:\2111113\t1_map_15deg,R:\2111113\t1_map_20deg
STOP
---- Example Ends Here ------
General Overview: 
The input file takes the following structure for defining its input variables. Please adhere to this standard or the code will not run correctly. No other text should be in this file except the commands listed below and their values
Each variable must be assigned by placing a single space, an equal (=) sign and another space before the value except the ### which must have nothing else on the line
### <- this defines the space between two different variable sets for different T1 maps generations, not necessary at the beginning and end of the file
STOP <- defines the end of obtaining the variables for generating the T1 Map
	Note: without the START and STOP variables defined for every map you wish to generate, the code will break and will not run correctly for subsequent entries.
START <- defines the start of processing a single map
FLIP_ANGLES <- defines the flip angles used in degrees, these MUST be in the same order as the scans in the ANGLE_PATHS variable
MRN <- the MRN of the patient being processed. This is to allow for easy searching in a large input file
TR <- the TR of the scan, you can also place the symbol HEADER to specify to grab the TR from the first scan's header given in the ANGLE_PATHS variable
PD_PATH <- path to define the place to store the proton density map, this can be left out and will place the scan in a folder called PD_Temp in the same folder as the location of the first scan defined in the ANGLE_PATHS variable
	ex: a scan in R:\2111113\t1_map_2deg will get its map saved to R:\2111113\PD_Temp if no PD_PATH is set
T1_PATH <- path to define the place to store the T1 map, this can be left out and will place the scan in a folder called T1_Temp in the same folder as the location of the first scan defined in the ANGLE_PATHS variable
	ex: a scan in R:\2111113\t1_map_2deg will get its map saved to R:\2111113\T1_Temp
ANGLE_PATHS <- please input the paths of each of the flip angle scan folders seperated by a single comma and NO SPACES, these do not need to be in the same directory path, but do 
	Notes: This is one of the most important variables and can make the code break if you have typos here, please be careful
		Make sure that the flip angles listed are in the same order as the paths given, the code does not confirm this!
		All scans need to be in a folder of only one set of scan DICOMs within it, other file types are allowed.
		The FIRST path defines many of the information grabbed for the automatic portions of the code so please be sure this is the correct path
	Automatic File Path Generation:
	IF your files for the flip angles are 
	1) all in the same superfolder
	2) they are in a folder without any other files with a folder name that:
		1) Contains the flip angle in it ie:t1_map_2deg
		2) There are no repetitions of that number ie: t1_map_2deg_2 would NOT work
	Then you can use the automatic file path generation which, assuming the naming convention above of t1_map_2deg will take a single file path ie: R:\2111113\t1_map_2deg
	and replace the flip angle number with the rest of those in the FLIP_ANGLES variable by adding EXTEND after the first file path. The result is something like this.
----------------
	ANGLE_PATHS = R:\2111113\t1_map_2deg,EXTEND
	converts to -> 
	ANGLE_PATHS = R:\2111113\t1_map_2deg,R:\2111113\t1_map_5deg,R:\2111113\t1_map_10deg,R:\2111113\t1_map_15deg,R:\2111113\t1_map_20deg 
----------------	
	if the used angles were 2,5,10,15,20
	Adhering to the naming convention above will produce reproducible behaviour, not obeying the rules stated will lead to unpredictable behaviour.

EXPECTED CODE USAGE:
1) Generate the input file 
2) run the code in matlab by passing in the path to the input file to the function
3) Check output file for any errors in processing the cohort
4) Confirm that all T1maps are generated and saved as individual slice dicoms in the folders you specified 
5) Continue with other processing

Notes: 
1) This code has no network error code management built in. It will break if you are loading data from a remote drive and the connection times out. 
2) Errors with one T1 map process (ie typo in the file paths) will have the output file note the issue and continue to the next full set of variables entry without issue
	you will thank me for this, we all make mistakes
	Search the output file for errors after to check and generate a new input file of any entrie with mistakes
3) All T1 Maps should be saved as uniquely named DICOM slices in the z direction in the folder you specified with all header data the same except the scan name will be T1_MAP_FITTED
	Any dicome viewer software should be able to reorder the slices

INPUT FILE EXAMPLE: 

START
FLIP_ANGLES = 2,5,10,15,20
MRN = 11111111
TR = HEADER
ANGLE_PATHS = R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1201_1.3.46.670589.11.79005.5.0.5688.2021070116115565743,R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1301_1.3.46.670589.11.79005.5.0.5688.2021070116122729845,R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1401_1.3.46.670589.11.79005.5.0.5688.2021070116125458879,R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1501_1.3.46.670589.11.79005.5.0.5688.2021070116132186913,R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1601_1.3.46.670589.11.79005.5.0.5688.2021070116134914947
STOP

OUTPUT FILE EXAMPLE: 
************Output File Opened**********
---------------------------------------
Starting New T1 Fit #1

Set Flip Angles:2,5,10,15,20
Patient MRN:11111111
Flip Angle Paths:
	R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1201_1.3.46.670589.11.79005.5.0.5688.2021070116115565743
	R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1301_1.3.46.670589.11.79005.5.0.5688.2021070116122729845
	R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1401_1.3.46.670589.11.79005.5.0.5688.2021070116125458879
	R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1501_1.3.46.670589.11.79005.5.0.5688.2021070116132186913
	R:\Travis_Salzillo\Relaxometry\TestT1MapCase\series_1601_1.3.46.670589.11.79005.5.0.5688.2021070116134914947
Performing Checks before Running T1 Fit
T1 Map output path not specified ..
Generating T1 file Directory in flip angle map directory ...
File Path Not Found, Creating File Path for T1 Map Storage...
PD Map output path not specified ..
Generating PD file Directory in flip angle map directory ...
File Path Not Found, Creating File Path for PD Map Storage...
Fit Complete, Saving New DICOMs






