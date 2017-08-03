load('colCenterFixed.mat');
load('align.mat');

colormap = prism;
dirlive = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/FinalOutfiles_completeTraces');
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/align.mat');
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/tform.mat');
load('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/peaksnewBF.mat');

colormap = prism;
t = imread('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/test4mid.tif');
figure(1); imshow(t(:,:,1),[100 3000]);
mytform = fitgeotrans(movingPoints, fixedPoints, 'affine');
toTranslate = [934-815, 1660-1330];%empirically determined from image
%toTranslate2 = 4*toTranslate-[377 424]; %correction empirically determined. [200 300]
toTranslate2 = [-140, 40];
midpoint = floor(size(t)/2);
rotmat = mytform.T(1:2,1:2);
colormap = prism;
positions = (0:39);
strdir = '_40X_imprBGandSegm.mat';
N = 0;
l = 100;
%%
q = 1;

for k=1:size(positions,2)
    outfile = [ dirlive '/' num2str(k-1) strdir ];
    load(outfile,'colonies')
    if ~isempty(colonies)
        for j=1:size(colonies,2)
            posnow = [];
            for h=1:size(colonies(j).cells,2)
                if colonies(j).cells(h).onframes(end) == (100)
                                %figure(q); hold on;
                    posnow = [posnow; colonies(j).cells(h).position(end,:)];
                end
            end
            if ~isempty(posnow)
            datatogether(q).colony = colonies(j);
            posnow = bsxfun(@plus,posnow,ac(k).absinds([2 1]));
            posnow = bsxfun(@minus,posnow,mean(xyall));
            posnow = posnow*rotmat;
            posnow = bsxfun(@plus,posnow,midpoint([2 1])+toTranslate2);
            
            colnow_center = mean(posnow,1);
            dists = bsxfun(@minus,colfixall,colnow_center);
            dists = sqrt(sum(dists.*dists,2));
            [~, ind]=min(dists);
            datatogether(q).fixedData = fluordata(ind,:);
            figure(1), hold on
            plot(colnow_center(1),colnow_center(2),'.','color',colormap(j+10,:,:),'markersize',10);%
            plot(colfixall(ind,1),colfixall(ind,2),'.','color',colormap(j+10,:,:),'markersize',10);%
            q= q + 1;
            end
        end
        
    end
    
end
save('fixedandLivematched','datatogether');
%% plot traces with fixed data
load('fixedandLivematched.mat');
positions = (0:39);
last = 100;
trajmin = 60;
findata1 = [];
findata2 = [];
fr_stim = 16;
traces = [];
colormap = customap;%prism;
cdx2tosmad4 = [];

for k=1:size(datatogether,2)   %  loop over colonies
    colSZ = datatogether(k).colony.numOfCells(fr_stim);
    if colSZ>0
        traces{k} = datatogether(k).colony.NucSmadRatio;%colonies(j).NucSmadRatio(:)
        traces{k}((traces{k} == 0)) = nan;
        
        for h = 1:size(traces{k},2)
            if length(traces{k}(isnan(traces{k}(:,h))==0))>trajmin
                figure(colSZ), plot(traces{k}(:,h),'-*','color',colormap(k,:,:));hold on
                
            end
            
        end
        
        text(datatogether(k).colony.cells(h).onframes(end),traces{k}(end,h),num2str(datatogether(k).fixedData(:,3)/datatogether(k).fixedData(:,2)),'color','b','fontsize',11);%['mean ColCdx2 ' num2str(colonies2(j).cells(h).fluorData(1,end))]
        
        figure(colSZ), hold on
        cdx2tosmad4 = [cdx2tosmad4; datatogether(k).fixedData(:,3)/datatogether(k).fixedData(:,2)];
%         text(datatogether(k).colony.cells(h).onframes(end)-0.5,traces{k}(end,h)-0.5,num2str(colSZ),'color','m','fontsize',7);%['mean ColCdx2 ' num2str(colonies2(j).cells(h).fluorData(1,end))]
%         figure(colSZ), hold on
    
    ylim([0 2.5]);
    xlim([0 115])
    ylabel('mean Nuc/Cyto smad4  ');
    xlabel('frames');
%     findata1 = [findata1 ; datatogether(k).fixedData(1,3)/datatogether(k).fixedData(1,2)];
%     findata2 = [findata2; colSZ];
    end
end

findat = cat(2,findata1,findata2);


%% colorcode the traces by the Cdx2 value and put all of them on the same
% plot
% make a custom colormap from Cdx2 values

customap = zeros(size(cdx2tosmad4,1),3); % rgb
a = max(cdx2tosmad4);% max cdx2 value
binSZ = a/3 ;
binSZ = [a/3 1.9];
for k=1:size(cdx2tosmad4,1)
    if cdx2tosmad4(k)<binSZ(1)
        
        customap(k,3)= 1;
    else if (binSZ(1)<=cdx2tosmad4(k)) && (cdx2tosmad4(k)<=binSZ(2))
            customap(k,2)= 1;
        else if cdx2tosmad4(k)>binSZ(2)
                customap(k,1)= 1;
            end
        end
    end
end


