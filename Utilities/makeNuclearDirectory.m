function makeNuclearDirectory(curr_dir,nuc_chan,nuc_dir)
% Function to write nuclear images from full images
% --------------------------------------------------
% makeNuclearDirectory(curr_dir,nuc_chan,nuc_dir)
% curr_dir - directory of images
% nuc_chan - channel number of nuclear image
% nuc_dir - name of output directory (will be inside curr_dir and will 
%           be created if does not exist


if ~exist('nuc_dir','var')
    nuc_dir = 'DAPI';
end

if ~exist('nuc_chan','var')
    nuc_chan = 1;
end

nuc_dir_full = [curr_dir filesep nuc_dir];

if ~exist(nuc_dir_full,'dir')
    mkdir(nuc_dir_full)
end

ff = dir([curr_dir filesep '*.tif']);

for ii = 1:length(ff)
    infile = fullfile(curr_dir,ff(ii).name);
    outfile = fullfile(nuc_dir_full,ff(ii).name);
    img = imread(infile,nuc_chan);
    imwrite(img,outfile);
end