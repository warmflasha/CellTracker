function outdat=runMultipleMMDirec(superdir,paramfile,nucchan)

ftmp=dir(superdir);
ftmp = ftmp( [ftmp.isdir]' & arrayfun(@isGoodDir,ftmp));

outdat = [];
for ii=1:length(ftmp)
    outnow=runOneMMDirec([superdir filesep ftmp(ii).name],paramfile,nucchan);
    outdat=[outdat; outnow];   
end

function outp=isGoodDir(fileIn)

if fileIn.name(1) == '.'
    outp=false;
else
    outp=true;
end