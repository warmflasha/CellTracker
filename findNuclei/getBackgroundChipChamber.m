function [B]=getBackgroundChipChamber(direc2,filesep, nucfiles,smadfiles,T)



T=1:4:T;

nucfilename=[direc2 filesep nucfiles(1).name];
A=imread(nucfilename);



A=zeros(size(A,1),size(A,2),length(T));
for i=1:length(T)
    nucfilename=[direc2 filesep nucfiles(T(i)).name];
    A(:,:,i)=imread(nucfilename);

end

a=reshape(A,size(A,1)*size(A,2)*size(A,3),1);
a=a(1:10:end);
[bandwidth,density,xmesh,cdf]=kde(a,max(2^(round(log2(length(a)))-2),32),min(a),max(a));
thresh_inten=xmesh(find(cdf>(0.01),1,'first'));
clear a


A(A<thresh_inten)=1;
A(A~=1)=0;
for i=1:length(T)
A(:,:,i)=bwmorph(A(:,:,i),'dilate',20);
end
f=sum(A,3);
f(f<length(T))=0;
f(f>=length(T))=1;
B=f;
[L,num]=bwlabel(B);

if num>20
    B(B>0)=0;
end
end





