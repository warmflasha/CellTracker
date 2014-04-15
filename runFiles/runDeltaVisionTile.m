function runDeltaVisionTile(direc,outfile,paramfile,step,tiffs,prefix)
%runDeltaVisionTile(direc,outfile,paramfile,step,tiffs,prefix)
%---------------------
%Version of runFullTile for DeltaVision (.dv) files
%Requries MATLAB Bio-Formats files
%Run from directory containing .dv.log file
%For a set of tiled images, runs segmentCells (uses parfor for this), runs
%alignment program for images, outputs in matfile -- peaks -- cell by cells
%list by image, colonies -- colonies data structure
%direc -- image directory 
%prefix -- prefix for TIFF images
%outfile -- matfile for output
%step = step to begin at. See code. allows for skipping finding cells etc.
%tiffs = 1 (0) means extract tiff images and save to direc (0 to skip,
%default = 1)

if ~exist('tiffs','var')
    tiffs = 1;
end

if ~exist('step','var')
    step=1;
end

if ~exist('paramfile','var')
    paramfile='setUserParamSC20xIFEDS';
end

reader=bfGetReader('path/to/data/file');
omeMeta=reader.getMetadataStore();
numChans=omeMeta.getChannelCount(0);
[dims, wavenames]=getDimsFromLogFile('.');

for ii = 1:numChans
    chanstemp{ii}=['w' char(omeMeta.getChannelEmissionWavelength(0,ii-1))];
end

if tiffs == 1
    dvToTiffs(direc,prefix,chanstemp,reader,dims)
end

chans=orderchans(chanstemp,wavenames);

ff=folderFilesFromKeyword(direc,chans{1});
maxims=ff(end-1);

nloop=12;
imgsperprocessor=ceil(maxims/12);
%generate background image for each channel
if step < 2
    for ii=1:length(chans)
        [minI meanI]=mkBackgroundImage(direc,chans{ii},min(500,maxims));
        bIms{ii}=uint16(2^16*minI);
        normIm=(meanI-minI);
        normIm=normIm.^-1;
        normIm=normIm/min(min(normIm));
        nIms{ii}=normIm;
    end
    
    si=size(bIms{1});
    save([direc filesep outfile],'bIms','nIms','dims','si');
end
%runTileLoop--runs segmentCells in parfor loop,
%send imgsperprocessor to each, nloop = total number necessary
%Assemble Mat Files--puts together matfiles, all data stored as peaks in
%outfile
if step < 3
    load([direc filesep outfile],'bIms','nIms');
    runTileLoop(direc,chans,imgsperprocessor,nloop,maxims,bIms,nIms,paramfile);
end

%performs a series of pairwise alignments,
%each img is aligned img on top and to the left, pixel overlap
%stored in accords, can also return fully aligned image, but not
%recommended for large numbers of files.
if step < 4
    [acoords]=alignManyPanels(direc,chans{1},1,4,dims,85:150,maxims);
    save([direc filesep outfile],'acoords','-append');
end

if step < 5
    assembleMatFiles(direc,imgsperprocessor,nloop,outfile);
end
%peaksToColonies generates the colony structure from peaks and accords
%computes alpha volume and then finds all connected components.
if step < 6
    load([direc filesep outfile],'bIms','nIms');
    [colonies, peaks]=peaksToColonies([direc filesep outfile]);
    plate1=plate(colonies,dims,direc,chans,bIms,nIms);
    save([direc filesep outfile],'plate1','peaks','-append');
end

function chans=orderchans(chanstemp,wavenames,nucname)

if ~exist('nucname','var')
    nucname='DAPI';
end

kk=strfind(wavenames,nucname);
ii=~cellfun(@isempty,kk);
nuc_ind=find(ii);

allchans=1:length(wavenames);
nonnucchans=setdiff(allchans,nuc_ind);
chans{1}=chanstemp{nuc_ind};
for jj=1:length(nonnucchans)
    chans{jj+1}=chanstemp{nonnucchans(jj)};
end

function dvToTiffs(direc,prefix,chans,reader,dims)

if ~exist(direc,'file')
    mkdir(direc);
end

for kk=1:length(chans)
    for ii=1:dims(1)
        for jj=1:dims(2)
            if ~mod(ii,2) %even
                oldnum=(ii-1)*dims(2)+dims(2)-jj+1;
            else
                oldnum=(ii-1)*dims(2)+jj;
            end
            
            newnum=(jj-1)*dims(1)+ii;
            
            reader.setSeries(oldnum-1);
            
            series_plane = bfGetPlane(reader, kk);
            
            %t1=imread(fnames(rr==oldnum).name);
            newname= [direc filesep prefix '_' chans{kk} '_s' int2str(newnum) '_t1.TIF'];
            imwrite(series_plane,newname);
        end
    end
end
