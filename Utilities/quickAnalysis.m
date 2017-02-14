function [ allPeaks,tidyPosMeansNuc,tidyPosMeansCyto,plotX ] = quickAnalysis(setAnalysisParam)
%quickAnalysis throws together commonly used plots for a directory of
%output files
%  reads the outfiles directory, has inputs to
%  match positions with conditions

%  maybe it calls an analysis parameter file specific to dataset
%  

%  
%  uses global parameter file "scripts&paramfiles/setAnalysisParams"
%
%  assumes '/outfiles' contains separate matfiles containing a peaks array for each
%  position
%
%%
addpath(genpath(cd),'-begin');
global analysisParam;

try
    eval(setAnalysisParam);
catch
    error('Could not evaluate paramfile command');
end
mkdir('Figures');
%% read in outfiles into allPeaks, an mxn cell where m is positions and n is conditions
 
 allPeaks = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));
for iPos = 0:analysisParam.nPos-1;
   load(['Outfiles' filesep 'pos' int2str(analysisParam.positionConditions(iPos+1)) '.mat'],'peaks');
   allPeaks{iPos+1} = peaks;
    clear('peaks');
    % load the index of the position, then use that toassign the second
    % value

end


%% a few calculations
nuc2nucRatioMeans = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));
%nuc2nucRatioStd = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));

nuc2cytoRatioMeans = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));
%nuc2cytoRatioStd = cell(size(analysisParam.positionConditions,1),size(analysisParam.positionConditions,2));

% find position averages
for iPos = 1:analysisParam.nPos;
    for iTime = 1:length(allPeaks{1})-1;
        if ~isempty((allPeaks{iPos}{iTime}));
        nuc2nucRatioMeans{iPos}(iTime) = meannonan(allPeaks{iPos}{iTime}(:,6)./allPeaks{iPos}{iTime}(:,5));
        nuc2cytoRatioMeans{iPos}(iTime) = meannonan(allPeaks{iPos}{iTime}(:,6)./allPeaks{iPos}{iTime}(:,7));
        else
         nuc2nucRatioMeans{iPos}(iTime) = nan;
        nuc2cytoRatioMeans{iPos}(iTime) = nan;   
        end
    end
end

for iCon = 1:analysisParam.nCon;
%subplot(analysisParam.nCon,1,iCon); hold on;
for iPos = 1:analysisParam.nPosPerCon;
tidyPosMeansNuc{iCon}(iPos,:) = nuc2nucRatioMeans{iCon,iPos};
tidyPosMeansCyto{iCon}(iPos,:) = nuc2cytoRatioMeans{iCon,iPos};
end
end

% determine array of x values for plotting
plotX = (0:length(allPeaks{1})-2)*analysisParam.nMinutesPerFrame./60;
plotX = plotX-analysisParam.tLigandAdded;

%% plotting

% plot each position
plotColors = distinguishable_colors(analysisParam.nCon);

figure(analysisParam.fig); clf;
pNum = 8;
for iCon = 1:4;
    
subplot(ceil(analysisParam.nCon./4),ceil(analysisParam.nCon./2),iCon); hold on;

plot(plotX,tidyPosMeansNuc{iCon}','Color',plotColors(iCon,:));
title(analysisParam.conNames{iCon});
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yNuc ' (nuc)']);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
ylim([0.75,1.2]);
xlim([min(plotX),max(plotX)]);
pNum = pNum -1;
end

savefig(['Figures' filesep 'SignalingByPositionNuc2Nuc.fig']);

iFig = analysisParam.fig+1;

figure(iFig); clf;
for iCon = 1:analysisParam.nCon;
subplot(ceil(analysisParam.nCon./2),ceil(analysisParam.nCon./2),iCon); hold on;

plot(plotX,tidyPosMeansCyto{iCon}',plotColors(iCon));
xlim([min(plotX),max(plotX)]);
title(analysisParam.conNames{iCon});
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yMolecule ' (cyto)']);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
end

savefig(['Figures' filesep 'SignalingByPositionNuc2Cyto.fig']);

iFig = iFig+1;

% plot position means without std
figure(iFig); clf;
subplot(1,2,1); hold on;
for iCon = 1:analysisParam.nCon;
plot(plotX,mean(tidyPosMeansNuc{iCon}))
end
xlim([min(plotX),max(plotX)]);
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yNuc ' (nuc)']);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
legend(analysisParam.conNames);
subplot(1,2,2); hold on;
for iCon = 1:analysisParam.nCon;
plot(plotX,mean(tidyPosMeansCyto{iCon}))
end
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yMolecule ' (cyto)']);
xlim([min(plotX),max(plotX)]);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
legend(analysisParam.conNames);
savefig(['Figures' filesep 'SignalingNoError.fig']);


iFig = iFig+1;

% plot position means with std
figure(iFig); clf;
subplot(1,2,1); hold on;
for iCon = 1:analysisParam.nCon;
errorbar(plotX,mean(tidyPosMeansNuc{iCon}),std(tidyPosMeansNuc{iCon}));
end
xlim([min(plotX),max(plotX)]);
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yNuc ' (nuc)']);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
legend(analysisParam.conNames);
title('errorbars = std of image means');
subplot(1,2,2); hold on;
for iCon = 1:analysisParam.nCon;
errorbar(plotX,mean(tidyPosMeansCyto{iCon}),std(tidyPosMeansCyto{iCon}));
end
ylabel([analysisParam.yMolecule ' (nuc) : ' analysisParam.yMolecule ' (cyto)']);
xlim([min(plotX),max(plotX)]);
xlabel(['time after ' analysisParam.ligandName ' added (hours)']);
legend(analysisParam.conNames);
title('errorbars = std of image means');
savefig(['Figures' filesep 'SignalingWithError.fig']);

% plot average number of cells detected in each position (with std)
figure(iFig); clf; hold on;
for iCon = 1:analysisParam.nCon;
    for iPos = 1:analysisParam.nPosPerCon;
        for iTime = 1:length(allPeaks{1})-1;
    cellCount(iTime) = size(allPeaks{iPos,iCon}{iTime},1);
        end
        subplot(ceil(analysisParam.nCon./2),ceil(analysisParam.nCon./2),iCon); hold on;
        plot(plotX,cellCount);
        legend(int2str([1:analysisParam.nPosPerCon]'));
        xlabel('time (hours)');
        title(analysisParam.conNames{iCon});
        ylabel('# detected cells');
    clear('cellCount');
    end
    
end
savefig(['Figures' filesep 'cellCounts.fig']);
save('quickAnalysisOutput.mat','tidyPosMeansNuc','tidyPosMeansCyto','nuc2nucRatioMeans','nuc2cytoRatioMeans','plotX','allPeaks');
end

