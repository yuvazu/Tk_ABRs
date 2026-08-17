% Plot_ABR_tk105_Selected
% this mfile  plots the selected ABR for gecko TK105 for all frequencies
% tested and relevant amplitudes. This plot is used later to determine by
% visual inspection by two independent observers the ABR threshold. 
% ABR threshold is the amplitude at which you can see a response to the
% stimulation. 
% 03/25/2026, yvz


clear all
close all

geckoID = 'tk105_L' %Tk-105, Left Ear before & after Surgery

print=0;
%% Choose Files Before or After Surgery
all_s=[0 1];

for thisS=1:length(all_s)
    s=all_s(thisS);
%% load the parameter files & Select NonSurgery & Surgery Files
    if s==0
        DataPath = '/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-24- Tk105/2026-03-24.02' % non surgery
        cd(DataPath)
        
        [num, txt, raw]=xlsread("parameters.xls",-1);
        matrix = txt(2:end,2)
        str = string(matrix);
        tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
        idx_s = find(tf); % indx of files after surgery
        idx_ns = find(~tf);  % indx of files NO surgery"
        nonSurgeryFiles = matrix(idx_ns)    % non surgery
    elseif s==1
        DataPath ='/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-24- Tk105/2026-03-24.03'% get to the next dir for surgery files
        cd(DataPath)
        [num, txt, raw]=xlsread("parameters.xls",-1);
        matrix = txt(2:end,2)
        str = string(matrix);
        tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
        idx_s = find(tf); % indx of files after surgery
        SurgeryFiles = matrix(idx_s)   % surgery files
    end


    %% use only the selected files
    if s==0
        idx = idx_ns;
        label_surgery =' '
        sel_indx = [2 4 5];
        n_graph = [1 3 5];
    elseif s==1
        idx =idx_s;
        label_surgery =' After Surgery'
        sel_indx = [9 7 8];
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

        c = ([colormap; colormap; colormap;  colormap; colormap]);
        contador = 1;
        contador2 = 1;


        labels=[];
        figure(1);
        subplot(3,2,n_graph(thisF)); hold on;
        % this is a subselection of amplitudes showing clear responses to
        % determine the ABR. 
        if thisFreq == 500
            i_start = 4; i_end = 2; %   before (42db) & after (47db) ok!
        elseif thisFreq ==2550 && s==0
            i_start =6;  i_end = 2;
        elseif thisFreq ==2550 && s==1
            i_start =5;  i_end = 4;
        elseif thisFreq ==5000
            i_start =7; i_end = 2; %
        end

        for a=i_start:length(all_amp)-i_end
            ia = find(M(1,:)==all_amp(a));
            if unique(M(2:end,ia))~=0
                plot(time, M(2:end,ia)+repmat(contador,length(M(2:end,ia)),1), '-','Color',c(contador2,:),'LineWidth',2);
                labels = [labels; all_amp(a)];

            end
            contador = contador + 50; % Shift the next trace to a different position in graph
            contador2 = contador2 +30; % Shift color for plotting. 
        end

        % Set axis labels and grid
        xlabel('Time (s)');
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
        xlabel('Time ');
        ylabel('Voltage')


    end
end

if print ==1
    cd('/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-24- Tk105')
    filename = 'ABR_tk105_Normal_n_Surgery_allAmp_Zoom'
    savefig(filename)
end


% ToSaveABR=0; 
% %% This was used to save the ABR thresholds in an mfile, after visual inspection & crossvalidation 
% if ToSaveABR==1;
%     field1 = 'freqStim';
%     value1 =[500, 2550, 5000];
%     field2 ='BeforeSurgery';
%     value2=[42, 52, 62]; % ABR determined using visual inspection
%     field3 = 'AfterSurgery';
%     value3=[47, 47, 62];
%     s = struct(field1,value1,field2,value2,field3,value3)
%     fname =[geckoID, '_ABRs'];
%     save(fname,'s')
% end
