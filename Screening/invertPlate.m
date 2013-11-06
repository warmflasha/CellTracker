function invertPlate(matfile)
load(matfile,'outdatall');

outdatall_old = outdatall;

for ii=1:384
    outdatall{ii}=outdatall_old{384-ii+1};
end

save(matfile,'outdatall','outdatall_old');