function [ allChannelsRatios ] = allPeaks2Ratios( allPeaks )
%allPeaks2Ratios outputs each channel's mean nuclear intensity normalized
%to the nuclear channel (e.g., GFP nuc / DAPI)

%future TO DO:
% currently relies on second dim of peaks array to determine number of channels and
% will not work if peaks array contains extra columns, such as colony
% information


possibleFimgChannels = [6 8 10];


for iCon = 1:size(allPeaks,1)
    for iPos = 1:size(allPeaks,2);
        if size(allPeaks{iCon,iPos},2)==11
            fimgChannels = possibleFimgChannels;
        end
        if size(allPeaks{iCon,iPos},2)==9
            fimgChannels = possibleFimgChannels(1:2);
        end
        if size(allPeaks{iCon,iPos},2)==7
            fimgChannels = possibleFimgChannels(1); %this may be incorrect for peaks arrays generated on only a nuc and single fimg channel
        end
        allChannelsRatios{iCon,iPos} = allPeaks{iCon,iPos}(:,possibleFimgChannels)./allPeaks{iCon,iPos}(:,[5 5 5]);
        
    end
end
 
