function run384(indir,outfile,paramfile,wellnames)

global userParam;
try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

if ~exist('wellnames','var')
    wellnames=mkWellNames;
end

displayon = 0;
%%
%wellnames = {'B02','B12','B24'};
posnames={'f00','f01','f02','f03','f04','f05'};
wavenames={'d0','d1'};
outdatall=cell(length(wellnames),1);
for ii = 1:length(wellnames)
    outdatall{ii}=[];
    for jj=1:length(posnames)
        try
            %read in the files
            f1nm=dir([indir filesep '*' wellnames{ii} posnames{jj} wavenames{1} '.TIF']);
            f1nm=[indir filesep f1nm(1).name];
            nuc=imread(f1nm);
            f1nm=dir([indir filesep '*' wellnames{ii} posnames{jj} wavenames{2} '.TIF']);
            f1nm=[indir filesep f1nm(1).name];
            fimg=imread(f1nm);
            
             nuc =presubBackground_self(nuc);
            
            [maskC statsN]=segmentCellsAW(nuc,fimg);
            [tmp statsN]=addCellAvr2StatsAW(maskC,fimg,statsN);
            if ~isempty(statsN)
                outdat=outputData4AWTracker(statsN,nuc);
                if displayon
                lim1=stretchlim(nuc,[0.05 0.99]);
                lim2=stretchlim(fimg,[0.05 0.99]);
                nuc = imadjust(nuc,lim1);
                fimg=imadjust(fimg,lim2);
                im2disp=cat(3,nuc,zeros(size(nuc)),zeros(size(nuc)));
                clf; imshow(im2disp,[]); hold on;
                plot(outdat(:,1),outdat(:,2),'c.'); drawnow;
                end
                outdatall{ii}=[outdatall{ii}; outdat];
            end
        catch
            disp('Error with image. Continuing...');
            continue;
        end
    end
    disp(['Directory: ' indir ' completed well ' wellnames(ii)]);
    save(outfile,'outdatall','userParam');
end