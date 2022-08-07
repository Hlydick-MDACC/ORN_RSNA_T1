function [] = T1_MultipleRegions_to_Excell(filepath, Seg_path, timepoint, excell_path)
    
    Seg_names = strsplit(Seg_path,'\');
    return_path = char(Seg_names(1));
    %reconstruct the path and catch the edgecases
    if (length(Seg_names) > 1)
        for i = 2:(length(Seg_names) - 1)
            return_path = strcat(return_path, '\', Seg_names(i));
        end
    end
    Seg_path_original = return_path{1}; %convert cell to string 
    T1Map = squeeze(dicomreadVolume(filepath));
    %% the Segmentations need to be in the same folder for the next part but break the dicomReadVolume function
    status = movefile(Seg_path,filepath); %Shrug it works
    %% Load in the RT Struct data
    filepath_segs = strcat(filepath,'\',Seg_names(end)');
    info = dicominfo(filepath_segs{1});
    MRN = info.PatientID; %need this to name the excel file later
    files_out = dicomrt2matlab(filepath_segs{1}); %pulls out all of the data for the maps from RT thresh
    temp_Seg = strsplit(Seg_names{end}, '.');
    temp_seg_final = strcat(temp_Seg{1}, '.mat');
    isodose_segmentations_struct = load(strcat(filepath, '\', temp_seg_final));
    %% Move the files back to maintain steadystate
    status = movefile(filepath_segs{1}, Seg_path_original);
    %% Get the data
    control_risk_region = [];
    low_risk_region = [];
    inter_risk_region =[];
    high_risk_region = [];
    isodose_struct = isodose_segmentations_struct.contours;
    [~,a] = size(isodose_struct);
    for i = 1:a
        name = isodose_struct(i).ROIName;
        temp = isodose_struct(i).Segmentation;
        %Flip images around because coordinate systems are not consistent
        %Thank you Velocity :)
        [a,b,c] = size(isodose_struct(i).Segmentation);
        flip_region = zeros(b,a,c);
        for j = 1:c
           flip_c = c+1-j;
           flip_region(:,:,flip_c) = temp(:,:,j)';
        end
        %Filter by name (Moamen promised they were consistent Edit2: they were not, getting more general here)
        if contains(name, 'control')
            control_risk_region = flip_region;
        elseif contains(name, 'low')
            low_risk_region = flip_region;   
        elseif contains(name, 'moderate')
            inter_risk_region = flip_region; 
        elseif contains(name, 'high')
            high_risk_region = flip_region; 
        else
            warning("Unknown Segmentation Found...Check that the files chosen were correct and in the correct filepaths");
        end 

    end
    %% Now get what we came here for, get that good shit
    %This is to check for image correct in debugging
    figure();
    imshow(high_risk_region(:,:,16));
    figure();
    imshow(T1Map(:,:,16), 'DisplayRange', []);
    
    control_indexes = find(control_risk_region);
    control_data = T1Map(control_indexes);
    low_indexes = find(low_risk_region);
    low_data = T1Map(low_indexes);
    inter_indexes = find(inter_risk_region);
    inter_data = T1Map(inter_indexes);
    high_indexes = find(high_risk_region);
    high_data = T1Map(high_indexes);


    all_data = [control_data;low_data;inter_data;high_data];


    %Extract some basic statistics before wrapping this all up
    %get kurtosis
    K_control = kurtosis(double(control_data));
    K_low = kurtosis(double(low_data));
    K_inter = kurtosis(double(inter_data));
    K_high = kurtosis(double(high_data));
    K_all = kurtosis(double(all_data));
    %get sample size

    size_control = length(control_data);
    size_low = length(low_data);
    size_inter = length(inter_data);
    size_high = length(high_data);
    size_all = length(all_data);
    %get mean 

    mean_control = mean(control_data);
    mean_low = mean(low_data);
    mean_inter = mean(inter_data);
    mean_high = mean(high_data);
    mean_all = mean(all_data);
    %get Skewness
    Skew_control = skewness(double(control_data));
    Skew_low = skewness(double(low_data));
    Skew_inter = skewness(double(inter_data));
    Skew_high = skewness(double(high_data));
    Skew_all = skewness(double(all_data));
    %get median

    median_control = median(control_data);
    median_low = median(low_data);
    median_inter = median(inter_data);
    median_high = median(high_data);
    median_all = median(all_data);

    %get inner quantiles
    quant_control = quantile(double(control_data), [0.05 0.95]);
    quant_low = quantile(double(low_data), [0.05 0.95] );
    quant_inter = quantile(double(inter_data), [0.05 0.95] );
    quant_high = quantile(double(high_data), [0.05 0.95] );
    quant_all = quantile(double(all_data), [0.05 0.95] );


    %% write everything to an excell sheet and lets be done with this
    % need to add file handling so i dont make an immortal file on accident
    %
    %Save expectations
    %
    %  C L I  H  N   M   m   s   K
    %  # # #  #      C  #   #   #   #   # 
    %  # # #  #      L  #   #   #   #   #
    %  # # #  #      I  #   #   #   #   #
    %  # # #  #      H  #   #   #   #   #
    %
    xlsx_filname =  strcat(MRN, '.xlsx');
    xlsx_filepath = strcat(excell_path, '\', xlsx_filname);

    col_name = 'C';
    xlswrite(xlsx_filepath,col_name , timepoint, 'A1');
    xlswrite(xlsx_filepath,control_data , timepoint, 'A2');

    col_name = "L";

    xlswrite(xlsx_filepath,col_name , timepoint, 'B1');
    xlswrite(xlsx_filepath,low_data , timepoint, 'B2');

    col_name = "I";

    xlswrite(xlsx_filepath,col_name , timepoint, 'C1');
    xlswrite(xlsx_filepath,inter_data , timepoint, 'C2');

    col_name = "H";

    xlswrite(xlsx_filepath,col_name , timepoint, 'D1');
    xlswrite(xlsx_filepath,high_data , timepoint, 'D2');

    col_name = "A";

    xlswrite(xlsx_filepath,col_name , timepoint, 'E1');
    xlswrite(xlsx_filepath,all_data , timepoint, 'E2');



    %Label the Data
    Row_names = ['C';'L';'I';'H';'A'];
    Col_names = 'NMmsK[]';
    xlswrite(xlsx_filepath,Col_names , timepoint, 'G1');
    xlswrite(xlsx_filepath,Row_names , timepoint, 'F2');

    xlswrite(xlsx_filepath, size_control , timepoint, 'G2');
    xlswrite(xlsx_filepath, size_low , timepoint, 'G3');
    xlswrite(xlsx_filepath, size_inter , timepoint, 'G4');
    xlswrite(xlsx_filepath, size_high , timepoint, 'G5');
    xlswrite(xlsx_filepath, size_all , timepoint, 'G6');

    xlswrite(xlsx_filepath, mean_control , timepoint, 'H2');
    xlswrite(xlsx_filepath, mean_low , timepoint, 'H3');
    xlswrite(xlsx_filepath, mean_inter , timepoint, 'H4');
    xlswrite(xlsx_filepath, mean_high , timepoint, 'H5');
    xlswrite(xlsx_filepath, mean_all , timepoint, 'H6');

    xlswrite(xlsx_filepath, median_control , timepoint, 'I2');
    xlswrite(xlsx_filepath, median_low , timepoint, 'I3');
    xlswrite(xlsx_filepath, median_inter , timepoint, 'I4');
    xlswrite(xlsx_filepath, median_high , timepoint, 'I5');
    xlswrite(xlsx_filepath, median_all , timepoint, 'I6');

    xlswrite(xlsx_filepath, Skew_control , timepoint, 'J2');
    xlswrite(xlsx_filepath, Skew_low , timepoint, 'J3');
    xlswrite(xlsx_filepath, Skew_inter , timepoint, 'J4');
    xlswrite(xlsx_filepath, Skew_high , timepoint, 'J5');
    xlswrite(xlsx_filepath, Skew_all , timepoint, 'J6');

    xlswrite(xlsx_filepath, K_control , timepoint, 'K2');
    xlswrite(xlsx_filepath, K_low , timepoint, 'K3');
    xlswrite(xlsx_filepath, K_inter , timepoint, 'K4');
    xlswrite(xlsx_filepath, K_high , timepoint, 'K5');
    xlswrite(xlsx_filepath, K_all , timepoint, 'K6');

    xlswrite(xlsx_filepath, quant_control , timepoint, 'L2');
    xlswrite(xlsx_filepath, quant_low , timepoint, 'L3');
    xlswrite(xlsx_filepath, quant_inter , timepoint, 'L4');
    xlswrite(xlsx_filepath, quant_high , timepoint, 'L5');
    xlswrite(xlsx_filepath, quant_all , timepoint, 'L6');


end

