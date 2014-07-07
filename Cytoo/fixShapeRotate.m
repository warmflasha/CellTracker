function fixShapeRotate(matfile)

load(matfile,'plate1')

ncol = length(plate1.colonies);

for ii=1:ncol
    if isempty(plate1.colonies(ii).shape)
        plate1.colonies(ii).shape = 0;
        plate1.colonies(ii).rotate = 0;
    end
end

save(matfile,'plate1','-append');