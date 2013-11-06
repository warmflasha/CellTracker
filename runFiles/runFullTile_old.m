function runFullTile(direc,outfile,chans,imgsperprocessor,dims,si,maxims,step)
%For a set of tiled images, runs segmentCells (uses parfor for this), runs
%alignment program for images, outputs in matfile -- peaks -- cell by cells
%list by image, colonies -- colonies data structure
%direc -- image directory
%outfile -- matfile for output
%chans -- channel keywords, nuc chan first followed by any number to quantitfy
%imgsperprocessor -- number of images to send to each processor
%dims -- tile dimensions
%si -- image size

peaks=1;
if ~exist('step','var')
    step=1;
end
if ~exist('maxims','var')
    maxims=dims(1)*dims(2);
end

nloop=ceil(maxims/imgsperprocessor);

%runTileLoop--runs segmentCells in parfor loop,
%send imgsperprocessor to each, nloop = total number necessary
if step < 2
    for ii=1:length(chans)
        bIms{ii}=mkBackgroundImage(direc,chans{ii},min(500,maxims));
    end 
    runTileLoop(direc,chans,imgsperprocessor,nloop,maxims,bIms);
end
%Assemble Mat Files--puts together matfiles, all data stored as peaks in
%outfile
if step < 3
    assembleMatFiles(direc,imgsperprocessor,nloop,outfile);
end
%performs a series of pairwise alignments,
%each img is aligned img on top and to the left, pixel overlap
%stored in accords, can also return fully aligned image, but not recommend
%for large numbers of files.
if step < 4
    [acoords]=alignManyPanels2(direc,chans{1},1,4,dims,85:125,maxims);
    save([direc filesep outfile],'acoords','-append');
end
%assembleTiledData--assigns a colony number to each cell,
%uses accords to align pieces of the same colony. makes consistent
%coordinates within each colony
if step < 5
    load([direc filesep outfile],'peaksall','acoords');
    peaks=assembleTiledData(peaksall,acoords,dims,si,maxims,0);
    save([direc filesep outfile],'peaks','-append');  
end
%getColonyData -- mk colony structure array
if step < 6
    load([direc filesep outfile],'peaks','acoords');
    colonies=getColonyData(peaks,acoords,dims,si);
    
    %analyzeColonies, add some analysis to colony structure
    colonies=analyzeColonies(colonies);
    save([direc filesep outfile],'colonies','-append')
end
