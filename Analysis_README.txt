For analysis of the T1 maps and segmentations for Quantitative Analysis of T1 MRI data in Osteoradionecrosis of the Mandible utilize the scripts in the following way.
Contact: Hayden Lydick @hlydick@mdanderon.org with any questions

1) Create an input file for T1_MultipleRegions_to_Excell_wrapper.m as defined in that script, organize files however you want but all folders
	Folders should only have one scan or one segmentation in it, do not mix segmentations and T1maps in the same folder or multiple scans in the same folder
2) Take the Excell files generated for all timepoints and patients and place in a single folder
3) Run Excell_to_Matlab.m from that folder
4) Run DataAnalysis.m from from that folder
