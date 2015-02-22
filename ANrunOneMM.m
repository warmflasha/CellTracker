function ANrunOneMM(direc,posNumberX,bIms,nIms,paramfile,nucname)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end
files = readMMdirectory(direc,nucname);
nImages=length(files.chan)-1;
xmax = max(files.pos_x)+1;
ymax = max(files.pos_y)+1;

imagetorun=files.pos_y(posNumberX);%pos_x
%if posNumberX > xmax 
  %  imagetorun=files.pos_y(posNumberY);

  %  end

%imagetorun=files.pos_x(posNumberX);

 ii=imagetorun;
    disp(['Running image ' int2str(imagetorun+1)]);
    %read the files
    try
        
        %read nuclear image, smooth and background subtract
        
        [x, y]=ind2sub([xmax ymax],ii);
        f1nm = mkMMfilename(files,x-1,y-1,[],[],1);%posNumberX

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
            f1nm = mkMMfilename(files,x-1,y-1,[],[],jj);
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
            %outdat=outputData4AWTracker(statsN,nuc,ii);
        %end
        figure, imshow(nuc,[]); hold on;                            
        plot(data(:,1),data(:,2),'r.','MarkerSize',10); hold on;
        
                
    catch err       
        disp(['Error with image ' int2str(ii)]);
        disp(err.identifier);
        rethrow(err);
    end
end