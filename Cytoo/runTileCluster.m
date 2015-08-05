function runTileCluster(direc,chans,nimages,bIms,nIms,paramfile)
%WORK IN PROGRESS, DISREGARD FOR NOW

s=matlabpool('size');
if s > 0
    matlabpool close;
end
matlabpool('local',nloop);
for ii=1:nimages
    scriptfile = ['job_' int2str(ii) '.pbs'];
    fid = fopen(scriptfile,'w');
    fprintf(fid,['#PBS -N job_' int2str(ii) ' \n']); 
    fprintf(fid,['#PBS -q serial\n']);
    fprintf(fid,['#PBS -l nodes=1:ppn=1,walltime=00:10:00\n']);
    fprintf(fid,['#PBS -W x=NACCESSPOLICY:SINGLEJOB\n']);
    fprintf(fid,['#PBS -M warmflasha@gmail.com\n']);
    fprintf(fid,['#PBS -V\n']);
    fprintf(fid,['#PBS -m abe\n']);
    outfile=[direc filesep 'out_' int2str(n1) '.mat'];
    
    fprintf(fid,['matlab -nodisplay -r "runTile(' direc ',' outfile ','chans,[ii ii],bIms,nIms,paramfile);; quit"
   
end
matlabpool close;