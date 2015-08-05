function files=MMputNucFirst(files,nucname)

if ~exist('nucname','var')
    nucname='DAPI';
end

kk=strfind(files.chan,nucname);
ii=~cellfun(@isempty,kk);
nuc_ind=find(ii);

other_inds=setdiff(1:length(files.chan),nuc_ind);

files.chan=files.chan([nuc_ind other_inds]);
