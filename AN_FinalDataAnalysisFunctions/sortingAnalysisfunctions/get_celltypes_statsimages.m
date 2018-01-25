function [untrackedstats,trackedstats,img_untracked,img_tracked]=get_celltypes_statsimages(direc_untracked,ifile_untracked,direc_tracked,ifile_tracked,paramfile,pos,chan_tracked,chan_untracked,ilastikprob)

run(paramfile)
global userParam
ff1 = readAndorDirectory(direc_untracked);
[nmask,untrackedstats] = getdatatotrack(direc_untracked,pos,chan_untracked,userParam.arealow,ifile_untracked,userParam.probthresh,ilastikprob);
% centroids of pluri cells (cell type 1) are in the var pluristats
% tracked data for CFP cells (cell type 2) are in var coordintime
nucmoviefile1 = getAndorFileName(ff1,ff1.p(pos),[],[],chan_untracked);%getAndorFileName(files,pos,time,z,w)
img_untracked = bfopen(nucmoviefile1);

ff2 = readAndorDirectory(direc_tracked);
nucmoviefile = getAndorFileName(ff2,ff2.p(pos),[],[],chan_tracked);%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
img_tracked = bfopen(nucmoviefile);
[nmask2,trackedstats] = getdatatotrack(direc_tracked,pos,chan_tracked,userParam.arealow,ifile_tracked,userParam.probthresh,ilastikprob);

end