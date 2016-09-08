%%
% run the data analysis overnight

% 

runFullTileMM('pluri_30um1','pluri_30um1.mat','setUserParamAN20X_uCOL');% 
runFullTileMM('pluri_62um1','pluri_62um1.mat','setUserParamAN20X_uCOLlargeCircles');% 

runFullTileMM('diff_30um','diff_30um.mat','setUserParamAN20X_uCOL');
runFullTileMM('diff_62um','diff_62um.mat','setUserParamAN20X_uCOLlargeCircles');


disp('successfully ran density exper')




templateSplitOlympData



