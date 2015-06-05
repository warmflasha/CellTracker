%%

% Make sure that the images folders do not have any subfolders 
% dir1 is the path of directory that contains images of all the samples. 

dir1 = '/Users/sapnac18/Desktop/CellTracker/cell_images/fish2/moreimages';


allSubFolders = genpath(dir1);

% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ':');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

sn = numberOfFolders - 1; % sn = no. of samples

mkdir(dir1, 'masks');

%%
% z = z range (assuming it to be the same for all samples)
% pos =  no. of positions
% sn = no. of different samples (Andor stores images as one folder for
% each sample)
% sname = name of each sample
%%
m = 1; % variable that stores mask numbers for each frame, m = 1 for frame 0, m = 2 for frame 1 and so on. 

for j = 2:numberOfFolders

    
    ff = readAndorDirectory(listOfFolderNames{j});
    
     pos(j-1) = length(ff.p);  %%saving parameters
     z1(j-1) = length(ff.z);
     sname{j-1} = ff.prefix;

   
     
     
     l = length (ff.p)-1; %% l: reference to the last position 
     st = ff.p(1);
     
     
     for i = st:l
        
     LcFull=mask60XCT(ff,i);
     
     file = sprintf('fishsegtest%02d.mat', m);
     fn = strcat(dir1, '/masks/', file); 
     save(fn,'LcFull');
     m = m+1;
     close all;
    end
end





%%
% Making a new folder with just fluorescent images of each channel

 
 c=[1,2]; % Channels to be analysed.

 for im = 1:length(c)
 imf =sprintf('images%02d', im); 
 mkdir(dir1, imf);
 
for k = 2 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
    filePattern = sprintf('%s/*_w%04d.tif', thisFolder, im);
	baseFileNames = dir(filePattern);
    nfiles = length(baseFileNames);
    
    for i = 1:nfiles
        s = strcat(thisFolder, '/', baseFileNames(i).name);
        imn =sprintf('/images%02d/', im); 
        s1 = strcat(dir1, imn);
        
        copyfile(s, s1);
        s2 = strcat(s1,baseFileNames(i).name);
        
        bo = baseFileNames(i).name;
        br = strtok(baseFileNames(i).name, '_');
        bn = sprintf('fish%01d', k-1);
        imgname = strrep(bo, br, bn);
        
        s3 = strcat(s1, imgname);
        movefile(s2,s3);
    end
end
 end
 


%% Quantifying mRNA 
% Note: each section below can be run only after the previous one has been
% run.
% 
%Spatzcell code begins!
dir1 = '/Users/sapnac18/Desktop/CellTracker/cell_images/fish2/moreimages';
z1 = [7,7,7,7];
pos = [11,15,15,11];

for i = 1:4
    fn = sprintf('fishsc%01d', i);
    sname{i} = fn;
end
sn = 4;
nch = 2; %channel to be analysed
%TestSpotThreshold(dir1, z1, pos, sn, nch, sname); Run this file to check
%the intensity threshold. 
RunSpotRecognitiontest(dir1, z1, pos, sn, nch, sname);
%%
dir1 = '/Users/sapnac18/Desktop/CellTracker/cell_images/fish2/moreimages';
z1 = [7,7,7,7];
pos = [11,15,15,11];
for i = 1:4
    fn = sprintf('fishsc%01d', i);
    sname{i} = fn;
end
sn = 4;
nch = 1; 
negsamp = 1;%%% Removing False Positives, nch = Specify the negative sample number
negperc = 70;
GroupSpotsAndPeakHistsTest(dir1, z1, pos, sn, nch, negsamp, sname, negperc);
%% 
%Spot Intensity Histograms, before and after removing false positives.
SpotIntHistsTest(dir1, z1, pos, sn,  nch, sname);
%%
GetSingleMrnaIntTest(dir1, z1, pos, sn, nch, sname);


%%
GroupCellSpotsTest(dir1, z1, pos, sn, nch, sname);

%%

dir1 = '/Users/sapnac18/Desktop/CellTracker/cell_images/fish2/moreimages';

n_ch = 2; % No. of channels
sn = 4; % No. of samples
tabulatemRNAposfish(dir1, sn, n_ch);
