function [cmasknew] = donutilastikoverlap(nmask,cmask1,rad)

n = nmask; %likastik generated and processed
c = cmask1;% ilastik-generated

donutonly = zeros(size(n));

donutwithnuc = imdilate(n,strel('disk',rad));
donutwithnuc(donutwithnuc == n)=0;
donutonly = donutwithnuc;

c(c~=donutonly)=0;

cmasknew = c;

end