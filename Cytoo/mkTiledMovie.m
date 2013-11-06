function mkTiledMovie(direc,inBase,outBase,posNums,timepoints,dims,bgIm,outdir)

for ii=timepoints
   [~, fI]=alignManyPanelsLiveFixedShift(direc,inBase,posNums,timepoints(ii),dims,bgIm);
   imshow(fI,[]); drawnow;
   fI=uint16(fI);
   outfilenm=[outdir filesep outBase '_t' int2str(timepoints(ii)) '.png'];
   imwrite(fI,outfilenm);
end
   

