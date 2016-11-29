%%
% run the data analysis overnight

%runFullTileMM('control','control.mat','setUserParamAN20X_uCOL');% 
%runFullTileMM('otherMEKi_R','otherMEKi_R.mat','setUserParamAN20X_uCOL');% 
runFullTileMM('area2_noPattern','area2_noPattern.mat','setUserParamAN20X_uCOL');% 



disp('successfully ran');



%%
% script to run the colony grouping
direc = '/Volumes/data2/Anastasiia/totestClonyGrouping/torun';
paramfile = '/Volumes/data2/Anastasiia/totestClonyGrouping/torun/setUserParamAN20X_uCOL.m';
run(paramfile);


ff = dir(direc);
for k=1:size(ff,1)
   if isdir(ff(k).name) == 0
   outfile = ff(k).name;
   load([direc filesep outfile],'bIms','nIms','dims');
   [colonies, peaks]=peaksToColonies([direc filesep outfile]);


%     plate1=plate(colonies,dims,direc,ff.chan,bIms,nIms, outfile);
%
%     plate1.mm = 1;
%     plate1.si = size(bIms{1});
    %save([direc filesep outfile],'plate1','peaks','-append');
    save([direc filesep outfile],'colonies','peaks','-append');
   end
end
