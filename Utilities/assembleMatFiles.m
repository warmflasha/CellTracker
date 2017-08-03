function assembleMatFiles(direc,imgspermatfile,nmatfiles,outfile)

peaks=[];
%nmatfiles = 3;
for ii=1:nmatfiles
    f1=(ii-1)*imgspermatfile+1;
    infile=[direc filesep 'out_' int2str(f1) '.mat'];
    load(infile);
    f2=min(length(peaks),ii*imgspermatfile);
    for jj=f1:f2
        peaksall{jj}=peaks{jj};
        imgfilesall(jj)=imgfiles(jj);
    end
end

imgfiles=imgfilesall;

peaks=peaksall;
save([direc filesep outfile],'peaks','userParam','imgfiles','-append');

