% Goal is to take in datasets and output Matlab file
clear all;close all;
%Get all file names
files = dir('*.xlsx');
[len, ~] = size(files);
%Establish constant labels
ColumnNames_const = {'Control', 'Low', 'Intermediate', 'High', ...
    'All', 'Regions', 'Samples', 'Mean', 'Median', 'Skewness', 'Kurtosis',...
    'Lower', 'Upper' ,'Scan_Dates', 'TimeDif', 'MRN'};
%Empty container for all the tables
Extracted_data = {};
for i = 1:length(files)
    path = files(i).folder;
    filename = files(i).name;
    temp1 = split(filename, '.');
    MRN = str2num(temp1{1});
    file_path_temp = strcat(path, '\', filename);
    [~, sheets] = xlsfinfo(file_path_temp);
    for j = 1:length(sheets) 
        T = readtable(file_path_temp, 'Sheet', j);
        Date(j) = datetime(sheets{j}, 'InputFormat', 'MM-dd-yyyy');
        temp = between(Date(1), Date(j) , 'Days');
        Delta(j) = caldays(temp);
        [extra, ~] = size(T);
        extra1 = extra - length(Date(j));
        extra_space = NaT(extra1,1);
        extra_num = NaN(extra1,1);
        MRN_temp = [MRN;extra_num];
        Date_temp = [Date(j); extra_space];
        Delta_temp = [Delta(j); extra_num];
        T_temp3 = table(MRN_temp);
        T_temp = table(Date_temp);
        T_temp2 = table(Delta_temp);
        T = [T,T_temp,T_temp2,T_temp3];
        T.Properties.VariableNames = ColumnNames_const;
        Extracted_data{i,j} = T;
        clear T
    end
end
%%
save('Extracted_Data.mat', 'Extracted_data');