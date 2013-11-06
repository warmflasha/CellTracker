function wellnames = mkWellNames
wellletters='A':'P';
wellnums=1:24;
for ii=1:24
    wellnumstr{ii}=int2str(wellnums(ii));
    if length(wellnumstr{ii})==1
        wellnumstr{ii}=['0' wellnumstr{ii}];
    end
end
q=1;
for ii=1:16
    for jj=1:24
        wellnames{q}=[wellletters(ii) wellnumstr{jj}];
        q=q+1;
    end
end