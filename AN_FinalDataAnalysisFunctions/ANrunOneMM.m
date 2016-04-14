% If flag == 0, then the images to be read were taken manually and contain
% only one coordinate for the index ( Pos0,Pos1...etc). then different
% function is used to read the MM directory (readMMdirectoryOneCoord) and
% make MM filename (mkMMfilenameOneCoord)
% if flag == 1,then the images to be read in conten double indexing, as MM
% assigns: prefix-Pos_00x_00y. then the usual functions are used:
% 'readMMdirectory' and 'mkMMfilename'

function [data,nuc]= ANrunOneMM(direc,posRange,bIms,nIms,paramfile,nucname,flag)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

if flag == 1
ff = readMMdirectory(direc,nucname);
dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
nImages=length(ff.chan)-1;
xmax = max(ff.pos_x)+1;
ymax = max(ff.pos_y)+1;

  ii=posRange; 
 
    disp(['Running image ' int2str(ii-1)]);
    %read the files
    try
        
        %read nuclear image, smooth and background subtract
        
        [x, y]=ind2sub([xmax ymax],ii);
        f1nm = mkMMfilename(ff,x-1,y-1,[],[],1);%posNumberX

        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm{1};
        nuc=imread(f1nm{1});
        si=size(nuc);
        
        %apply gaussian smoothing
        nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
        %subtract precalculated background Image
        nuc=imsubtract(nuc,bIms{1});
        nuc=immultiply(im2double(nuc),nIms{1});
        nuc=uint16(65536*nuc);
        
        
        fimg=zeros(si(1),si(2),1);
        for jj=2:(1+1)
            f1nm = mkMMfilename(ff,x-1,y-1,[],[],jj);
            fimgnow=imread(f1nm{1});
            fimgnow = smoothImage(fimgnow,userParam.gaussRadius,userParam.gaussSigma);
            imgfiles(ii).smadfile{jj}=f1nm{1};%
            fimgnow=imsubtract(fimgnow,bIms{jj});
            fimgnow=immultiply(im2double(fimgnow),nIms{jj});
            fimg(:,:,jj)=uint16(65536*fimgnow);%
       
        end

        
        %Initialize error string
        userParam.errorStr=sprintf('Position %d\n',ii);
        
        [maskC, statsN]=segmentCells2(nuc,fimg);
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
       % if ~isempty(statsN)
          data  = stats2xy(statsN);
            %outdat=outputData4AWTracker(statsN,nuc,ii); % AN return
        %end
        figure, imshow(nuc,[]); hold on;                            
        plot(data(:,1),data(:,2),'r.','MarkerSize',10); hold on;
        
                
    catch err       
        disp(['Error with image ' int2str(ii-1)]);
        disp(err.identifier);
        %rethrow(err);
    end
end
if flag == 0 || isempty('flag'); 
    
    ff = readMMdirectoryOneCoord(direc,nucname);
 
 nImages=length(ff.chan)-1;
 xmax = max(ff.pos_x)+1;
 
  ii=posRange; 

    disp(['Running image ' int2str(ii-1)]);
    %read the files
    try
        
        %read nuclear image, smooth and background subtract
        x = ff.pos_x(ii);
        %[x, y]=ind2sub([xmax ymax],ii);
        ff.prefix = [];
        f1nm = mkMMfilenameOneCoord(ff,x,[],[],1);%posNumberX

        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm{1};
        nuc=imread(f1nm{1});
        si=size(nuc);
        %apply gaussian smoothing
        nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
        %subtract precalculated background Image
        nuc=imsubtract(nuc,bIms{1});
        nuc=immultiply(im2double(nuc),nIms{1});
        nuc=uint16(65536*nuc);
        
        
        fimg=zeros(si(1),si(2),1);
        for jj= ii; %2:(1+1)
            f1nm = mkMMfilenameOneCoord(ff,x,[],[],jj);
            fimgnow=imread(f1nm{1});
            fimgnow = smoothImage(fimgnow,userParam.gaussRadius,userParam.gaussSigma);
            imgfiles(ii).smadfile{jj}=f1nm{1};%
            fimgnow=imsubtract(fimgnow,bIms{jj});
            fimgnow=immultiply(im2double(fimgnow),nIms{jj});
            fimg(:,:,jj)=uint16(65536*fimgnow);%
       
        end

        
        %Initialize error string
        userParam.errorStr=sprintf('Position %d\n',ii);
        
        [maskC, statsN]=segmentCells2(nuc,fimg);
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        if ~isempty(statsN)
          data  = stats2xy(statsN);
         % outdat=outputData4AWTracker(statsN,nuc,ii);
        end
        %  peaks{ii}=outdat;
         % save(outfile,'peaks','userParam','imgfiles');
        %end
        figure, imshow(nuc,[]); hold on;                            
        plot(data(:,1),data(:,2),'r.','MarkerSize',10); hold on;
        
                
    catch err       
        disp(['Error with image ' int2str(ii-1)]);
        disp(err.identifier);
        %rethrow(err);
    end
    
    
end
