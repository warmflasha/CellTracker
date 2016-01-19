
 %%
 % imdir : directory that contains image folders, one folder for each sample. 
 
 clear all;
 
 imdir = '/Users/sapnac18/Desktop/renamefold/'; 
 
 curdir1 = dir(imdir);
 nsamp = size(curdir1, 1);
 %%
 
 for samp = 4:nsamp
     sample = strcat(imdir, curdir1(samp).name);
     curdir = dir(sample);
 
 npos = size(curdir, 1);
 
 nfile = sprintf('%s_newim', curdir1(samp).name);
 nfold = strcat(imdir, nfile);
 mkdir(nfold);
 
 pos_start = 4;
 
 for pos = pos_start:npos;
     dir1 = strcat(sample, '/', curdir(pos).name);
 
%for adding position variable 'f' to the files

ff = readAndorDirectory(dir1);

imax = ff.z(end);
jmax = ff.w(end);
nfiles = size(ff.z,2)*numel(ff.w);

d1 = dir(dir1);
k = size(d1,1) - nfiles + 1;

if(ff.ordering(1)=='w')
    ilim = jmax;
    jlim = imax;
else
    ilim = imax;
    jlim = jmax;
end
   

 for i = 0:ilim
     for j = 0:jlim
         
         old_name = d1(k).name;
         
         if(ff.ordering(1)=='w')
             new_name = sprintf('%s_f%04d_w%04d_z%04d.tif', curdir1(samp).name, pos-pos_start, i, j);
         else
             new_name = sprintf('%s_f%04d_z%04d_w%04d.tif',curdir1(samp).name, pos-pos_start, i, j);
         end
         
         old_file = strcat(dir1, '/', old_name);
         old_filen = strcat(nfold, '/');
         
         copyfile(old_file, old_filen);
         
         old_filem = strcat(nfold,'/',  old_name);
         new_file = strcat(nfold,'/',  new_name);
         
         movefile(old_filem, new_file);
         k = k+1;
     end
 end
 

 
 end
 
 rmdir(sample, 's');
 end

 

        
    
        