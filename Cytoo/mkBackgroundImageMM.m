function [minIm, meanIm]=mkBackgroundImageMM(files,chan,maxIm,filterrad)


if ~exist('filterrad','var')
    filterrad=200;
end


q=1;
xmax = max(files.pos_x)+1;
ymax = max(files.pos_y)+1;

nIms=xmax*ymax;
ImRange=randperm(nIms);
disp(xmax); disp(ymax);
for jj=1:length(ImRange)
    
    [x, y]=ind2sub([xmax ymax],ImRange(jj));
    
    if x == 1 || y == 1 || x == xmax || y == ymax
        continue;
    end
    
    
  
    imnm = mkMMfilename(files,x-1,y-1,[],[],chan);
    
    if exist('maxIm','var') && q > maxIm
        break;
    end
    imNow=im2double(imread(imnm{1}));
    
    if min(min(imNow)) == 0
        disp(['here ' int2str([x y])]);
    end
        if q==1
            minIm=imNow;
            meanIm=imNow;
        else
            minIm=min(minIm,imNow);
            meanIm=((q-1)*meanIm+imNow)/q;
        end
        q=q+1;
end

 gfilt=fspecial('gaussian',filterrad,filterrad/5);
 minIm=imfilter(minIm,gfilt,'symmetric');
 meanIm=imfilter(meanIm,gfilt,'symmetric');