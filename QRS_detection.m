clear all
close all
%make_8x10_pdf
%Takes 8-lead ASCII (with 1 headerline)

%% Opening of the data
%Select a single file - no error checking performed for 'Cancel'
[filename, pathname] = uigetfile('*.ECG','Select an .ECG file to read and plot', 'MultiSelect', 'on');

%read the ECG-signal
cd(pathname);
for i = 1:length(filename)
    a(1,i) = string(filename(i));
end

% a = importdata(filename); %to open a single file
% ecg_signal = a.data;
ecg_signal = [];
for subj = 1:length(filename)
    
    c = importdata(a(1,subj));
    
    ecg_signal1 = c.data;
    ecg_signal = [ecg_signal ecg_signal1 - mean(ecg_signal1)];
end

%% Preprocessing
    dt = 0.002;
    fs = 500;
    [bf,af]=butter(3,0.5/(fs/2),'high');% filtro passa alto
    [bf,af]=butter(3,40/(fs/2),'low');% filtro passa basso

    y1 = filtfilt(bf,af,ecg_signal);
    ecg_signal_filtered = filtfilt(bf,af,y1);
    ecg_signal_filtered = round(ecg_signal_filtered(:,:));

%% Processing
R_row = [];

for subj = 1:length(filename)
    %Below are the settings for a landscape, A4, correct aspect ratio 
    %and 10 mm = 1 mV scale / 25 mm = 1 s
    page_setup = [-2 0, 32.1, 20.56];
    PaperPosition = page_setup;

%     
%     figure('PaperPosition',page_setup, 'PaperOrientation', 'landscape','PaperUnits', 'centimeters','PaperType', 'A4');
%     hold on


    R_row2 = [];
    R_row3 = [];
    index = 1;
    
    for lead = (((subj-1)*8)+1):(8*subj)
        %make sure each signal has enough room
        trace_pos = 18000 - index*2000;
    
        d_ecg_signal_filtered1(:,lead) = diff(ecg_signal_filtered(:,lead));
        d_ecg_signal_filtered(:,lead) = [0; d_ecg_signal_filtered1(:,lead)];
        dd_ecg_signal_filtered1(:,lead) = diff(d_ecg_signal_filtered(:,lead));
        dd_ecg_signal_filtered(:,lead) = [0; dd_ecg_signal_filtered1(:,lead)];
    
        [amp,R_row1,delay] = pan_tompkin(ecg_signal_filtered(:,lead),fs,0); %Identifico i picchi R
    
        if size(R_row1,2) ~= size(R_row2,2)
            R_row2 = zeros(1,size(R_row1,2));
        end
        
        if R_row1(1, end) > 4960
            R_row2 = zeros(1,size(R_row1,2)-1);
            R_row2(1, :) = R_row1(1, 1:end-1);
        else
            R_row2(1, :) = R_row1(1, :);
        end
        
        if R_row2(1,1) < 50
            R_row3 = zeros(1,size(R_row2,2)-1);
            R_row3(1,:) = R_row2(1, 2:end);
        else
            R_row3 = zeros(1,size(R_row2,2));
            R_row3(1,:) = R_row2(1, :);
        end
        
    
        if subj ~= 1 && index == 1
            R_row = zeros(8, size(R_row3,2));
            R_index = zeros(8, size(R_row3,2));
            Q_row = zeros(8, size(R_row3,2));
            Q_index = zeros(8, size(R_row3,2));
            S_row = zeros(8, size(R_row3,2));
            S_index = zeros(8, size(R_row3,2));
            on_set = zeros(8, size(R_row3,2));
            off_set = zeros(8, size(R_row3,2));
        end
        
        if size(R_row,2) ~= size(R_row3,2) && subj ~= 1
            R_row3 = zeros(1, size(R_row,2));
        
            if index == 1
                problem = 1;
                while abs(R_row3(1,problem)-R_row3(1,problem+1)) <= 200
                    R_row3(1,problem) = mean(R_row3,problem:(problem+1));
                    R_row3(1,problem+1) = [];
                    problem = problem + 1;
                end
            else
                R_row3(1,:) = R_row(index-1, :);
            end
            R_row(index, :) = R_row3(1,:);
        else
            R_row(index, :) = R_row3(1,:);
        end
        
        for i = 1:size(R_row,2)
            [M(1, i) R_index(index,i)] = max(ecg_signal_filtered(R_row(index,i)-20:R_row(index,i)+20,lead));
        end
        R_row(index,:) = R_row(index,:) +(R_index(index,:)-21);


        for j = 1:size(R_row,2)
            c = 1;
            while sign(d_ecg_signal_filtered(R_row(index,j)-(c+1),lead)) == sign(d_ecg_signal_filtered(R_row(index,j)-(c+2),lead))
                c = c + 1;
                if c > 15
                    break
                end
            end
            Q_row(index, j) = R_row(index,j) - (c+2);
        end
        
        
        for k = 1:size(R_row,2)
            c = 1;
            while sign(d_ecg_signal_filtered(R_row(index,k)+(c+1),lead)) == sign(d_ecg_signal_filtered(R_row(index,k)+(c+2),lead))
                c = c + 1;
                if c > 20
                    break
                end
            end            
            S_row(index, k) = R_row(index,k) + (c+1);
        end
    
        
        for p = 1:size(Q_row,2)
            c = 1;
            while sign(d_ecg_signal_filtered(Q_row(index,p)-c,lead)) == sign(d_ecg_signal_filtered(Q_row(index,p)-(c+1),lead))
                c = c + 1;
                if c > 10
                    break
                end
            end
            on_set(index,p) = Q_row(index,p) - (c+1);
        end
        
        
        for q = 1:size(S_row,2)
            c = 1;  
            while sign(d_ecg_signal_filtered(S_row(index,q)+(c+1),lead)) == sign(d_ecg_signal_filtered(S_row(index,q)+(c+2),lead)) 
                c = c + 1;
                if c > 10
                    d = 1 + c;
                    while sign(dd_ecg_signal_filtered(S_row(index,q)+(d+1),lead)) == sign(dd_ecg_signal_filtered(S_row(index,q)+(d+2),lead))
                        d = d + 1;
                        if d > 15
                           break
                        end
                    end
                    off_set(index,q) = S_row(index,q) + d;
                    break
                end
            end
        
            if c <= 10
                off_set(index,q) = S_row(index,q) + c;
            end
        end
        
        if subj ~= 1 && index == 1
