function [avgall tt]=avgOverMovies(direc,nn,toavg,sample)

for ii=1:length(nn)
    if exist('sample','var')
        ftoread=[direc 'Sample' int2str(sample) 's' int2str(nn(ii)) 'out'];
    else
        ftoread=[direc 's' int2str(nn(ii)) 'out'];
    end
    [avgnow tt]=mkAveragePlot(ftoread,toavg,0);
    if ii==1
        avgall=avgnow/length(nn);
    else
        avgall=avgall+avgnow/length(nn);
    end
end
