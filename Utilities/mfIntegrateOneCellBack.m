function [allfdata posarray]=mfIntegrateOneCellBack(cells,peaks,cellnum,firstframe,lastframe,timestep,radius)

totalframes=lastframe-firstframe+1;
allfdata=zeros(totalframes,3);
posarray=zeros(totalframes/timestep+1,2);

cellframe=find(cells(cellnum).onframes==lastframe);
cellpos=cells(cellnum).data(cellframe,[1 2]);
q=totalframes/timestep+1;
posarray(q,:)=cellpos;
for currFrame=lastframe:-timestep:firstframe
    if currFrame-timestep < firstframe
        timestep=currFrame-firstframe;
    end
    [newpos fdataavg]=doOneStep(cells,peaks,cellnum,cellpos,currFrame,timestep,radius);
    q=q-1;
    posarray(q,:)=newpos;
    cellpos=newpos;
    allfdata((currFrame-timestep+1):currFrame,:)=fdataavg;
end



function [newpos fdataavg]=doOneStep(cells,peaks,cellnum,cellpos,currFrame,timestep,radius)
cneighbors=findNeighbors(cellpos,peaks,currFrame,radius);
ncells=0;displaceavg=[0 0]; fdataavg=zeros(timestep,3);
for ii=1:length(cneighbors)
    cn=cneighbors(ii);
    if cn > 0
        f1=find(cells(cn).onframes==currFrame);
        f2=find(cells(cn).onframes==(currFrame-timestep));
        if ~isempty(f1) && ~isempty(f2)
            ncells=ncells+1;
            if cn~=cellnum
                displaceavg=displaceavg+cells(cn).data(f2,[1 2])-cells(cn).data(f1,[1 2]);
            end
            fdataavg=fdataavg+cells(cn).fdata(f2+1:f1,:);
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

