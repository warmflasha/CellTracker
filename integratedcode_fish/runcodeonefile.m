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

sn = numberOfFolders - 1;

mkdir(dir1, 'masks');
%mkdir(dir1, 'spots_quantify');

%%
% z = z range (assuming it to be the same for all samples)
% pos =  no. of positions
% sn = no. of different samples (Andor stores images as one folder for
% each sample)
% sname = name of each sample
%%
m = 1;
for j = 2:numberOfFolders
    
    ff = readAndorDirectory(listOfFolderNames{j});
    
     pos(j-1) = length(ff.p);  %%saving parameters
     z1(j-1) = length(ff.z);
     sname{j-1} = ff.prefix;

     %sname1 = sprintf('sname%01d', j-1);
     
     
     l = length (ff.p)-1; %% Makin g masks
     st = ff.p(1);
    for i = st:l
    [od, mask, nuc, fimg, LcFull]=runOneAndorMask(ff,'setUserParamSapna_60X_1',i,[],[]);
     file = sprintf('fishsegrtest%0d.mat', m);
     save([dir1 '/masks/' file ],'LcFull');
     m = m+1;
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
%TestSpotThreshold(dir1, z1, pos, sn, nch, sname);
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
nch = 2; 
negsamp = 1;%%% Removing False Positives, nch = Specify the negative sample number
GroupSpotsAndPeakHistsTest(dir1, z1, pos, sn, nch, negsamp, sname);
%% 
%Spot Intensity Histograms, before and after removing false positives.
SpotIntHistsTest(dir1, z1, pos, sn,  nch, sname);
%%
GetSingleMrnaIntTest(dir1, z1, pos, sn, nch, sname);

%%
GroupCellSpotsTest(dir1, z1, pos, sn, nch, sname);

