%% used to create figures
%% Load in the data set
clear all; close all; clc;
load Extracted_Data.mat
%% Histogram for viewing ie: do we need to filter the data further?
pt_full = Extracted_data{1,1};
figure;
for h = 1:7
    for w = 1:3
    pt_full = Extracted_data{h,w};
    pt = pt_full{:,5};
    threshold = 3*std(pt);
    validRange = mean(pt) + [-1 1] * threshold;
    pt_Inner95 = pt( pt >= validRange(1) & pt <= validRange(2));
    subplot(7,3,(h-1)*3+w);
    histogram(pt_Inner95, 25);
    xlim([0 2000]);
    ylim([0 4000]);
    xlabel('T1');
    title(['Patient ', num2str(h), ' Timepoint ', num2str(w)]);
    end
end


%% Median Values for the control area over time 
[patient_num, scan_num] = size(Extracted_data);
time_v_median = zeros(patient_num, scan_num);
Control_median_v_time = zeros(patient_num, scan_num);
Low_median_v_time = zeros(patient_num, scan_num);
inter_median_v_time = zeros(patient_num, scan_num);
high_median_v_time = zeros(patient_num, scan_num);
for i = 1:patient_num
       for j = 1:scan_num
           patient = Extracted_data{i,j};
           time_v_median(i,j) = patient{1,15};
           Control_median_v_time(i,j) = patient{1,9};
           Low_median_v_time(i,j) = patient{2,9};
           inter_median_v_time(i,j) = patient{3,9};
           high_median_v_time(i,j) = patient{4,9};
       end

