function copyLSMZStacks(indirec,outdirec,chan,npos,ntime)


if ~exist('npos','var') %find number of positions
    npos = 0;
    numstr = '01';
    while exist(fullfile(indirec,['Track00' numstr]))
        npos = npos + 1;
        numstr = int2str(npos+1);
        while length(numstr) < 2
            numstr = ['0' numstr];
        end
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
    for jj = 1:npos
        
        timestr = int2str(ii);
        posstr = int2str(jj);
        outfile1 = fullfile(outdirec,['pos' posstr '_' timestr '.tif']);
        
        if length(timestr) < 2
            timestr = ['0' timestr];
        end
        
        if length(posstr) < 2
            posstr = ['0' posstr];
        end
        
        file1 = fullfile(indirec,['Track00' posstr],['Image00' posstr '_' timestr '.oif']);
        try
            renameZStack(file1,outfile1,chan);
        catch
            continue;
        end
    end
end