function fixPlate(matfile,indir)
global userParam;

load(matfile);

badones = find(cellfun(@isempty,outdatall));
nbad = length(badones);

wn=mkWellNames;
wellnames = wn(badones);
posnames={'f00','f01','f02','f03','f04','f05'};
wavenames={'d0','d1'};

displayon = 1;
for ii=1:nbad
    
    for jj=1:length(posnames)
       % try
            %read in the files
            f1nm=dir([indir filesep '*' wellnames{ii} posnames{jj} wavenames{1} '.TIF']);
            f1nm=[indir filesep f1nm(1).name];
            nuc=imread(f1nm);
            f1nm=dir([indir filesep '*' wellnames{ii} posnames{jj} wavenames{2} '.TIF']);
            f1nm=[indir filesep f1nm(1).name];
            fimg=imread(f1nm);
            
            nuc =presubBackground_self(nuc);
            errmsg = 'Before segment cells';
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
                outdatall{badones(ii)}=[outdatall{badones(ii)}; outdat];
            end
%         catch
%             disp('Error with image. Continuing...');
%             continue;
%         end
    end
    disp(['Directory: ' indir ' completed well ' wellnames(ii)]);
    save(matfile,'outdatall','userParam');
end