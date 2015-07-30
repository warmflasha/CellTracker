%%
% Make sure that the images folders do not have any subfolders 
% dir1 is the path of directory that contains images of all the samples. 
% Specify the negative sample
% Specify the negative sample threshold as percentage
% Specify the intensity threshold in the function
% 'InitializeSpotRecognitionParameterstest'.
% Tabulated mRNA results are stored in results folder in the matrix finalmat. 


clear all;
dir1 = '.';
%dir1 = '/Users/sapnac18/Desktop/150712fishmp/imagess1/Test Sample FISH';

allSubFolders = genpath(dir1);

negsamp = 2;%%% Removing False Positives, nch = Specify the negative sample number
negperc = 90;

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
%nch = channel number to be analysed
%%
m = 1; % variable that stores mask numbers for each frame, m = 1 for frame 0, m = 2 for frame 1 and so on. 
%j = 2;
for j = 2:numberOfFolders

    clear ff;
    ff = readAndorDirectorymont(listOfFolderNames{j});
     pos(j-1) = length(ff.p);  %%saving parameters
     z1(j-1) = length(ff.z);
     sname{j-1} = ff.prefix;
     l = length (ff.p)-1; %% l: reference to the last position 
     st = ff.p(1);
     imch = length(ff.w)-1;
     
     %i = 0;
     for i = st:l
          
      [LcFull]=mask60XCT(ff,i);
     %[LcFull] = mask60Xall(ff,i); % colony as one cell/ cell information not separated. 
     
      save(fn,'LcFull');
      close all;
    
     % Saving imagefiles to the output variable
      Nucmask{m} = compressBinaryImg(LcFull, size(LcFull));
      errorstr{m} = sprintf('sample%02d_pos%02d', j-1, i);
      nucfile{m} = sprintf('sample%02d_pos%02d', j-1, i);
      smadfile{m} = sprintf('sample%02d_pos%02d', j-1, i);
      
      m = m+1;
     end
end


%%
% Making a new folder with just fluorescent images of each channel
% Channel for calculating mRNA 

 
 imc=[1:imch]; % Channel no. to be analyzed

 for im = 1:length(imc)
 imf =sprintf('images%02d', imc(im)); 
 mkdir(dir1, imf);
 
for k = 2 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
    filePattern = sprintf('%s/*_w%04d.tif', thisFolder, imc(im));
	baseFileNames = dir(filePattern);
    nfiles = length(baseFileNames);
    
    for i = 1:nfiles
        s = strcat(thisFolder, '/', baseFileNames(i).name);
        imn =sprintf('/images%02d/', imc(im)); 
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

nch = 2; %channel to be analysed

%TestSpotThreshold(dir1, z1, pos, sn, nch, sname); % to determine appropriate threshold
RunSpotRecognitiontest(dir1, z1, pos, sn, nch, sname);
%%
nch = 1;
negperc = 55;
negsamp = 2;
z1 = [25 25];
pos = [12 12];
sn = 2;
dir1 = '.';

for i = 1:sn
    sname{i} = sprintf('sample%d', i);
end
    

GroupSpotsAndPeakHistsTest(dir1, z1, pos, sn, nch, negsamp, sname, negperc);

GetSingleMrnaIntTest(dir1, z1, pos, sn, nch, sname);

GroupCellSpotsTest(dir1, z1, pos, sn, nch, sname);

%%
n_ch = [1 2 3]; % Channels that are analysed and need to be tabulated. List out all the channels that need to be tabulated.
sn = 2;
%dir1 = pwd;

tabulatemRNAposfish(dir1, sn, n_ch, Nucmask, errorstr, nucfile, smadfile);

