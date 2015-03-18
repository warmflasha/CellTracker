function runTileLoopMMCluster(direc,paramfile)

files = readMMdirectory(direc);

nImages = length(files.pos_x)*length(files.pos_y);


imgsperprocessor=12;
nloop = ceil(nImages/imgsperprocessor);

disp('here1');
for ii=1:1 %:nloop
    disp('here2');
    scriptfile = [direc filesep '.jobscripts' filesep 'job_' int2str(ii) '.pbs'];
    fid = fopen(scriptfile,'w');
    fprintf(fid,['#PBS -N job_' int2str(ii) ' \n']); 
    fprintf(fid,'#PBS -q serial\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=00:10:00\n');
    fprintf(fid,'#PBS -W x=NACCESSPOLICY:SINGLEJOB\n');
    fprintf(fid,'#PBS -V\n');
    fprintf(fid,'#PBS -m abe\n');  
    n1=(ii-1)*imgsperprocessor+1;
    n2=min(ii*imgsperprocessor,nImages);
    fprintf(fid,['matlab -nodisplay -r "addpath(genpath(''/home/aw21/CellTracker'')); matlabpool(''local'',' int2str(imgsperprocessor) '); runTileMMCluster(''' direc ''',''outall.mat'',' int2str(n1) ':' int2str(n2)  ',''' paramfile '''); matlabpool(''close''); quit"']);
    fclose(fid);
    system(['qsub ' scriptfile]);
end
