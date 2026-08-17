% Plot_Selected_ABR_tk98
% this mfile  plots the selected ABR for gecko TK98 for all frequencies
% tested and relevant amplitudes -without noise or weird bumps. This plot is used later to determine by
% visual inspection by two independent observers the ABR threshold. 
% ABR threshold is the amplitude at which you can see a response to the
% stimulation. 
% 03/25/2026, yvz
clear all
close all

geckoID = 'tk98_R' %Tk-98, Right Ear before & after Surgery
printThis=0;


s=0;
DataPath ='/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-19_Tk99/2026-03-19.02'

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


%% use only the selected files

% good before surgery
% 104857 --> 500 Hz (4)
% 105343 --> 2550 Hz (6)
% 105708 --> 5000 Hz (8)

% good after surgery
% 115013 --> 500  Hz  (12)
% 115302 ---> 2550 Hz (13)
% 120705 ---> 5000 Hz (28)

%% 
%% Choose Files Before or After Surgery
all_s=[0 1];

for thisS=1:length(all_s)

    s=all_s(thisS);
    if s==0
        idx = idx_ns;
        label_surgery =' '
        sel_indx = [3 5 7];
        n_graph = [1 3 5];
    elseif s==1
        idx =idx_s;
        label_surgery =' After Surgery'
        sel_indx = [2 3 18];
        n_graph = [2 4 6];
    end
    all_files =  txt(2:end,1);
    selected_Files = all_files(idx(sel_indx)); % files with meta info -excel file

    % find the freq from the metadata
    all_FreqUsed = num(2:end,9)
    selected_Freq = all_FreqUsed(idx(sel_indx))


    % load for thisFrequency the Corresponding Avg File
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

        c = ([colormap; colormap; colormap; colormap; colormap; colormap; colormap; colormap]);
        contador = 1;
        contador2 = 1;


        labels=[];
        figure(1);
        subplot(3,2,n_graph(thisF)); hold on;

        if thisFreq == 500 && s==0
            i_start = 4; i_end=8; % fine before [4 8]
        elseif thisFreq == 500 && s==1
            i_start = 5; i_end=5; % fine after [5 5]
        elseif thisFreq ==2550 && s==0 %fine before [3 9]
            i_start = 3; i_end=9;
        elseif thisFreq ==2550 && s==1 % fine before [5 6]
            i_start = 5; i_end=6;
        elseif thisFreq ==5000 && s==0 % fine before [7 3]
            i_start =7; i_end=3;
        elseif thisFreq ==5000 && s==1 % fine before [7 3]
            i_start =10; i_end=0;
        end

        for a=i_start:length(all_amp)-i_end
            ia = find(M(1,:)==all_amp(a));
            if unique(M(2:end,ia))~=0
                plot(time, M(2:end,ia)+repmat(contador,length(M(2:end,ia)),1), '-','Color',c(contador2,:),'LineWidth',2);
                labels = [labels; all_amp(a)];

            end
            contador = contador + 30; % Increment the color index for the next plot
            contador2 = contador2 + 170; % plot in position above
        end

        % Set axis labels and grid
        xlabel('Time (s)');
        grid on;

        subplot(3,2,n_graph(thisF));
        ax=gca;
        ax.Title.String =[geckoID, '  ', fname(1:end-4) ', ' num2str(thisFreq) 'Hz ' label_surgery];
        xlim([0 0.025])
        string_labels = cellstr(num2str(labels(:)));  % ensure column vector
        lgd =legend(ax,string_labels, 'Location','northeastoutside')
        % Remove the box (legend box outline) by setting the Box property to 'off'
        lgd.Box = 'off';
        labels=[];
        set(ax, 'YTickLabel', []);
        set(ax, 'XTickLabel', []);
    end
end

cd '/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-19-Tk98'


if printThis ==1
    fname1 = 'ABR_tk98_Normal_n_Surgery_allFreq_Zoom_v2'
    savefig(fname1)
    print(fname1,'-dtiff')
end

%%% This was used to save the ABR thresholds in an mfile, after visual inspection & cross-validation 
ToSaveABR=0;

if ToSaveABR==1
    field1 = 'freqStim';
    value1 =[500, 2550, 5000];
    field2 ='BeforeSurgery';
    value2=[32, 22, 47]; % ABR determined using visual inspection
    field3 = 'AfterSurgery';
    value3=[37, 37 72];
    s = struct(field1,value1,field2,value2,field3,value3)
    fname =[geckoID, '_ABRs'];
    save(fname,'s')
end