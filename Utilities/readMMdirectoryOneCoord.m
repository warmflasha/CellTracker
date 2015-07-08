function files = readMMdirectoryOneCoord(direc,nucname)

if ~exist('nucname','var')
    nucname='DAPI';
end


ftmp = dir(direc);

ftmp = ftmp( [ftmp.isdir]' & arrayfun(@isGoodDir,ftmp));

for ii=1:length(ftmp)
    ind = strfind(ftmp(ii).name,'Pos');
    pos_x(ii) = str2double(ftmp(ii).name(length(ftmp(ii).name)));
  end

files=readMMsubdir([direc filesep ftmp(1).name]);
files.direc = direc;
files.pos_x = unique(pos_x);
files=MMputNucFirst(files,nucname);




function files=readMMsubdir(subdir,files)
    ff = dir([subdir filesep '*tif']);
    
    for ii = 1:length(ff)
        dividers = find(ff(ii).name=='_');
        subprefix=ff(ii).name(1:(dividers(1)-1));
        time(ii) = str2double(ff(ii).name((dividers(1)+1):(dividers(2)-1)));
        chan{ii}=ff(ii).name((dividers(2)+1):(dividers(3)-1));
        z(ii)=str2double(ff(ii).name( (dividers(3)+1):(dividers(3)+3)));
    end
    
    files.subprefix = subprefix;
    files.time=unique(time);
    files.chan=unique(chan);
    files.z=unique(z);
    


function outp=isGoodDir(fileIn)

if fileIn.name(1) == '.'
     outp=false;
else
     outp=true;
end