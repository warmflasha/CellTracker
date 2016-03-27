function [outdat, statsN] = runOneVsiFile(filename,chan,paramfile)

global userParam;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

if isdir(filename)
    ff = dir([filename filesep '*.vsi']);
    file_to_use = [filename filesep ff(1).name];
else
    file_to_use = filename;
end

imgs = bfopen(file_to_use);

imgs = imgs{1};

nuc = imgs{chan(1),1};

for ii = 2:length(chan)
    fimg(:,:,ii-1) = imgs{chan(ii),1};
end


[nuc, fimg] = preprocessImages(nuc,fimg);
[outdat, ~, statsN] = image2peaks(nuc,fimg);
