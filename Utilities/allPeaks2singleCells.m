function [ singleCells ] = allPeaks2singleCells( allPeaks )
%allPeaks2singleCells reformats allPeaks so that it is position agnostic
%   
% 
global analysisParam;
for iCon = 1:analysisParam.nCon;
    %for each position
    for iPos = 1:analysisParam.nPosPerCon;
        
        %for each timepoint
        for iTime = 1:length(allPeaks{iCon,iPos})
            if iPos == 1;
            singleCells{iCon}{iTime}=allPeaks{iCon,iPos}{iTime};
            else
                singleCells{iCon}{iTime}=[singleCells{iCon}{iTime};allPeaks{iCon,iPos}{iTime}];
            end
        end
    end
end
           

end

