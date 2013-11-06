function wellnames = mkWellNames96
wellletters='A':'H';
wellnums=1:12;
for ii=1:12
    wellnumstr{ii}=int2str(wellnums(ii));
     if length(wellnumstr{ii})==1 
         wellnumstr{ii}=['0' wellnumstr{ii}];
     end
end
q=1;
for ii=1:8
    for jj=1:12
        wellnames{q}=[wellletters(ii) wellnumstr{jj}];
        q=q+1;
    end
end