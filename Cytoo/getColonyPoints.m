function inds=getColonyPoints(col,coord,radius,coord_type,coord_unit)
% inds=getColonyPoints(col,coord,radius,coord_type,coord_unit)
% -------------------------------------------------
% return indices of points in the colony object col within radius of coord.
% coord_type is either 'cartesian' or 'polar' (default 'cartesian')
% coord_unit is either 'micron' of 'pixel', default 'pixel'. 'Micron assumes
% usual scaling from Wendolene microscope
%
% See also colony/getPointsAroundCoordinate

if ~exist('coord_type','var') ||...
        (~strcmpi(coord_type,'cartesian') && ~strcmpi(coord_type,'polar'))
    coord_type='cartesian';
end

if ~exist('coord_unit','var') ||...
        (~strcmpi(coord_unit,'pixel') && ~strcmpi(coord_unit,'micron'))
    coord_unit='pixel';
end

if strcmpi(coord_type,'polar')
    [coord_cart(1), coord_cart(2)]=pol2cart(coord(2),coord(1));
else
    coord_cart=coord;
end

if strcmpi(coord_unit,'micron')
    coord_cart=3*coord_cart; %standard conversion for wendolene. 
    radius = radius*3;
end

inds=col.getPointsAroundCoordinate(coord_cart,radius);


    
