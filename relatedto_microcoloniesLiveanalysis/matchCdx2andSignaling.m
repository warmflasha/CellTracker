%% get the centroids of the live data plotted on the montage 
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/registeredDAPI.mat','colfixall','xyall','fluordata'); %load the data with coordinates of the fixed colonies (centroid of the colony)
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/alignWithDapi.mat');              % load acoords which matched live and fixed data after reimaging with dapi 
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/tformwithDAPI.mat');
% from spice
% load('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/registeredDAPI.mat','colfixall','xyall','fluordata');
% load('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/alignWithDapi.mat'); 
% load('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/tformwithDAPI.mat');
%dirlive = ('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-10-29-LIVECELLanalysis/2016-10-17-new_outfiles_tiling1');

dirlive = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/2016-10-17-projections/2016-11-02-improvedSegmTiling');%new_outfiles_tiling1anBG new_outfiles_tiling1
t = imread('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/testwithDAPI.tif');
%t = imread('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/testwithDAPI.tif');

figure(1), imshow(t(:,:,1),[0 5e3]); hold on;

mytform = fitgeotrans(movingPoints, fixedPoints, 'affine');
toTranslate = [-250,50];    
midpoint = floor(size(t)/2);
rotmat = mytform.T(1:2,1:2);

colormap = prism;
positions = (0:39);
strdir = '_outTiling1BGan2.mat';% _out tile1BGan 
last = 100;             % which time point in live dataset to check before matching

q = 1;

for k=1:size(positions,2)
    outfile = [ dirlive '/' num2str(k-1) strdir ];
    load(outfile,'colonies')
    if ~isempty(colonies)
        for j=1:size(colonies,2)
            posnow = [];
            for h=2:size(colonies(j).cells,2)                               % start from second, since the first one is empty , as returned by the new analysis
                if colonies(j).cells(h).onframes(end) == (last)
                                %figure(q); hold on;
                    posnow = [posnow; colonies(j).cells(h).position(end,:)];
                end
            end
            if ~isempty(posnow)
            datatogether(q).colony = colonies(j);
            posnow = bsxfun(@plus,posnow,acdapi(k).absinds([2 1]));
            posnow = bsxfun(@minus,posnow,mean(xyall));
            posnow = posnow*rotmat;
            posnow = bsxfun(@plus,posnow,midpoint([2 1])+toTranslate);
            
            colnow_center = mean(posnow,1);
            dists = bsxfun(@minus,colfixall,colnow_center);
            dists = sqrt(sum(dists.*dists,2));
            [~, ind]=min(dists);
            datatogether(q).fixedData = fluordata(ind,:);
            %disp(outfile);
            datatogether(q).outfiles = outfile; % save the outfile that was matched
            figure(1), hold on
            plot(colnow_center(1),colnow_center(2),'.','color',colormap(j+10,:,:),'markersize',10);%
            plot(colfixall(ind,1),colfixall(ind,2),'*','color',colormap(j+10,:,:),'markersize',10);%
            q= q + 1;
            end
        end
        
    end
    
end

%save('registeredDAPInewTraces_ANbg','datatogether');

