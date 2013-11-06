function addimgfiles2mat(matfile,direc,smadstring,nucstring)
%function to add imgfiles structure array to an already tracked .mat file

load(matfile);

[smadrange smadfiles]=folderFilesFromKeyword(direc,smadstring);
[nucrange nucfiles]=folderFilesFromKeyword(direc,nucstring);

pictimes=zeros(length(nucrange),1);

for ii=1:length(nucrange)
    nucfilename= nucfiles(nucrange(ii)).name;
    smadfilename= smadfiles(nucrange(ii)).name;
    
    
    if ii > 1
        pictimes(ii)=(nucfiles(nucrange(ii)).datenum-nucfiles(nucrange(1)).datenum)*24;
    end
    
    imgfiles(ii).smadfile=smadfilename;
    imgfiles(ii).nucfile=nucfilename;
    imgfiles(ii).time=pictimes(ii);
end

save(matfile,'imgfiles','-append');