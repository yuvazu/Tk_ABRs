%% Plot_ABR_Tk99_2550Hz_wBox
% this mfile plots the ABR Response for Gecko Tk 99 at a Frequency of Stimulation = 2550 Hz, before and after performing a surgery which exposed the hearing organ.  
% The idea is that the ABR threshold should be similar if the hearing organ has no damage. 
% 04/2026, modified 08/2026 for Stimulus box, and Zoom. 

% Note: the raw voltage data are saved in the following config:
% Raw voltage * 10^4 (comes from amplifier) * software gain ( 10^4). 
% So to go back to the raw voltage values, you need to divide 10^8, to undo
% the gains from the amplifier & software, and turn it into microvolts
% (/10^2) (line 199)

clear all;
close all;


geckoID = 'tk99_R' % animal ID 

ToPrint=0; % set to 1 if you want to save/store as svg
scaleON=0; % set to 1 if you want to add a time & voltage scale bar, the position is suboptimal which means you will need to edit it in Illustrator
BoxOn=0; % set to 1 if you want to add a box around the stimulus timing. 
ZoomOn=1; % set to 1 if you want to just plot the signal from 

%% set Data Path to the ABR Data 
DataPath = '/Users/yuriria/Documents/MATLAB/HUDSPETH_LAB/Gecko_ABR/2026-03-19_Tk99/2026-03-19.04';
cd(DataPath)

%% load the parameter files & Select NonSurgery & Surgery Files
[num, txt, raw]=xlsread("parameters.xls",-1);
matrix = txt(2:end,2)
str = string(matrix);
tf = contains(str, "surgery", "IgnoreCase", true); % logical mask
idx_s = find(tf); % files after surgery
idx_ns = find(~tf);  % files NO surgery

SurgeryFiles = matrix(idx_s);      % surgery files
nonSurgeryFiles = matrix(idx_ns);     % non surgery




%% Choose the Selected Files to plot Before or After Surgery
% 151315 avg.txt' 2550 Hz 
% 160837 avg.txt 2550 Hz
all_s=[0 1];


