function avgOut=computeShapeAverages(colonies,shapenum,intensity_norm)

mkplot = 0;
binsize = 200;
minbin = 12;

if ~exist('intensity_norm','var')
    intensity_norm=0;
end

inds = find([colonies.shape]==shapenum);

rotmat = [ -1 0; 0 -1];
%q=1;

    den = zeros(2*minbin+1);
    counter=den;
    markers=zeros(2*minbin+1,2*minbin+1,3);

for ii=1:length(inds)
    
    % mean subtract xy coords,
    %rotate if necessary
    
    col=colonies(inds(ii));
    dat=col.data(:,1:2);
    mdat=mean(dat);
    dat=bsxfun(@minus,dat,mdat);
    if col.rotate
        dat=dat*rotmat;
    end
    col.data(:,1:2)=dat;
    
    %plotting
    if mkplot
    subplot(6,6,q);
    col.plotColonyColorPoints(0);
    axis equal;
    q=q+1;
    end
    
    indx=(dat(:,1)-mod(dat(:,1),binsize))/binsize+minbin;
    indy=(dat(:,2)-mod(dat(:,2),binsize))/binsize+minbin;
    
    for kk=min(indx):max(indx)
        for jj=min(indy):max(indy)
            indstouse = (indx==kk) & (indy==jj);
            
            ncells=sum(indstouse);
            
            if ncells > 0
            markdat=mean(col.data(indstouse,[6 8 10])./col.data(indstouse,[5 5 5]));
            den(kk,jj)=den(kk,jj)+ncells;
            markers(kk,jj,:)=squeeze(markers(kk,jj,:))+markdat';
            end
            counter(kk,jj)=counter(kk,jj)+1;
        end
    end
    
    density=den./counter;
    markeravgs=markers./counter(:,:,[1 1 1]);
    
    if intensity_norm
        for kk=1:size(markeravgs,3)
            dat=markeravgs(:,:,kk);
            dat=dat(:);
            coun=counter(:);
            inds_good = coun >  max(coun)/2;
            
            mm=median(dat(inds_good));
            
            markeravgs(:,:,kk)=markeravgs(:,:,kk)/mm;
        end
    end
    
    avgOut.markerAvgs=markeravgs;
    avgOut.density=density;
    avgOut.counter=counter;
    avgOut.shape_id=shapenum;
            
end