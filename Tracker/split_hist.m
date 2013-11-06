function split_hist(data)
% Divide histogram to minimize sums of squares of hi/lo points from split
% point.
% Model for data sum of 2 gaussians compute division point such that prob
% each set of data is sample from gaussian is as large as possible. Compute
% mean and var for each partition of data, compare sums of cnts over sigma
% width bands and compare with expectations

nbin = 100;
[cnts, bins] = hist(data, nbin);
nbin = length(cnts);
% cut off extreme 1% of data
bin0 = max(1, chist2bin(cnts, 1));
bin1 = min(nbin, chist2bin(cnts, 99));
cnts = cnts(bin0:bin1);
bins = bins(bin0:bin1);
nbin = length(cnts);

% wt0 = 0;
% wt1 = sum(cnts);
% cnts2 = (1:nbin).^2;
% cnts2 = cnts .* cnts2;
% cnts1 = cnts .*(1:nbin);
% barbel = zeros(1,nbin);
% for cut = 2:(nbin-1)
%     wt0 = wt0 + cnts(cut-1);
%     wt1 = wt1 - cnts(cut-1);
%    
%     barbel(cut) = -sum( cnts1(1:(cut-1)) )/wt0 + sum( cnts1((cut+1):nbin) )/wt1;
% end
% [val, cut0] = min(barbel(2:(nbin-1)));
% cut0 = cut0 + 1;


return; 


function bin0 = chist2bin(cnts, perc)
% find the max/min bin0 such that
%   sum [1:bin0] <= perc total (if perc < 50)
%   sum [bin0:end] >= perc * total (if perc >= 50)
% may return bin0=0 or bin0=nbin+1, out of range values.

sumh = sum(cnts);
nbin = length(cnts);
sumc = 0;
if perc < 50
    for bin0 = 1:nbin
        sumc = sumc + cnts(bin0);
        if sumc > perc*sumh/100
            bin0 = bin0 - 1;
            return
        end
    end
else
    for bin0 = nbin:-1:1
        sumc = sumc + cnts(bin0);
        if sumc > (1-perc)*sumh/100
            bin0 = bin0 + 1;
            return
        end
    end
end
