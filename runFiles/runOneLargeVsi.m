function [outdat, statsAll]=runOneLargeVsi(vsifile,paramfile,chans)

global userParam;
eval(paramfile);
userParam.errorStr = [];

reader = bfGetReader(vsifile);

xmax = reader.getSizeX;
ymax = reader.getSizeY;

xmid = floor(xmax/2);
ymid = floor(ymax/2);

tilexstart = [1 1 xmid xmid];
tileystart = [1 ymid 1 ymid];
tilewidth =[xmid-1 xmid-1 xmax-xmid+1 xmax-xmid+1];
tileheight = [ymid-1 ymax-ymid+1 ymid-1 ymax-ymid+1];
statsAll =[];
for ii = 1:4
    disp(['Reading image, chunk #' int2str(ii)]);
    tic;
    img_bf = bfopen_mod(vsifile,tilexstart(ii),tileystart(ii),tilewidth(ii),tileheight(ii),1);
    toc;
    nuc = img_bf{1}{chans(1),1};
    for jj = 2:numel(chans)
        fimg(:,:,jj-1)=img_bf{1}{chans(jj),1};
    end
    clear img_bf;
    disp('Preprocessing...'); tic;
    [nuc, fimg] = preprocessImages(nuc,fimg);
    toc;
    
    tic; disp('Segmenting...');
    maskN=localMaxPlusWatershed(nuc);
    statsN=ilastik2stats2D(maskN,cat(3,nuc,fimg));
    for jj  = 1:numel(statsN)
        statsN(jj).Centroid = statsN(jj).Centroid+[tilexstart(ii)-1 tileystart(ii)-1];
    end
    statsAll = [statsAll; statsN];
    toc;
    clear fimg;
end


outdat = [cat(1,statsAll.Centroid), cat(1,statsAll.MeanIntensity)];


