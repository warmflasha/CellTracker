%% Plot spot intensity distributions
function SpotIntHistsTest(dir1, z1, pos, sn, nch, sname)

%% 0. Initialize general experiment parameters
ip              = InitializeExptest(dir1, z1, pos, sn, sname);
SpotChannel     = nch ;
df1             = sprintf('/spots_quantify_t7ntch%d/data/', nch);
data_folder     = [ip.exp.path df1];
spotlist_new    = cell(1,max(ip.exp.sampleList)) ;
scale           = 0; % scale for the plot, 0 = log, 1 = linear; 
colors          = [1 .6 .3; .3 .6 1; .6 .6 .6; 1,.3,.6] ;

if scale == 0
    nbin = logspace(2,8,200) ;
    x_scale = 'log' ; 
    x_lim = [6e2 5e6];
else
    nbin = linspace(1e2,1e6,400) ;
    x_scale = 'linear' ;
    x_lim = [6e2 3e5];
end

%% 1. Spot intensity distributions

load([data_folder 'FISH_spots_data_new.mat'],'spotlist_new','NegPeakThreshold');

figure('Units','normalized','Position',[0.2 0.2 0.6 0.40],...
    'Name','Spot intensity distributions','NumberTitle','off') ;
    
% Spot intensity distributions before applying the negative spot threshold 
subplot(1,2,1);
box off ; hold all ;
ymax = 0;

for n_sample = ip.exp.sampleList
          
    [ya,xa] = hist(spotlist_new{n_sample}(:,5),nbin) ;
    
    plot(xa,ya/sum(ya),'-',...
        'Color',colors(n_sample,:),...
        'LineWidth',1,...
        'DisplayName',ip.sample{n_sample}.name) ;
    
    ymax = max([ymax max(ya/sum(ya))]);
    
end

set(gca,'XScale',x_scale);
lh = legend('show','Location','NorthWest') ;
set(lh,'fontsize',8);
xlim(x_lim) ;
ylim([0 1.2*ymax]) ;
xlabel('Spot intensity (A.U.)') ;
ylabel('Probability') ;

% Spot intensity distributions after applying the negative spot threshold 
subplot(1,2,2);
box off ; hold all ;
% ymax = 0;

for n_sample = ip.exp.sampleList
      
    SubPop = spotlist_new{n_sample}(:,4)>NegPeakThreshold ;
    
    [ya,xa] = hist(spotlist_new{n_sample}(SubPop,5),nbin) ;
    
    plot(xa,ya/sum(ya),'-',...
        'Color',colors(n_sample,:),...
        'LineWidth',1,...
        'DisplayName',ip.sample{n_sample}.name) ;
        
end

set(gca,'XScale',x_scale);
lh = legend('show','Location','NorthWest') ;
set(lh,'fontsize',8);
xlim(x_lim) ;
ylim([0 1.2*ymax]) ;
xlabel('Spot intensity (A.U., after throwing negative spots)') ;
ylabel('Probability') ;

