% plot the signaling value on top of the image
function MatchTrajectorywithColony(ilastikdirnuc,ilastikdircyto,imagedir1,imagedir2,positions,pl,strnuc,strcyto,m,n1,n2,matfile,coltoplot)
clear X
clear Y
clear ratio
clear img
timegroup = [];
chanal = 1;

pos = positions(1);
[ilastikCytoAll] = FindPositionMasks(ilastikdircyto,pl,pos,strcyto);    % get the specific position ilastik masks (all z projections)
[ilastikNucAll] = FindPositionMasks(ilastikdirnuc,pl,pos,strnuc);

imgfilescyto = struct;
imgfiles = struct;
img = zeros(1024,1024);
% read raw images
load(matfile);
[imgsnuc_reader]   =  getrawimgfiles(imagedir1,pl, pos-1,timegroup,chanal(1));        % get the raw images for that position and merge them into a 3d format
[imgscyto_reader] =   getrawimgfiles(imagedir2,pl, pos-1,timegroup,chanal(1));
nT = imgsnuc_reader{1}.getSizeT;  

numcol = size(colonies,2);% how many colonies were grouped within the image
% colors = colormap(colorcube);
% cmap = colors(1:20,:);close all
c = {'r','g','b','r','c','m','g','r','g','b','r','c','m','g'};

if coltoplot > numcol
    disp('there are no more colonies in this image')
    return
end

for k=n1:n2
    
    curr = imgsnuc_reader{m}.getIndex(0,0, k - 1) + 1;
    img = bfGetPlane(imgsnuc_reader{m},curr);
    
    %for j=coltoplot
    for i=coltoplot     % loop over colony ( for now loo at specific colony at a time
        
        figure(i),subplot(1,2,1),imshow(img,[]);hold on
        for h=1:size(colonies(i).cells,2)   % loop oevr the cells within colonies
            [r ~] = find(colonies(i).cells(h).onframes == k);
            if ~isempty(r)
                X = colonies(i).cells(h).position(r,1);
                Y = colonies(i).cells(h).position(r,2);
                ratio = (colonies(i).cells(h).fluorData(r,2)./colonies(i).cells(h).fluorData(r,3));
                
                figure(i),subplot(1,2,1),plot(X,Y,'*','color',c{i});hold on%cmap(i,:)
                figure(i),subplot(1,2,1), text(X+10,Y+10,num2str(ratio),'Color','m');hold on
                
                figure(i),subplot(1,2,2),plot(colonies(i).cells(h).onframes(r),colonies(i).cells(h).fluorData(r,2)./colonies(i).cells(h).fluorData(r,3),'*','color',c{i},'markersize',20);hold on
            end
        end
        figure(i),subplot(1,2,2),xlim([1 n2]); ylim([0.4 1.8]);
    end
    
    
end
    
    

end
