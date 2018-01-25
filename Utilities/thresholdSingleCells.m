function [ singleCellsThresh ] = thresholdSingleCells( singleCells,threshChannel,thresh )
%thresholdSingleCells outputs singleCellsThresh, a variable in the same
%format as singleCells but excludes cells that are beneath a minimum ratio
%for the specified channel
%   % for now assumes thresh is in ratio of threshChannel/nucChannel

% main loop over singleCells
for iSingleCells = 1:length(singleCells);
    %loop over any time points
    for iTime = 1:length(singleCells{iSingleCells});
        %find indexes of cells with channel ratio above thresh
        tempRatios = singleCells{iSingleCells}{iTime}(:,threshChannel)./singleCells{iSingleCells}{iTime}(:,5);
        threshIndex = find(tempRatios > 0.45);
        
        singleCellsThresh{iSingleCells,1}{iTime} = singleCells{iSingleCells,1}{iTime}(threshIndex,:);
    end
end



end

