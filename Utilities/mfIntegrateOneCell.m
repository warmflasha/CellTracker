function [allfdata posarray]=mfIntegrateOneCell(cells,peaks,cellnum,startframe,timestep,radius)

totalframes=length(peaks);
allfdata=zeros(totalframes,3);
posarray=zeros(totalframes/timestep+1,2);

cellframe=find(cells(cellnum).onframes == startframe);
cellpos=cells(cellnum).data(cellframe,[1 2]);
posarray(1,:)=cellpos;

q=2;
for currFrame=startframe:timestep:totalframes
    if currFrame+timestep > totalframes
        timestep=totalframes-currFrame;
    end
    [newpos fdataavg]=doOneStep(cells,peaks,cellnum,cellpos,currFrame,timestep,radius);
    posarray(q,:)=newpos;
    q=q+1;
    cellpos=newpos;
    allfdata((currFrame+1):(currFrame+timestep),:)=fdataavg;
end



function [newpos fdataavg]=doOneStep(cells,peaks,cellnum,cellpos,currFrame,timestep,radius)
cneighbors=findNeighbors(cellpos,peaks,currFrame,radius);
ncells=0;displaceavg=[0 0]; fdataavg=zeros(timestep,3);
for ii=1:length(cneighbors)
    cn=cneighbors(ii);
    if cn > 0
    f1=find(cells(cn).onframes==currFrame);
    f2=find(cells(cn).onframes==(currFrame+timestep));
    if ~isempty(f1) && ~isempty(f2)
        ncells=ncells+1;
        if cn~=cellnum
        displaceavg=displaceavg+cells(cn).data(f2,[1 2])-cells(cn).data(f1,[1 2]);
        end
        fdataavg=fdataavg+cells(cn).fdata((f1+1):f2,:);
    end
    end
end
fdataavg=fdataavg/ncells; displaceavg=displaceavg/ncells;
newpos=cellpos+displaceavg; 





function [cellneighbors peakneighbors]=findNeighbors(cellpos,peaks,frame,radius)
%find the indices of the cells within radius of cell cellnum
distances=ipdm(cellpos,peaks{frame}(:,[1 2]));
peakneighbors=find(distances < radius);
cellneighbors=peaks{frame}(peakneighbors,end);

