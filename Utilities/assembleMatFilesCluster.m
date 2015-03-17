function assembleMatFilesCluster(direc,outfile)

[~,ff]=folderFilesFromKeyword([direc filesep '.tmp_analysis'],'.mat');

for ii=1:length(ff)
    ind=strfind(ff(ii).name,'.');
    ind2=strfind(ff(ii).name,'_');
    num=str2double(ff(ii).name((ind2+1):(ind-1)));
    pp=load([direc filesep '.tmp_analysis' filesep ff(ii).name]);
    peaks{num}=pp.outdat;
    imgfilesall(num)=pp.imgfiles;
end

imgfiles=imgfilesall;

save([direc filesep outfile],'peaks','imgfiles','-append');

