classdef colony
    %Data class to store a stem cell colony
    properties
        data %cell by cell data for colony
        ncells %number of cells
        center %x-y coordinates of center
        radius %radius of colony
        aspectRatio %aspect ratio (x/y) of colony
        density %cell density
        imagenumbers %stage positions numbers in the image directory.
        imagecoords  %coordinate entries from acoords, allows for image
        compressNucMask %compressed binary mask of nuclei
        shape %denotes shape type of colony
        rotate % indicates need to rotate colony for alignment
        %alignment
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %BEGIN METHODS        %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        
        %CONSTRUCTOR function
        function obj=colony(data,acoords,dims,si,imgfiles,mm)
            %Constructor function for colony object
            %obj=colony(data,acoords,dims)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %constructor function. supply cell by cell data, will compute properties
            %the first two columns of data must be x,y coords. all other
            %columns optional and will be including in obj.data but not
            %used during construction.
            %For IF data, supply the acoords alignments and dims -- the
            %dimension of the tiling. If these are left out, it will assume
            %all data is from a single image.
            %si is the image size. default is 1024x1344.
            
            if ~exist('mm','var')
                mm=1;
            end
            
            if ~exist('si','var') || isempty(si)
                if mm
                    si=[2048 2048];%1024 1344
                else
                    si=[1024 1024];
                end
            end
            
            if isempty(data) %|| size(data,1) < 4
                obj.data=[];
                obj.ncells=0;
                obj.center=[0 0];
                obj.radius=0;
                obj.density=0;
                obj.aspectRatio=0;
                return;
            end
            
            obj.data=data;
            obj.ncells=size(data,1);
            
            
            if nargin==1
                obj.imagenumbers=1;
                ac.wabove=[0 0];
                ac.wside=[0 0];
                ac.absinds=[1 1];
                obj.imagecoords=ac;
                newdata=data;
            elseif nargin<=6
                %store image stuff for later reconstruction
                %will take a rectangular grid of images to avoid
                %problems later
                
                if ~exist('mm','var') || mm==0
                    imnums=unique(data(:,end-1));
                    obj.imagecoords=acoords(obj.imagenumbers);
                    yimg=fix((imnums-1)/dims(1));
                    ximg=rem((imnums-1),dims(1));
                    xmin=min(ximg); xmax=max(ximg);
                    ymin=min(yimg); ymax=max(yimg);
                    
                    xrange=xmax-xmin+1; yrange=ymax-ymin+1;
                    allimgs=zeros(xrange*yrange,1);
                    
                    for ii=ymin:ymax
                        allimgs((xrange*(ii-ymin)+1):(xrange*(ii-ymin)+xrange))...
                            =ii*dims(1)+((xmin+1):(xmax+1));
                    end
                    
                    obj.imagenumbers=allimgs;
                    obj.imagecoords=acoords(allimgs);
                    
                    %put coordinates in image coordinates
                    %of colony image, not plate coordinates
                    [newdata, mask]=realignPointsAndor(obj,si,dims,imgfiles);
                    
                else
                    imnums=unique(data(:,end-1));
                    %obj.imagecoords=acoords(obj.imagenumbers);
                    [ximg, yimg]=ind2sub(dims,imnums);
                    [t1, t2]=meshgrid(min(ximg):max(ximg),min(yimg):max(yimg));
                    imnums=sub2ind(dims,t1(:),t2(:));
                    obj.imagenumbers=imnums;
                    obj.imagecoords=acoords(imnums);
                    [newdata, mask]=realignPointsMM(obj,si,imgfiles,dims,acoords);
                end
                obj.compressNucMask=mask;
                obj.data(:,1:2)=newdata;
            else
                error('Colony constructor function must <= 5 arguments');
            end
            %find center, radius, and density by fitting exterior
            %points to a circle
            try
                edgeInds=convhull(newdata(:,1),newdata(:,2));
            catch
                edgeInds=1:size(newdata,1);
            end
            [xc, yc, rad]=circfit(newdata(edgeInds,1),newdata(edgeInds,2));
            obj.center=round([xc yc]);
            obj.radius=rad;
            
            %find aspect ratio
            xdiff=max(newdata(:,1))-min(newdata(:,1));
            ydiff=max(newdata(:,2))-min(newdata(:,2));
            obj.aspectRatio=xdiff/ydiff;
            
            
            
        end
        
        
        function fullImage=assembleColony(obj,direc,imKeyWord,backIm,normIm)
            %Assemble the image of the colony.
            %
            %fullImage=assembleColony(obj,direc,imKeyWord,overlayPoints,backIm)
            %
            %Function to take a colony, a directory of images, and a
            %keyword, and to return an image of that colony.
            %
            %backIm is an optional background image to subtract from each
            %picture before pasting.
            %Note: imKeyWord is  a cell array of keywords. fullImage is a
            %cell array of the same length as imKeyword
            
            
            % disp('Calling this function!!');
            
            imnums=obj.imagenumbers;
            dim1=find(diff(imnums)>1,1,'first');%dim1=find(diff(obj.imagenumbers)>1,1,'first');
            if isempty(dim1)
                total1=length(imnums);
                total2=1;
            else
                total1=dim1;
                total2=length(imnums)/dim1;
            end
            
            ac=obj.imagecoords;
            
            
            [junk, imFiles]=folderFilesFromKeyword(direc,imKeyWord{1});
            
            if isempty(imFiles)
                error('Error: files with first keyword not found...');
            end
            
            tmp1=imread([direc filesep imFiles(1).name]);
            si=size(tmp1);
            
            
            for jj=1:length(imKeyWord)
                %fullImage{jj}=zeros(si(1)*max(coords(:,1)),si(2)*max(coords(:,2)));
                fullImage{jj}=uint16(zeros(si(1)*total1,si(2)*total2));
                
                for ii=1:length(imnums)
                    
                    
                    if isempty(dim1)
                        over2=0;
                        over1=ii-1;
                    else
                        over2=fix((ii-1)/dim1);
                        over1=rem((ii-1),dim1);
                        
                    end
                    
                    
                    
                    currinds=[over1*si(1)+1 over2*si(2)+1];
                    for kk=1:over1
                        currinds(1)=currinds(1)-ac(ii-(kk-1)).wabove(1);
                    end
                    for mm=1:over2
                        currinds(2)=currinds(2)-ac(ii-(mm-1)*dim1).wside(1);
                    end
                    
                    if jj==1
                        imname=imFiles(imnums(ii)).name;
                    else
                        imname=strrep(imFiles(imnums(ii)).name,imKeyWord{1},imKeyWord{jj});
                    end
                    
                    %If file doesn't exist, return empty array for this
                    %keyword.
                    if ~exist([direc filesep imname],'file')
                        disp(['Warning: file ' imname ' not found. Skipping this keyword.']);
                        fullImage{jj}=[];
                        break;
                    end
                    
                    currimg=imread([direc filesep imname]);
                    
                    %background subtraction
                    if exist('backIm','var')
                        currimg=imsubtract(currimg,backIm{jj});
                    end
                    if exist('normIm','var')
                        newIm=immultiply(im2double(currimg),normIm{jj});
                        newIm=uint16(65536*newIm);
                    else
                        newIm=currimg;
                    end
                    
                    fullImage{jj}(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=newIm;
                    
                end
                
            end
            
            
        end
        
        function fullImage=assembleColonyAndor(obj,direc,dims,backIm,normIm)
            %Assemble the image of the colony.
            %
            %fullImage=assembleColony(obj,direc,imKeyWord,overlayPoints,backIm)
            %
            %Function to take a colony, a directory of images, and a
            %keyword, and to return an image of that colony.
            %
            %backIm is an optional background image to subtract from each
            %picture before pasting.
            %Note: imKeyWord is  a cell array of keywords. fullImage is a
            %cell array of the same length as imKeyword
            
            
            
            imnums=obj.imagenumbers;
            
            
            firstimage = min(imnums);
            firstcolumn= firstimage:dims(1):(firstimage+dims(1)*100);
            endfirstcolumn = firstcolumn(find(ismember(firstcolumn,imnums),1,'last'));
            coord2 = (endfirstcolumn-firstimage)/dims(1)+1;
            coord1 = length(imnums)/coord2;
            ac=obj.imagecoords;
            nucpixall = [];
            
            
            files = readAndorDirectory(direc);
            
            
            tmp1=andorMaxIntensity(files,0,0,0);
            si=size(tmp1);
            
            
            for jj=1:length(files.w)
                %fullImage{jj}=zeros(si(1)*max(coords(:,1)),si(2)*max(coords(:,2)));
                fullImage{jj}=uint16(zeros(si(1)*coord2,si(2)*coord1));
                
                for ii=1:length(imnums)
                    
                    
                    over1=floor((imnums(ii)-firstimage)/dims(1));
                    
                    over2=imnums(ii)-firstimage-dims(1)*over1;
                    
                    %calculate alignment
                    currinds=[over1*si(1)+1 over2*si(2)+1];
                    for kk=1:over1
                        currinds(1)=currinds(1)-ac(ii-(kk-1)*dims(1)).wabove(1);
                    end
                    for mm=1:over2
                        currinds(2)=currinds(2)-ac(ii-mm+1).wside(1);
                    end
                    
                    currimg=andorMaxIntensity(files,ii-1,0,files.w(jj));
                    
                    %background subtraction
                    if exist('backIm','var')
                        currimg=imsubtract(currimg,backIm{jj});
                    end
                    if exist('normIm','var')
                        newIm=immultiply(im2double(currimg),normIm{jj});
                        newIm=uint16(65536*newIm);
                    else
                        newIm=currimg;
                    end
                    
                    fullImage{jj}(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=newIm;
                    
                end
                
            end
            
            
        end
        
        function fullImage=assembleColonyMM(obj,direc,acoords,si,backIm,normIm)
            %Assemble the image of the colony.
            %
            %fullImage=assembleColony(obj,direc,imKeyWord,overlayPoints,backIm)
            %
            %Function to take a colony, a directory of images, and a
            %keyword, and to return an image of that colony.
            %
            %backIm is an optional background image to subtract from each
            %picture before pasting.
            %Note: imKeyWord is  a cell array of keywords. fullImage is a
            %cell array of the same length as imKeyword
            
            
            
            
            ff=readMMdirectory(direc);
            dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
            
            
            imnums=obj.imagenumbers;
            [pos_x, pos_y]=ind2sub(dims,imnums);
            
            %             tosub=[ac.absinds];
            %             tosub=reshape(tosub,2,length(ac));
            %             tosub=min(tosub,[],2)';
            
            for jj=1:length(ff.chan)
                fullImage{jj}=uint16(zeros(si(1)*length(unique(pos_x)),si(2)*length(unique(pos_y))));
            end
            
            for ii=1:length(imnums)
                %currinds = ac(ii).absinds-tosub+1;
                
                xnow = pos_x(ii); ynow=pos_y(ii);
                currinds=[(max(pos_x)-xnow)*si(1)+1 (ynow-min(pos_y))*si(2)+1];
                for kk=(min(pos_y)+1):ynow
                    currinds(2)=currinds(2)-acoords(sub2ind(dims,xnow,kk)).wabove(1);
                end
                for mm= xnow:(max(pos_x)-1)
                    currinds(1)=currinds(1)-acoords(sub2ind(dims,mm,ynow)).wside(1);
                end
                currinds=currinds([2 1]); %somehow the above ended up backwar
                
                filenames = mkMMfilename(ff,pos_x(ii)-1,pos_y(ii)-1,[],[],ff.chan);
                for jj=1:length(filenames)
                    currimg=imread(filenames{jj});
                    
                    if exist('backIm','var')
                        currimg=imsubtract(currimg,backIm{jj});
                    end
                    if exist('normIm','var')
                        newIm=immultiply(im2double(currimg),normIm{jj});
                        newIm=uint16(65536*newIm);
                    else
                        newIm=currimg;
                    end
                    
                    fullImage{jj}(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=newIm;
                end
            end
            
            
            
        end
        
        function [rA, cellsinbin, dmax]=radialAverage(obj,column,ncolumn,binsize,compfrom,toohigh)
            %computes the radial average of one column of data.
            %
            %[rA cellsinbin]=radialAverage(obj,column,ncolumn,binsize)
            %
            % obj = colony object
            % column = column of data to use in obj.data
            % ncolumn= column to use for normalization (typically DAPI
            % data or cytoplasmic data for same marker). set to 0 if don't
            % want to normalize.
            % binsize = number of pixels to use for spatial binning (~50 is
            % reasonable for 1024x1344 images)
            % rA returns the radial average using the bins of size binsize
            % and cellsinbin returns the number of cells in that bin.
            %compfrom = 0 (1) means compute distance from center (boundary)
            %default = 0
            
            if ~exist('compfrom','var')
                compfrom = 0;
            end
            
            
            
            
            if ~compfrom %compute distance from center
                coord=bsxfun(@minus,obj.data(:,1:2),obj.center);
                dists=sqrt(sum(coord.*coord,2));
            else %compute distance from boundary using bwdist
                colmax=max(obj.data(:,1:2));
                mask=false(colmax(1)+10,colmax(2)+10);
                inds=sub2ind(size(mask),obj.data(:,1),obj.data(:,2));
                mask(inds)=1;
                mask=bwconvhull(mask);
                distt=bwdist(~mask);
                dists=distt(inds);
            end
            
            
            
            
            dmax=max(dists);
            
            
            cellsinbin=zeros(ceil(dmax/binsize),1); rA=cellsinbin;
            q=1;
            for jj=0:binsize:dmax
                inds= dists >= binsize*(q-1) & dists < binsize*q;
                if sum(inds) > 0
                    dat=obj.data(inds,column);
                    if ncolumn > 0
                        ndat=obj.data(inds,ncolumn);
                        dat=dat./ndat;
                    end
                    if exist('toohigh','var')
                        nogood = dat > toohigh; 
                    else
                        nogood = false(size(dat));
                    end
                    rA(q)=meannonan(dat(~nogood));
                    cellsinbin(q)=sum(inds)-sum(nogood);
                else
                    rA(q)=0;
                    cellsinbin(q)=0;
                end
                q=q+1;
            end
        end
        
        
        function plotColonyColorPoints(obj,plotcircle)
            %plots the positions of cells in the colony colored by image
            
            if ~exist('plotcircle','var')
                plotcircle=1;
            end
            
            od=obj.data;
            
            cols=unique(od(:,end-1));
            ncols = length(cols);
            cc=colorcube(28);
            for ii=1:ncols
                inds=od(:,end-1)==cols(ii);
                colorind=mod(cols(ii),27);
                plot(od(inds,1),od(inds,2),'.','Color',cc(colorind+1,:),'MarkerSize',18);
                hold on;
            end
            
            if plotcircle
                plot(obj.center(1),obj.center(2),'cs','MarkerSize',20);
                drawcircle(obj.center,obj.radius,'c');
            end
            hold off;
            
        end
        
        function inds=getPointsAroundCoordinate(obj,coord,radius)
            %Extract all cells inside radius around coord. radius and coord
            %both in pixels. Coords chosen so [mean(x), mean(y)]=[0,0]
            %for colony. Returns indices of points.
            
            com_coords=bsxfun(@minus,obj.data(:,1:2),mean(obj.data(:,1:2)));
            disttopoint=bsxfun(@minus,com_coords,coord);
            disttopoint=sqrt(sum(disttopoint.*disttopoint,2));
            inds = disttopoint < radius;
            
        end
        
        
        
    end
end

function [newdata, compressednuc]=realignPoints(obj,si,imgfiles)

imnums=obj.imagenumbers;
dim1=find(diff(obj.imagenumbers)>1,1,'first');
if isempty(dim1)
    total1=length(imnums);
    total2=1;
else
    total1=dim1;
    total2=length(imnums)/dim1;
end
%if only 1 column of images, dim1= number of images
if isempty(dim1)
    dim1=length(imnums);
end
ac=obj.imagecoords;

newdata=obj.data(:,1:2);


nucpixall=[];
for ii=1:length(imnums)
    
    
    
    over2=fix((ii-1)/dim1);
    over1=rem((ii-1),dim1);
    %fprintf('ii= %d, over 1 = %d, over2 = %d\n',ii,over1,over2);
    
    %get the data from current image
    currimgcells=obj.data(:,end-1)==imnums(ii);
    origdata=obj.data(currimgcells,1:2);
    
    %back to image coords (not plate coords)
    origdata=bsxfun(@minus,origdata,[ac(ii).absinds(2) ac(ii).absinds(1)]);
    
    
    %calculate alignment
    currinds=[over1*si(1)+1 over2*si(2)+1];
    for kk=1:over1
        currinds(1)=currinds(1)-ac(ii-(kk-1)).wabove(1);
    end
    for mm=1:over2
        currinds(2)=currinds(2)-ac(ii-(mm-1)*dim1).wside(1);
    end
    
    origdata=bsxfun(@plus,origdata,[currinds(2)-1 currinds(1)-1]);
    
    if ~isempty(imgfiles(imnums(ii)).compressNucMask)
        nucmask=uncompressBinaryImg(imgfiles(imnums(ii)).compressNucMask);
        [nucpix_x, nucpix_y]=ind2sub(size(nucmask),find(nucmask));
        
        badinds1=nucpix_x < ac(ii).wabove(1);
        badinds2=nucpix_y < ac(ii).wside(1);
        
        badinds=badinds1 | badinds2;
        
        nucpix_x(badinds)=[]; nucpix_y(badinds)=[];
        
        nucpix=bsxfun(@plus,[nucpix_x nucpix_y],[currinds(1)-1 currinds(2)-1]);
        
        nucpixall=[nucpixall; nucpix];
    end
    
    newdata(currimgcells,:)=origdata;
    
end

compressednuc=compressBinaryImg(sub2ind([total1*si(1) total2*si(2)],nucpixall(:,1),nucpixall(:,2)),[total1*si(1) total2*si(2)]);
end

function [newdata, compressednuc]=realignPointsMM(obj,si,imgfiles,dims,acoords)

imnums=obj.imagenumbers;
[ximg, yimg]=ind2sub(dims,imnums);
ac = obj.imagecoords;

nucpixall=[];
for ii=1:length(imnums)
    
    
    %get the data from current image
    currimgcells=obj.data(:,end-1)==imnums(ii);
    origdata=obj.data(currimgcells,1:2);
    
    %back to image coords (not plate coords)
    origdata=bsxfun(@minus,origdata,[ac(ii).absinds(2) ac(ii).absinds(1)]);
    
    
    %currimgind=sub2ind(dims,jj,ii);
    xnow = ximg(ii); ynow=yimg(ii);
    currinds=[(max(ximg)-xnow)*si(1)+1 (ynow-min(yimg))*si(2)+1];
    for kk=(min(yimg)+1):ynow
        currinds(2)=currinds(2)-acoords(sub2ind(dims,xnow,kk)).wabove(1);
    end
    for mm= xnow:(max(ximg)-1)
        currinds(1)=currinds(1)-acoords(sub2ind(dims,mm,ynow)).wside(1);
    end
    currinds=currinds([2 1]); %somehow the above ended up backwar
    %acoords(currimgind).absinds=[currinds(2) currinds(1)]; %for image coords
    
    origdata=bsxfun(@plus,origdata,[currinds(2)-1 currinds(1)-1]);
    
    if ~isempty(imgfiles(imnums(ii)).compressNucMask)
        nucmask=uncompressBinaryImg(imgfiles(imnums(ii)).compressNucMask);
        [nucpix_x, nucpix_y]=ind2sub(size(nucmask),find(nucmask));
        
        badinds1=nucpix_x < ac(ii).wabove(1);
        badinds2=nucpix_y < ac(ii).wside(1);
        
        badinds=badinds1 | badinds2;
        
        nucpix_x(badinds)=[]; nucpix_y(badinds)=[];
        
        nucpix=bsxfun(@plus,[nucpix_x nucpix_y],[currinds(1)-1 currinds(2)-1]);
        
        nucpixall=[nucpixall; nucpix];
    end
    
    newdata(currimgcells,:)=origdata;
    
end
total1 = max(ximg)-min(ximg)+1;
total2 = max(yimg)-min(yimg)+1;
compressednuc=compressBinaryImg(sub2ind([total2*si(1) total1*si(2)],nucpixall(:,1),nucpixall(:,2)),[total1*si(1) total2*si(2)]);
end

function [newdata, compressednuc]=realignPointsAndor(obj,si,dims,imgfiles)

imnums=obj.imagenumbers;

newdata=obj.data(:,1:2);

firstimage = min(imnums);
firstcolumn= firstimage:dims(1):(firstimage+dims(1)*100);
endfirstcolumn = firstcolumn(find(ismember(firstcolumn,imnums),1,'last'));
coord2 = (endfirstcolumn-firstimage)/dims(1)+1;
coord1 = length(imnums)/coord2;
ac=obj.imagecoords;
nucpixall = [];
for ii=1:length(imnums)
    
    %get the data from current image
    currimgcells=obj.data(:,end-1)==imnums(ii);
    origdata=obj.data(currimgcells,1:2);
    
    %back to image coords (not plate coords)
    origdata=bsxfun(@minus,origdata,[ac(ii).absinds(2) ac(ii).absinds(1)]);
    
    over1=floor((imnums(ii)-firstimage)/dims(1));
    
    over2=imnums(ii)-firstimage-dims(1)*over1;
    
    %calculate alignment
    currinds=[over1*si(1)+1 over2*si(2)+1];
    for kk=1:over1
        currinds(1)=currinds(1)-ac(ii-(kk-1)*dims(1)).wabove(1);
    end
    for mm=1:over2
        currinds(2)=currinds(2)-ac(ii-mm+1).wside(1);
    end
    
    origdata=bsxfun(@plus,origdata,[currinds(2)-1 currinds(1)-1]);
    
    if ~isempty(imgfiles(imnums(ii)).compressNucMask)
        nucmask=uncompressBinaryImg(imgfiles(imnums(ii)).compressNucMask);
        [nucpix_x, nucpix_y]=ind2sub(size(nucmask),find(nucmask));
        
        badinds1=nucpix_x < ac(ii).wabove(1);
        badinds2=nucpix_y < ac(ii).wside(1);
        
        badinds=badinds1 | badinds2;
        
        nucpix_x(badinds)=[]; nucpix_y(badinds)=[];
        
        nucpix=bsxfun(@plus,[nucpix_x nucpix_y],[currinds(1)-1 currinds(2)-1]);
        
        nucpixall=[nucpixall; nucpix];
    end
    
    newdata(currimgcells,:)=origdata;
    
end

compressednuc=compressBinaryImg(sub2ind([coord2*si(1) coord1*si(2)],nucpixall(:,1),nucpixall(:,2)),[coord2*si(1) coord1*si(2)]);
end