read me for TrackViewer, a GUI to view cell traces produced by runSegmentCells and runTracker.

To get started, load images using the Image loading panel. There are three options:

1. CCC expt -- for cell culture chip experiments. choosing the directory and will assume the file naming conventions associated with CCC experiments.

2. confocal experiment -- all data is stored in 1 multilayered .lsm image file. Dialogue box will open to input image file, matfile, and 2 component vector with channels to use (1st number for nuc marker, 2nd number for Smad image).

3. Other -- assumes files are all in directory. dialogue box will open to input directory, keywords to search for the images, and the .mat file.

#image window :left window is to display images
using the slider bar below this window one can change the image displayed

the 3 slider bar at the bottom are inactive in this version, the checks box are to select which channel to display
 (from top to bottom:RGB)

 

# plot display window : right window where cell traces are plotted
using the slider bar below this window one can change the cell displayed (the number after good cell # is the index in the cells2 array)

spline are plotted on cells that where qualified as good by AW's routine "decideifgoodandaddspline"
when one change cell trace, the corrsponding cell should by highlited in the image window. if this is not the case, it is because the current
cell is not present in the frame displayed in the image window. use the image slider bar to move to a frame where the cell is present.
when one change cell, the dot in the image window might not be pointing at the cell. go one frame forward or backward to synchronize the two displays.
this issue should be fixed.


buttons

#load images

a window pops up asking to select a folder where images produced by CCC are. will look for red and green images
and a mat file with the data from the track named Chxxout.mat located in the parent folder.

it will load only the names and the first image unless the "load in memory box is checked" (not recomended)
the images will be loaded one by one when the user press the arrows on the slider bar below the image window

once the images names are loaded a message box says "found a mat file" if a tracking data were successfully loaded.
and the average trace shouldappear in the plot window. if not (this can happen) press the show average plot button

# show average plot
as its name says

# find cell

will ask the user to click on a cell in the image window. the trace corresponding to cell will appear in the plot window.


# run segmentCell
run the segment cell routine on the image displayed. it will need to load the file paramater setUserParamCCC10x([1024 1344])
also one need to specify the string for the nuc and smad file in the code TrackViewer.m in  RunSegmentCell_pushbutton_Callback
line 914. this should be improved.

# show good cells

display in the image window the position of the cell for the current image (from peacks) the number besides the point is the match in next frame (4th column in peacks)

# show growth

a figure window will popup to display cell number as a function of time


#export plot

graph in the plot window will popup in a new figure, useful to export graph

#make report 
utility to plot all the average graphs of one day of experiment in a 2x3 subplot array in a size ok for printing 
