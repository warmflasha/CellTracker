function renameZStack(infile,outfile,allChan)


reader1 = bfGetReader(infile);

nz1 = reader1.getSizeZ;
nc1 = reader1.getSizeC;
nx = reader1.getSizeX;
ny = reader1.getSizeY;

if ~exist('allChan','var')
    allChan = 1:nc1;
end

for ii = 1:nz1
    fi_all = uint16(zeros(nx,ny,3));
    for jj = 1:length(allChan)        
        iPlane = reader1.getIndex(ii-1,allChan(jj)-1,0)+1; %z, chan, time
        im1 = bfGetPlane(reader1,iPlane);
        fi_all(:,:,jj) = im1;
    end
    
    if ii == 1
        imwrite(fi_all,outfile,'Compression','none');
    else
        imwrite(fi_all,outfile,'Compression','none','Writemode','append');
    end
    
end