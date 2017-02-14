function [ allPeaks ] = getAllPeaks
%getAllPeaks reads peaks array in outfiles from a directory defined in analysisParam 
%            into allPeaks, an mxn cell where m is positions and n is conditions
%   
global analysisParam;
 allPeaks = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));
for iPos = 0:analysisParam.nPos-1;
   load([analysisParam.outDirec filesep 'pos' int2str(analysisParam.positionConditions(iPos+1)) '.mat'],'peaks');
   allPeaks{iPos+1} = peaks;
    clear('peaks');
    
end

plotX = (0:length(allPeaks{1})-2)*analysisParam.nMinutesPerFrame./60;
analysisParam.plotX = plotX-analysisParam.tLigandAdded;
end

