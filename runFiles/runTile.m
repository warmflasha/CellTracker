function runTile(indir,outfile,channames,posRange,bIms,nIms,paramfile)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

nImages=length(channames)-1;

for ii=posRange(1):posRange(2)
    disp(['Running image ' int2str(ii)]);
    %read the files
    try
        f1nm=dir([indir filesep '*' channames{1} '*' 's' int2str(ii) '_t1.TIF']);
        f1nm=[indir filesep f1nm(1).name];
        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm;
        nuc=imread(f1nm);
        si=size(nuc);
        fimg=zeros(si(1),si(2),nImages);
        for jj=2:(nImages+1)
            f1nm=dir([indir filesep '*' channames{jj} '*' 's' int2str(ii) '_t1.TIF']);
            f1nm=[indir filesep f1nm(1).name];
            fimgnow=imread(f1nm);
            imgfiles(ii).smadfile{jj-1}=f1nm;
            fimgnow=imsubtract(fimgnow,bIms{jj});
            fimgnow=immultiply(im2double(fimgnow),nIms{jj});
            fimg(:,:,jj-1)=uint16(65536*fimgnow);
        end
        
        %subtract precalculated background Image
        nuc=imsubtract(nuc,bIms{1});
        nuc=immultiply(im2double(nuc),nIms{1});
        nuc=uint16(65536*nuc);
        
        %Initialize error string
        userParam.errorStr=sprintf('Position %d\n',ii);
        
        [maskC statsN]=segmentCells(nuc,fimg);
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        
        if ~isempty(statsN)
            outdat=outputData4AWTracker(statsN,nuc,nImages);
            peaks{ii}=outdat;
            imgfiles(ii).errorStr=userParam.errorStr;
            % compress and save the binary mask for nuclei
            imgfiles(ii).compressNucMask = compressBinaryImg([statsN.PixelIdxList], size(nuc) );
            save(outfile,'peaks','userParam','imgfiles');
        end
        
    catch err       
        disp(['Error with image ' int2str(ii)]);
        disp(err.identifier);
        %rethrow(err);
    end
end