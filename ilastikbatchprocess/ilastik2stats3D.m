function stats = ilastik2stats3D(h5file,imgfile,paramfile)

global userParam;

% try
%     eval(paramfile);
% catch
%     error('Could not evaluate paramfile command');
% end

mask1 = readIlastikFile(h5file);
        if isfield(userParam,'maskDiskSize3D')
        mask1 = imopen(mask1,strel('disk',userParam.maskDiskSize));
        end
stats = ilastikMaskToStats(mask1);

reader = bfGetReader(imgfile);


nc = reader.getSizeC;
nz = reader.getSizeZ;


img =zeros(reader.getSizeX,reader.getSizeY,nz);

for cc=1:nc
    for ii=1:nz
        iplane=reader.getIndex(ii - 1, cc -1, 0) + 1;
        img(:,:,ii) = bfGetPlane(reader,iplane);
    end
    stats_tmp = regionprops(mask1,img,'MeanIntensity');
    for jj = 1:length(stats)
        stats(jj).MeanIntensity(cc) = stats_tmp(jj).MeanIntensity;
    end
end
        
