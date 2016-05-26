function oifToTiff(infile,outfilebase,preprocessparamfile)


if exist('preprocessparamfile','var')
    eval(preprocessparamfile);
    preprocess = 1;
end

reader = bfGetReader(infile);

nz = reader.getSizeZ;
nc = reader.getSizeC;

for cc = 1:nc
    outfile = [outfilebase '_' int2str(cc) '.tif'];
    for ii = 1:nz
        iplane = reader.getIndex(ii - 1,cc-1,0) + 1;
        img = bfGetPlane(reader,iplane);
        if preprocess
            img = preprocessImages(img);
        end
        if ii==1
            imwrite(img,outfile,'Compression','none');
        else
            imwrite(img,outfile,'writemode','append','Compression','none');
        end
    end
end