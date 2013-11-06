function runSegmentCellsLSMZstack(filename,chan,outfile,paramfile)

try
    eval(paramfile);
catch
    error('Cannot evaluate paramfile');
end

fdata=lsminfo(filename);
si=[fdata.DimensionX fdata.DimensionY];
nz=fdata.DimensionZ;
nt=fdata.DimensionTime;

if nt > 1
pictimes=(fdata.TimeStamps.TimeStamps)/3600;
end

for tt=1:nt
    
    nucmax=zeros(si); nucmax=im2uint8(nucmax);
    for zz=1:nz
        imnum=(tt-1)*nz+zz;
        imnum=2*imnum-1;
        nucnow=tiffread27(filename,imnum);
        nucmax=max(nucmax,nucnow.data{chan(1)});
    end
    for zz=1:nz
        imnum=(tt-1)*nz+zz;
        imnum=2*imnum-1;
        imgs=tiffread27(filename,imnum);
        fimg=imgs.data{chan(2)};
        [maskC statsN]=segmentCells(nucmax,fimg);
        ncells=length(statsN);
        if zz==1
            outdat_tmp=zeros(ncells,7,nz);
        end
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        outdat_tmp(:,:,zz)=outputData4AWTracker(statsN,nucmax);
    end
    
    outdat=zeros(ncells,8);
    for jj=1:size(outdat_tmp,1)
        [~, goodplane]=max(outdat_tmp(jj,5,:));
        outdat(jj,1:7)=outdat_tmp(jj,:,goodplane);
        outdat(jj,8)=goodplane;
    end
    
    peaks{tt}=outdat;
    statsArray{tt}=statsN;
end
dateSegmentCells = clock;
global userParam;
if nt > 1
save(outfile,'peaks','statsArray','userParam','pictimes','dateSegmentCells');
else
    save(outfile,'peaks','statsArray','userParam','dateSegmentCells');
end
