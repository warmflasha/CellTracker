function runPlotColorColonies(matfile,colnum,newfig,col)

cc=load(matfile,'colonies');

plotcolorcolonies(cc.colonies(colnum).data,newfig,col);