for thisS=1:length(all_s)
    s=all_s(thisS);
    if s==0
        idx = idx_ns;
        label_surgery =' '
        sel_indx = [1 2 5];
        n_graph = [1];
    elseif s==1
        idx =idx_s;
        label_surgery =' After Surgery'
        sel_indx = [3 4 10];
        n_graph = [2];
    end

    all_files =  txt(2:end,1);
    selected_Files = all_files(idx(sel_indx)); % files with meta info -excel file

    % find the freq from the metadata
    all_FreqUsed = num(2:end,9)
    selected_Freq = all_FreqUsed(idx(sel_indx))



    % load for Stimulation Frequency=2550Hz, the Corresponding Avg File
    thisF=2;% 2550Hz

    % load the corresponding file
    fname = [selected_Files{thisF}(1:end-4), ' avg.txt']
    thisFreq = selected_Freq(thisF)
    disp([ '------Used Filename & Freq =  ', fname, ', ', num2str(thisFreq),'Hz'])
    load(fname)
    M = readmatrix(fname); %  M= Amplitude of Stimulation(1,:); Voltage(2:end,:)

    fs = 100000; % 100 kHz
    % Determine the sampling period and time vector
    T = 1/fs; % Sampling period
    time = (1:size(M, 1)-1) * T; % Time vector based on the number of samples

    % all amplitudes for this frequency!
    all_amp = sort(unique(M(1,:)),'ascend');
    c = ([colormap(parula); colormap(parula); colormap(parula)]);

    contador = 1;
    contador2 = 1;

    labels=[];
    figure(1);
    subplot(1,2,n_graph); hold on;
    if thisFreq == 500
        i_start = 3;
    elseif thisFreq ==2550
        i_start = 6;
    elseif thisFreq ==5000
        i_start =7;
    end

    for a=i_start:length(all_amp)
        ia = find(M(1,:)==all_amp(a));
        if unique(M(2:end,ia))~=0
            plot(time, M(2:end,ia)+repmat(contador,length(M(2:end,ia)),1), '-','Color',c(contador2,:),'LineWidth',1.5);
            labels = [labels; all_amp(a)];
        end
        contador = contador + 100; % plot in a position above
        contador2 = contador2 + 25; % plot with a different color (increment on the color matrix)
    end
    
    % Set axis labels and grid
    xlabel('Time (s)');
    grid on;

    subplot(1,2,n_graph);
    ax=gca;
    ax.Title.String =[geckoID, '  ', fname(1:end-4) ', ' num2str(thisFreq) 'Hz ' label_surgery];

    if BoxOn==1
        % draw a semi-transparent gray rectangle spanning x = [0.012 0.022] across the y-limits
        ax = gca;
        x_rect = [0.012, 0.022, 0.022, 0.012];
        yl = ax.YLim;
        y_rect = [yl(1), yl(1), yl(2), yl(2)];
        p = patch('XData', x_rect, 'YData', y_rect, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'Parent', ax);
        uistack(p, 'bottom'); % put the patch behind plotted traces
    end

    if ZoomOn==1
        xlim([0.012 0.022])
    end

    if scaleON==1 && s==1; % this is for adding a time-voltage scale bar,

        if a==length(all_amp)
            % Draw a horizontal time-scale line at the very top of the current subplot
            ax = gca; % current axes
            drawnow; % ensure ticks and limits are up-to-date

            % Get current x-ticks (in seconds) and y-limits
            xt = ax.XTick;
            if numel(xt) < 2
                % fallback: use axis limits to define a reasonable scale length
                xlims = ax.XLim;
                scale_len = (xlims(2) - xlims(1)) * 0.1;
            else
                scale_len = xt(2) - xt(1);
            end

            yl = ax.YLim;
            % place the line slightly below the top of the y-axis range (so it's visible)
            y_pos = yl(2) - 0.02 * (yl(2) - yl(1));

            % choose horizontal line start so it's centered near left of axes but fully visible
            x_start = ax.XLim(1) + 0.05 * (ax.XLim(2) - ax.XLim(1));
            x_end = x_start + scale_len;

            % draw the line and a small vertical tick at each end
            hold on;
            h_line = plot([x_start, x_end], [y_pos, y_pos], 'k-', 'LineWidth', 2);
            plot([x_start, x_start], [y_pos - 0.005*(yl(2)-yl(1)), y_pos + 0.005*(yl(2)-yl(1))], 'k-', 'LineWidth', 2);
            plot([x_end, x_end], [y_pos - 0.005*(yl(2)-yl(1)), y_pos + 0.005*(yl(2)-yl(1))], 'k-', 'LineWidth', 2);

            % add text label above the line showing the duration (in ms or s depending on scale)
            duration = x_end - x_start;
            if duration < 0.01
                txt = sprintf('%.1f ms', duration*1000);
            else
                txt = sprintf('%.2f s', duration);
            end
            text((x_start + x_end)/2, y_pos + 0.03*(yl(2)-yl(1)), txt, 'HorizontalAlignment','center', 'FontWeight','bold');
            hold off;
        end

        

        % For the final amplitude (a == length(all_amp)) draw a vertical bar showing signal amplitude range.
        % Find indices for columns corresponding to the last amplitude
 
        % For the amplitude equal to 62, draw a similar vertical amplitude bar
        amp_target = 62;
        ia_amp62 = find(M(1,:) == amp_target);

        if ~isempty(ia_amp62)
            % Use mean across repeats if multiple columns exist
            wave62 = mean(M(2:end, ia_amp62), 2);
            n62 = length(wave62);
            winWidth62 = round(n62 * 0.1);
            mid62 = round(n62/2);
            winStart62 = max(1, mid62 - round(winWidth62/2));
            winEnd62 = min(n62, mid62 + round(winWidth62/2));
            window_seg62 = wave62(winStart62:winEnd62);

            y_min62 = min(window_seg62);
            y_max62 = max(window_seg62);
            y_range62 = y_max62 - y_min62;
            y_range62 = y_range62/(10^2); % transform to microvolts (/10^2)
            ax = gca;

      
            % place this vertical bar in the top-left (northwest) of the axes
            % Choose x-position at 10% from left
            x_pos62 = ax.XLim(1) + 0.10*(ax.XLim(2)-ax.XLim(1));
            % Place the bar near the top of the current plotted stack:
            % contador at loop end was incremented beyond last plotted trace by +100,
            % so use contador-100 as baseline for last trace; place this bar aligned with that same baseline.
            yb62 = [y_min62 + contador - 100, y_max62 + contador - 100];

            hold on;
            plot([x_pos62, x_pos62], yb62, 'k-', 'LineWidth', 2);
            cap_w62 = 0.01*(ax.XLim(2)-ax.XLim(1));
            plot([x_pos62-cap_w62, x_pos62+cap_w62], [yb62(1), yb62(1)], 'k-', 'LineWidth', 2);
            plot([x_pos62-cap_w62, x_pos62+cap_w62], [yb62(2), yb62(2)], 'k-', 'LineWidth', 2);

            % Add text label just to the right of the bar, vertically centered; ensure it's placed toward top-left (northwest)
            txt62 = sprintf('%.1f \\muV', y_range62);
            text(x_pos62 + 0.02*(ax.XLim(2)-ax.XLim(1)), mean(yb62), txt62, ...
                'VerticalAlignment','middle', 'HorizontalAlignment','left', 'FontWeight','bold');

            hold off;
        end

    end

    string_labels = cellstr(num2str(labels(:)));  % ensure column vector
    if BoxOn==1
        string_labels = [{''}; string_labels];
    end

    lgd =legend(ax,string_labels, 'Location','northeastoutside')
   
    labels=[];
    set(gca,'YTickLabel',[]);
    ylabel ('Voltage (\muV)')
    axis off
    
end

if ToPrint==1
    %fname1 = 'ABR_tk99_2550Hz_Normal_n_Surgery_scale_v2';
    fname1 = 'ABR_tk99_2550Hz_Normal_n_Surgery_scale_Zoomed';
    saveas(gcf, fname1)
    set(gcf, 'Position', get(0, 'Screensize'));
    print(fname1,'-dsvg');
end