function [ mom ] = calculateMoment(col,columns,ncolumns)
%calculateMoment(col,columns,ncolumns)
%---------------------------------------   
%calculate moments of marker expression to look for asymmetry


mom = zeros(length(columns),2);
if length(ncolumns)==1 && length(columns) > 1
    ncolumns=ncolumns(ones(length(columns),1));
    for ii=1:length(columns)
        dat=col.data(:,columns(ii));
        dat=(dat-min(dat))/(max(dat)-min(dat));
        dat=dat/mean(dat);
        markdat = dat./col.data(:,ncolumns(ii));
        mom(ii,:)=meannonan(col.data(:,1:2).*markdat(:,[1 1]));
    end
end

