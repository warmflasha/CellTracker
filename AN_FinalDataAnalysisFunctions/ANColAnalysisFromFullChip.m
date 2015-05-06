%
% this function loads the colony structure or runs peakstocolonies ( if the
% plate1 for a given matfile does not exist)
% then the colony structure from full chip is separated into colonies,
% corresponding to each quadrant, which forms Nplot of 'coloniesnew'
% the image numbers which correspond to separate quadrants are obtaine
% using a function 'GetSeparateQuadrantImgNumbersAN', which outputs the
% 'toplot' cellarray
% another generalized function (PlotColAnalysisFullChipAN) plots the standard colony analysis resuts:
%  fraction of genepositive cells, colonies as a f(colony size) and the
%  colony size distribution.
% thresh = defined based on the scatter plot results 
% index1,param1,Nplor,nms,nms2,midcoord and fincoord = as explained in the MeansFromQuadrantsOfFullChip
% 
% see also: MeansFromQuadrantsOfFullChip

function [totalcells] = ANColAnalysisFromFullChip(Nplot,nms,thresh,nms2,param1,index1,midcoord,fincoord)

for k=1
    % colonies{k}=[];
    filename = ['.' filesep  nms{k} '.mat'];
    
    load(filename);
    if exist('plate1');
        
        disp([filename,'plate1']);
        
        colonies{k} = plate1.colonies;
    else
        
        disp(filename);
        [colonies{k}, peaks]=peaksToColonies(filename);% the choice to run the single cell or circular data is now done within the peakstocolonies function
        
    end
end

[toplot,peaks] = GetSeparateQuadrantImgNumbersAN(Nplot,filename,midcoord,fincoord);

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

M=max([colonies{1}.ncells]);

[totalcells] = PlotColAnalysisFullChipAN(Nplot,coloniesnew,M,thresh,nms2,param1,index1);


end