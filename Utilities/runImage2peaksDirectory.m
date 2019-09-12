function runImage2peaksDirectory(dir_name)
ff = dir([dir_name filesep '*.tif']);
for ii=1:length(ff)
    h5name = geth5name2(ff(ii).name,'_Simple Segmentation');
    h5file = fullfile(dir_name,'DAPI',h5name);
    mask = readIlastikFile(h5file,true);
    allimgs = bfopen(fullfile(dir_name,ff(ii).name));
    outdat{ii} = image2peaks(allimgs{1}{1,1},cat(3,allimgs{1}{2:4,1}),mask);

end
save(fullfile(dir_name,'outdat.mat'),'outdat');