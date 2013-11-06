function col=analyzeColonies(col)

pixelbin=50;

for ii=1:length(col)
    col(ii).ncells=length(col(ii).data(:,1));
end

%remove colonies with 3 or less cells
inds = [col.ncells] < 4 | [col.ncells] > 10000;
col(inds)=[];

ndat=size(col(1).data,2);
ndat=ndat-7;
ndat=ndat/2;

for ii=1:length(col)
    if ~mod(ii,50)
        disp(int2str(ii))
    end
    %     if ii==4
    %         continue;
    %     end
    col(ii).center=mean(col(ii).data(:,1:2));
    col(ii).coord=bsxfun(@minus,col(ii).data(:,1:2),col(ii).center);
    nn_ids=knnsearch(col(ii).coord);
    
    dists=sqrt(sum(col(ii).coord.*col(ii).coord,2));
    
    if col(ii).ncells < 10000
        nn_dists=col(ii).coord-col(ii).coord(nn_ids,:);
        nn_dists=sqrt(sum(nn_dists.*nn_dists,2));
        toremove = nn_dists > mean(nn_dists)+3*std(nn_dists);
        dists(toremove)=[];
    end
    col(ii).radius=max(dists);
    
    
    
    cd=col(ii).data;
    cd(toremove,:)=[];
    
    if max(cd(:,1))-min(cd(:,1)) > 0 && max(cd(:,2))-min(cd(:,2)) > 0
        edgeInds=convhull(cd(:,1),cd(:,2));
        [xc yc rad]=circfit(cd(edgeInds,1),cd(edgeInds,2));
        col(ii).center=[xc yc];
        col(ii).radius=rad;
        col(ii).coord=bsxfun(@minus,col(ii).data(:,1:2),col(ii).center);
        dists=sqrt(sum(col(ii).coord.*col(ii).coord,2));
        dists(toremove)=[];
    end
    
    
    xdiff=max(cd(:,1))-min(cd(:,1));
    ydiff=max(cd(:,2))-min(cd(:,2));
    col(ii).aspectRatio=xdiff/ydiff;
    col(ii).density=col(ii).ncells/(pi*col(ii).radius^2);
    
    dmax=max(dists);
    q=1;
    clear cellsinbin rat binneddata;
    rat=zeros(ceil(dmax/pixelbin),ndat);
    rat2=rat; cellsinbin=zeros(ceil(dmax/pixelbin),1);
    for jj=0:pixelbin:dmax
        inds= dists >= pixelbin*(q-1) & dists < pixelbin*q;
        nucdat=cd(inds,6:2:end-2);
        cytdat=cd(inds,7:2:end-2);
        nucmarkerdat=cd(inds,5);
        ncol=size(nucdat,2);
        nucmarkerdat=nucmarkerdat(:,ones(ncol,1));
        rat(q,:)=meannonan(nucdat./cytdat,1);
        rat2(q,:)=meannonan(nucdat./nucmarkerdat,1);
        cellsinbin(q)=sum(inds);
        dbin = cd(inds,:);
        %dbin(isnan(dbin(:,1)),:)=[];
        binneddata(q,:)=meannonan(dbin,1);
        q=q+1;
    end
    col(ii).bdata=binneddata;
    col(ii).rat=rat;
    col(ii).rat2=rat2;
    col(ii).cellsinbin=cellsinbin;
    
end

