function colonies=getColonyData(peaks,ac,dims,si)

%put all the data into one big matrix
totalcells=0;
for ii=1:(length(peaks)-1)
    if ~isempty(peaks{ii})
        totalcells=totalcells+length(peaks{ii}(:,1));
    end
end

allcelldata=zeros(totalcells,size(peaks{1},2));

cc=1;
for ii=1:(length(peaks)-1)
    if ~isempty(peaks{ii})
        nc=length(peaks{ii}(:,1));
        allcelldata(cc:(cc+nc-1),:)=peaks{ii};
        cc=cc+nc;
    end
end

%get list of unique colony numbers
colnums=unique(allcelldata(:,end));
ncols=length(colnums);

%put together each colony
for ii=1:ncols
    
    cdata=allcelldata(allcelldata(:,end)==colnums(ii),:);
    picnums=unique(cdata(:,end-1)); %get picture nums
    picnums=sort(picnums); %put in ascending order
    pic1=picnums(1);
    for jj=2:length(picnums)
        
        %find number of pics displaced from upper left pic
        ydiff=picnums(jj)-picnums(1); xdiff=0;
        while ydiff >= dims(1)
            ydiff=ydiff-dims(1);
            xdiff=xdiff+1;
        end
        
        %find the pixel displacements
        xdisplace=0; ydisplace=0;
        for kk=1:ydiff
            ydisplace=ydisplace+si(1)-ac(pic1+kk).wabove(1);
            if xdiff==0
                xdisplace=xdisplace+ac(pic1+kk).wabove(2);
            end
            
        end
        for kk=1:xdiff
            xdisplace=xdisplace+si(2)-ac(pic1+ydiff+kk*dims(1)).wside(1);
            if ydiff==0
                ydisplace=ydisplace+ac(pic1+ydiff+kk*dims(1)).wside(2);
            end
        end
        inds=cdata(:,end-1)==picnums(jj);
        cdata(inds,1)=cdata(inds,1)+xdisplace;
        cdata(inds,2)=cdata(inds,2)+ydisplace;        
    end
    
    colonies(ii).data=cdata;
    
    
end