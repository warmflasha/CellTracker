function [outdat, tt]=runOneMultiLayerImage(lsmfile,chan,paramfile)
% [outdat, tt]=runOneMultiLayerImage(lsmfile,chan)
% ---------------------------------------------------------
% run segmentation of one multilayered tiff file
% Inputs:
% lsmfile - multilayer file (anything readable by bioformats, assumed
% single timepoint and z-slice, multiple z channels)
% chan- a list of the channels, first is the channel to be segmented, then
% each channel to be quantified. first channel is '1'
% Outputs:
% outdat - segmentation output in the usual format, one row per cell
% tt - output of opening lsmfile with bfopen. 

global userParam;
eval(paramfile);

tt=bfopen(lsmfile);

nuc=tt{1}{chan(1),1};

nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
for ii=2:length(chan)
    fimg(:,:,ii-1)=tt{1}{chan(ii),1};
end


[maskC, statsN]=segmentCells2(nuc,fimg);
[~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
outdat=outputData4AWTracker(statsN,nuc,length(chan)-1)