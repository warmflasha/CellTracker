function oifToTiffTimeLapse(infile,outfilebase,preprocessparamfile)


if exist('preprocessparamfile','var')
    eval(preprocessparamfile);
    preprocess = true;
else
    preprocess = false;
end

reader = bfGetReader(infile);

nT = reader.getSizeT;
nc = reader.getSizeC;

for cc = 1:nc
    outfile = [outfilebase '_' int2str(cc) '.tif'];
    for ii = 1:nT
        iplane = reader.getIndex(0,cc-1,ii - 1) + 1;
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