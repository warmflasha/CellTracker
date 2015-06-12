function [A] = findcolonyAN(dir,toshow,chan,nms,index1,thresh,dataset)

    %k = dataset;%k=1:size(nms,2)
    filename{dataset} = [dir filesep  nms{dataset} '.mat'];
    load(filename{dataset},'plate1','acoords','bIms','nIms');
    disp(filename{dataset});
    colonies{dataset} = plate1.colonies;
    if ~exist('plate1','var')
        [colonies{dataset}, ~]=peaksToColonies(filename);
    end
   


col = colonies{dataset};
for ii=1:length(col)
    dat = col(ii).data(:,index1(1))./col(ii).data(:,5);
    
    if any(dat > thresh) %
        newdat(ii) = 1;
    else
        newdat(ii) = 0;
    end
end
%end
A = find(newdat);% these are the numbers of colonies to which these cells belong
A = A';
for j=1:toshow
fi = assembleColonyMM(colonies{dataset}(A(j)),dir,acoords,[2048 2048],bIms,nIms);
dat = colonies{dataset}(A(j)).data(:,index1(1))./colonies{dataset}(A(j)).data(:,5);
figure(j),subplot(1,2,1), imshow(fi{chan(1)},[]);
hold on;  plot(colonies{dataset}(A(j)).data(:,1),colonies{dataset}(A(j)).data(:,2),'r*');
title('dapi');

figure(j),subplot(1,2,2),imshow(fi{chan(2)},[]);
hold on;  plot(colonies{dataset}(A(j)).data(:,1),colonies{dataset}(A(j)).data(:,2),'r*');
text(colonies{dataset}(A(j)).data(:,1)+5,colonies{dataset}(A(j)).data(:,2),num2str(dat),'Color','r');

end

end