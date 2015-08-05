 %% Obtain the typical fluorescence of a single mRNA
function GroupCellSpotsTest(dir1, z1, pos, sn, nch, sname)

%% 0. Initialize general experiment parameters
ip              = InitializeExptest(dir1, z1, pos, sn, sname);
SpotChannel     = nch ;
df1             = sprintf('/spots_quantify_t7ntch%d/data/', nch);
data_folder     = [ip.exp.path df1];
nbin            = 250;
pixelsize       = 16/250;

%% 1. Re-group spot data into cell data

load([data_folder 'FISH_spots_data_new.mat'],'spotlist_new','NegPeakThreshold');

enlistcell_new = cell(1,max(ip.exp.sampleList)) ;
for n_sample = ip.exp.sampleList
    
    fprintf(1,['Sample ' num2str(n_sample) ' of ' num2str(max(ip.exp.sampleList)) '.' sprintf('\n')]);
    
    cells_in_group = [] ;
    
    progress_2 = [];

    for n_image = ip.sample{n_sample}.idx
        
        % the corresponding frame number
        n_frame = ip.exp.splimg2frm(n_sample,n_image+1);
        
        for d_=1:1:size(progress_2,2) ; fprintf(1,'\b') ; end
        progress_2 = [sprintf('\t') 'Image ' num2str(n_image) ' in ' ...
            num2str(min(ip.sample{n_sample}.idx)) '-' num2str(max(ip.sample{n_sample}.idx)) '.'] ;
        fprintf(1,progress_2) ;
        
        % load the segmentation mask
        sr = InitializeSpotRecognitionParameterstest(ip,n_frame,SpotChannel,data_folder, z1); %% update file name here
        load([sr.seg.dir sr.seg.name],'LcFull') ;
        
        % load spatzcells result
        load([data_folder  'peakdata' num2str(n_frame,'%03d') '.mat'],'peakdata');
                
        ThrowAway = imag(peakdata(:,14))~=0 | peakdata(:,1)<NegPeakThreshold;
        peakdata(ThrowAway,:) = [] ;
        
        CellStats = regionprops(LcFull,'MajorAxisLength') ;
        
        for n_cell = unique(nonzeros(LcFull(:)))' %1:1:Num1
            
            % Make a new row for each cell.
            cells_in_group = [cells_in_group ; [n_cell n_frame zeros(1,4)]] ;
            
            % Number of spots recognized in the cell.
            cells_in_group(end,3) = nansum(peakdata(:,12)==n_cell) ;
            
            % Total spots intensity of the cell.
            cells_in_group(end,4) = nansum(peakdata(peakdata(:,12)==n_cell,14)) ;
            
            % Cell length in microns
            cells_in_group(end,5) = CellStats(n_cell).MajorAxisLength*pixelsize;
            
            % Intensity of the brightest spot.
            if ~isempty(max(peakdata(peakdata(:,12)==n_cell,14)))
                cells_in_group(end,6) = max(peakdata(peakdata(:,12)==n_cell,14)) ;
            end
            
        end
        
    end
    
    fprintf(1,sprintf('\n')) ;
    
    enlistcell_new{n_sample} = cells_in_group ;
    
end
save([data_folder 'FISH_spots_data_new.mat'],...
    'enlistcell_new','-append'); %% updated FISH_spots_data_new.mat that contains both original spots and and the new enlistcell.mat

%% 2. plot mRNA copy number histograms

load([data_folder 'FISH_spots_data_new.mat'],'enlistcell_new','One_mRNA');

% initialize plot parameters
max_cell_length = 30;
%x_lim           = [2000 2000 2000];

figure('Units','normalized','Position',[0.2 0.2 0.7 0.3],...
    'Name','mRNA copy number histograms','NumberTitle','off') ;

for n_sample = ip.exp.sampleList
       
    % gate cells by cell length, discard very long cells
    if max_cell_length > 0
        cell_Length = enlistcell_new{n_sample}(:,5);
        length_idx = cell_Length < max_cell_length;
    else
        length_idx = ones(1,size(enlistcell_new{n_sample}(:,5),1));
    end
    
    RNA = round(enlistcell_new{n_sample}(:,4)/One_mRNA);  
    
    RNA = RNA(RNA>=0);
    
    [y,x] = hist(RNA,0:max(RNA)) ;
    
    subplot(2,2,n_sample); hold on;
    p1 = plot(x,y/sum(y),'ko');    
    errorbar(x,y/sum(y),y./(sum(y)*sqrt(y)),'.','color',[.5 .5 .5]);
    plot(x,y/sum(y),'ko'); 
    xlabel('mRNA per cell', 'fontsize', 12);
    ylabel('Probability', 'fontsize', 12)
    %xlim([0 x_lim(n_sample)]);
    
    lh = legend(p1,['\langlen\rangle = ' num2str(mean(RNA),'%2.1f') ', \sigma = ' num2str(std(RNA),'%2.1f')]);
    set(lh,'fontsize', 12);
    title(ip.sample{n_sample}.name,'fontsize',10) ;
end
