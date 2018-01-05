function [pluristats,diffstats,img_pluri,img_diff]=get_celltypes_statsimages(direc_pluri,ifile_pluri,direc_diff,ifile_diff,paramfile,pos,chan_diff,chan_pluri)

run(paramfile)
global userParam
ff1 = readAndorDirectory(direc_pluri);
[nmask,pluristats] = getdatatotrack(direc_pluri,pos,chan_pluri,userParam.arealow,ifile_pluri);
% centroids of pluri cells (cell type 1) are in the var pluristats
% tracked data for CFP cells (cell type 2) are in var coordintime
nucmoviefile1 = getAndorFileName(ff1,ff1.p(pos),[],[],chan_pluri);%getAndorFileName(files,pos,time,z,w)
img_pluri = bfopen(nucmoviefile1);

ff2 = readAndorDirectory(direc_diff);
nucmoviefile = getAndorFileName(ff2,ff2.p(pos),[],[],chan_diff);%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
img_diff = bfopen(nucmoviefile);
[nmask2,diffstats] = getdatatotrack(direc_diff,pos,chan_diff,userParam.arealow,ifile_diff);

end