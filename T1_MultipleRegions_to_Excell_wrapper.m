function [] = T1_MultipleRegions_to_Excell_wrapper(input_file_path)

% Input format ----> MRN;Timepoint(1-3);T1MapPath;Segmentation;
% Filepath;Excellpath
 fileID = fopen(input_file_path, 'r');
 [input_path, input_name, ext] = fileparts(input_file_path);
 output_file = strcat(input_path, "\", input_name, "_output", ext);
 output_FID = fopen(output_file, 'a');
 fprintf(output_FID, '************Output File Opened**********\n');
 %start getting the parameters
 tline = fgetl(fileID);
 end_of_file  = -1;
 batch_count = 1;
 while(tline ~= end_of_file) 
 fprintf(output_FID,'---------------------------------------\n');
 fprintf(output_FID,  strcat('Starting New Region Extraction Fit #',num2str(batch_count), '\n'));
 B = convertCharsToStrings(tline);
 parts = strsplit(B, ';');    
 parts = strtrim(parts);  
 t1map_path = parts(3);
 seg_path = parts(4);
 excell_path = parts(5);
 timepoint = str2double(parts(2));
 fprintf(output_FID,strcat('MRN:', parts(1), '\nTimepoint:', parts(2)));
 try    
   T1_MultipleRegions_to_Excell(char(t1map_path), char(seg_path), timepoint, char(excell_path));
   fprintf(output_FID,'\nComplete! Excell Saved!\n');
   
 catch
   fprintf(output_FID,strcat('\nError with MRN:', parts(1), ' Timepoint:', parts(2) ,'\nContinuing to next Extraction\n')); 
   fclose(fileID);
 end
 tline = fgetl(fileID);
 batch_count = batch_count + 1;
 end
 fclose(output_FID);
 fclose(fileID);
end

