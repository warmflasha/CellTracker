%%
% run the data analysis overnight

runFullTileMM('controlGATA3cdx2','controlGATA3cdx2.mat','setUserParamAN20X_uCOLlargeCircles');% 
runFullTileMM('10ngmlBMP4gata3cdx2','10ngmlBMP4gata3cdx2.mat','setUserParamAN20X_uCOLlargeCircles');% 


disp('successfully ran uCol with GATA# and CDX2 staining ');

%%
% script to run the colony grouping
direc = '/Volumes/data2/Anastasiia/totestClonyGrouping/torun';
paramfile = '/Volumes/data2/Anastasiia/totestClonyGrouping/setUserParamAN20X_uCOL.m';
run(paramfile);

ff = readMMdirectory(direc);
ff = dir(direc);
for k=1:size(ff,1)
    if isdir(ff(k).name) == 0
    outfile = ff(k).name;
    load([direc filesep outfile],'bIms','nIms','dims','colonies');
    [colonies, peaks]=peaksToColonies([direc filesep outfile]);
    
    
    plate1=plate(colonies,dims,direc,ff.chan,bIms,nIms, outfile);

    plate1.mm = 1;
    plate1.si = size(bIms{1});
     save([direc filesep outfile],'plate1','peaks','-append'); 
    % save([direc filesep outfile],'colonies','peaks','-append'); 
    end
end


