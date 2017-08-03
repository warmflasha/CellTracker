function runTileMM_usemultipleChansforSeg_2(files,outfile,posRange,bIms,nIms,paramfile)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

%nImages=length(files.chan)-1;
nImages=length(files.chan)-1;% AN
xmax = max(files.pos_x)+1;
ymax = max(files.pos_y)+1;

for ii=posRange(1):posRange(2)
    disp(['Running image ' int2str(ii)]);
    try
        %read the files
        %read nuclear image, smooth and background subtract
        nuc_chan = 1;                                        % AN
        [x, y]=ind2sub([xmax ymax],ii);
        f1nm = mkMMfilename(files,x-1,y-1,[],[],nuc_chan);
        
        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm{1};
        nuc=imread(f1nm{1});
        si=size(nuc);
        %apply gaussian smoothing
        nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
        %subtract precalculated background Image
        nuc=imsubtract(nuc,bIms{nuc_chan});
        nuc=immultiply(im2double(nuc),nIms{nuc_chan});        % AN
        nuc=uint16(65536*nuc);
        
        
        fimg=zeros(si(1),si(2),nImages);
        for jj=2:(nImages+1) % AN   was bf:  jj=2:(nImages+1)
            f1nm = mkMMfilename(files,x-1,y-1,[],[],jj);
            fimgnow=imread(f1nm{1});
            fimgnow = smoothImage(fimgnow,userParam.gaussRadius,userParam.gaussSigma);
            imgfiles(ii).smadfile{jj-1}=f1nm{1};%   AN imgfiles(ii).smadfile{jj-1}
            fimgnow=imsubtract(fimgnow,bIms{jj});
            fimgnow=immultiply(im2double(fimgnow),nIms{jj});
            fimg(:,:,jj-1)=uint16(65536*fimgnow);% AN fimg(:,:,jj-1)
        end
        
        
        
        %Initialize error string
        userParam.errorStr=sprintf('Position %d\n',ii);
        [~,maskCnew,statsout]= makeMaskswith2chans_nooverlap(files,ii,bIms,nIms,paramfile,0); % AN makeMaskswithmultiplechanelsMM
        
        
       % [maskC, statsN]=segmentCells2(nuc,fimg);%no need to segment, the masks are already made
        [~, statsN]=addCellAvr2Stats(maskCnew,fimg,statsN);% here the masks are applied to all the other chanels
        
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
end


