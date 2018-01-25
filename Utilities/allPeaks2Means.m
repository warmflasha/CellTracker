function [ allMeans2 allStds ] = allPeaks2Means( allPeaks )
%allPeaks2Means outputs each position's mean into allMeans and the std of
%the means of each position into allStds

allRatios = allPeaks2Ratios(allPeaks);
for iCon = 1:size(allPeaks,1)
    for iPos = 1:size(allPeaks,2);
        allMeans{iCon,iPos} = mean(allRatios{iCon,iPos});
    end
end

for iCon = 1:size(allPeaks,1)
    for iPos = 1:size(allPeaks,2);
        conTemp(iPos,:) = allMeans{iCon,iPos};
    end
    allMeans2(iCon,:) = mean(conTemp);
    allStds(iCon,:) = std(conTemp);
end



end

