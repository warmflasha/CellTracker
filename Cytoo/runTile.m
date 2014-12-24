function runTile(indir,outfile,channames,posRange,bIms,nIms,paramfile)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

nImages=length(channames)-1;

for ii=1:length(channames)
    [~, ff{ii}]=folderFilesFromKeyword(indir,channames{ii});
end

for ii=posRange(1):posRange(2)
    disp(['Running image ' int2str(ii)]);
    %read the files
    try
        
        %read nuclear image, smooth and background subtract
        f1nm=[indir filesep ff{1}(ii).name];
        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm;
        nuc=imread(f1nm);
        imgfiles(ii).nucfile=f1nm;
        si=size(nuc);
        %apply gaussian smoothing
        nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
        %subtract precalculated background Image
        nuc=imsubtract(nuc,bIms{1});
        nuc=immultiply(im2double(nuc),nIms{1});
        nuc=uint16(65536*nuc);
        
        
        fimg=zeros(si(1),si(2),nImages);
        for jj=2:(nImages+1)
            f1nm=[indir filesep ff{jj}(ii).name];
            fimgnow=imread(f1nm);
            fimgnow = smoothImage(fimgnow,userParam.gaussRadius,userParam.gaussSigma);
            imgfiles(ii).smadfile{jj-1}=f1nm;
            fimgnow=imsubtract(fimgnow,bIms{jj});
            fimgnow=immultiply(im2double(fimgnow),nIms{jj});
            fimg(:,:,jj-1)=uint16(65536*fimgnow);
        end
        

        
        %Initialize error string
        userParam.errorStr=sprintf('Position %d\n',ii);
        
        [maskC, statsN]=segmentCells2(nuc,fimg);
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