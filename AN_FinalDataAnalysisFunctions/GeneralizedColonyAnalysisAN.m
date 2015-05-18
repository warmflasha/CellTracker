
% function to plot  the results of colony-size-dependent analysis.
% all the arguments are the same as described in the MMrunscriptsAN and
% 'plotallanalysisAN' function
% see also: plotallanalysisAN,MMrunscriptsAN


function [] = GeneralizedColonyAnalysisAN(thresh,nms,nms2,midcoord,fincoord,index1,param1,plottype)
if plottype == 1
    for k=1:size(nms,2)
        
        filename{k} = ['.' filesep  nms{k} '.mat'];
        
        load(filename{k},'peaks','dims','plate1');
        colonies{k} = plate1.colonies;
        if ~exist('plate1','var')
            [colonies{k}, ~]=peaksToColonies(filename);
        end
        M(k) = max([colonies{k}.ncells]);
        
        
        
        [toplot,peaks] = GetSeparateQuadrantImgNumbersAN(nms2,peaks,dims,midcoord,fincoord);
        
    end
    M = max(M);
    
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
    [totalcells] = PlotColAnalysisQuadrAN(coloniesnew,M,thresh,nms2,param1,index1);
end

if plottype == 0 % do NOT need to separate into quadrants
    for k=1:size(nms,2)
        
        filename{k} = ['.' filesep  nms{k} '.mat'];
        
        load(filename{k},'plate1');
        colonies{k} = plate1.colonies;
        if ~exist('plate1','var')
            [colonies{k}, ~]=peaksToColonies(filename);
        end
        M(k) = max([colonies{k}.ncells]);
        
    end
    M = max(M);
    [totalcells] = PlotColAnalysisQuadrAN(colonies,M,thresh,nms2,param1,index1); % separate function which does the plotting
    
end
end
