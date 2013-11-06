function ind=wellname2ind(well2find,platesize)


if ~exist('platesize','var') || platesize==384
    wellnames=mkWellNames;
elseif platesize==96
    wellnames=mkWellNames96;
end

tt=strfind(wellnames,well2find);

for ii=1:length(tt)
    if ~isempty(tt{ii})
        ind=ii;
        return;
    end
end
ind = -1;