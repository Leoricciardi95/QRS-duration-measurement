clear all
close all
%% salvarli in xml
data = load('mean_QRS_duration.mat');
% fid = fopen('QRS_persubj.txt', 'wt');
mean_QRS_duration = data.mean_QRS_duration;

for subj = 1:size(mean_QRS_duration,2)
    single_mean = mean(mean_QRS_duration(:,subj));
    percent = prctile(mean_QRS_duration(:,subj),[25 75]);

    for i = 1:size(mean_QRS_duration,1)
        if mean_QRS_duration(i,subj) > percent(2) || mean_QRS_duration(i,subj) < percent(1)
            mean_QRS_duration(i,subj) = NaN;
        end
    end
    
    x = [];

    for i = 1:size(mean_QRS_duration,1)
        if isnan(mean_QRS_duration(i,subj))
        else
            x = [x; mean_QRS_duration(i,subj)];
        end
    end
    
    mean_QRS_persubj(subj,1) = mean(x(:,1));
    std_QRS_persubj(subj,1) = std(x(:,1));
end

mean_QRS_persubj = round(mean_QRS_persubj);
std_QRS_persubj = round(std_QRS_persubj);

p_std_5ms = sum(std_QRS_persubj(:,1)<5)/numel(std_QRS_persubj(:,1))*100;
p_QRS_110ms = sum(mean_QRS_persubj(:,1)<=105)/numel(mean_QRS_persubj(:,1))*100;

tot(:,1) = mean_QRS_persubj(:,1);
tot(:,2) = std_QRS_persubj(:,1);

y = [];
for i = 1:100
    if tot(i,1) <= 100 && tot(i,1) >= 90
        y = [y; tot(i,:)];
    end
end
p_std = round(sum(y(:,2)<=5)/numel(y(:,2))*100);
    

figure
histogram(mean_QRS_persubj, 9);
xlabel('QRS duration [ms]')
ylabel('Number of Subjects')

% fprintf(fid, '%d\n', mean_QRS_persubj);
% fclose(fid);