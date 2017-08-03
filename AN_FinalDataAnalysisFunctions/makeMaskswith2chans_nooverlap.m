function [nuc1,fmask,statsout]= makeMaskswith2chans_nooverlap(files,posRange,bIms,nIms,paramfile,flag)
% function to obtain masks from separate channels ( not all cells have
% nuclear marker), special case of the sorting experiment
global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end
ff1 = files;%readMMdirectory(direc,nucname{1});
% dims = [ max(ff1.pos_x)+1 max(ff1.pos_y)+1];
% nImages=length(ff1.chan)-1;
xmax = max(ff1.pos_x)+1;
ymax = max(ff1.pos_y)+1;
ii=posRange;
disp(['Running image ' int2str(ii-1)]);
%read the files
try    
    %read nuclear image, smooth and background subtract
    [x, y]=ind2sub([xmax ymax],ii);
    fnmtosegm = cell(size(ff1.chan,2),1);
    clear f1nm
    clear nuc1
    for k=1:size(ff1.chan,2)% want to use chans 1 and 3 for making mask
        f1nm = mkMMfilename(ff1,x-1,y-1,[],[],k);%posNumberX
        disp(['Nuc marker img:' f1nm]);
        imfiles(ii).nucfile=f1nm;
        fnmtosegm{k}=imread(num2str(f1nm{1}));
    end
    
    si=size(fnmtosegm{1});
    nuc1 = cell(size(ff1.chan,2),1);
    for k=1:size(ff1.chan,2)
        %apply gaussian smoothing
        nuc1{k}=smoothImage(fnmtosegm{k},userParam.gaussRadius,userParam.gaussSigma);
        %subtract precalculated background Image
        nuc1{k}=imsubtract(nuc1{k},bIms{k});
        nuc1{k}=immultiply(im2double(nuc1{k}),nIms{k});
        nuc1{k}=uint16(65536*nuc1{k});
       % nuc1{k} = simplebg([],allmasks(:,:,k),nuc1{k});
    end    
    fimg1=zeros(si(1),si(2),size(ff1.chan,2));
    alldata = [];
    alldata1 = [];
    allmasks = zeros(si(1),si(2),size(ff1.chan,2));
    data1 = struct;
    statsAll = struct; % need to combine all stats from all chanels
    %Initialize error string
    userParam.errorStr=sprintf('Position %d\n',ii);
    for k=1:2:size(ff1.chan,2) % segment based on channels 1 and 2 ( depends on the channel order in each dataset)
        %clear statsN       
            [allmasks(:,:,k), statsN]=segmentCells2(nuc1{k},fimg1(:,:,k));%nuc1{k}
           % [~, statsN1]=addCellAvr2Stats(allmasks{k},fimg1(:,:,k),statsN);
            data1(k).chandata  = stats2xy(statsN);
            alldata = [ alldata ; data1(k).chandata];
            statsAll(k).statsN  = statsN;       
    end
    % here need to just combine two asks, since cfp and rfp never overlap
    % in the same cell
    %clear fmask
    fmask = zeros(size(nuc1{1}));
    statsout = [];    
    fmask = allmasks(:,:,1);% mask based on channel for nuc label of cell type1
    I2 = allmasks(:,:,3); %  Need to merge specific masks, hardcoded here (TODO: generalize)     size(ff1.chan,2) 
    fmask(I2 ==1) = 2;% add the second chanel cells into the mask
   
    %statsout = [statsAll(1).statsN; statsAll(2).statsN]; % combine stats for all unique cells in each chanel
       for k=1:size(statsAll,2)
           sz(k) = size(statsAll(k).statsN,1);
       end
       [~,c] = find(sz);
       statsout=cat(1,statsAll(c).statsN); % combine all the data for the unique cells into one structure
   
 alldata1 = cat(1,statsout.Centroid); % data based on two channels 
% get rid of very small cells that came from cells that were segmented as
% two instead of one cell
%toedit= bwlabel(fmask);
toedit = regionprops(logical(fmask),'Area','PixelIdxList');
badinds = cat(1,toedit.Area);

[a1,~]=find(badinds<80);
[a2,~]=find(badinds>2500);
a3 = cat(1,a1,a2);
for j=1:size(a3,1)
fmask(sub2ind(size(nuc1{1}),toedit(a3(j)).PixelIdxList)) = 0;
end

    if flag == 1
    figure(1), imshow(fmask,[]);
    hold on, plot(alldata1(:,1),alldata1(:,2),'*m','markersize',14)
    for k=1:size(ff1.chan,2)
    figure(2+k),imshow(nuc1{k},[]); hold on;
    if ~isempty(data1(k).chandata)
    plot(data1(k).chandata(:,1),data1(k).chandata(:,2),'.y','MarkerSize',15); hold on;
    end
    end
    end
    
catch err
    disp(['Error with image ' int2str(ii-1)]);
    disp(err.identifier);
    %rethrow(err);
end
end
