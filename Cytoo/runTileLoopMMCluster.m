function runTileLoopMMCluster(direc,paramfile)

files = readMMdirectory(direc);

nImages = length(files.pos_x)*length(files.pos_y);

for ii=1:nImages
    scriptfile = [direc filesep '.jobscripts' filesep 'job_' int2str(ii) '.pbs'];
    fid = fopen(scriptfile,'w');
    fprintf(fid,['#PBS -N job_' int2str(ii) ' \n']); 
    fprintf(fid,'#PBS -q serial\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=00:10:00\n');
    fprintf(fid,'#PBS -W x=NACCESSPOLICY:SINGLEJOB\n');
    fprintf(fid,'#PBS -V\n');
    fprintf(fid,'#PBS -m abe\n');    
    fprintf(fid,['matlab -nodisplay -r "addpath(genpath(''/home/aw21/CellTracker'')); runTileMMCluster(''' direc ''',''outall.mat'',' int2str(ii) ',''' paramfile '''); quit"']);
    fclose(fid);
    system(['qsub ' scriptfile]);
end
