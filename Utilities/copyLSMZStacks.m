function copyLSMZStacks(indirec,outdirec,chan,npos,ntime,posToUse)


if ~exist('npos','var') || isempty(npos) %find number of positions
    npos = 0;
    numstr = '01';
    while exist(fullfile(indirec,['Track00' numstr]))
        npos = npos + 1;
        numstr = int2str(npos+1);
        while length(numstr) < 2
            numstr = ['0' numstr];
        end
    end
    posarray = 1:npos;
else
    if length(npos) < 2
        posarray = 1:npos;
    else
        posarray = npos;
    end
end



if ~exist('ntime','var')
    ntime = 0;
    timestr = '01';
    while exist(fullfile(indirec,'Track0001',['Image0001_' timestr '.oif']))
        ntime = ntime + 1;
        timestr = int2str(ntime+1);
        if length(timestr) < 2
            timestr = ['0' timestr];
        end
    end
end

if ~exist(outdirec)
    mkdir(outdirec);
end




for ii = 1:ntime
    q = 1;
    for jj = posarray
        
        timestr = int2str(ii);
        posstr = int2str(jj);
        outfile1 = fullfile(outdirec,['pos' posstr '_' timestr '.tif']);
        
        if length(timestr) < 2
            timestr = ['0' timestr];
        end
        
        if length(posstr) < 2
            posstr = ['0' posstr];
        end
        
        if ~exist('posToUse','var')
            posstr2 = posstr;
        else
            posstr2 = int2str(posToUse(q));
            if length(posstr2) < 2
                posstr2 = ['0' posstr2];
            end
            q = q + 1;
        end
        
        file1 = fullfile(indirec,['Track00' posstr],['Image00' posstr2 '_' timestr '.oif']);
        if exist(file1,'file')
            try
                renameZStack(file1,outfile1,chan);
            catch
                continue;
            end
        else
            disp([file1 ' does not exist.']);
        end
    end
end