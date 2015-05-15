

function [] = GeneralizedColonyAnalysisAN(filename,thresh,nms,nms2,peaks,toplot,index1,param1,plottype)

for k=1:size(nms,2)
    %
    %     if exist('plate1');
    load(filename{k},'plate1');
    disp([filename,'plate1']);
    %
    colonies{k} = plate1.colonies;
    %    if ~exist('plate1','var')
    %             [colonies{k}, ~]=peaksToColonies(filename);
     M(k) = max([colonies{k}.ncells]);        
end
M = max(M(k));
if plottype == 0 % do NOT need to separate into quadrants
    
    [totalcells]=PlotColAnalysisQuadrAN(colonies,M,thresh,nms2,param1,index1); % separate function which does the plotting
    
end

if plottype == 1 %% you DO need to separate into quadrants
    
    quadrants =zeros(length(peaks),1);
    for ii=1:length(toplot)
        quadrants(toplot{ii})=ii;
        coloniesnew{ii}=[];
    end
    for ii=1:length(colonies{1})
        j=unique(quadrants(colonies{1}(ii).imagenumbers));
        if length(j) > 1 || j==0
            disp(['Error colony is in more than one Quadrant: ' int2str(ii)])
        else
            if isempty(coloniesnew{j})
                coloniesnew{j}=colonies{1}(ii);
            else
                coloniesnew{j}(end+1)=colonies{1}(ii);
            end
        end
    end
    
    
    %M(k) = max([coloniesnew{k}.ncells]);
    [totalcells] = PlotColAnalysisQuadrAN(coloniesnew,M,thresh,nms2,param1,index1);
    
    
end
end