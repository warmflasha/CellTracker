function runFullTileMM(direc,outfile,paramfile,step)
%runFullTileMM(direc,outfile,maxims,step)
%---------------------
% For a set of tiled images, runs segmentCells (uses parfor for this), runs
% alignment program for images, 
% Inputs:
%   direc -- image directory, must be in format of micromanager tiling output
%   outfile -- matfile for output
%   paramfile - parameter file to use
%   step = step to begin at. See code. allows for skipping finding cells etc.
% outputs in matfile:
%   peaks -- cell by cellslist by image 
%   plate1 -- plate data structure

if ~exist('step','var')
    step=1;
end


%  if ~isfield('userParam','coltype')
%      userParam.coltype = 1;
%  end

ff=readMMdirectory(direc);
dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
wavenames=ff.chan;

maxims= dims(1)*dims(2);
%nloop=12;
nloop = 4;
imgsperprocessor=ceil(maxims/nloop);

%generate background image for each channel
if step < 2
    for ii=1:length(wavenames)
        [minI, meanI]=mkBackgroundImageMM(ff,ii,min(500,maxims));
        bIms{ii}=uint16(2^16*minI);
        nIms{ii}=ones(size(bIms{ii}));
%         normIm=(meanI-minI);
%         normIm=normIm.^-1;
%         normIm=normIm/min(min(normIm));
%         nIms{ii}=normIm;
    end
    save([direc filesep outfile],'bIms','nIms','dims');
end
%runTileLoop--runs segmentCells in parfor loop,
%send imgsperprocessor to each, nloop = total number necessary
%Assemble Mat Files--puts together matfiles, all data stored as peaks in
%outfile
if step < 3
    load([direc filesep outfile],'bIms','nIms');
    runTileLoopMM(ff,imgsperprocessor,nloop,maxims,bIms,nIms,paramfile);
end

%performs a series of pairwise alignments,
%each img is aligned img on top and to the left, pixel overlap
%stored in accords, can also return fully aligned image, but not
%recommended for large numbers of files.
if step < 4
    % here add the condition that if acoords already exists (as should be
    % saved from when you split the .tif huge file from Olympus) then just save the
    % existing acoords
    if exist('acoords','var')
        save([direc filesep outfile],'acoords','-append');
    end
    acoords=alignManyPanelsMM(ff,1:200,maxims);
    save([direc filesep outfile],'acoords','-append');
end


if step < 5
     assembleMatFiles(direc,imgsperprocessor,nloop,outfile);
end
%peaksToColonies generates the colony structure from peaks and accords
%computes alpha volume and then finds all connected components / OR groups
%the cells based on their proximoty to each other (single cell data) into
%colonies
if step < 6
    
    
    load([direc filesep outfile],'bIms','nIms');
    
    
    [colonies, peaks]=peaksToColonies([direc filesep outfile]);
    %elseif coltype == 0
       % [colonies, peaks]=peaksToColonies([direc filesep outfile]);
%     else
%         disp('Error: coltype must be 1 or 0');
%     end
    plate1=plate(colonies,dims,direc,ff.chan,bIms,nIms, outfile);

    plate1.mm = 1;
    plate1.si = size(bIms{1});
    save([direc filesep outfile],'plate1','peaks','-append');  
    
end


    