%             QRS_duration = zeros(size(R_row,2), size(R_row,1));
            QRS_duration_ms = zeros(1, size(R_row,2));
        end
    
%         plot(ecg_signal_filtered(:,lead));
%         hold on
% %         plot(R_row(index,:),ecg_signal_filtered(R_row(index,:),lead), 'or', 'LineWidth', 2);
% %         hold on
% %         plot(Q_row(index,:),ecg_signal_filtered(Q_row(index,:),lead), 'oy', 'LineWidth', 2);
% %         hold on
% %         plot(S_row(index,:),ecg_signal_filtered(S_row(index,:),lead), 'ob', 'LineWidth', 2);
% %         hold on
%         plot(on_set(index,:),ecg_signal_filtered(on_set(index,:),lead), 'og', 'LineWidth', 1);
%         hold on
%         plot(off_set(index,:),ecg_signal_filtered(off_set(index,:),lead), 'ok', 'LineWidth', 1);
%         xlabel('Samples')
%         ylabel('Amplitude [\muV]')
% %         legend('Signal', 'R-peak', 'Q-peak', 'S-peak', 'On-set', 'Off-set')
        index = index + 1;
    end
    
    ordered_on_set = sort(on_set);
    on = ordered_on_set(2,:);
    ordered_off_set = sort(off_set);
    off = ordered_off_set(end-1,:);
    
    QRS_duration_ms(1,:) = (off - on)*dt*1000; 
    
    percent = prctile(QRS_duration_ms(1,:),[25 75]);
    
    for i = 1:size(QRS_duration_ms,2)
        if QRS_duration_ms(1,i) >= percent(2) || QRS_duration_ms(1,i) < percent(1)
            QRS_duration_ms(1,i) = NaN;
        end
    end
    
    if isnan(QRS_duration_ms)
        QRS_duration_ms = (off - on)*dt*1000;
    end
        
    
    mean_QRS_duration(subj,1) = round(mean(QRS_duration_ms(1,:),'omitnan'));
    std_QRS_persubj(subj,1) = std(mean(QRS_duration_ms(1,:),'omitnan'));
%     file = sprintf('QRS_duration_%d.mat', subj);
%     dlmwrite(file, QRS_duration_ms1); 

end

i = 1;

while mean_QRS_duration(i,1) < 160
    i = i + 1;
    if i > 100
        break
    end
end

if i < 100
    mean_QRS_duration(i,1) = (mean_QRS_duration(i-1,1)+mean_QRS_duration(i+1,1))/2;
end

if i < 100
    j = i + 1;
    while mean_QRS_duration(j,1) < 150
        j = j + 1;
        if j > 100
            break
        end
    end
end

if j <= 100
    mean_QRS_duration(j,1) = (mean_QRS_duration(j-1,1)+mean_QRS_duration(j+1,1))/2;
end

% fid = fopen('QRS_corrected.txt', 'wt');
% fprintf(fid, '%d\n', mean_QRS_duration);
% fclose(fid);

p_std_5ms = sum(std_QRS_persubj(:,1)<4)/numel(std_QRS_persubj(:,1))*100;
p_QRS_150ms = sum(mean_QRS_duration(:,1)<=150)/numel(mean_QRS_duration(:,1))*100;

figure
histogram(mean_QRS_duration, 10);
xlabel('QRS duration [ms]')
ylabel('Number of Subjects')
