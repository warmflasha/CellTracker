function files = readAndorDirectorymont(direc)
% files = readAndorDirectory(direc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% takes a directory produced by the Andor iQ3 software and returns a
% structure containing information about the files. 
% input directory should have all images stored as single-layed tif 
%
% see also: getAndorFileName, andorMaxIntensity


allfiles = dir([direc filesep '*.tif']);

nprefix = 0;
nImages = length(allfiles);
prefixes ={};

for ii=1:nImages
    nm = allfiles(ii).name;
    currPrefix = strtok(nm,'_');
    currPrefixNum=find(~cellfun(@isempty,strfind(prefixes,currPrefix)));
    if isempty(currPrefixNum)
        nprefix = nprefix + 1;
        prefixes{nprefix}=currPrefix;
        currPrefixNum=nprefix;
        p{nprefix}=[]; t{nprefix}=[];
        z{nprefix}=[]; w{nprefix}=[];
    end
    
    ind = strfind(nm,'_m');
    if ~isempty(ind)
        inds(1) = ind;
        p{currPrefixNum} = [p{currPrefixNum} str2num(nm((inds(1)+2):(inds(1)+5)))];
    else
        inds(1) = 0;
    end
    
    ind = strfind(nm,'_t');
    if ~isempty(ind)
        inds(2) = ind;
    t{currPrefixNum} = [t{currPrefixNum} str2num(nm((inds(2)+2):(inds(2)+5)))];
    else
        inds(2) = 0;
    end
    
    ind = strfind(nm,'_z');
    if ~isempty(ind)
        inds(3) = ind;
        z{currPrefixNum} = [z{currPrefixNum} str2num(nm((inds(3)+2):(inds(3)+5)))];
    else
        inds(3) = 0;
    end
    
    ind = strfind(nm,'_w');
    if ~isempty(ind)
        inds(4) = ind;
        w{currPrefixNum} = [w{currPrefixNum} str2num(nm((inds(4)+2):(inds(4)+5)))];
    else
        inds(4) = 0;
    end
end

ordering = 'mtzw';
drop = inds == 0;
ordering(drop) =[];
inds(drop) =[];
[~, reord]=sort(inds);
ordering=ordering(reord);


for ii=1:nprefix
    files(ii).direc = direc;
    files(ii).ordering = ordering;
    files(ii).prefix = prefixes{ii};
    files(ii).p=sort(unique(p{ii}));
    files(ii).t=sort(unique(t{ii}));
    files(ii).z=sort(unique(z{ii}));
    files(ii).w=sort(unique(w{ii}));
end    