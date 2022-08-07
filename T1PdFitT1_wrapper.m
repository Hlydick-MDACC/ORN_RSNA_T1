% Written by Hayden B Lydick as a input file wrapper T1PdFitT1
% Goals: Easy batch processing of a large number of T1 fits
%        Error Processing and handling over the course of a long run
%        Saving T1 fits as dicoms
%        
% Pass in a .txt file
% See example.txt for file structure
% Requirements: Need T1PdFitT1.m and all dependecies to function
% make sure you add the folder where these files are located to the path
function [t1, pd] = T1PdFitT1_wrapper(input_file_path)
    Series_Name = "T1_MAP_FITTED";
    Series_Name_PD = "PROTON_DENSITY_MAP";
    batch_count = 0;
    lines = [];
    TR = 0.0;
    mrn = 0;
    flip_angles = [];
if(isfile(input_file_path))
    %open the input file and create output file
    fileID = fopen(input_file_path, 'r');
    [input_path, input_name, ext] = fileparts(input_file_path);
    output_file = strcat(input_path, "\", input_name, "_output", ext);
    output_FID = fopen(output_file, 'a');
    fprintf(output_FID, '************Output File Opened**********\n');
    %start getting the parameters
    tline = fgetl(fileID);
    %go through all the lines in the files
    while(tline ~= -1)  
    B = convertCharsToStrings(tline);
    parts = strsplit(B, '=');
    parts = strtrim(parts);
    %process what the command is saying
    switch parts(1)
        case "START"
            %clean everything up for the next iteration
            T1_output_path = [];
            PD_output_path = [];
            flip_angles = [];
            mrn = 0;
            angle_paths = [];
            TR = 0;
            batch_count= batch_count + 1;
            fprintf(output_FID,'---------------------------------------\n');
            fprintf(output_FID,  strcat('Starting New T1 Fit #',num2str(batch_count), '\n\n'));
        case "T1_PATH"
            T1_output_path = parts(2);            
            fprintf(output_FID, strcat('T1 Output Folder: ', parts(2), '\n'));
        case "PD_PATH"
            PD_output_path = parts(2);
            fprintf(output_FID, strcat('PD Output Folder: ', parts(2), '\n'));
        case "FLIP_ANGLES"
            nums = strsplit(parts(2),',');
            for angle = nums
               flip_angles = [flip_angles, str2double(angle)];
            end 
            fprintf(output_FID,strcat('Set Flip Angles: ', parts(2), '\n'));
        case "MRN" %patient MRN, no necessary but helps track which ones might go wrong
            mrn = str2double(parts(2));
            fprintf(output_FID, strcat('Patient MRN: ', parts(2), '\n'));
        case "ANGLE_PATHS" %get the paths to the angle data
            angle_paths = strtrim(strsplit(parts(2), ','));
            fprintf(output_FID, "Flip Angle Paths:\n");
            if (strcmp(angle_paths(2), "EXTEND") && ~isempty(flip_angles)) %requires that flip angles be present
                dir_path = strsplit(angle_paths(1),'\'); %split and get the ending folder name
                dir_path_temp = []; %need to define for matlab to not bitch 
                for j = 1:(length(dir_path)-1)
                    dir_path_temp = strcat(dir_path_temp ,dir_path(j), '\');%reform the path
                end
                dir_name = dir_path(end);
                first_angle = nums(1);
                for i = 2:length(nums)
                    dir_name_temp = strrep(dir_name, first_angle, nums(i));
                    angle_paths(i) = strcat(dir_path_temp ,dir_name_temp);%
                end
                
                
            end
            for angle = angle_paths
                fprintf(output_FID, strcat('\t',insertAfter(angle,"\", "\"), '\n'));
            end 
        case "TR" %get relaxation time
            if (strcmp(parts(2), "HEADER"))
                TR = -1; %flag to get the TR from the first image 
            else
                TR = str2double(parts(2));
                fprintf(output_FID, strcat('TR: ', parts(2), '\n'));
            end
        case "STOP" %start the T1 fit 
            fprintf(output_FID, "Performing Checks before Running T1 Fit\n");
            
            %confirm there is a location for the T1 maps to go
            if isempty(T1_output_path)
                fprintf(output_FID, ...
                    "T1 Map output path not specified ..\nGenerating T1 file Directory in flip angle map directory ...\n");
                [tempT1path, ~, ~] = fileparts(angle_paths(1));
                T1_output_path = strcat(tempT1path, "\T1_Map_Temp");                              
            end
            
            if (not(isfolder(char(T1_output_path))) && not(isempty(T1_output_path)))
                fprintf(output_FID, 'File Path Not Found, Creating File Path for T1 Map Storage...\n');
                mkdir(char(T1_output_path));
            end
            
            %confirm there is a location for the PD maps to go
            if isempty(PD_output_path)
                fprintf(output_FID, ...
                    "PD Map output path not specified ..\nGenerating PD file Directory in flip angle map directory ...\n");
                [tempPDpath, ~, ~] = fileparts(angle_paths(1));
                PD_output_path = strcat(tempPDpath, "\PD_Map_Temp");                              
            end
            
            if (not(isfolder(char(PD_output_path))) && not(isempty(PD_output_path)))
                fprintf(output_FID, 'File Path Not Found, Creating File Path for PD Map Storage...\n');
                mkdir(char(PD_output_path));
            end
           
            %Load in the data for the array processing
            angle_data = [];
            i = 1;
            first_dicom_info_sorted = [];
            try
                for angle_path = angle_paths
                       angle_data(:,:,:,i) = squeeze(dicomreadVolume(angle_path));
                       i = i + 1;
                end
                %Gets the dicominfo for every single dicom in the folder and organizes the slice information correctly
                %This little block should not have to be this complicated but whatever
                first_angle_files = dir(char(angle_paths(1)));

                first_dicom_info = [];
                slice_location = [];
                for i = 1:length(first_angle_files)
                     first_angle_paths = [first_angle_files(i).folder, '\', first_angle_files(i).name];
                     if(contains(first_angle_paths, '.dcm')) 
                        if(isdicom(first_angle_paths))
                            info = dicominfo(first_angle_paths);
                            first_dicom_info = [first_dicom_info,info];
                            if TR == -1 %check to see if we need to get the TR from a header
                                TR = info.RepetitionTime; %excessive but all the TRs should be the same anyway 
                                
                            end 
                            slice_location = [slice_location, info.InstanceNumber]; 
                        end
                     end

                end 

                [~,order] = sort(slice_location); %sort by the instance number and obtain the new ordering, needs to be reversed for correct viewing
                first_dicom_info_sorted = first_dicom_info(1,order);%reorder
           
                
            catch error %catch if there was an error loading the maps
                fprintf(output_FID, error.identifier);
                fprintf(output_FID, '\n');
                fprintf(output_FID, error.message);
                fprintf(output_FID, '\n');
                fprintf(output_FID, 'Error Thrown during dicominfo loading Going to Next Input....\n');
                tline = fgetl(fileID); %update line pointer
                continue;
            
            end
            
            %Input Mistake Check
            [~,~,~,angledata_length] = size(angle_data);
            if(angledata_length ~= length(flip_angles))
                fprintf(output_FID, 'Flip Angle Data and Listed Angles Do Not Match...\n Skipping to Next Input...\n');
                tline = fgetl(fileID); %update line pointer
                continue;
            end
            
            
            %Run the T1 Fit and catch any errors thrown
            t1 = [];
            pd = [];
            
            try
                [t1,pd] = T1PdFitT1(angle_data,flip_angles,TR,[]);% assume B1 map is empty for now
                fprintf(output_FID, 'Fit Complete, Saving New DICOMs\n');
                 %%Save the resulting image; 
                 [~,~,slicemax] = size(t1);
                 t1 = flip(t1,3); %need to reverse order
                 pd = flip(pd,3);
                 seriesUID = dicomuid;
                 seriesUID_PD = dicomuid;
                 for slicenum = 1:slicemax
                    uid = dicomuid; %to create unique filename
                    %for this we should probably check for truncation error
                    slice = uint16(squeeze(t1(:,:,slicenum))*1000); %convert to miliseconds and uint16 
                    info = first_dicom_info_sorted(slicenum);
                    file_name = strcat(T1_output_path, '\', uid,'.dcm');
                    info.SeriesDescription = char(Series_Name);
                    info.SeriesInstanceUID = seriesUID; 
                    dicomwrite(slice,file_name,info, 'CreateMode', 'Create');
                                    
                    uid = dicomuid; %to create unique filename
                    %for this we should probably check for truncation error
                    slice = uint16(squeeze(pd(:,:,slicenum)));                      
                    file_name = strcat(PD_output_path, '\', uid, '.dcm');
                    info.SeriesDescription = char(Series_Name_PD);
                    info.SeriesInstanceUID = seriesUID_PD; 
                    dicomwrite(slice,file_name,info, 'CreateMode', 'Create');
                 
                 end
                           
            catch error
                fprintf(output_FID, error.identifier);
                fprintf(output_FID, '\n');
                fprintf(output_FID, error.message);
                fprintf(output_FID, '\n');
                fprintf(output_FID, 'Error Thrown, Going to Next Input....\n');
            end 
                        
        case "###"
            %ignore these as organization dead space
            
        otherwise
            warning('Unexpected Input Type');
    end
    %lines = [lines;B];
    tline = fgetl(fileID);  
    
    end

    %disp(lines)
else
    disp("Input File Does Not Exist: Try Using the Absolute Path");
end
fclose(fileID);
fclose(output_FID);
pause(1)
return


