classdef plate
    %class to store data from one Cytoo plate
    
    properties
        colonies %contains colony objects on plate
        dims %image dimensions of plate
        inds1000 %indices of 1000um colonies
        inds800 % indices of 800um colonies
        inds500 %indices of 500um colonies
        inds200 %indices of 200um colonies
        indsSm %indices of smaller colonies
        direc %name of directory where image files are store
        chans %name of channels in image files
        bIms % background images
        nIms % normalization images
        mm % 1 for micromanager directories
        si % image size
    end
    
    methods
        
        function obj=plate(colonies,dims,direc,chans,bIms,nIms,outfile)
            
            load([direc filesep outfile], 'userParam');
           % conv = userParam.umtopxl; 
           
                                    % this was added for Cecilia
                                    % analysis?AN(september 2015)

            % Constructor function for plate object
            %
            % obj=plate(colonies,dims,direc,chans)
            %
            % direc and chans optional arguments
            %
            if exist('direc','var')
                obj.direc=direc;
            end
            
            
            if exist('chans','var')
                obj.chans=chans;
            end
            if exist('bIms','var')
                obj.bIms=bIms;
            end
            if exist('nIms','var')
                obj.nIms=nIms;
            end
            
            obj.colonies=colonies;
            obj.dims=dims;
            col=colonies;
        %--------------------------------------added for Sapna analysis? 
            ncell = [col.ncells]; % _SC
            rad=[col.radius];
            
            gind= [col.aspectRatio] > 0.66 & [col.aspectRatio] < 1.5; %& [ncell./(rad.^2) > 0.0030]; %_SC
            conv = 3.1104; % pix per micro 1/0.3215
            col1000= gind & rad > 500*conv*0.9;
            col800 = gind & rad < 400*conv*1.1 & rad > 400*conv*0.9;
            col500 = gind & rad < 250*conv*1.1 & rad > 250*conv*0.9;
            col200 = gind & rad < 100*conv*1.1 & rad > 100*conv*0.9;
            
            %colSm=gind & rad < 100*conv*0.5;
            
            
            obj.inds1000=find(col1000);
            obj.inds500=find(col500);
            obj.inds800= find(col800);
            obj.inds200=find(col200);
            
            %obj.indsSm=find(colSm);
       %---------------     
        end
        
        function fI=getColonyImages(obj,colnum,acoords,direc)
            
            %function to call the assemble colony method and get images of
            %colony number colnum. will use plate1.direc unless the direc
            %argument is specified.
            
            if exist('direc','var')
                usedir=direc;
            else
                
                %correct file separators in obj.direc
                dd=obj.direc;
                if dd(end)=='/' || dd(end)=='\'
                    dd(end)=[];
                end
                
                ind1=find(dd=='\');
                ind2=find(dd=='/');
                
                if ~isempty(ind1) || ~isempty(ind2)
                    xx=max(cat(2,ind1,ind2));
                    usedir=dd((xx+1):end);
                else
                    usedir=dd;
                end
            end
            
            
            
            
            
            if any(strcmp(properties(obj),'nIms')) && any(strcmp(properties(obj),'bIms'))
                if ~any(strcmp(properties(obj),'mm')) || obj.mm == 0
                    fI=obj.colonies(colnum).assembleColony(usedir,obj.chans,obj.bIms,obj.nIms);
                else
                    fI=obj.colonies(colnum).assembleColonyMM(usedir,acoords,obj.si,obj.bIms,obj.nIms);
                end
            else
                fI=obj.colonies(colnum).assembleColony(usedir,obj.chans);
            end
        end
        
        function [rA, rAerr]=radialAverageOverColonies(obj,colinds,column,ncolumn,binsize,compfrom)
            
            if ~exist('compfrom','var')
                compfrom=0;
            end
            
            rA=zeros(round(5000/binsize),1); rA2=rA; counter=rA;
            for ii=1:length(colinds)
                [rAnow cibnow]=obj.colonies(colinds(ii)).radialAverage(column,ncolumn,binsize,compfrom);
                npoints=length(rAnow);
                if npoints > length(rA)
                    continue;
                end               
                rA(1:npoints)=rA(1:npoints)+rAnow.*cibnow;
                rA2(1:npoints)=rA2(1:npoints)+rAnow.*rAnow.*cibnow;
                counter(1:npoints)=counter(1:npoints)+cibnow;
            end
            
            rA=rA./counter;
            rA2=rA2./counter;
            rAerr=sqrt(rA2-rA.*rA);
            badinds=isnan(rA);
            rA(badinds)=[]; rAerr(badinds)=[];
        end
        
        function colData=getColonyData(obj,colinds,column,ncolumn,binsize,compfrom)
           %returns radial average for each colony, colData is a cell array with
            for ii=1:length(colinds)
                [colData(ii).data colData(ii).cellsinbin]=obj.colonies(colinds(ii)).radialAverage(column,ncolumn,binsize,compfrom);
            end
        end
        
        
    end
    
end