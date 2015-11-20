%%
function [rA cellsinbin dmax] = radavgcc(obj,column,ncolumn,binsize)
% best way to find out edge of concentric circles

clear new
obj = plate1.colonies(colcl{7}(3));
colmax=max(obj.data(:,1:2));
mask=false(colmax(1)+10,colmax(2)+10);
inds=sub2ind(size(mask),obj.data(:,1),obj.data(:,2));
mask(inds)=1;
mask1=bwconvhull(mask);

m1 = mask;

dp = 80;
m2 = imdilate(m1, strel('disk', dp));

mf = imfill(m2, 'holes');

hole = mf & ~m2;


bhole = bwareaopen(hole,4000);

shole = hole & ~bhole;

new = m2|shole;


new1 = bwareaopen(new, 10e4);
new2 = imerode(new1, strel('disk', 30));

newm = mask1 & new2;
figure; imshow(newm);

%new3 = imdilate(new1, strel('disk', 1));
figure; imshow(mask1); figure; imshow(new1); figure; imshow(new2); %figure; imshow(new3);
%%
figure; imshow(new1);
figure; imshow(mask);

%%
dist = bwdist(~newm);
dists = dist(inds);

%%
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
                    rA(q)=meannonan(dat);
                    cellsinbin(q)=sum(inds);
                else
                    rA(q)=0;
                    cellsinbin(q)=0;
                end
                q=q+1;
            end
       
        


