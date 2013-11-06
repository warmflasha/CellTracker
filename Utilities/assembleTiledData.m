function [peaks, setequiv]=assembleTiledData(peaks,ac,dims,si,maxims,skipfirst)


%mindtobound = 100;
overlapreg=50;
minoverlap =20;
colsmoothpix=40;
showfig = 0;

lastcolnum=0;

%if ~exist(outfile,'file')
if ~skipfirst
    %Make a first pass, assign colony numbers:
    %this will make the index of the current image in the 2nd
    %to last column and the index of the colony in the last
    for jj=1:dims(2)
        for ii=1:dims(1)
            
            currimgind=(jj-1)*dims(1)+ii;
            
            if currimgind <= maxims
                disp(['first pass: img ' int2str(currimgind)]);
                od=peaks{currimgind};
                
                if ~isempty(od)
                    %label colonies
                    
                    zz=zeros(si);
                    for kk=1:size(od,1)
                        zz(od(kk,1),od(kk,2))=1;
                    end
                    
                    zz=imdilate(zz,strel('disk',colsmoothpix));
                    zz=bwlabel(zz);
                    
                    %assign colony numbers to each
                    pcolumns = size(peaks{currimgind},2); % number of columns in peaks
                    ncol=max(max(zz));
                    zz=zz+lastcolnum;
                    peaks{currimgind}(:,pcolumns+1)=currimgind;
                    
                    for kk=1:size(od,1)
                        peaks{currimgind}(kk,pcolumns+2)=zz(od(kk,1),od(kk,2));
                    end
                    %increment total colonies
                    lastcolnum=lastcolnum+ncol;
                    if showfig
                        clf;
                        imshow(zz,[]); hold on;
                        plot(od(:,2),od(:,1),'r.'); drawnow;
                        
                    end
                end
            end
            
        end
    end
    save('peakstmp.mat','peaks');
end
if showfig
    clf;
