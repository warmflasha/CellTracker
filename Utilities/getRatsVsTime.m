function [RatToNucMarker RatToCyt RawDat Cellsinbin ncells radius center newpeaks]=getRatsVsTime(peaks)

ncells=zeros(length(peaks),1);
radius=ncells;
center=zeros(length(peaks),2);

pixelbin = 50;

ndat=size(peaks{1},2);
ndat=ndat-5;
ndat=ndat/2;

for ii=1:length(peaks)
    
    if ~mod(ii,10)
        disp(int2str(ii));
    end
    
    cd=peaks{ii};
    [center(ii,:) radius(ii) inds]=MCfitCircleToData(peaks{ii}(:,1:2));
    cd=cd(inds,:);
    coord=bsxfun(@minus,cd(:,1:2),center(ii));
    dists=sqrt(sum(coord.*coord,2));
    dmax=max(dists);
    
    newpeaks{ii}=cd;
    
    q=1;
    clear cellsinbin rat binneddata;
    rat=zeros(ceil(dmax/pixelbin),ndat);
    rat2=rat; cellsinbin=zeros(ceil(dmax/pixelbin),1);
    for jj=0:pixelbin:dmax
        inds= dists >= pixelbin*(q-1) & dists < pixelbin*q;
        nucdat=cd(inds,6:2:end);
        cytdat=cd(inds,7:2:end);
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
    RawDat{ii}=binneddata;
    RatToCyt{ii}=rat;
    RatToNucMarker{ii}=rat2;
    Cellsinbin{ii}=cellsinbin;
end

