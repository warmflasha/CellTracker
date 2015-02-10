function [minIm, meanIm]=mkBackgroundImageMM(files,maxIm,filterrad)


if ~exist('filterrad','var')
    filterrad=200;
end


q=1;
nIms=files;
ImRange=randperm(nIms-1);
for jj=1:length(ImRange)
    ii=ImRange(jj);
    if exist('maxIm','var') && q > maxIm
        break;
    end
    imnm=ImFiles(ii).name;
    imNow=im2double(imread([direc filesep imnm]));
    %if max(max(imNow)) > 300
        if q==1
            minIm=imNow;
            meanIm=imNow;
        else
            minIm=min(minIm,imNow);
            meanIm=((q-1)*meanIm+imNow)/q;
        end
        q=q+1;
%      else
%          continue;
%      end
end

 gfilt=fspecial('gaussian',filterrad,filterrad/5);
 minIm=imfilter(minIm,gfilt,'symmetric');
 meanIm=imfilter(meanIm,gfilt,'symmetric');