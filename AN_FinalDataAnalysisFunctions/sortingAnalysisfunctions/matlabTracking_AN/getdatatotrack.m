function [nmask,datatomatch] = getdatatotrack(direc1,pos,chan,arealow,ifile,thresh,ilastikprob)

ff1 = readAndorDirectory(direc1);
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),2,0,chan);
disp(['opened ' nucmoviefile ])
nmask = readIlastikFile(ifile);
if ilastikprob == 1
nmask = readIlastikProbMask(ifile,thresh);
end
nmask = cleanIlastikMasks(nmask,arealow);% area filter last argument
datatomatch = struct;
statstmp = [];
for k=1:size(nmask,3) % only imported 80 tpts for this dataset(since sorting is done at that time point)
%tmpmask = imerode(nmask(:,:,k),strel('disk',erodepxl));% erode such that avoid merged objects, more reliable tracking 
statstmp = regionprops(nmask(:,:,k),'Area','Centroid','PixelIdxList');
datatomatch(k).stats = statstmp;
datatomatch(k).img = nmask(:,:,k);%nmask(:,:,k);
%datatomatch(k).img_eroded = tmpmask;

end
end