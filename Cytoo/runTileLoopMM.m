function runTileLoopMM(files,imgsperprocessor,nloop,maxims,bIms,nIms,paramfile)

%s=matlabpool('size');
% if s > 0
%     matlabpool close;
% end
% matlabpool('local',nloop);
parpool(nloop);
parfor ii=1:nloop
    n1=(ii-1)*imgsperprocessor+1;
    n2=min(ii*imgsperprocessor,maxims);
    outfile=[files.direc filesep 'out_' int2str(n1) '.mat'];
    runTileMM(files,outfile,[n1 n2],bIms,nIms,paramfile);
    %runTileMM_usemultipleChansforSeg(files,outfile,[n1 n2],bIms,nIms,paramfile); % AN special function to get the nuclear masks from the combination of channels
end
delete(gcp);