function files = readAndorDirectory(direc)
% files = readAndorDirectory(direc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% takes a directory produced by the Andor iQ3 software and returns a
% structure containing information about the files. 
% input directory should have all images stored as single-layed tif 
%
% see also: getAndorFileName, andorMaxIntensity


allfiles = dir([direc filesep '*.tif']);%% '.tif'

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
        m{nprefix}=[];
    end
    
    ind = strfind(nm,'_f0');
    if length(ind) > 1 
        toremove = false(length(ind),1);
        for ii=1:length(ind)
            if isempty(str2num(nm(ind(ii)+2)))
                toremove(ii)=1;
            end
        end
        if sum(toremove) > 0
            ind(toremove)=[];
        end
    end
    if ~isempty(ind)
        inds(1) = ind;
        p{currPrefixNum} = [p{currPrefixNum} str2num(nm((inds(1)+2):(inds(1)+5)))];
    else
        inds(1) = 0;
    end
    
    ind = strfind(nm,'_t0');
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
    
    ind = strfind(nm,'_m');
    if ~isempty(ind)
        inds(5) = ind;
        m{currPrefixNum} = [m{currPrefixNum} str2num(nm((inds(5)+2):(inds(5)+5)))];
    else
        inds(5) = 0;
    end
    
end

inds_nonzero=inds(inds>0);

first_ind=min(inds_nonzero);
if nprefix==1
    prefixes{1}=allfiles(1).name(1:(first_ind-1));
end


ordering = 'ftzwm';
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
    files(ii).m=sort(unique(m{ii}));
end    