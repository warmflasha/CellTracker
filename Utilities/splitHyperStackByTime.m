function splitHyperStackByTime(indir,outbase,pos,chan)

ff=readAndorDirectory(indir);

q=1;
for ii=1:length(ff.t)
    filename=getAndorFileName(ff,pos,ff.t(ii),[],[]);
    reader=bfGetReader(filename);
    nt=reader.getSizeT;
    for jj=1:nt
        outfile = [outbase '_t' int2str(q) '.tif'];
        saveOneZstack(reader,outfile,jj,chan);
        q=q+1;
    end
end