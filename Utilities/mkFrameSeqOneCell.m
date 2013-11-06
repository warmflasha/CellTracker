function mkFrameSeqOneCell(lsmfile,matfile,cellnum,zlevel,frames)

load(matfile,'cells');

of=cells(cellnum).onframes;
dd=cells(cellnum).data;

uf=zeros(length(frames),1);
for ii=1:length(frames)
    uf(ii)=find(of==frames(ii));
end

px=dd(uf,1);
py=dd(uf,2);

xmin=min(px); xmax=max(px); ymin=min(py); ymax=max(py);
sp=50;
rect=[xmin-sp ymin-sp xmax-xmin+2*sp ymax-ymin+2*sp];

for ii=1:length(frames)
    imgs{ii}=openOneFrameLSM(lsmfile,frames(ii),zlevel);
end

sl=stretchlim(imgs{1}{1},[0.05 0.99]); nl=stretchlim(imgs{1}{2},[0.05 0.99]);
figure; 
for ii=1:length(frames)
    simg=imcrop(imadjust(imgs{ii}{1},sl),rect);
    nimg=imcrop(imadjust(imgs{ii}{2},nl),rect);
    zz=zeros(size(simg));
    subplot(2,length(frames),ii); imshow(cat(3,zz,simg,zz));
    subplot(2,length(frames),ii+length(frames)); imshow(cat(3,nimg,zz,zz));
end
    