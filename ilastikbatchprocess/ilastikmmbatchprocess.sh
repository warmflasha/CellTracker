#!/bin/bash
# running ilastik segmentation on micromanager files
#trainproject: path corresponding to ilastik project that was used to train a sample dataset
#exportpath: path corresponding to ilastik output
#inputdir: path corresponding to sample images that are to be segmented - serves as an input to the matlab function
#inputfiles: image files in the inputdir that are to be segmented 



trainproject=/Users/sapnachhabra/Desktop/CellTrackercd/Experiments/151220shapes4/MMPixelClassify.ilp

inputfiles=/Users/sapnachhabra/Desktop/CellTrackercd/Experiments/151220shapes4/ilastiktest/*

exportpath=/Users/sapnachhabra/Desktop/CellTrackercd/Experiments/151220shapes4/ilastiksegmentation/segmentfile.h5

segchannel=DAPI

segmentfiletif=/img_000000000_${segchannel}_000.tif

for f in $inputfiles

do
	segmentfilepath=${f}${segmentfiletif}
	
	/Users/sapnachhabra/Desktop/ilastik-1.1.8-OSX.app/Contents/MacOS/python ilastik-1.1.8-OSX.app/Contents/Resources/ilastik.py --headless  --project=$trainproject $segmentfilepath
	
	scp $exportpath ${f}/segmentfile.h5
	
done






