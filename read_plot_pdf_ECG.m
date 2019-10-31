%make_8x10_pdf
%Takes 8-lead ASCII (with 1 headerline)

%Select a single file - no error checking performed for 'Cancel'
[filename, pathname] = uigetfile('*.ECG','Select an .ECG file to read and plot');

%read the ECG-signal
%if you need the header use ==>  header = a.textdata;
cd(pathname);
a = importdata (filename);
ecg_signal = a.data;

%Below are the settings for a landscape, A4, correct aspect ratio 
%and 10 mm = 1 mV scale / 25 mm = 1 s
page_setup = [-2 0, 32.1, 20.56];
PaperPosition = page_setup;

figure('PaperPosition',page_setup, 'PaperOrientation', 'landscape','PaperUnits', 'centimeters','PaperType', 'A4');
hold on;

for lead = 1:8
    %make sure each signal has enough room
    trace_pos = 18000 - lead*2000;
    plot(ecg_signal(:,lead)+trace_pos);
end

%Some filenames contain an underscore _ which will be interpreted by the text statement, see below, as subscript indicator 
filename_for_title = strrep(filename,'_','\_');

title(filename_for_title);
outfile_name = [filename(1:end-4) '.pdf'];
print ('-dpdf', outfile_name);
close all


