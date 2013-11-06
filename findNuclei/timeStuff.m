function timeStuff()

data = rand(1024, 1344);
mask = data > 0.5;
%tic
findBackgnd(data, 0)
%pts = data(mask);
%std(pts(:));
%toc

%     len = 61;
%     sizei = [1024, 1344];
%     %sizei = [64, 64];
%     
%     polyx = [2, len+1, len, 2];
%     polyy = [2, 2, len-2, len];
% tic;
%     for i = 1:400
%         bw = poly2mask(polyx, polyy, sizei(1), sizei(2) );
%         bw = imerode(bw, strel('disk', 1));
%     end
% toc;