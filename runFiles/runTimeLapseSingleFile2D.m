function [peaks, stats] = runTimeLapseSingleFile2D(imgfile,chans,maskfile,paramfile,framestoUse)

eval(paramfile);

reader = bfGetReader(imgfile);
masks = readIlastikFile(maskfile, 0);



nT = reader.getSizeT;

if ~exist('framestoUse','var')
    framestoUse = 1:nT;
end

for ii = framestoUse
    try 
    disp(['Processing frame ' int2str(ii)]);
    iplane = reader.getIndex(0, chans(1)-1, ii - 1) + 1;
    nuc = bfGetPlane(reader,iplane);
    nc = length(chans);
    fimg = zeros(size(nuc,1),size(nuc,2),nc-1);
    for jj = 2:nc
        iplane = reader.getIndex(0, chans(jj)-1, ii - 1) + 1;
        fimg(:,:,jj-1) = bfGetPlane(reader,iplane);
    end
    [peaks{ii}, ~, stats{ii}] = image2peaks(nuc,fimg,masks(:,:,ii));
    catch
        peaks{ii}=[];
        stats{ii}=[];
    end
end