function [datacell,Lnuc,Lcytofin] = laserscanningOutdat(mask1,mask2,img_nuc,img_cyto)
% [datacell,Lnuc,Lcytofin] = nucCytoIlastik2peaks(mask1,mask2,img_nuc,img_cyto,paramfile)
% --------------------------------------------------------------
% takes masks produced by ilastik for two markers, and quantifies how much
% of marker 2 is overlapping with marker 1 vs not. Use case is if marker 1
% is nuclear marker while marker 2 is smad image. each case of marker 2
% must have marker 1 inside. 
%
% Inputs:
%   -mask1 - mask for marker 1
%   -mask2 - mask for marker 2
%   -img_nuc - actual image for marker 1
%   -img_cyto - actual image for marker 2
%   -paramfile - paramter file
% Outputs:
%   -datacell - output segmentation data in the usual format, one row per
%   cell
%   -Lnuc (final nuclear marker mask)
%   -Lcyto (final cytoplasmic mask (exclusive with nuclear marker)

%process nuclear mask
% the nuc masks come already filtered and preprocessed
Lnuc = mask1; % 
%cytoplasmic mask
LcytoIl = imfill(mask2,'holes');
Lcytonondil = LcytoIl;
%if no nuclei, exit
if sum(sum(sum(Lnuc))) == 0
    datacell = [];
    Lcytofin =zeros(size(Lnuc));
    return;
end
%raw images
I2 = img_cyto;
Inuc = img_nuc;
%this removes cytoplasms that don't have any nucleus inside.  
cc = bwconncomp(LcytoIl);
cnuc = bwconncomp(Lnuc);                        
st = regionprops(cc,'PixelIdxList');         
stnuc = regionprops(cnuc,'PixelIdxList','Area');  %
goodinds = zeros(length(st),1);
for i = 1:length(stnuc);
    x =stnuc(i).PixelIdxList;
    for k=1:length(st);
        y = st(k).PixelIdxList;
        in = intersect(x,y);
        if ~isempty(in) && size(in,1)>10 % the cytoplasms are at least 200 pixels ( bc if some junk was founf in nuclear channel it will likely have very small sytos
            goodinds(k,1) = k;            
        end
    end    
end
goodindsfin = nonzeros(goodinds);%
goodstats = st(goodindsfin);
% here need to leave the PixelIds of the goodinds and then convert back to
% the labeled image to get the final mask of the cytoplasms (still nuclei
% are in)%
onebiglist = cat(1,goodstats.PixelIdxList);
Inew = zeros(1024,1024,size(mask1,3));
Inew(onebiglist) = true;
LcytoIl(Inew==0) =0;   %  this is the good cyto mask with only the cytos WITH nucleus

% now subtract those nuclei from filled cytoplasms to get final good
% labeled masks
% erode nuclei a little since sometimes causes problems
t = imerode(Lnuc,strel('disk',1));     
LcytoIl(t>0)=0;                                           % remove nuclei from the cytoplasms
% return back to the non-dilated cyto masks
% and non-eroded nuc mask
LcytoIl(Lcytonondil ==0)=0;
LcytoIl(Lnuc > 0)=0; 
Lcytofin = LcytoIl;   % keep the nuc eroded by 1 pixel

Lnuc = imerode(Lnuc,strel('disk',1));   
% at this point have the set of 2D masks (nuc and cyto); 
%  
% I2proc = img_cyto;   % the input image is already background subtracted
I2proc = simplebg2(Lcytofin,Lnuc,img_cyto); % just the imfilled background
bgsubimg = simplebg(Lcytofin,Lnuc,img_cyto); % just the imfilled background

%get the NUCLEAR mean intensity for each labeled object
statsnuc = regionprops(Lnuc,bgsubimg,'Area','Centroid','PixelIdxList','MeanIntensity');
statsnucw0 = regionprops(Lnuc,Inuc,'Area','Centroid','PixelIdxList','MeanIntensity');% these are the stats for the actual nuclear image(rfp)
badinds = [statsnuc.Area] == 0;   % don't need to filter anything since the number of elements in nuc and cyto is already matched in the code above      
badinds2 = [statsnucw0.Area] == 0;
statsnucw0(badinds2) = [];
statsnuc(badinds) = [];
%get the cytoplasmic mean intensity for each labeled object
statscyto = regionprops(Lcytofin,bgsubimg,'Area','Centroid','PixelIdxList','MeanIntensity');
badinds = [statscyto.Area] == 0;  % don't need to filter anything since the number of elements in nuc and cyto is already matched in the code above 
statscyto(badinds) = [];
finsz = size(statscyto,1);
if size(statsnucw0,1) ~= size(statscyto,1)
%  datacell = [];
%  disp('N of elements is not the same1')
%     return;
if size(statsnucw0,1) > size(statscyto,1)
    finsz = size(statscyto,1);
end
if size(statsnucw0,1) < size(statscyto,1)
    finsz = size(statscyto,1);
end
end
xya = round([statsnucw0(1:finsz).Centroid]);
xx =  xya(1:2:end)';
xyaall = zeros(size(xx,1),3); % initialize the atrix for the data once the number of rows is known (ftom size of xx)
yy =  xya(2:2:end)';
a =  round([statscyto(1:finsz).Area])';%(zrange*ones(1,size(statsnucw0,1)))';% save the area of the cyto if only one z plane
xyaall = cat(2,xx,yy,a);

nuc_avrw0  = [statsnucw0(1:finsz).MeanIntensity]';%
nuc_areaw0  = [statsnucw0(1:finsz).Area]';%
nuc_avrw1 = round([statsnuc(1:finsz).MeanIntensity]');
cyto_area  = [statscyto(1:finsz).Area]';
cyto_avrw1  = round([statscyto(1:finsz).MeanIntensity]');
placeholder = -round(ones(length(xyaall(:,1)),1));
meanbckgr = mean(mean(nonzeros(I2proc)))*ones(length(xyaall(:,1)),1);

if isempty(statscyto)
    cyto_area = zeros(length(nuc_avrw1),1);
    cyto_avrw1 = cyto_area;
end

%this is done for whne all the previous clean up failed and still there is
%a mismatch between the nuc and cyto number of elements , only then remove
%that datapoint
if size(cyto_area,1) < size(nuc_areaw0,1) ||  size(cyto_area,1) > size(nuc_areaw0,1) || isempty(xyaall)
    datacell = [];
    disp('N of elements is not the same2')
    return;
end
datacell=[xyaall(:,1) xyaall(:,2) xyaall(:,3) meanbckgr nuc_avrw0 nuc_avrw1 cyto_avrw1];%cyto_area

end