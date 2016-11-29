function setAnalysisParam
% for use with quickAnalysis function

global analysisParam;

fprintf(1, '%s called to define params\n',mfilename);
analysisParam.nPos = 24; %total number of positions in dataset
analysisParam.nCon = 4; %total number of separate conditions
analysisParam.nPosPerCon = 6; %set how many positions per condition
analysisParam.nMinutesPerFrame = 15; %minutes per frame
analysisParam.tLigandAdded = 2; %time ligand added in hours
analysisParam.ligandName = 'TNFalpha';
analysisParam.backgroundPositions = nan; %array of positions for bg subtraction
analysisParam.positionConditions = ([0:5;6:11;12:17;18:23]') %corresponds to
                                    %which positions belong to each condition
analysisParam.yMolecule = 'RelA-YFP';
analysisParam.yNuc = 'CFP-H2B';
analysisParam.fig = 20; %set which figure to start plotting at

analysisParam.conNames = {'+TNFa, +MG132';'-TNFa, +MG132';'+TNFa, +Cycloheximide';'-TNFa, +Cycloheximide'};


end