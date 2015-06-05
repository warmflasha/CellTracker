function p = InitializeExptest(dir1, z1, pos, sn, sname)
% Initialize variables containing information about the experiment. Change
% "p.exp.path" to the name of the folder where you extracted spatzcells.zip
% 

%% GENERAL INFORMATION
p.exp.path          = dir1; % !!! CHANGE VARIABLE TO YOUR COMPUTER PATH

z = z1(1) - 1;
%% IMAGE INFORMATION
p.image.zrange      = 0:z;
p.image.base_name   = 'fish';

%% SEGMENTATION INFORMATION
p.seg.dir           =  [p.exp.path '/masks/'];   
p.seg.base_name     =  'fishsegtest';

%% SAMPLES INFORMATION
% image numbers




% BW14894
for i = 1:length(pos)
p.sample{i}.idx  = 0:pos(i)-1; 
p.sample{i}.name = sname{i};
end
% TK310, 1mM IPTG, 0.03mM cAMP
            % TK310, 1mM IPTG, 10mM cAMP

% sample names
%  p.sample{1}.name    = 'Negative Control';
%  p.sample{2}.name    = 'Activin';
%  p.sample{3}.name    = 'SB';

%% INDEX MAPPING VARIABLES
% Each sample has 20 images, for schnitcells and spatzcells we use a consecutive numbering, 
% going from 1 to 60. 

max_image_num = 0;
n_frame = 0;
for n_sample = 1:numel(p.sample)  
    if numel(p.sample{n_sample}.idx) >= max_image_num, 
        max_image_num = numel(p.sample{n_sample}.idx);
    end

    for n_image = p.sample{n_sample}.idx
        n_frame = n_frame + 1;
    end
end

p.exp.totalframes   = n_frame;
p.exp.frm2spl       = zeros(p.exp.totalframes,1);
p.exp.frm2img       = zeros(p.exp.totalframes,1);
p.exp.frm_spl_img   = zeros(p.exp.totalframes,3);
p.exp.splimg2frm    = zeros(numel(p.sample),max_image_num); 
p.exp.sampleList    = 1:sn;


n_frame = 0;
for n_sample = 1:numel(p.sample)
    for n_image = p.sample{n_sample}.idx
        n_frame = n_frame + 1;
        p.exp.frm2spl(n_frame) = n_sample;
        p.exp.frm2img(n_frame) = n_image;
        p.exp.frm_spl_img(n_frame,:) = [n_frame n_sample n_image];
        p.exp.splimg2frm(n_sample,n_image+1) = n_frame;
    end
end

return