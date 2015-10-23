function runTileLoopMMCluster(direc,paramfile)

files = readMMdirectory(direc);

nImages = length(files.pos_x)*length(files.pos_y);


imgsperprocessor=12;
nloop = ceil(nImages/imgsperprocessor);

for ii=1:nloop
    scriptfile = [direc filesep '.jobscripts' filesep 'job_' int2str(ii) '.slurm'];
    fid = fopen(scriptfile,'w');
    fprintf(fid,'#!/bin/bash\n')
    fprintf(fid,['#SBATCH --job-name job_' int2str(ii) ' \n']); 
    fprintf(fid,'#SBATCH --partition=commons\n');
    fprintf(fid,'#SBATCH --ntasks=1\n');
    fprintf(fid,'#SBATCH --mem-per-cpu=1000m\n');
    fprintf(fid,'#SBATCH --time=00:30:00\n');
    n1=(ii-1)*imgsperprocessor+1;
    n2=min(ii*imgsperprocessor,nImages);
    fprintf(fid,['srun matlab -nodisplay -r "addpath(genpath(''/home/aw21/CellTracker'')); parpool(' int2str(imgsperprocessor) '); runTileMMCluster(''' direc ''',''outall.mat'',' int2str(n1) ':' int2str(n2)  ',''' paramfile '''); delete(gcp); quit"']);
    fclose(fid);
    system(['sbatch ' scriptfile]);
end
