function [colonies, peaks]=peaksToColonies(matfile,mm,ts)

pp=load(matfile,'peaks','acoords','imgfiles','dims','userParam'); % AN
peaks=pp.peaks;
ac=pp.acoords;
dims=pp.dims;
param = pp.userParam;
% if exist('userParam','var')
% param = pp.userParam;

if ~isfield(param,'coltype')
    disp('Error: coltype must be 1 or 0');
    return 
end

coltype=param.coltype; % AN
%  else
%      coltype = 0;
% end
 
if ~exist('mm','var')
    mm=1;
end

if any(dims > 1)
peaks=removeDuplicateCells(peaks,ac);
end

if exist('ts','var')
    peaks=peaks(ts);
end

k1=num2cell(ones(1,length(peaks)));
lens=cellfun(@size,peaks,k1);
totcells=sum(lens);

%get number of columns from first non-empty image
q=1; ncol=0;
while ncol==0
    if ~isempty(peaks{q})
        ncol=size(peaks{q},2);
    end
    q=q+1;
end

% peaks contains segmented cells for each image 
% combine peaks from all images in one big array
% allocate array:
alldat=zeros(totcells,ncol+1);

% combine:
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


if  coltype == 1    %analysis for the single cell data
    disp('Running the SingleCell colony analysis');
    allinds=NewColoniesAW(pts);
    alldat = [alldat, allinds];
    ngroups = max(allinds);
    
    %Make colony structure for the single cell algorythm
    for ii=1:ngroups;
        cellstouse=allinds==ii;
        colonies(ii)=colony(alldat(cellstouse,:),ac,dims,[2048 2048],pp.imgfiles);%[1024 1344]
    end
    
    %put data back into peaks
    for ii=1:length(peaks)
        cellstouse=alldat(:,end-1)==ii;
        peaks{ii}=[peaks{ii} alldat(cellstouse,end-1:end)];
    end
end
if  coltype == 0  % analysis for the circular colonies data; 
    disp('Running the alphavol-based colony grouping');
    [~, S]=alphavol(pts,pp.userParam.alphavol);% this line was modified
    groups=getUniqueBounds(S.bnd);   % S.bnd - Boundary facets (Px2 or Px3)
    
    allinds=assignCellsToColonies(pts,groups);
    alldat=[alldat full(allinds)];
    %Make colony structure for the alphavol algorythim
    for ii=1:length(groups)
        disp(int2str(ii));
        cellstouse=allinds==ii;
        colonies(ii)=colony(alldat(cellstouse,:),ac,dims,[],pp.imgfiles,mm);
    end
    
    %put data back into peaks
    for ii=1:length(peaks)
        cellstouse=alldat(:,end-1)==ii;
        peaks{ii}=[peaks{ii} alldat(cellstouse,end-1:end)];
    end
    
end


end
        



