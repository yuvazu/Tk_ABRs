%%PlotAll_Tks_ABRs_InVivo

% This mfile plots the ABRs (before & after surgery) for all 4 geckos (tk98,99,102,105) measured in vivo.
% It stores the figures in depsc. This code is related to Figure 4C and
% Supplementary Figure 2. 

% set print to 1, if you want to save the figure
ToPrint=0;

% this is the path where the ABR are stored, should be changed depending on the user. 
TargetDir = '/Users/yuriria/Dropbox/HUDSPETH_LAB/Geckos/A_Manuscript_Geckos/ABR_InVivo_ToShare';
cd(TargetDir)


all_files = dir('tk*.mat')

% Colorblind-friendly colors (Okabe-Ito palette)
colors = [0.000, 0.447, 0.741;   % blue
          0.902, 0.624, 0.000;   % orange
          0.000, 0.620, 0.451;   % bluish green
          0.835, 0.369, 0.000];  % vermillion

s_label = [];

figure(1); clf




for i=1:length(all_files)
    load(all_files(i).name);
    %s_label{i,1} = all_files(i).name(1:5);
    subplot(2,2,i)
    freq = s.freqStim;
    bs = s.BeforeSurgery;
    as = s.AfterSurgery;
    plot(freq,bs, '-o', 'LineWidth',3, 'Color',[colors(i,:),0.5], 'MarkerFacecolor', colors(i,:),'MarkerSize',3); hold on;
    s=1;
    if s==1
        plot(freq,as, '--o', 'LineWidth',3, 'Color', colors(i,:), 'MarkerFacecolor', colors(i,:),'MarkerSize',3);
    end
  
    title([ all_files(i).name(1:5)])
    xlim([0 6000])
    ylim ([ 20 80])
    xlabel('Frequency (Hz) ','FontSize',12,'FontName','Arial')
    ylabel('ABR threshold (dB) ', 'FontSize',12, 'FontName','Arial')
    box off
    ax= gca;
    set(ax,'Tickdir', 'in', 'TickLength', [0.02 0.02])
    axis square
    legend ('Before Surgery','After Surgery')
    legend('boxoff')
    hold off
    bs=[];
    as=[];
    
end

if ToPrint==1
    storename = 'ABR_All_thr_inVivo'; 
    %%storename = 'ABR_3Tk_thr_inVivo';
    savefig(storename);
    print(storename,'-depsc')
end
