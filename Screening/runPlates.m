function runPlates(screennum,platenums,basedirec)

if ~exist('basedirec','var')
    basedirec = '~/Desktop/ScreenData';
end

for ii=1:length(platenums)
    pn = int2str(platenums(ii));
    if length(pn) == 1
        pn = ['0' pn];
    end
    direc=[basedirec filesep 'S' int2str(screennum) '-MP-' pn];
    outfile = [direc '.mat'];
    run384(direc,outfile,'setUserParamBenoitGFPS4AW');
end