function [colonies peaks]=peaksToColonies(matfile,mm)

pp=load(matfile,'peaks','acoords','imgfiles','dims','userParam'); % AN: added to load userParam file to see which option(single cell or alphavol) to use in the peakstocolonies later on
peaks=pp.peaks;
ac=pp.acoords;
dims=pp.dims;
coltype=pp.userParam.coltype; % AN
pp.userParam.coltype

if ~exist('mm','var')
    mm=1;
end

peaks=removeDuplicateCells(peaks,ac);

k1=num2cell(ones(1,length(peaks)));
lens=cellfun(@size,peaks,k1);
totcells=sum(lens);

%get number of columns from first non-empty image
q=1; ncol=0;
while ncol==0
ncol=size(peaks{q},2);
q=q+1;
end

alldat=zeros(totcells,ncol+1);

q=1;
for ii=1:length(peaks)
    if ~isempty(peaks{ii})
        currdat=peaks{ii};
        toadd=[ac(ii).absinds(2) ac(ii).absinds(1)];
        currdat(:,1:2)=bsxfun(@plus,currdat(:,1:2),toadd);
        alldat(q:(q+lens(ii)-1),:)=[currdat ii*ones(lens(ii),1)];
        q=q+lens(ii);
    end
end
pts=alldat(:,1:2);

% [~, S]=alphavol(pts,100);%original value 100            
% groups=getUniqueBounds(S.bnd);   % S.bnd - Boundary facets (Px2 or Px3)
% 
% 
% allinds=assignCellsToColonies(pts,groups);
% alldat=[alldat full(allinds)];

%------------------------------------------ this is where the chice is made
if  exist('coltype','var') && coltype == 1    %analysis for the single cell data                           
    disp('Running the SC colony analysis');
    allinds=NewColoniesAW(pts);
    alldat = [alldat, allinds];
    groups = max(allinds);
    
else if  coltype == 0 || ~ exist('coltype','var') % analysis for the circular colonies data; defaule it no coltype variable is specified in the parameterfile
        disp('Running the alphavol');

        [~, S]=alphavol(pts,pp.userParam.alphavol);

       
        groups=getUniqueBounds(S.bnd);   % S.bnd - Boundary facets (Px2 or Px3)
            
        allinds=assignCellsToColonies(pts,groups);
        alldat=[alldat full(allinds)];
    end
    
end 
%------------------------------- %below this point all the same as in either peakstoColoniesSC ot peakstocolonies           

%Make colony structure
for ii=1:length(groups)
    cellstouse=allinds==ii;
    colonies(ii)=colony(alldat(cellstouse,:),ac,dims,[],pp.imgfiles,mm);
end

%put data back into peaks
for ii=1:length(peaks)
    cellstouse=alldat(:,end-1)==ii;
    peaks{ii}=[peaks{ii} alldat(cellstouse,end-1:end)];
end

