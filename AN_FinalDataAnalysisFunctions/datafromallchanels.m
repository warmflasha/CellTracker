function outdata = datafromallchanels(statsN,nuc1,chans)
global userParam

ncells = length(statsN);
xy = stats2xy(statsN);
nuc_avr  = [statsN.NuclearAvr];
nuc_area  = [statsN.NuclearArea];

nuc_marker_avr = zeros(ncells, 1);
for i = 1:ncells
    data = nuc1(statsN(i).PixelIdxList);%%%
    nuc_marker_avr = round(mean(data) );
    datacell=[xy(i,1) xy(i,2) nuc_area(i) -1 nuc_marker_avr];
    for xx=1:chans%%%%
        if userParam.donutRadiusMax > 0
            datacell=[datacell statsN(i).NuclearAvr(xx) statsN(i).DonutAvr(xx)];
        else
            datacell=[datacell statsN(i).NuclearAvr(xx) statsN(i).CytoplasmAvr(xx)];
        end
        
    end
    outdata(i,:)=datacell; 
end
return
end
  