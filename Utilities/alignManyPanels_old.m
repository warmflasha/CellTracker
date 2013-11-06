function fullIm=alignManyPanels(imKeyWord,dir1,dir2,dims,parrange)

[imRange imFiles]=folderFilesFromKeyword('.',imKeyWord);



for jj=1:dims(2)
    imstrips{jj}=imread(imFiles((jj-1)*dims(1)+1).name);
    for ii=2:dims(1)
        nind = (jj-1)*dims(1)+ii;
        newIm=imread(imFiles(nind).name);
        [imstrips{jj} i1 i2]=alignTwoImages(imstrips{jj},newIm,dir1,parrange,40);
        disp([int2str(i1) '  ' int2str(i2)]);
    end
    if jj==1
        fullIm=imstrips{1};
    else
        fullIm=alignTwoImages(fullIm,imstrips{jj},dir2);
    end
end
        
    
