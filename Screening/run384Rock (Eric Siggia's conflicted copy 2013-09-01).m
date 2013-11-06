function run384Rock(indir,outfile,paramfile,wellnames)

global userParam;
try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

if ~exist('wellnames','var')
    wellnames=mkWellNames;
end

displayon = 1;
%%
%wellnames = {'B02','B12','B24'};
%posnames={'f00','f01','f02','f03','f04','f05'};
%posnames={'s1','s2','s3','s4','s5','s6'};
posnames={'s1','s2','s3','s4'};

wavenames={'w1','w2'};
outdatall=cell(length(wellnames),1);
for ii = 1:length(wellnames)
    outdatall{ii}=[];
    for jj=1:length(posnames)
        try
            %read in the files
            f1nm=dir([indir filesep '*' wellnames{ii} '_' posnames{jj} '_' wavenames{1} '*.TIF']);
            if isempty(findstr(f1nm(1).name,'thumb'))
                f1nm=[indir filesep f1nm(1).name];
            else
                f1nm=[indir filesep f1nm(2).name];
            end
            nuc=imread(f1nm);
            f1nm=dir([indir filesep '*' wellnames{ii} '_' posnames{jj} '_' wavenames{2} '*.TIF']); 
            if isempty(findstr(f1nm(1).name,'thumb'))
                f1nm=[indir filesep f1nm(1).name];
            else
                f1nm=[indir filesep f1nm(2).name];
            end
            fimg=imread(f1nm);
            
             nuc =presubBackground_self(nuc);
            
            [maskC statsN]=segmentCells(nuc,fimg);
            [tmp statsN]=addCellAvr2Stats(maskC,fimg,statsN);
            if ~isempty(statsN)
                outdat=outputData4AWTracker(statsN,nuc,1);
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
        catch err
            disp('Error with image. Continuing...');
            rethrow(err);
            continue;
        end
    end
    disp(['Directory: ' indir ' completed well ' wellnames(ii)]);
    save(outfile,'outdatall','userParam');
end