end
%Make a second pass, merge colonies on boundary, remove overlapping
q=1;
setequiv=[0 0];
for jj=1:dims(2)
    for ii=1:dims(1)
        
        currimgind=(jj-1)*dims(1)+ii;
        
        if currimgind <=maxims
            disp(['second pass: img ' int2str(currimgind)]);
            
            leftimgind=currimgind-dims(1);
            if leftimgind > 0
                odup=peaks{leftimgind}; %all data from left image
            end
            if jj > 1 && ~isempty(od)  && ~isempty(odup) % if not at the left, align colonies on left with adjoinging image
                indsup=od(:,1) < ac(currimgind).wside(1)+overlapreg; %indices in overlapping region
                
                
                %get cells in overlapping region from above image
                indsforabove=(si(2)-odup(:,1)) < ac(currimgind).wside(1)+overlapreg;
                
                if any(indsup)&& any(indsforabove)
                    
                    
                    %get corresponding colony numbers
                    colnumsabove = unique(odup(indsforabove,end));
                    
                    %colony numbers from below
                    colnumsbelow=unique(od(indsup,end)); % colony numbers
                    
                    %average y position of above colonys
                    maxabovex=zeros(length(colnumsabove),1); minabovex=maxabovex;
                    
                    for kk=1:length(colnumsabove)
                        maxabovex(kk)=max(odup(odup(:,end)==colnumsabove(kk),2));
                        minabovex(kk)=min(odup(odup(:,end)==colnumsabove(kk),2));
                    end
                    
                    %identify each below colony with one above
                    toremove=zeros(length(od(:,end)),1);
                    for kk=1:length(colnumsbelow)
                        colinds=od(:,end)==colnumsbelow(kk);
                        
                        
                        %                     dtobound=min(od(colinds,1));
                        %                     if dtobound < mindtobound % minimum distance from boundary to align
                        %
                        maxbelowx=max(od(colinds,2));
                        minbelowx=min(od(colinds,2));
                        overlap=zeros(length(colnumsabove),1);
                        for mm=1:length(maxabovex)
                            overlap(mm)=min(maxbelowx,maxabovex(mm))-max(minbelowx,minabovex(mm));
                        end
                        
                        [maxov maxind]=max(overlap);
                        if maxov > minoverlap
                            newcolind=colnumsabove(maxind);
                            newind=min(newcolind,colnumsbelow(kk));
                            odupinds=odup(:,end)==newcolind;
                            od(colinds,end)=newind; %reset colony index
                            odup(odupinds,end)=newind;
                            toremovecurr=colinds & indsup;
                            toremove = toremove | toremovecurr;
                            peaks{leftimgind}=odup;
                            %                         if newind~=aboveind
                            %                             setequiv(q,:)=[newind aboveind];
                            %                             q=q+1;
                            %                         end
                        end
                        
                        %   end
                    end
                    if sum(toremove) > 0
                        od(toremove,:)=[]; %remove overlapping
                    end
                end
                if showfig && any(indsup)
                    subplot(1,3,3);
                    im1=imread(['120723_Cytoo' filesep 'RUES2_Smad2_Oct4_pSmad1_Dapi_Scan_w4_s' int2str(leftimgind) '_t1.TIF']);
                    imshow(im1,[]); hold on;
                    plotcolorcolonies(odup,0);
                else
                    subplot(1,3,3); cla;
                end
                
            end
            
            od=peaks{currimgind};
            if ii > 1
                odup=peaks{currimgind-1}; %all data from above image
            end
            if ii > 1 && ~isempty(od) && ~isempty(odup) % if not at the top, align colonies on top with above
                
                indsup=od(:,2) < ac(currimgind).wabove(1)+overlapreg; %indices in overlapping region
                
                %get cells in overlapping region from above image
                indsforabove=(si(1)-odup(:,2)) < ac(currimgind).wabove(1)+overlapreg;
                
                if any(indsup) && any(indsforabove)
                    
                    %get corresponding colony numbers
                    colnumsabove = unique(odup(indsforabove,end));
                    
                    
                    %colony numbers from below
                    colnumsbelow=unique(od(indsup,end)); % colony numbers
                    
                    %get x-span of above colonys
                    maxabovex=zeros(length(colnumsabove),1); minabovex=maxabovex;
                    for kk=1:length(colnumsabove)
                        maxabovex(kk)=max(odup(odup(:,end)==colnumsabove(kk),1));
                        minabovex(kk)=min(odup(odup(:,end)==colnumsabove(kk),1));
                    end
                    
                    %identify each below colony with one above
                    toremove=zeros(length(od(:,end)),1);
                    for kk=1:length(colnumsbelow)
                        colinds=od(:,end)==colnumsbelow(kk);
                        
                        
                        %dtobound=min(od(colinds,2));
                        %if dtobound < mindtobound % minimum distance from boundary to align
                        
                        maxbelowx=max(od(colinds,1));
                        minbelowx=min(od(colinds,1));
                        overlap=zeros(length(colnumsabove),1);
                        for mm=1:length(maxabovex)
                            overlap(mm)=min(maxbelowx,maxabovex(mm))-max(minbelowx,minabovex(mm));
                        end
                        
                        [maxov maxind]=max(overlap);
                        if maxov > minoverlap
                            newcolind=colnumsabove(maxind);
                            newind=min(newcolind,colnumsbelow(kk));
                            odupinds=odup(:,end)==newcolind;
                            od(colinds,end)=newind; %reset colony index
                            odup(odupinds,end)=newind;
                            toremovecurr=colinds & indsup;
                            toremove= toremove | toremovecurr;
                            peaks{currimgind-1}=odup;
                            %aboveind=newind;
                        end
                        %end
                    end
                    if sum(toremove) > 0
                        od(toremove,:)=[]; %remove overlapping
                    end
                end
                if showfig && any(indsup)
                    subplot(1,3,2);
                    im1=imread(['120723_Cytoo' filesep 'RUES2_Smad2_Oct4_pSmad1_Dapi_Scan_w4_s' int2str(currimgind-1) '_t1.TIF']);
                    imshow(im1,[]); hold on;
                    plotcolorcolonies(odup,0);
                else
                    subplot(1,3,2); cla;
                end
            end
            
            leftimgind=currimgind-dims(1);
            if leftimgind > 0
                odup=peaks{leftimgind}; %all data from left image
            end
            if jj > 1 && ~isempty(od)  && ~isempty(odup) % if not at the left, align colonies on left with adjoinging image
                indsup=od(:,1) < ac(currimgind).wside(1)+overlapreg; %indices in overlapping region
                
                
                %get cells in overlapping region from above image
                indsforabove=(si(2)-odup(:,1)) < ac(currimgind).wside(1)+overlapreg;
                
                if any(indsup)&& any(indsforabove)
                    
                    
                    %get corresponding colony numbers
                    colnumsabove = unique(odup(indsforabove,end));
                    
                    %colony numbers from below
                    colnumsbelow=unique(od(indsup,end)); % colony numbers
                    
                    %average y position of above colonys
                    maxabovex=zeros(length(colnumsabove),1); minabovex=maxabovex;
                    
                    for kk=1:length(colnumsabove)
                        maxabovex(kk)=max(odup(odup(:,end)==colnumsabove(kk),2));
                        minabovex(kk)=min(odup(odup(:,end)==colnumsabove(kk),2));
                    end
                    
                    %identify each below colony with one above
                    toremove=zeros(length(od(:,end)),1);
                    for kk=1:length(colnumsbelow)
                        colinds=od(:,end)==colnumsbelow(kk);
                        
                        
                        %                     dtobound=min(od(colinds,1));
                        %                     if dtobound < mindtobound % minimum distance from boundary to align
                        %
                        maxbelowx=max(od(colinds,2));
                        minbelowx=min(od(colinds,2));
                        overlap=zeros(length(colnumsabove),1);
                        for mm=1:length(maxabovex)
                            overlap(mm)=min(maxbelowx,maxabovex(mm))-max(minbelowx,minabovex(mm));
                        end
                        
                        [maxov maxind]=max(overlap);
                        if maxov > minoverlap
                            newcolind=colnumsabove(maxind);
                            newind=min(newcolind,colnumsbelow(kk));
                            odupinds=odup(:,end)==newcolind;
                            od(colinds,end)=newind; %reset colony index
                            odup(odupinds,end)=newind;
                            toremovecurr=colinds & indsup;
                            toremove = toremove | toremovecurr;
                            peaks{leftimgind}=odup;
                            %                         if newind~=aboveind
                            %                             setequiv(q,:)=[newind aboveind];
                            %                             q=q+1;
                            %                         end
                        end
                        
                        %   end
                    end
                    if sum(toremove) > 0
                        od(toremove,:)=[]; %remove overlapping
                    end
                end
                if showfig && any(indsup)
                    subplot(1,3,3);
                    im1=imread(['120723_Cytoo' filesep 'RUES2_Smad2_Oct4_pSmad1_Dapi_Scan_w4_s' int2str(leftimgind) '_t1.TIF']);
                    imshow(im1,[]); hold on;
                    plotcolorcolonies(odup,0);
                else
                    subplot(1,3,3); cla;
                end
                
            end
            
            if showfig && ~isempty(od)
                subplot(1,3,1);
                im1=imread(['120723_Cytoo' filesep 'RUES2_Smad2_Oct4_pSmad1_Dapi_Scan_w4_s' int2str(currimgind) '_t1.TIF']);
                imshow(im1,[]); hold on;
                plotcolorcolonies(od,0);
                %pause(0.01);
            else
                subplot(1,3,1); cla;
            end
            peaks{currimgind}=od;
            %alldata=[alldata; od];
        end
    end
end

