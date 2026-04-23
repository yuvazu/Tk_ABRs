% Plot_ABR_Tk99_Selected
% this mfile  plots the selected ABR for gecko TK99 for all frequencies
% tested and relevant amplitudes. This plot is used later to determine by
% visual inspection by two independent observers the ABR threshold. 
% ABR threshold is the amplitude at which you can see a response to the
% stimulation. 
% 03/25/2026, yvz

clear all;
close all;

geckoID = 'tk99_R'; % Gecko 99, Right Ear 
print=0;

DataPath = '/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-19_Tk99/2026-03-19.04';
cd(DataPath)
%% load the parameter files & Select NonSurgery & Surgery Files
[num, txt, raw]=xlsread("parameters.xls",-1);
matrix = txt(2:end,2)
str = string(matrix);
tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
idx_s = find(tf); % indx of files after surgery
idx_ns = find(~tf);  % indx of files NO surgery"

SurgeryFiles = matrix(idx_s);      % surgery files
nonSurgeryFiles = matrix(idx_ns);     % non surgery

%% List of used selected files
% good before surgery
% 151057 --> 500 Hz, 
% 151315 --> 2550 Hz, 
% 151626 --> 5000 Hz, 
% good after surgery
% 160619 --> 500 Hz, 
% 160837 --> 2550 Hz, 
% 161257 --> 5000 Hz, 

%% Choose Files Before or After Surgery
all_s=[0 1];

for thisS=1:length(all_s)
    s=all_s(thisS);
    if s==0
        idx = idx_ns;
        label_surgery =' '
        sel_indx = [1 2 5];
        n_graph = [1 3 5];
    elseif s==1
        idx =idx_s;
        label_surgery =' After Surgery'
        sel_indx = [3 4 10];
        n_graph = [2 4 6];
    end

    all_files =  txt(2:end,1);
    selected_Files = all_files(idx(sel_indx)); % files with meta info -excel file

    % find the frequency in the metadata
    all_FreqUsed = num(2:end,9)
    selected_Freq = all_FreqUsed(idx(sel_indx))


    % load for thisFrequency the Average File
    for thisF=1:length(selected_Files);
        % load the corresponding file
        fname = [selected_Files{thisF}(1:end-4), ' avg.txt']
        thisFreq = selected_Freq(thisF)
        disp([ '------Used Filename & Freq =  ', fname, ', ', num2str(thisFreq),'Hz'])
        load(fname)
        M = readmatrix(fname); %  M= Amplidue of Stimulation(1,:); Volage(2:end,:)


        fs = 100000; % 100 kHz
        % Determine the sampling period and time vector
        T = 1/fs; % Sampling period
        time = (1:size(M, 1)-1) * T; % Time vector based on the number of samples

        % all amplitudes for this frequency!
        all_amp = sort(unique(M(1,:)),'ascend');

        c = ([colormap(flipud(parula)); colormap(flipud(parula)); colormap(flipud(parula))]);

        contador = 1;
        contador2 = 13;

        labels=[];
        figure(1);
        subplot(3,2,n_graph(thisF)); hold on;
        if thisFreq == 500
            i_start = 3;
        elseif thisFreq ==2550
            i_start = 4;
        elseif thisFreq ==5000
            i_start =7;
        end

        for a=i_start:length(all_amp)
            ia = find(M(1,:)==all_amp(a));
            if unique(M(2:end,ia))~=0
                plot(time, M(2:end,ia)+repmat(contador,length(M(2:end,ia)),1), '-','Color',c(contador2,:),'LineWidth',1.5);
                labels = [labels; all_amp(a)];

            end
            contador = contador + 100; % plot in position above
            contador2 = contador2 + 15; % increment in colors
        end

        % Set axis labels and grid
        xlabel('Time');
        ylabel ('Voltage')
        grid on;

        subplot(3,2,n_graph(thisF));
        ax=gca;
        ax.Title.String =[geckoID, '  ', fname(1:end-4) ', ' num2str(thisFreq) 'Hz ' label_surgery];

        string_labels = cellstr(num2str(labels(:)));  % ensure column vector
        lgd =legend(ax,string_labels, 'Location','northeastoutside')
        lgd.Box = 'off';
        labels=[];
        set(ax, 'YTickLabel', []);
        set(ax, 'XTickLabel', []);
    end
end

cd('/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-19_Tk99')

if print ==1
    fname1 = 'ABR_tk99_Normal_n_Surgery_allFreq_Zoom'
    saveas(gcf, fname1)
    set(gcf, 'Position', get(0, 'Screensize'));
    print(fname1,'-dtiff')
end


%  ToSaveABR=0; 
%% This was used to save the ABR thresholds in an mfile, after visual inspection & crossvalidation 
% if ToSaveABR==1;
%     field1 = 'freqStim';
%     value1 =[500, 2550, 5000];
%     field2 ='BeforeSurgery';
%     value2=[42, 47, 67]; % ABR determined using visual inspection
%     field3 = 'AfterSurgery';
%     value3=[47, 47, 67];
%     s = struct(field1,value1,field2,value2,field3,value3)
%     fname =[geckoID, '_ABRs'];
%     save(fname,'s')
% end