%Reading just one file
%Set Parameters in Parameter file

 ii = 2;
 
 ff=readAndorDirectory('.');
 runOneAndor(ff, 'setUserParamCG', ii, [], []);
 
