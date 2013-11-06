function [newImage ind ind2 scale_fac]=alignTwoImages(im1,im2,side,parrange,perpsearch,bgIm)


%   side = 1  im2 below im1
%          2  im2 left of im1
%          3  im2 above im1
%          4  im2 right of im1

if ~exist('parrange','var') || isempty(parrange)
    parrange=1:200;
end
if ~exist('perpsearch','var') || isempty(perpsearch)
    perpsearch=20;
end

scale=1;

%get image sizes, check if same size for alignment, if not, pad the small
%image with zeros

si1=size(im1); si2=size(im2);
if (side==1 || side==3) && si1(2)~=si2(2)
    sdiff=si1(2)-si2(2);
    if sdiff > 0 %need to pad
        im2(:,(end+1):(end+sdiff))=0;
    else
        im1(:,(end+1):(end-sdiff))=0;
    end
end

if (side==2 || side==4) && si1(1)~=si2(1)
    sdiff=si1(1)-si2(1);
    if sdiff > 0 %need to pad
        im2((end+1):(end+sdiff),:)=0;
    else
        im1((end+1):(end-sdiff),:)=0;
    end
end
si1=size(im1); si2=size(im2);

diffs = 1000*ones(max(parrange),1);
diffs(parrange)=0;
mindiff = 1e6; ovbestpar = -1;
%find overlap in primary direction
for ov=parrange
    switch side
        case 1
            pix1=im1((end-ov):end,:);
            pix2=im2(1:(1+ov),:);
        case 2
            pix1=im1(:,1:(1+ov));
            pix2=im2(:,(end-ov):end);
        case 3
            pix1=im1(1:(1+ov),:);
            pix2=im2((end-ov):end,:);
        case 4
            pix1=im1(:,(end-ov):end);
            pix2=im2(:,1:(1+ov));
    end
    diffs(ov)=sum(sum(abs(pix1-pix2)))/ov/mean2(pix1)/mean2(pix2);
    if diffs(ov) < mindiff || ovbestpar == -1
        ovbestpar=ov;
        mindiff=diffs(ov);
        pix1best=pix1; pix2best=pix2;
    end
end


diffs2=zeros(2*perpsearch+1,1);
mindiff=1e6; ovbestperp=-1;
for ov=-perpsearch:perpsearch
    pix2b=pix2best; pix1b=pix1best;
    if side==1 || side==3
        if ov < 0
            pix2b(:,(end+ov):end)=[];
            pix1b(:,1:(1-ov))=[];
            diffs2(ov+perpsearch+1)=sum(sum(abs(pix1b-pix2b)))/(si1(1)+ov);
        else
            pix2b(:,1:(1+ov))=[];
            pix1b(:,(end-ov):end)=[];
            diffs2(ov+perpsearch+1)=sum(sum(abs(pix1b-pix2b)))/(si1(1)-ov);
        end
    end
    
    if side==2 || side==4
        if ov < 0
            pix2b((end+ov):end,:)=[];
            pix1b(1:(1-ov),:)=[];
            diffs2(ov+perpsearch+1)=sum(sum(abs(pix1b-pix2b)))/(si1(1)+ov);
        else
            pix2b(1:(1+ov),:)=[];
            pix1b((end-ov):end,:)=[];
            diffs2(ov+perpsearch+1)=sum(sum(abs(pix1b-pix2b)))/(si1(1)-ov);
        end
    end
    
    if diffs2(ov+perpsearch+1) < mindiff
        ovbestperp=ov;
        mindiff=diffs2(ov+perpsearch+1);
    end
end

ind=ovbestpar;
ind2=ovbestperp;



if exist('bgIm','var')
    im1return=imsubtract(im1,bgIm);
    im2return=imsubtract(im2,bgIm);
else
    im1return=im1;
    im2return=im2;
end

    scale_fac=sum(sum(pix1))/sum(sum(pix2));
if scale
    im2return=im2return*scale_fac;
end

if side==1 || side==3
    if ind2 < 0
        im2return(:,(end+ind2):end)=[];
        im1return(:,1:(1-ind2))=[];
    else
        im2return(:,1:(1+ind2))=[];
        im1return(:,(end-ind2):end)=[];
    end
elseif side==2 || side==4
    if ind2 < 0
        im2return((end+ind2):end,:)=[];
        im1return(1:(1-ind2),:)=[];
    else
        im2return(1:(1+ind2),:)=[];
        im1return((end-ind2):end,:)=[];
    end
end

half_s=ceil(ind/2);

switch side
    
    
    case 1
        newImage=[im1return(1:(end-half_s),:); im2return((ind+1-half_s):end,:)];
    case 2
        newImage=[im2return im1return(:,(ind+1):end)];
    case 3
        newImage=[im2return; im1return((ind+1):end,:)];
    case 4
        newImage=[im1return im2return(:,(ind+1):end)];
end
