%%

% checking parameter file.
[outdat, nuc, fimg] = runOneMM(ff, 493 , bIms, nIms, 'setUserParamCG');

 x = outdat(:,1);
 y = outdat(:,2);
 
 figure; imshow(nuc,[]);
 hold on;
 
 for i = 1:size(outdat,1)
     plot(x,y,'r*');
 end
 
 %%
 % Running segmentation for the entire dataset.
 tic;
 %eval('setUserParamCGs');
 %save([direc filesep outfile], 'userParam', '-append');
 
 runFullTileMM('.', 'outputn.mat', 'setUserParamCGs', 5);
 load('outputn.mat');
 plate1
 toc;