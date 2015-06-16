function runOneMMDirec(direc,paramfile,nucchan)

files=readMMsubdir(direc);

files
function files=readMMsubdir(subdir)
    ff = dir([subdir filesep '*tif']);
    
    if isempty(ff)
        ff=dir([subdir filesep 'Pos0' filesep '*.tif']);
    end
    
    if isempty(ff)
        disp('Error: didn''t find any .tif files');
        return;
    end
    
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
    