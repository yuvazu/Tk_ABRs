%% Plot_ABR_Selected_tk102
% this mfile  plots the selected ABR for gecko TK102, right ear for all frequencies
% tested and relevant amplitudes. This plot is used later to determine by
% visual inspection by two independent observers the ABR threshold. 
% ABR threshold is the amplitude at which you can see a response to the
% stimulation. This animal was tested after surgery && surgery+ OCT. 
% 03/25/2026, yvz


clear all;
close all;

geckoID = 'tk102_R'; % Gecko 102, Right Ear

afterOCT=1; % set afterOCT=0 to plot after control + ABR surgery, set afterOCT=1 to plot after control + ABR surgery after OCT 
print=0;

all_s=[0 1];

for thisS=1:length(all_s)
    s=all_s(thisS);

    if s==0
        DataPath='/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-30-Tk102/2026-03-30.03' % before surgery Tk102
        cd(DataPath)
        %% load the parameter files & Select NonSurgery & Surgery Files
        [num, txt, raw]=xlsread("parameters.xls",-1);
        matrix = txt(2:end,2)
        str = string(matrix);
        tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
        idx_s = find(tf); % indx of files after surgery
        idx_ns = find(~tf);  % indx of files NO surgery"
        nonSurgeryFiles = matrix(idx_ns)    % non surgery

    elseif s==1
        if afterOCT==0
            DataPath ='/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-30-Tk102/2026-03-30.05'% get to the next dir for surgery files
        elseif afterOCT==1
            DataPath ='/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-30-Tk102/2026-03-30.06'% get to the next dir for surgery files
        end
        cd(DataPath)
        [num, txt, raw]=xlsread("parameters.xls",-1);
        matrix = txt(2:end,2)
        str = string(matrix);
        tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
        idx_s = find(tf); % indx of files after surgery
        SurgeryFiles = matrix(idx_s)   % surgery files
    end

    all_files =  txt(2:end,1);


    %% Choose Selected Files Before or After Surgery

    if s==0
        idx = idx_ns;
        label_surgery =' '
        sel_indx = [2 3 4]; % dont change
        n_graph = [1 3 5];
    elseif s==1 && afterOCT==0
        idx =idx_s;
        label_surgery =' After Surgery';
        sel_indx = [1 4 5]; % dont change
        n_graph = [2 4 6];
    elseif s==1 && afterOCT==1
        idx =idx_s;
        label_surgery =' After Surgery+OCT';
        sel_indx = [2 3 7]; % dont change
        n_graph = [2 4 6];
    end


    selected_Files = all_files(idx(sel_indx)); % files with meta info -excel file

    % find the freq from the metadata
    all_FreqUsed = num(2:end,9);
    selected_Freq = all_FreqUsed(idx(sel_indx));


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

        c = ([colormap; colormap; colormap;  colormap; colormap]);
        contador = 1;
        contador2 = 1;


        labels=[];
        figure(1);
        subplot(3,2,n_graph(thisF)); hold on;

        if thisFreq == 500
            i_start = 4; i_end = 3; % this is ok
        elseif thisFreq ==2550
            i_start =5;  i_end = 3; % this is ok
        elseif thisFreq ==5000
            i_start =9; i_end = 0; %ok
        end

        for a=i_start:length(all_amp)-i_end
            ia = find(M(1,:)==all_amp(a));
            if unique(M(2:end,ia))~=0
                plot(time, M(2:end,ia)+repmat(contador,length(M(2:end,ia)),1), '-','Color',c(contador2,:),'LineWidth',2);
                labels = [labels; all_amp(a)];

            end
            contador = contador + 50; % Increment in postion in plot
            contador2 = contador2 +30; % color shift
        end

        % Set axis labels and grid
        xlabel('Time ');
        ylabel('Voltage')
        grid on;
        xlim([0 0.025])

        subplot(3,2,n_graph(thisF));
        ax=gca;
        ax.Title.String =[geckoID, '  ', fname(1:end-4) ', ' num2str(thisFreq) 'Hz ' label_surgery];

        string_labels = cellstr(num2str(labels(:)));  % ensure column vector
        lgd =legend(ax,string_labels, 'Location','northeastoutside')
        % Remove the box (legend box outline) by setting the Box property to 'off'
        lgd.Box = 'off';
        labels=[];
        set(ax, 'YTickLabel', []);
        set(ax, 'XTickLabel', []);
    end
end


if print ==1 && afterOCT==0
    cd('/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-30-Tk102')
    filename = ['ABR_', geckoID, '_Normal_n_Surgery_allAmp_Zoom']
    savefig(filename)
elseif print ==1 && afterOCT==1
    cd('/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-30-Tk102')
    filename = ['ABR_', geckoID, '_Normal_n_SurgeryOCT_allAmp_Zoom']
    savefig(filename)
end

% ToSaveABR=0; 
%% This was used to save the ABR thresholds in an mfile, after visual inspection & crossvalidation 

% if ToSaveABR==1;
%     field1 = 'freqStim';
%     value1 =[500, 2550, 5000];
%     field2 ='BeforeSurgery';
%     value2=[37, 42, 62]; % ABR determined using visual inspection
%     field3 = 'AfterSurgery';
%     value3=[42, 42, 62];
%     field4='AfterSurgeryOCT';
%     value4=[42,42,67];
%     s = struct(field1,value1,field2,value2,field3,value3,field4,value4)
%     fname =[geckoID, '_ABRs'];
%     save(fname,'s')
% end