end
figure;
subplot(2,2,1);
plot(time_v_median'/30, Control_median_v_time');
title('Control Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,2);
plot(time_v_median'/30, Low_median_v_time');
title('Low Risk Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,3);
plot(time_v_median'/30, inter_median_v_time');
title('Intermediate Risk Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,4);
plot(time_v_median'/30, high_median_v_time');
title('High Risk Region');
ylabel('T1');
xlabel('Months');


%% Median Values for the control area over time 
[patient_num, scan_num] = size(Extracted_data);
time_v_median = zeros(patient_num, scan_num);
Control_median_v_time = zeros(patient_num, scan_num);
Low_median_v_time = zeros(patient_num, scan_num);
inter_median_v_time = zeros(patient_num, scan_num);
high_median_v_time = zeros(patient_num, scan_num);
for i = 1:patient_num
       for j = 1:scan_num
           patient = Extracted_data{i,j};
           time_v_median(i,j) = patient{1,15};
           
           control_med = patient{:,1};
           control_med(isnan(control_med)) = [];
           threshold = 3*std(control_med);
           validRange = mean(control_med) + [-1 1] * threshold;
           control_Inner95 = control_med( control_med >= validRange(1) & control_med <= validRange(2));
           control_Inner95_median = median(control_Inner95);
        
           Control_median_v_time(i,j) = control_Inner95_median;
           
           low_med = patient{:,2};
           low_med(isnan(low_med)) = [];
           threshold = 3*std(low_med);
           validRange = mean(low_med) + [-1 1] * threshold;
           low_Inner95 = low_med( low_med >= validRange(1) & low_med <= validRange(2));
           low_Inner95_median = median(low_Inner95);
           
           Low_median_v_time(i,j) = low_Inner95_median;
           
           inter_med = patient{:,3};
           inter_med(isnan(inter_med)) = [];
           threshold = 3*std(inter_med);
           validRange = mean(inter_med) + [-1 1] * threshold;
           inter_Inner95 = inter_med( inter_med >= validRange(1) & inter_med <= validRange(2));
           inter_Inner95_median = median(inter_med);
           
           inter_median_v_time(i,j) = inter_Inner95_median;
           
           high_med = patient{:,3};
           high_med(isnan(high_med)) = [];
           threshold = 3*std(high_med);
           validRange = mean(high_med) + [-1 1] * threshold;
           high_Inner95 = high_med( high_med >= validRange(1) & high_med <= validRange(2));
           high_Inner95_median = median(high_med);
           
           high_median_v_time(i,j) = high_Inner95_median;
       end

end
figure;
subplot(2,2,1);
plot(time_v_median'/30, Control_median_v_time');
title('Control Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,2);
plot(time_v_median'/30, Low_median_v_time');
title('Low Risk Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,3);
plot(time_v_median'/30, inter_median_v_time');
title('Intermediate Risk Region');
ylabel('T1');
xlabel('Months');
subplot(2,2,4);
plot(time_v_median'/30, high_median_v_time');
title('High Risk Region');
ylabel('T1');
xlabel('Months');

%% Change between regions over time
Lowchange_fromcontrol_v_time = ((Low_median_v_time - Control_median_v_time)./Control_median_v_time);
inter_fromcontrol_v_time = ((inter_median_v_time - Control_median_v_time)./Control_median_v_time);
high_fromcontrol_v_time = ((high_median_v_time - Control_median_v_time)./Control_median_v_time);
figure;
subplot(1,3,1);
plot(time_v_median'/30, Lowchange_fromcontrol_v_time');
title('% Low Median Change vs Control Region');
ylabel('Delta T1');
xlabel('Months');
ylim([-2.5 2.5]);
subplot(1,3,2);
plot(time_v_median'/30, inter_fromcontrol_v_time');
title('% Intermediate Median Change vs Control Region');
ylabel('Delta T1');
xlabel('Months');
ylim([-2.5 2.5]);
subplot(1,3,3);
plot(time_v_median'/30, high_fromcontrol_v_time');
title('% High Median Change vs Control Region');
ylabel('Delta T1');
xlabel('Months');
ylim([-2.5 2.5]);


%% Change of regions over time 
Low_median_tp1 = Low_median_v_time(:,1);
control_median_tp1 = Control_median_v_time(:,1);
inter_median_tp1 = inter_median_v_time(:,1);
high_median_tp1 = high_median_v_time(:,1);



%%
Lowchange_dt_median = abs((Low_median_v_time - Low_median_tp1)./Low_median_tp1);
inter_dt_median = abs((inter_median_v_time - inter_median_tp1)./inter_median_tp1);
high_dt_median = abs((high_median_v_time - high_median_tp1)./high_median_tp1);
control_dt_median = abs((Control_median_v_time - control_median_tp1)./[control_median_tp1,control_median_tp1,control_median_tp1]);
figure;
subplot(2,2,1);
plot(time_v_median'/30, Lowchange_dt_median');
title('Low Median Change Against Planning Scan');
ylabel('Delta T1');
xlabel('Months');
ylim([0 2]);
subplot(2,2,2);
plot(time_v_median'/30, inter_dt_median');
title('Intermediate Median Change Against Planning Scan');
ylabel('Delta T1');
xlabel('Months');
ylim([0 2]);
subplot(2,2,3);
plot(time_v_median'/30, high_dt_median');
title('High Median Change Against Planning Scan');
ylabel('Delta T1');
xlabel('Months');
ylim([0 2]);
subplot(2,2,4);
plot(time_v_median'/30, control_dt_median');
title('Control Median Change Against Planning Scan');
ylabel('Delta T1');
xlabel('Months');
ylim([0 2]);
%% Kurtosis for the regions over time
 
[patient_num, scan_num] = size(Extracted_data);
time_v_kurt = zeros(patient_num, scan_num);
Control_kurt_v_time = zeros(patient_num, scan_num);
Low_kurt_v_time = zeros(patient_num, scan_num);
inter_kurt_v_time = zeros(patient_num, scan_num);
high_kurt_v_time = zeros(patient_num, scan_num);
for i = 1:patient_num
       for j = 1:scan_num
           patient = Extracted_data{i,j};
           time_v_kurt(i,j) = patient{1,15};
           Control_kurt_v_time(i,j) = patient{1,11};
           Low_kurt_v_time(i,j) = patient{2,11};
           inter_kurt_v_time(i,j) = patient{3,11};
           high_kurt_v_time(i,j) = patient{4,11};
       end

end
figure;
subplot(2,2,1);
plot(time_v_kurt'/30, Control_kurt_v_time');
title('Control Region');
ylabel('Kurtosis');
xlabel('Months');
subplot(2,2,2);
ylim([0, 100])
plot(time_v_kurt'/30, Low_kurt_v_time');
title('Low Risk Region');
ylabel('Kurtosis');
xlabel('Months');
ylim([0, 100])
subplot(2,2,3);
plot(time_v_kurt'/30, inter_kurt_v_time');
title('Intermediate Risk Region');
ylabel('Kurtosis');
xlabel('Months');
ylim([0, 100])
subplot(2,2,4);
plot(time_v_kurt'/30, high_kurt_v_time');
title('High Risk Region');
ylabel('Kurtosis');
xlabel('Months');
ylim([0, 100])
 %% Change between regions over time kurtosis 
Lowchange_fromcontrol_kurt_v_time = (Low_kurt_v_time - Control_kurt_v_time);
inter_fromcontrol_kurt_v_time = (inter_kurt_v_time - Control_kurt_v_time);
high_fromcontrol_kurt_v_time = (high_kurt_v_time - Control_kurt_v_time);
figure;
subplot(1,3,1);
plot(time_v_kurt'/30, Lowchange_fromcontrol_kurt_v_time');
title('% Low Kurtosis Change vs Control Region');
ylabel('% Kurtosis Change');
xlabel('Months');

subplot(1,3,2);
plot(time_v_kurt'/30, inter_fromcontrol_kurt_v_time');
title('% Intermediate Kurtosis Change vs Control Region');
ylabel('% Kurtosis Change');
xlabel('Months');

subplot(1,3,3);
plot(time_v_kurt'/30, high_fromcontrol_kurt_v_time');
title('% High Kurtosis Change vs Control Region');
ylabel('% Kurtosis Change');
xlabel('Months');

 %% Change between regions over time kurtosis 
%Lowchange_fromlow_kurt_v_time = ((Low_kurt_v_time - Control_kurt_v_time)./Control_kurt_v_time)*100;
inter_fromlow_kurt_v_time = ((inter_kurt_v_time - Low_kurt_v_time)./Low_kurt_v_time)*100;
high_fromlow_kurt_v_time = ((high_kurt_v_time - Low_kurt_v_time)./Low_kurt_v_time)*100;
figure;
% subplot(1,3,1);
% plot(time_v_kurt'/30, Lowchange_fromcontrol_kurt_v_time');
% title('% Low Kurtosis Change vs Control Region');
% ylabel('% Kurtosis Change');
% xlabel('Months');

subplot(1,2,1);
plot(time_v_kurt'/30, inter_fromlow_kurt_v_time');
title('% Intermediate Kurtosis Change vs Low Risk Region');
ylabel('% Kurtosis Change');
xlabel('Months');

subplot(1,2,2);
plot(time_v_kurt'/30, high_fromlow_kurt_v_time');
title('% High Kurtosis Change vs Low Risk Region');
ylabel('% Kurtosis Change');
xlabel('Months');

%% Change of regions over time 
Low_kurt_tp1 = Low_kurt_v_time(:,1);
control_kurt_tp1 = Control_kurt_v_time(:,1);
inter_kurt_tp1 = inter_kurt_v_time(:,1);
high_kurt_tp1 = high_kurt_v_time(:,1);



%%
Lowchange_dt_kurt = abs((Low_kurt_v_time - Low_kurt_tp1)./Low_kurt_tp1);
inter_dt_kurt = abs((inter_kurt_v_time - inter_kurt_tp1)./inter_kurt_tp1);
high_dt_kurt = abs((high_kurt_v_time - high_kurt_tp1)./high_kurt_tp1);
control_dt_kurt = abs((Control_kurt_v_time - control_kurt_tp1)./[control_kurt_tp1,control_kurt_tp1,control_kurt_tp1]);
figure;
subplot(2,2,1);
plot(time_v_kurt'/30, Lowchange_dt_kurt');
title('Low Kurtosis Change Against TP1');
ylabel('Kurtosis Scaled Change against TP1');
xlabel('Months');
ylim([0 5]);
subplot(2,2,2);
plot(time_v_kurt'/30, inter_dt_kurt');
title('Intermediate Kurtosis Change Against TP1');
ylabel('Kurtosis Scaled Change against TP1');
xlabel('Months');
ylim([0 5]);
subplot(2,2,3);
plot(time_v_kurt'/30, high_dt_kurt');
title('High Kurtosis Change Against TP1');
ylabel('Kurtosis Scaled Change against TP1');
xlabel('Months');
ylim([0 5]);
subplot(2,2,4);
plot(time_v_kurt'/30, control_dt_kurt');
title('Control Kurtosis Change Against TP1');
ylabel('Kurtosis Scaled Change');
xlabel('Months');
ylim([0 5]);

%% Creating super set of L/h/i/c regions

threshold = 3*std(pt);
validRange = mean(pt) + [-1 1] * threshold;
pt_Inner95 = pt( pt >= validRange(1) & pt <= validRange(2));
control_full = [];
low_full = [];
inter_full = [];
high_full = [];
time_full = [];
control_ranges = [];
low_ranges = [];
inter_ranges = [];
high_ranges = [];

for w = 1:3
    control =[];
    low = [];
    inter =[];
    high = [];
    time = [];
    for h = 1:7 
        pt_full = Extracted_data{h,w};
        control =  [control; pt_full{:,1}];
        low = [low ; pt_full{:,2}];
        inter = [inter; pt_full{:,3}];
        high = [high; pt_full{:,4}];
        
        time = [time; pt_full{1,15}];
    end 
    control(isnan(control)) = [];
    threshold = 3*std(control);
    validRange = mean(control) + [-1 1] * threshold;
    control_Inner95 = control( control >= validRange(1) & control <= validRange(2));
    control_Inner95_median = median(control_Inner95);
    control_ranges(w,:) = validRange;
    low(isnan(low)) = [];
    threshold = 3*std(low);
    validRange = mean(low) + [-1 1] * threshold;
    low_Inner95 = low( low >= validRange(1) & low <= validRange(2));
    low_Inner95_median = median(low_Inner95);
    low_ranges(w,:) =  validRange;
    inter(isnan(inter)) = [];
    threshold = 3*std(inter);
    validRange = mean(inter) + [-1 1] * threshold;
    inter_Inner95 = inter( inter >= validRange(1) & inter <= validRange(2));
    inter_Inner95_median = median(inter_Inner95);
    inter_ranges(w,:) = validRange;
    high(isnan(high)) = [];
    threshold = 3*std(high);
    validRange = mean(high) + [-1 1] * threshold;
    high_Inner95 = high( high >= validRange(1) & high <= validRange(2));
    high_Inner95_median = median(high_Inner95);
    high_ranges(w,:) = validRange;
    control_full(w) = control_Inner95_median;
    low_full(w) = low_Inner95_median;
    inter_full(w) = inter_Inner95_median;
    high_full(w) = high_Inner95_median;
    time_full(w) = mean(time); 
   
end 
figure();
subplot(1,4,1);
histogram(control_full);
subplot(1,4,2);
histogram(low_full);
subplot(1,4,3);
histogram(inter_full);
subplot(1,4,4);
histogram(high_full);


figure();
subplot(1,4,1);
plot(time_full/30, control_full);
title('All Voxels Control Region Median');
ylabel('T1');
xlabel('Months');
ylim([300 600]);
subplot(1,4,2);
plot(time_full/30, low_full');
title('All Voxels Low Risk Region Median');
ylabel('T1');
xlabel('Months');
ylim([300 600]);
subplot(1,4,3);
plot(time_full/30, inter_full');
title('All Voxels Intermediate Risk Region Median');
ylabel('T1');
xlabel('Months');
ylim([300 600]);
subplot(1,4,4);
plot(time_full/30, high_full');
title('All Voxels High Risk Region Median');
ylabel('T1');
xlabel('Months');
ylim([300 600]);

figure();
subplot(2,2,1);
plot(time_full/30, (control_full - (control_full(1)))/control_full(1)*100, 'LineWidth',2);
title('Control Superset Median Percent Change from TP1');
ylabel('Percent Change in T1');
xlabel('Months since TP1');
ylim([0,80])
xlim([0 5])
subplot(2,2,2);
plot(time_full/30, (low_full - (low_full(1)))/low_full(1)*100, 'LineWidth',2);
title('Low Risk Superset Median Percent Change from TP1');
ylabel('Percent Change in T1');
xlabel('Months since TP1');
ylim([0,80])
xlim([0 5])
subplot(2,2,3);
plot(time_full/30, (inter_full - (inter_full(1)))/inter_full(1)*100, 'LineWidth',2);
title('Intermediate Risk Superset Median Percent Change from TP1');
ylabel('Percent Change in T1');
xlabel('Months since TP1');
ylim([0,80])
xlim([0 5])
subplot(2,2,4);
plot(time_full/30, (high_full - (high_full(1)))/high_full(1)*100, 'LineWidth',2);
title('High Risk Superset Median Percent Change from TP1');
ylabel('Percent Change in T1');
xlabel('Months since TP1');
ylim([0,80]);
xlim([0 5])


%%
