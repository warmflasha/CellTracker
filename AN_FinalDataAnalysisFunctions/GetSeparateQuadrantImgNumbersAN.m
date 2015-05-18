
% function to obtain the cell array of image numbers (toplot) and
% corresponding data from peaks (peaksnew) for each quadrant
% filename is a single outall file obtained after executing runfulltileMM
% see also: MeansFromQuadrantsOfFullChip

function [toplot,peaks] = GetSeparateQuadrantImgNumbersAN(nms2,peaks,dims,midcoord,fincoord)
 
%filename = ['.' filesep  nms{k} '.mat'];
        
% load(filename,'peaks','dims');
% disp([filename]);

if isempty(midcoord) && isempty(fincoord)
        midcoord = [dims(1)/2; dims(2)/2];
        fincoord = [dims(1)-1; dims(2)-1];
        end


xx=0:midcoord(1);
yy=0:midcoord(2);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{1} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1); % 

xx=(midcoord(1)+1):fincoord(1);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{2} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

yy=(midcoord(2)+1):fincoord(2);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{4} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

xx=0:midcoord(1);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{3} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

for j=1:size(nms2,2)
    toplot{j}=toplot{j}(toplot{j} < length(peaks));
 end

%to determine the image numbers used for each quadrant ( inverse of the code above)

for t=1:size(nms2,2)           
for z=1:length(toplot{t})
   
   [x1, y1]=ind2sub(dims,toplot{t}(z));
    positions{t}(z,1)=x1-1;
    positions{t}(z,2)=y1-1;
end
end


end

