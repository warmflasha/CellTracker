function olympusToMMbtfclusterrun(filenames, MMdirec)
tic;
% files = olympusToMM(MMdirec,filenames,chan,imsize)
%------------------------------------------------------
% Convert from Olympus output large tiled image into a directory with a
% subdirectory for each postion.
% inputs:   MMdirec - name of output directory
%           filenames - cell array of input file names, one for each
%               channel
%           chan - channel names. will be used for the image names in
%               micromanager
%           imsize - size of individual images to break the image into
%           (default is 2048x2048).



imsize = [2048 2048];

h = imread(filenames,1);
n_width = size(h,2)/imsize(1);
n_height = size(h,1)/imsize(2);

if ~isinteger(n_width)
    n_width = floor(n_width) + 1;
end
if ~isinteger(n_height)
    n_height = floor(n_height)+1;
end

%for ii = 1
    %for jj = 1
for ii = 1:n_width
    %for jj = 1:n_height
        
    scriptfile = [MMdirec filesep 'jobscripts' filesep 'jobcl' int2str(ii) '.slurm'];
    fid = fopen(scriptfile,'w');
    fprintf(fid, '#!/bin/bash \n');
    fprintf(fid,['#SBATCH --job-name=job' int2str(ii) '\n']); 
    fprintf(fid, '#SBATCH --ntasks=1 \n');
    fprintf(fid,'#SBATCH --partition=serial\n');
    %fprintf(fid,'#SBATCH --nodes=2 \n');
    
  
    fprintf(fid,'#SBATCH --time=00:10:00 \n');
   
    
    fprintf(fid,'#SBATCH --mail-type ALL \n');
    fprintf(fid,'#SBATCH --mail-user sc65@rice.edu \n');  
    fprintf(fid, '#SBATCH --account=commons \n'); 
    fprintf(fid, 'echo "My job ran on:" \n');
    fprintf(fid, 'cat $SLURM_NODELIST \n');
    
    %fprintf(fid,['matlab -nodisplay -r "addpath(genpath(''/home/sc65/CellTracker'')); RunSpotRecognitioncluster(''' direc ''', ''' paramfile ''');  quit"']);
    fprintf(fid, ['matlab -nodisplay -r "olympusToMMbtfcluster(''' MMdirec ''', ''' filenames ''', ' int2str(ii) '); quit"']);
    fclose(fid);
    system(['sbatch ' scriptfile]);
       
    %end
end





toc;
end
