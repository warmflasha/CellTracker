%% Obtain the typical fluorescence of a single mRNA

function GetSingleMrnaIntTest(dir1, z1, pos, sn, nch, sname)
%% 0. Initialize general experiment parameters
ip              = InitializeExptest(dir1, z1, pos, sn,  sname);
SpotChannel     = nch ;
df1             = sprintf('/spots_quantify_t7ntch%d/data/', nch);
data_folder     = [ip.exp.path df1];
spotlist_new    = cell(1,max(ip.exp.sampleList));
colors          = [1 .6 .3; .3 .6 1; .6 .6 .6; .6, .3,1] ;
nbin            = 250;

%% 1. fit to a multi-gaussian model

% read spot data
load([data_folder 'FISH_spots_data_new.mat'],'spotlist_new','NegPeakThreshold');

% filter spots, and then calculate the mean intensity of the spots to guide the fit.
SubPop = spotlist_new{2}(:,4)>NegPeakThreshold & isfinite(spotlist_new{2}(:,5));
[y,x] = hist(spotlist_new{2}(SubPop,5),nbin) ;
mSpot = mean(spotlist_new{2}(SubPop,5));

% Set up fittype and options.
ft = fittype( 'a*exp(-((x-b)/c)^2)  + d*exp( -((x-2*b)/(sqrt(2)*c))^2  )  + f*exp(-((x-3*b)/(sqrt(3)*c))^2  )', ...
              'independent', 'x', 'dependent', 'y');
opts            = fitoptions( ft );
opts.Display    = 'Off';
opts.StartPoint = [1 mSpot .5*mSpot .5 .25];
opts.Lower      = .1*opts.StartPoint;
opts.Upper      = 10*opts.StartPoint;

% Fit model to data.
[fit_, gof] = fit( x', y'/max(y), ft, opts );

% Plot fit with data.
figure('Units','normalized','Position',[0.2 0.2 0.3 0.3],...
    'Name','Peak height','NumberTitle','off') ;
hold on;

xf = 0:100:250000;

f1 = fit_.a*exp(-((xf-fit_.b)/fit_.c).^2);  
f2 = fit_.d*exp(-((xf-2*fit_.b)/(sqrt(2)*fit_.c)).^2);  
f3 = fit_.f*exp(-((xf-3*fit_.b)/(sqrt(3)*fit_.c)).^2);

p1 = plot(x,y/max(y),'ro');
p2 = plot(xf,f1,'-','color',[.5 .5 .5]);
plot(xf,f2,'-','color',[.5 .5 .5]);
plot(xf,f3,'-','color',[.5 .5 .5]);
p3 = plot(xf,f1 + f2 + f3,'k-');
ph = plot(fit_.b*[1 1],[0 1],'r--');
lh = legend([p1 p2 p3 ph],{'data','single gaussians','multi gaussian fit',['One mRNA = ' num2str(fit_.b)]});
set(lh,'fontsize',12);
set(gca,'fontsize',10);
xlabel( 'Spot intensity (A.U.)' ,'fontsize', 12);
ylabel( 'Scaled probability' ,'fontsize', 12);
xlim([0 2.5e5]);

% save one-mRNA intensity
One_mRNA = fit_.b;
if exist([data_folder 'FISH_spots_data_new.mat'],'file')
    save([data_folder 'FISH_spots_data_new.mat'],'One_mRNA','-append');
else
    save([data_folder 'FISH_spots_data_new.mat'],'One_mRNA');
end

