T1PdFitT1.m Basic Users Guide

Necessary Items:
1) All code in the additions01, niiproc, spm8 folders 
2) T1PdFitT1.m

Extra: 
1) T1PdFitT1_wrapper.m
2) NII_T1PD_inputPara.m

Intructions for Use (Basic)

The T1PdFitT1.m function is a basic MATLAB function
	Inputs
	data: flip angle maps as a 4D array x*y*z*n size: x,y,z are the matrix dimension size of the images, n is the number of flip angles
	flipAngles: 1*n sized array with the flip angles used in the same order as the 4D array 
	tr: TR of the acquired images
	b1Map: 3D array of the B1 Map with x*y*z size
		this can be passed as an empty array if no B1 map acquired
	Outputs
	t1: T1 map with the size of x*y*z 
	pd: proton density map with the size of x*y*z
	
Quick Information: 
1) Always be sure that additions01, niiproc, spm8 folders are in the MATLAB path before use or the code will crash
2) the program runs much faster on local storage 
3) A file system parser has been created for the quick batch processing of T1 maps called T1PdFitT1_wrapper.m 
	this will allow for processing of T1 maps without manually loading the acquired images into memory
	A separate README will be provided for how to utilize this function and code. 
	Correct use requires strict adherence to the syntax defined in that document.
	
	 