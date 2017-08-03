%% Cdx2toSignaling 
%close all
%load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/registeredDAPInewTraces.mat');
%load('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/registeredDAPInewTraces.mat');
%load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/registeredDAPInewTraces.mat','datatogether');
% need to load the 'datatogether' var
positions = (0:39);
clear tracesbycol
trajmin = 30; %
fr_stim = 16; % needed to check the colony size at this point
traces = [];  % initialize
cdx2todapi = [];
binSZ = [1];
C = {'b','r'};
clear dat
clear binneddata
binneddata = struct;
q = 1;
N = 30;
clear test
clear cdx2bins

for k=1:size(datatogether,2)   %  loop over colonies
    fr_stim_col = find(datatogether(k).colony.onframes == fr_stim);
    if ~isempty(fr_stim_col)          % if the cell traced at least untill stimulation
        colSZ =datatogether(k).colony.ncells_actual(fr_stim_col) ;          % check colony size
        
        cdx2todapi(k) = datatogether(k).fixedData(:,3)/datatogether(k).fixedData(:,1); % get the value of cdx2dapi for this colony
        test = (cdx2todapi(k)<= binSZ(1));
        cdx2bins = test+1;
        %traces{k} = datatogether(k).colony.NucSmadRatio;              % get the nuclea2smad ratio for all traces in this colony
        traces{k} = datatogether(k).colony.NucOnlyData;
        traces{k}((traces{k} == 0)) = nan;                            % put nans instead of zeros, to avoid merging theminto consecutive time points and ahe plotting wrong
        for h = 1:size(traces{k},2)                                  % loop over traces
            [r,~] = find(isfinite(traces{k}(:,h)));                  %
            dat = zeros(size(traces{k},1),1);
            dat(r,1) = traces{k}(r,h);                              % dat contains values of signling corresponding to their frame numbers, rest is zeros
            if length(nonzeros(dat))>trajmin                         % here filter out short trajectories
                disp(['filter trajectories below' num2str(trajmin)]);
                disp(['use' num2str(length(nonzeros(dat)))]);
                figure(cdx2bins), plot(dat,'-*','color',C{cdx2bins});hold on         % here plot the traces that met the condition
                
                binneddata(cdx2bins).traces{colSZ}(:,q+size(dat,2)-1) = dat;                      % here store the traces which meat condition
                binneddata(cdx2bins).cdx2{colSZ}(:,q+size(dat,2)-1) = datatogether(k).fixedData(:,3)/datatogether(k).fixedData(:,1);
                binneddata(cdx2bins).finsign{colSZ}(:,q+size(dat,2)-1) = mean(nonzeros(dat((end-N):end)));
            end
            
        end
        q = q+size(dat,2);
        
    end
    
end
%% plot binned data
tpt = 100;
meantraj = zeros(tpt,2);
cdx2bins = 2;
C = {'r','c','m'};
ucol = 2;  
% clean the data
exclude = [100 800];
for k=1:cdx2bins
    for h=1:ucol
        for ii=1:size(binneddata(k).traces{h},2)
        for j=1:size(binneddata(k).traces{h},1)
                if binneddata(k).traces{h}(j,ii) < exclude(1) || binneddata(k).traces{h}(j,ii) > exclude(2);   % mean over nonzero values of signaling at each time point
                binneddata(k).traces{h}(j,ii) =0;
                end
        end
        end
       
    end
    
end
% average the data
for k=1:cdx2bins
    for h=1:ucol
        for j=1:size(binneddata(k).traces{h},1)
            meantraj(j,h) = mean(nonzeros(binneddata(k).traces{h}(j,:)));   % mean over nonzero values of signaling at each time point
            err(j,h) = std(nonzeros(binneddata(k).traces{h}(j,:)));
        end
    end
    Cdx2{k} = meantraj;
end
% plot means
for h=1:ucol
for k=1:cdx2bins
    
    figure(h), plot(Cdx2{k}(:,h),'.-','color',C{k},'markersize',16);hold on
    ylim([200 800])
end
end
% plot cdx2 values vs final signaling
yy = (0:0.5:2);
xx = 350*ones(size(yy));
xx1 = (0:100:800);
yy1 = ones(size(xx1));
for h=1:ucol
    for k=1:cdx2bins
        figure(h+2), plot(nonzeros(binneddata(k).finsign{h}),nonzeros(binneddata(k).cdx2{h}),'*','color',C{k},'Markersize',16);hold on
        ylim([0 2])
        xlim([0 800])
        
    end
    end
hold on,figure(3), plot(xx,yy,'k-')
hold on,figure(3), plot(xx1,yy1,'k-')

hold on,figure(4), plot(xx,yy,'k-')
hold on,figure(4), plot(xx1,yy1,'k-')


%histograms in cdx2 and signaling

xbins1 = (exclude(1):100:exclude(2));
xbins2 = (0:0.2:1.5);

for h=1%:ucol
    for k=1:cdx2bins
        figure(h+4), histogram(nonzeros(binneddata(k).finsign{h}),xbins1,'Normalization','pdf','FaceColor',C{k});
        ylim([0 10])
        xlim([exclude(1) exclude(2)]);title('Signaling');
        figure(h+6), histogram(nonzeros(binneddata(k).cdx2{h}),xbins2,'Normalization','pdf','FaceColor',C{k});
        
        ylim([0 10])
        xlim([0 2]);title('Cdx2');
        
    end
end






