function saveOneZstack(reader,outfile,imsize,time,chan)

%nt=reader.getSizeT;
nz=reader.getSizeZ;
%nc=reader.getSizeC;

if length(imsize)==1
    imsize=[imsize imsize];
end

saveimg = zeros(imsize(1),imsize(2),nz,'uint16');

for ii=1:nz
    iPlane=reader.getIndex(ii - 1, chan -1, time - 1) + 1;
    saveimg(:,:,ii)=bfGetPlane(reader,iPlane);
end

bfsave(saveimg,outfile);