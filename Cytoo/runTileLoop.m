function runTileLoop(direc,chans,imgsperprocessor,nloop,maxims,bIms,nIms,paramfile)

s=matlabpool('size');
if s > 0
    matlabpool close;
end
matlabpool('local',nloop);
parfor ii=1:nloop
    n1=(ii-1)*imgsperprocessor+1;
    n2=min(ii*imgsperprocessor,maxims);
    outfile=[direc filesep 'out_' int2str(n1) '.mat'];
    runTile(direc,outfile,chans,[n1 n2],bIms,nIms,paramfile);
end
matlabpool close;