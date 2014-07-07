function shapeout=computeMarkerAveragesFromMatfile(matfile,shapenums,intensity_norm)

if ~exist('shapenums','var') || isempty(shapenums)
    shapenums=1:18;
end

if ~exist('intensity_norm','var')
    intensity_norm=0;
end

pp=load(matfile,'plate1');

col=pp.plate1.colonies;

for ii=1:length(shapenums)
    if any([col.shape]==ii)
    shapeout(ii)=computeShapeAverages(col,shapenums(ii),intensity_norm);
    end
end