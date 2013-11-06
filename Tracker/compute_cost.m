
function cc = compute_cost(Ilink, Jlink, peaks_data, cost)
% compute cost using either the link data or peaks (call with
% peaks{frame-1}

cc = 0;
if isempty(Ilink)
    Jlink = peaks_data(:,4);
    ok = find(Jlink>0);
    for ii = 1:length(ok)
        cc = cc + cost(ok(ii), Jlink(ok(ii)) );
    end

else
    ok = find(Jlink>0);
    for ii = 1:length(ok)
        % [ok(ii), Ilink(ok(ii)), Jlink(ok(ii)), cost(Ilink(ok(ii)), Jlink(ok(ii)) )]
        cc = cc + cost(Ilink(ok(ii)), Jlink(ok(ii)) );
    end
end
osize = size(cost,1) -1;  
nsize = size(cost,2) -1;
% cost for no match * ( number of old and new nuclei not matched )
cc = cc + cost(end, end)*( osize - length(ok) + nsize - length(ok) ); 
