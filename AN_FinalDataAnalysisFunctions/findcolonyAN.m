function [A,B,C] = findcolonyAN(dir,toshow,chan,nms,dataset,index1,thresh,nc,showcol,flag,flag2)

   % chan = [ dapi chan]
    filename{dataset} = [dir filesep  nms{dataset} '.mat'];
    load(filename{dataset},'plate1','acoords','bIms','nIms','dims');
    disp(filename{dataset});
    colonies{dataset} = plate1.colonies;
    if ~exist('plate1','var')
        [colonies{dataset}, ~]=peaksToColonies(filename);
    end
   


col = colonies{dataset};
for ii=1:length(col)
    dat = col(ii).data(:,index1(1))./col(ii).data(:,5);
    dat2 = col(ii).ncells;
    if any(dat > thresh) %
        newdat(ii) = 1;
    else
        newdat(ii) = 0;
    end
    if any(dat2 == nc)
    newdat2(ii) = 1;
    else
        newdat2(ii) = 0;
    end
      if any(dat2 == nc) && any(dat > thresh)
         newdat3(ii) = 1; 
      else
          newdat3(ii) = 0;
      end
end

A = find(newdat);% these are the numbers of colonies to which the cells with expression above thresh belong belong
B = find(newdat2);% these are the numbers of colonies which are of size 'nc'
C = find(newdat3);
C = C';
if isempty(C)
    disp('There are no colonies of such size AND expression above the specified thresh');
    return
end
A = A';
B = B';
if isempty(A)
    disp('there are no colonies with cells above this threshold')
   return;
end

if isempty(B)
    disp('there are no colonies of this size')
   return;
end
if showcol > size(B,1)
    disp('showcol exceeds the number of found colonies of this size')
   return;
end
if toshow > size(A,1)
    disp('toshow exceeds the number of found colonies of this size')
   %return;
end
if flag == 1
for j=1:toshow
fi = assembleColonyMM(colonies{dataset}(A(j)),dir,acoords,[2048 2048],bIms,nIms);
dat = colonies{dataset}(A(j)).data(:,index1(1))./colonies{dataset}(A(j)).data(:,5);
im = colonies{dataset}(A(j)).imagenumbers;
si = colonies{dataset}(A(j)).ncells;
[x,y]= ind2sub(dims,im);
x=x-1;
y=y-1;
disp([x,y]);disp(si);
figure(j),subplot(1,2,1), imshow(fi{chan(1)},[]);
hold on;  plot(colonies{dataset}(A(j)).data(:,1),colonies{dataset}(A(j)).data(:,2),'r*');
%text(colonies{dataset}(A(j)).data(:,1)+5,colonies{dataset}(A(j)).data(:,2),num2str(im),'Color','y');
title('dapi');

figure(j),subplot(1,2,2),imshow(fi{chan(2)},[]);
hold on;  plot(colonies{dataset}(A(j)).data(:,1),colonies{dataset}(A(j)).data(:,2),'r*');
text(colonies{dataset}(A(j)).data(:,1)+5,colonies{dataset}(A(j)).data(:,2),num2str(dat),'Color','r');

end
end
if flag == 0 
for j=1:showcol
    fi = assembleColonyMM(colonies{dataset}(B(j)),dir,acoords,[2048 2048],bIms,nIms);
    dat = colonies{dataset}(B(j)).data(:,index1(1))./colonies{dataset}(B(j)).data(:,5);
    im = colonies{dataset}(B(j)).imagenumbers;
    [x,y]= ind2sub(dims,im);
    x=x-1;
    y=y-1;
    disp([x,y]);
    figure(toshow+j), imshow(fi{chan(1)},[]);
    hold on;  plot(colonies{dataset}(B(j)).data(:,1),colonies{dataset}(B(j)).data(:,2),'r*');
    text(colonies{dataset}(B(j)).data(:,1)+5,colonies{dataset}(B(j)).data(:,2),num2str(dat),'Color','r');
    
    title('dapi');
end
end

% find the colony numbers with the specific size && AND expression in
% channel 'index' above the threshold (basically find the intersection
% between vectors A and B
% fi returned is a cell array with four images in order of ff.chan (returned by ff = readMMdirectory(dir); readMMdirectory : { Dapi Cy5 Gfp Rfp} 

if flag2 == 2
for j=1:showcol
im = colonies{dataset}(C(j)).imagenumbers;
    fi = assembleColonyMM(colonies{dataset}(C(j)),dir,acoords,[2048 2048],bIms,nIms);
    dat = colonies{dataset}(C(j)).data(:,index1(1))./colonies{dataset}(C(j)).data(:,5);
    im = colonies{dataset}(C(j)).imagenumbers;
    [x,y]= ind2sub(dims,im);
    x=x-1;
    y=y-1;
    
    si = colonies{dataset}(C(j)).ncells;
    disp([x,y]);
    disp([si]);
    figure(j),subplot(1,2,1), imshow(fi{chan(1)},[]);
    hold on;  plot(colonies{dataset}(C(j)).data(:,1),colonies{dataset}(C(j)).data(:,2),'y*');
    text(colonies{dataset}(C(j)).data(:,1)+5,colonies{dataset}(C(j)).data(:,2),num2str(dat),'Color','y');
    %text(colonies{dataset}(C(j)).data(:,1)+35,colonies{dataset}(C(j)).data(:,2),num2str(im),'Color','m');
    title('dapi');
    
    figure(j),subplot(1,2,2),imshow(fi{chan(2)},[]);
    hold on;  plot(colonies{dataset}(C(j)).data(:,1),colonies{dataset}(C(j)).data(:,2),'r*');
    text(colonies{dataset}(C(j)).data(:,1)+5,colonies{dataset}(C(j)).data(:,2),num2str(dat),'Color','r');
end
end

end