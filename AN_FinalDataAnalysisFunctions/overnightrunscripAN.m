%%
% run the data analysis overnight

% 
runFullTileMM('control','controlsparse.mat','setUserParamAN20X_uCOL');

disp('successfully ran control sparse')

runFullTileMM('10ngmlBMP4','10ngmlBMP4sparse.mat','setUserParamAN20X_uCOL');% 

disp('successfully ran  10ngml bmp4 sparse')

