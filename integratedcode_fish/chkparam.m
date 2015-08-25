%Reading just one file
%Set Parameters in Parameter file

 ii = 1;
 
 ff=readAndorDirectory('.');
 runOneAndor(ff, 'setUserParamSapna', ii, [], 0);
 
