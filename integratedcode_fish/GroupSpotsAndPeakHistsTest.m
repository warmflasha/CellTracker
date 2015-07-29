function  GroupSpotsAndPeakHistsTest(dir1, z1, pos, sn, nch, negsamp, sname, negperc)


%% 0. Initialize general experiment parameters
ip          = InitializeExptest(dir1, z1, pos, sn, sname);
SpotChannel     = nch ;
df1             = sprintf('/spots_quantify_t7ntch%d/data/', nch);
data_folder     = [ip.exp.path df1];
spotlist_new    = cell(1,max(ip.exp.sampleList)) ;

%% 1. Re-group data

for n_sample = ip.exp.sampleList
    
    fprintf(1,['Group ' num2str(n_sample) ' of ' num2str(max(ip.exp.sampleList)) '.' sprintf('\n')]);
    
    spots_in_group = [] ;
    
    r1 = 0 ;
    r2 = 0 ;
    
    progress_2 = [];
    for n_image = ip.sample{n_sample}.idx
       
        % the corresponding frame number
        n_frame = ip.exp.splimg2frm(n_sample,n_image+1);
        
        load([data_folder 'peakdata' num2str(n_frame,'%03d') '.mat'],'peakdata');
        
        % count total number of spots and ill-fitted spots
        r1 = r1 + sum(imag(peakdata(:,14))~=0) ;
        r2 = r2 + size(peakdata,1) ;
        
        % Discard all "complex spots". Spatzcells give complex parameters
        % for the fit in cases where the spots reside between two other
        % spots with significantly higher intensity.
        peakdata(imag(peakdata(:,14))~=0,:) = [];
        
        if ~isempty(peakdata)
            spots_in_group = [spots_in_group ; ...
                peakdata(:,13) ...                      % Z-slice  (1)
                [1:size(peakdata,1)]' ...               % vector with a list of spot numbers for the frame (2)
                peakdata(:,[7 1 14]) ...                % BG PeakInt SpotInt (3 4 5)
                pi*peakdata(:,16).*peakdata(:,15)...    % Area of spot, pi*major*minor. (6)
                peakdata(:,[2 3 12 ]) ...               % X Y cellnum (7 8 9)
                peakdata(:,[18 19 20 21 ])...           % pos_long_axis pos_across pos_long_axis_pix pos_across_axis_pix (10 11 12 13)
                peakdata(:,[17 16 15]) ] ;              % frame Major_axis Minor_axis (14 15 16)
        end
        
    end
    
    % Display how many spots are recognized in each sample, as well as the percentage of imaginary
    % (ill-fitted) spots 
    if r2~=0
        fprintf(1,[sprintf('\t') num2str(r1/r2*100,'%4.2f') '%% of spots are complex.' sprintf('\n')]);
    else
        fprintf(1,[sprintf('\t') 'No spots recognized.' sprintf('\n')]);
    end
    
    if ~isempty(spots_in_group)
        spotlist_new{n_sample} = spots_in_group ;
    else
        spotlist_new{n_sample} = zeros(1,16) ;
    end
    
end
if exist([data_folder 'FISH_spots_data_new.mat'],'file')
    save([data_folder 'FISH_spots_data_new.mat'],'spotlist_new','-append');
else
    save([data_folder 'FISH_spots_data_new.mat'],'spotlist_new');
end



%% 2. Plot histogram of peak intensity and determine threshold for negative spots.
n_NegSample = negsamp ;   % which sample is the negative, update the number for the negative sample
neg_perct   = negperc ;  % percentile of negative spots to set as threshold

% calculate threshold for negative spots
NegPeakThreshold = sort(spotlist_new{n_NegSample}(:,4),'ascend') ;
NegPeakThreshold = max(NegPeakThreshold(1:floor((neg_perct/100)*length(NegPeakThreshold)))) ;
df1             = sprintf('/spots_quantify_t7ntch%d/data/', nch);
data_folder     = [ip.exp.path df1];
        
N = [200 200 200] ; % number of bins for each sample
%N = [500 500];

figure('Units','normalized','Position',[0.1 0.1 0.7 0.3],...
    'Name','Peak height histograms','NumberTitle','off') ;
iplot = 1 ;

for n_sample = ip.exp.sampleList
    
    if ~isempty(spotlist_new{n_sample})
        
        subplot(2,ceil(max(ip.exp.sampleList)/2),iplot,'XScale','log','FontSize',8) ;
        box on ; 
        hold all ;
        
        plot(NegPeakThreshold,0,':','Color',[0.5 0.5 0.5],'LineWidth',2,...
            'DisplayName',[ip.sample{n_NegSample}.name ' ' num2str(neg_perct) ' percentile']) ;
        lh = legend('show','Location','NorthEast') ;
        set(lh,'FontSize',10) ;
        
        minP = min(spotlist_new{n_sample}(:,4)) ;
        maxP = max(spotlist_new{n_sample}(:,4)) ;
        nbin = logspace(log10(minP),log10(maxP),N(n_sample)) ;
        
        [ya,xa] = hist(spotlist_new{n_sample}(:,4),nbin) ;
        
        plot(xa,ya/sum(ya),'-',...
            'Color',[.3 .6 1],'LineWidth',1,...
            'DisplayName',ip.sample{n_sample}.name) ;
        
        xlim([8e1 4e5]) ;
        yl = get(gca,'YLim') ;
        
        plot(NegPeakThreshold*[1 1],yl,':',...
            'Color',[0.5 0.5 0.5],'LineWidth',2,...
            'DisplayName',[num2str(neg_perct) ' percentile of ' ip.sample{n_NegSample}.name]) ;
        
        ylabel('Probability','fontsize',12) ;
        title(ip.sample{n_sample}.name,'fontsize',10) ;
        set(gca,'XTickLabel',[]) ;
        
        iplot = iplot + 1 ;
        
        set(gca,'XTickLabelMode','auto') ;
        xlabel('Peak height','fontsize',12) ;

        
    end
    
end

% save the peak height threshold for the other sample
if exist([data_folder 'FISH_spots_data_new.mat'],'file')
    save([data_folder 'FISH_spots_data_new.mat'],...
    'spotlist_new','NegPeakThreshold','-append');
else
    save([data_folder 'FISH_spots_data_new.mat'],...
    'spotlist_new','NegPeakThreshold');
end

