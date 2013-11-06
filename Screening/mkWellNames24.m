function wellnames = mkWellNames24
wellletters='A':'D';
wellnums=1:6;
for ii=1:length(wellnums)
    wellnumstr{ii}=int2str(wellnums(ii));
     if length(wellnumstr{ii})==1 
         wellnumstr{ii}=['0' wellnumstr{ii}];
     end
end
q=1;
for ii=1:length(wellletters)
    for jj=1:length(wellnumstr)
        wellnames{q}=[wellletters(ii) wellnumstr{jj}];
        q=q+1;
    end
end