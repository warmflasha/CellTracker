function [ind, well]=wellname96toind384(wellname,quad)

if length(wellname)==2
    wellname=[wellname(1) '0' wellname(2)];
end

wellind96=wellname2ind(wellname,96);
rowind=floor((wellind96-1)/12)+1;
colind=mod((wellind96-1),12)+1;

if quad==1
    rowind384=2*rowind-1;
    colind384=2*colind-1;
elseif quad ==2
    rowind384=2*rowind-1;
    colind384=2*colind;
elseif quad==3
    rowind384=2*rowind;
    colind384=2*colind-1;
elseif quad==4
    rowind384=2*rowind;
    colind384=2*colind;
else
    disp('Error: quad must be 1-4');
    ind=0;
    well='None';
    return;
end

ind=(rowind384-1)*24+colind384;
wells=mkWellNames;
well=wells(ind);

