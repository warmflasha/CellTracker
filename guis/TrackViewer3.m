function varargout = TrackViewer3(varargin)
% TRACKVIEWER3 M-file for TrackViewer3.fig
%      TRACKVIEWER3, by itself, creates a new TRACKVIEWER3 or raises the existing
%      singleton*.
%
%      H = TRACKVIEWER3 returns the handle to a new TRACKVIEWER3 or the handle to
%      the existing singleton*.
%
%      TRACKVIEWER3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKVIEWER3.M with the given input arguments.
%
%      TRACKVIEWER3('Property','Value',...) creates a new TRACKVIEWER3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackViewer3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  allcells_radio inputs are passed to TrackViewer3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackViewer3

% Last Modified by GUIDE v2.5 01-Dec-2011 11:02:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TrackViewer3_OpeningFcn, ...
    'gui_OutputFcn',  @TrackViewer3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TrackViewer3 is made visible.
function TrackViewer3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackViewer3 (see VARARGIN)

global DataIF

% Choose default command line output for TrackViewer3
handles.output = hObject;


%check that required .m files are on path, display warning
requiredFiles={'StructDlg','averagePlot_TV3','singleCellPlot_TV3'};
missingstring=checkForRequiredFiles(requiredFiles);
if ~isempty(missingstring)
    set(handles.message_text,'String',missingstring,'ForegroundColor', 'r');
end

% initialise a few stuff
handles.chemin = pwd;
handles.channel2display = [1 1 0];
handles.LoadImages2memory = 0;
handles.PictNbSliderValue = 1;
handles.showCells=0;
set(handles.allCells_radio,'Value',1);
set(handles.CCC_radio,'Value',1);
handles.CCCexpt=1; handles.confocalexpt=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackViewer3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrackViewer3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in LoadImages_pushbutton.
function LoadImages_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImages_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack;
DataIF=[]; dataTrack=[];


% tmp.CCCexpt={'{yes}|no'};
% tmp=StructDlg(tmp);
% if strcmp(tmp.CCCexpt,'yes')
%     handles.CCCexpt=1;
% else
%     handles.CCCexpt=0;
% end


if handles.CCCexpt
    % get path of the experiment folder
    [chemin] = uigetdir(handles.chemin,'pick a folder');
    if chemin~=0
        handles.chemin = chemin;
        
        % decompose chemin
        findBackSlash = strfind(chemin, filesep);
        chamberName = chemin(findBackSlash(length(findBackSlash))+1:length(chemin));
        handles.chamberName = chamberName;
        DateOfExperiment = chemin(findBackSlash(length(findBackSlash)-1)+1:findBackSlash(length(findBackSlash))-1);
        s1.imagedirectory=chemin;
        
        s1.smadKeyWord='smad';
        s1.nucKeyWord='nuc';
        
%         s1.smadKeyWord='red';
%         s1.nucKeyWord='green';
    else
        return;
    end
elseif ~handles.confocalexpt
    S.imagedirectory={{'uigetdir(''.'')'}};
    S.matfile={{'uigetfile(''.'')'}};
    S.nucKeyWord='FP_s1';
    S.smadKeyWord='mine_s1';
    s1=StructDlg(S);
    if isempty(s1)
        return;
    end
    handles.chemin=s1.imagedirectory;
else
    S.imagefile={{'uigetfile(''./*.lsm'')'}};
    S.matfile={{'uigetfile(''./*.mat'')'}};
    S.chan2use=[2 1];
    s1=StructDlg(S);
    if isempty(s1)
        return;
    end
end

%read in the image files
handles=readImageFiles(handles,s1);

%image and image window size definition
handles.ActualImageSize = size(DataIF(1).red);
if max(size(DataIF(1).red)) > 1000
    handles.ImageScaleFactor = 2;
else
    handles.ImageScaleFactor=1;
end
handles.ImageWindowSize = handles.ActualImageSize / handles.ImageScaleFactor;

% resize the image window to the appropriate size
set(handles.MainFigure,'Position',[2 180 handles.ImageWindowSize(2) handles.ImageWindowSize(1)])

% initialise pictNb_slider
NbFichier = length(DataIF);
set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 10/(NbFichier-1)]);
handles.currentImageIndex = 1;
handles.Zoomin = 0;

if handles.CCCexpt
    cd(chemin)
    cd ..
    handles.experimentFolder = pwd;
    matFileName = dir(['*' chamberName '*.mat']);
    s1.matfile=matFileName.name;
end

%try
%read in the matfile
handles=readMatFile(handles,s1.matfile);
CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)
% catch
% set(handles.message_text,'String','did not find the mat file');
% handles.OKdatatrack =0;
% end

cd(handles.chemin)

% show average plot
if handles.OKdatatrack
    handles = MakeAveragePlot_pushbutton_Callback(hObject, eventdata, handles);
end
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in red_checkbox.
function red_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to red_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of red_checkbox
handles.channel2display(1) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);

% --- Executes on button press in green_checkbox.
function green_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to green_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of green_checkbox

handles.channel2display(2) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);

% --- Executes on button press in blue_checkbox.
function blue_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to blue_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of blue_checkbox

handles.channel2display(3) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);
% --- Executes on slider movement.





function pictNb_slider_Callback(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global DataIF dataTrack

handles.PictNbSliderValue = round(get(hObject,'Value'));
handles.currentImageIndex = handles.PictNbSliderValue;

% load image into memory if it is not already
if ~handles.LoadImages2memory && isempty(DataIF(handles.currentImageIndex).red)
    
    red = imread([handles.chemin filesep DataIF(handles.currentImageIndex).RedImagesNames]);
    DataIF(handles.currentImageIndex).red = imadjust(red,stretchlim(red,[0.1 0.999]));
    
    green = imread([handles.chemin filesep DataIF(handles.currentImageIndex).GreenImagesNames]);
    DataIF(handles.currentImageIndex).green = imadjust(green,stretchlim(green,[0.1 0.999]));
end

% update image window
handles = UpdateImageDisplay(hObject,handles);

% return data in the workspace, if they are available
if handles.OKdatatrack
    currentPeak = dataTrack.peaks{handles.currentImageIndex};
    assignin('base','pic',currentPeak);
end

% Update handles structure
guidata(hObject, handles);

%% --- Executes during object creation, after setting allCells_radio properties.
function pictNb_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after allCells_radio CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% UpdateImageDisplay
function handles = UpdateImageDisplay(hObject,handles)

global DataIF dataTrack
currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
handles.onFrames = currentGoodCell.onframes;
xyRange =  currentGoodCell.xyrange;

set(handles.text1,'String',DataIF(handles.currentImageIndex).RedImagesNames);

redDisp = DataIF(handles.currentImageIndex).red*handles.channel2display(1);
greenDisp = DataIF(handles.currentImageIndex).green*handles.channel2display(2);


if handles.Zoomin
    
    xyrange = round(dataTrack.FilteredCells(handles.cell2display).xyrange);
    
    rect = [xyrange(1) xyrange(3) xyrange(2)-xyrange(1) xyrange(4)-xyrange(3)];
    redDisp = imcrop(redDisp,rect);
    greenDisp = imcrop(greenDisp,rect);
    
end

blueDisp = zeros(size(redDisp));

RGB = cat(3,redDisp,greenDisp,blueDisp);
axes(handles.MainFigure)
imshow(RGB)

hold on;

if handles.OKdatatrack % if track data are loaded, try to spot cells in the picture
    
    if handles.showCells % display the position of all the cells
        cellsInFrame = dataTrack.peaks{handles.currentImageIndex};
        
        if handles.Zoomin
            inds = cellsInFrame(:,1) > xyRange(1) & cellsInFrame(:,1) < xyRange(2) & cellsInFrame(:,2) > xyRange(3) & cellsInFrame(:,2) < xyRange(4);
            cellsInFrame = cellsInFrame(inds,:);
            xPos = cellsInFrame(:,1)- xyRange(1);
            yPos = cellsInFrame(:,2)- xyRange(3);
            
        else
            xPos = cellsInFrame(:,1);
            yPos = cellsInFrame(:,2);
        end
        
        cellNumber = cellsInFrame(:,8); % could be replace by the 8th column to get the cellID (index in the cell2 array)
        plot(xPos,yPos,'b.','MarkerSize',12)
        text(xPos,yPos-10,num2str(cellNumber),'Color','w');
        
    else % put a mark on the current cell
        
        if  sum(handles.onFrames == handles.PictNbSliderValue)
            [idx,valeur] = find (currentGoodCell.onframes == handles.PictNbSliderValue);
            
            cdata = currentGoodCell.data(valeur,:);
            cfdata = currentGoodCell.fdata(valeur,:);
            
            if handles.Zoomin
                xPos=cdata(1)-xyRange(1);
                yPos=cdata(2)-xyRange(3);
            else
                xPos=cdata(1);
                yPos=cdata(2);
            end
            
            plot(xPos,yPos,'r.','MarkerSize',12);
            text(xPos,yPos-10,num2str(cfdata(2)/cfdata(3),2),'Color','m');
        end
        
        
    end
end
drawnow;
hold off;

%  Update the highlighted point in the PlotDisplay
if handles.OKdatatrack
    cells = dataTrack.FilteredCells;
    ii = handles.cell2display;
    frameNbIdx = find(cells(ii).onframes == handles.currentImageIndex);
    pictimes = dataTrack.pictimes;
end


switch handles.What2plot
    case 'undefined'
        
    case 'single'
        set(handles.plotCursor,'XData',dataTrack.pictimes(cells(ii).onframes(frameNbIdx)),'YData',cells(ii).fdata(frameNbIdx,2)./cells(ii).fdata(frameNbIdx,3))
    case 'average'
        set(handles.plotCursor,'XData',pictimes(handles.currentImageIndex),'YData',handles.avgreturn(handles.currentImageIndex))
end

%% UpdatePlotDisplay
function handles = UpdatePlotDisplay(hObject,handles)

if handles.OKdatatrack
    global DataIF dataTrack
    
    cells = dataTrack.FilteredCells;
    feedings = dataTrack.feedings;
    pictimes = dataTrack.pictimes;
    paxes = handles.FigurePlot;
    ii = handles.cell2display;
    births = dataTrack.births;
%     look in the births array for the current cell
if ~isempty(births)
    birthIndex = find([births.cellN]==cells(ii).cellID);
else
    birthIndex = [];
end  
    
    if isfield(cells,'merge')
        set(handles.text_plot,'String',['index in the cell2array (cell ID) : ' int2str(cells(ii).cellID) '  ||   merge : ' int2str(cells(ii).merge)]);
    else
        set(handles.text_plot,'String',['index in the cell2array (cell ID) : ' int2str(cells(ii).cellID)]);
    end
     set(handles.textplot2,'String',['no divisions detected here']);
     
    if ~isempty(birthIndex)
        CurrentCellBirthTime = [births(birthIndex).time];
        
        for abc = 1:length(birthIndex)
        siblingID(abc) = births(birthIndex(abc)).sibling.cellN;
        end
    set(handles.textplot2,'String',['division(s) at frame : ' int2str(CurrentCellBirthTime) '  ||   sibbling(s) : ' int2str(siblingID)]);
    end
    
    % plot single cell trace in figurePlot window
    axes(handles.FigurePlot);
    
    if cells(ii).good
        
        [singleCellreturn,curseur] = singleCellPlot_TV3(cells,ii,pictimes,paxes,feedings,handles.currentImageIndex,1);
        
        currentCellData.timePoints = pictimes(cells(ii).onframes);
        currentCellData.nucSpline = cells(ii).sdata(:,1)/cells(ii).fdata(1,1);
        currentCellData.nucPoints = cells(ii).fdata(:,1)/cells(ii).fdata(1,1);
        currentCellData.smadPoint = cells(ii).fdata(:,2)./cells(ii).fdata(:,3);
        currentCellData.smadSpline = cells(ii).sdata(:,2)./cells(ii).sdata(:,3);
        
        if handles.CCCexpt
            currentCellData.fmedianum=[feedings.medianum];
            currentCellData.ftimes=[feedings.time];
        end
        
        
        
    else % what to plot in case the cell is not marked as good
        [singleCellreturn,curseur] = singleCellPlot_TV3(cells,ii,pictimes,paxes,feedings,handles.currentImageIndex,0);
        
    end
    
    %
    % % % % return data in the workspace
    assignin('base','currentCell',cells(ii));
    handles.plotCursor = curseur;
    
    % UpdateImageDisplay(hObject,handles)
    
end

% Update handles structure
% guidata(hObject, handles);
% --- Executes on button press in Load2mem_checkbox.
function Load2mem_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Load2mem_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.LoadImages2memory = get(hObject,'Value'); %returns toggle state of Load2mem_checkbox

% Update handles structure
guidata(hObject, handles);
% update single cell plot
% UpdatePlotDisplay(handles)


% --- Executes on slider movement.
function Figureplot_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Figureplot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global dataTrack
% get cell number
handles.cell2display = round(get(hObject,'Value'));

currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
handles.onFrames = currentGoodCell.onframes;
handles.currentImageIndex = currentGoodCell.onframes(1);

%go to the first frame where this cell is present
handles.PictNbSliderValue = currentGoodCell.onframes(1);
set(handles.pictNb_slider,'Value',handles.PictNbSliderValue);

handles.What2plot = 'single';

% Update plots and handles structure
handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting allCells_radio properties.
function Figureplot_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Figureplot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after allCells_radio CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% MakeAveragePlot_pushbutton_Callback
% --- Executes on button press in MakeAveragePlot_pushbutton.
function handles = MakeAveragePlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MakeAveragePlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataTrack
% options for averagePlot_TV3

plotcols=[2 3];
ps='k.-';
mkhandle=1;
includefeedings=1;

% data for averagePlot_TV3
cells = dataTrack.FilteredCells
% cells = dataTrack.allCells;
feedings = dataTrack.feedings;
pictimes = dataTrack.pictimes;


axes(handles.FigurePlot);

[avgreturn,curseur] = averagePlot_TV3(cells,plotcols,pictimes,feedings,ps,mkhandle,1,handles.currentImageIndex);

set(handles.text_plot,'String','average plot');

handles.What2plot = 'average';
handles.plotCursor =  curseur;
handles.avgreturn = avgreturn;

% Update handles structure et plots
guidata(hObject, handles);
% return data in the workspace
% assignin('base','cell',cells);

% --- Executes on button press in Zoomin_checkbox.
function Zoomin_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Zoomin_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.OKdatatrack
    handles.Zoomin =  get(hObject,'Value');% returns toggle state of Zoomin_checkbox
end


handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in showFilteredCells_pushbutton.
function showGoodCells_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to showFilteredCells_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CCCcheckbox

handles.showCells=get(hObject,'Value');% returns toggle state of showGoodCells_checkbox

handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

% Update handles structure
guidata(hObject, handles);


%% showGrowth_pushbutton.
function showGrowth_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showGrowth_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack
figure(2)
plotGrowth(dataTrack)

%% ExportPlot_pushbutton.
function ExportPlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportPlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF dataTrack
if handles.OKdatatrack
    
    switch handles.What2plot
        case 'single'
            cells = dataTrack.FilteredCells;
            feedings = dataTrack.feedings;
            pictimes = dataTrack.pictimes;
            % paxes = handles.FigurePlot;
            ii = handles.cell2display;
            
            figure(1)
            clf
            A = axes;
            [singleCellreturn,curseur] = singleCellPlot_TV3(cells,ii,pictimes,A,feedings,1,1)
            
            % Create xlabel
            xlabel('time (hours)','FontSize',14);
            
            % Create ylabel
            ylabel('Smad nuc/cyto (green)','FontSize',14);
            
            figTitle = [[handles.chemin ' cell nb ' int2str(ii)]];
            figTitle = strrep(figTitle,'Z:\110502\','')
            figTitle = strrep(strrep( strrep(figTitle,' ','-'),'Z:\',''),'\','-');
            
            title(figTitle)
            
            avgreturn = singleCellreturn.smad;
            pictimes = singleCellreturn.time;
            singleCellreturn.CellID = cells(ii).cellID;

        case 'average'
            % options for averagePlot_TV3
            
            plotcols=[2 3];
            ps='k.-';
            mkhandle=0;
            includefeedings=1;
            
            % data for averagePlot_TV3
            
            cells = dataTrack.FilteredCells;
            feedings = dataTrack.feedings;
            pictimes = dataTrack.pictimes;
            
            
            
            figure(1)
            clf
            
            [avgreturn] = averagePlot_TV3(cells,plotcols,pictimes,feedings,ps,mkhandle,1)
            
            
            % Create xlabel
            xlabel('time (hours)','FontSize',24);
            
            % Create ylabel
            ylabel('Smad4 nuc/cyto','FontSize',24);
            
            % title
            figTitle = [handles.chemin ' Average Plot'];
            figTitle = strrep(figTitle,'Z:\110502\','');
            figTitle = strrep(strrep( strrep(figTitle,' ','-'),'Z:\',''),'\','-');
%             title(figTitle)
%             set(gca,'XLim',[0 25])
%             set(gca,'YLim',[0.55 1.3]) 
            set(gca,'FontSize',16)
          end     
%  export aa average plot with feeding plotted with stairs            
            
media = [feedings.medianum];
feedTime = [feedings.time];
for ii = 1:length(feedings)
    conc = feedings(ii).medianame;
    
        if strfind(conc,' no FBS')
        conc = strrep(conc,' no FBS','')     
        if isempty(conc)
         conc = 'tgf0';
        end
        end
        
    if strfind(conc,'dmem')
        conc = strrep(conc,'dmem','')     
        if isempty(conc)
         conc = 'tgf0';
        end
    end
    
        if strfind(conc,'DM')
        conc = strrep(conc,'DM','')     
        if isempty(conc)
         conc = 'tgf0';
        end
        end

        
TGFconc(ii) = str2num(strrep(conc,'tgf',''))    
end

% close(2)
figure(2)
clf
[xb,yb] = stairs(feedTime,TGFconc)
hold on
[AX,H1,H2] = plotyy(pictimes,avgreturn,xb,yb)
set(AX(1),'YLim',[0.65 1.3],'YTickMode','auto','FontSize',14)
set(AX(2),'YLim',[-0.02 1.02],'YTickMode','auto','YColor','k','FontSize',14)
set(AX(1),'XLim',[0 60],'XTickMode','auto','FontSize',14)
set(AX(2),'XLim',[0 60],'XTickMode','auto','FontSize',14)

set(H1,'LineStyle','-','LineWidth',3)
set(H2,'LineStyle','-','LineWidth',2,'Color','k')

set(get(AX(1),'Xlabel'),'String','time (hrs)','FontSize',16) 
set(get(AX(1),'Ylabel'),'String','Smad 4 nuc/cyto','FontSize',16) 
set(get(AX(2),'Ylabel'),'String','[TGFb]','FontSize',16) 


% export data in a mat file


        slsh = strfind(handles.experimentFolder,'\');         
        expFolder = handles.experimentFolder(slsh(end)+1:end);  
        
     switch handles.What2plot
         
         case 'single'
            SmadDATA = singleCellreturn;
            saveName = [expFolder num2str(handles.chamberName) 'Cellnb' num2str(singleCellreturn.CellID) '.mat']
         case 'average'
            SmadDATA.smad = avgreturn(avgreturn>0.1);
            SmadDATA.time = pictimes(avgreturn>0.1);
            pp=csaps(SmadDATA.time,SmadDATA.smad,0.99);   
            SmadDATA.sspline = ppval(pp,SmadDATA.time);
            SmadDATA.nuc = [];
            SmadDATA.nspline = [];
            SmadDATA.CellID = 0;
            saveName = [expFolder num2str(handles.chamberName) 'average.mat']
     end
     
        TimeDATA = pictimes;
        feedingsTime = [feedings.time];
        feedingCycles = [feedings.cycles]
        feedingsMedium =TGFconc;
        dataCount1 = dataTrack.dataCount;
        dataCount2 = dataTrack.dataCount2;


% saveFolder = 'C:\Users\Marcel\Dropbox\sorre_eds\figure1\'
saveFolder = 'C:\Users\Marcel\Dropbox\sorre_eds\figure4\'
save([saveFolder saveName],'TimeDATA','SmadDATA','feedingsTime','feedingsMedium','feedingCycles','dataCount1','dataCount2', '-mat')
 
% savename = ['Z:\110502\graphs\' strrep(figTitle,'\','')];
    %
    %  saveas(gcf, savename, 'jpg')
    
end

%% RunSegmentCell_pushbutton.
function RunSegmentCell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RunSegmentCell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF dataTrack

setUserParamCCC10x([1024 1344])

% try
%     eval(paramfile);
% catch
%     error('Could not evaluate paramfile command');
% end
red = imread([handles.chemin filesep DataIF(handles.currentImageIndex).RedImagesNames]);
green = imread([handles.chemin filesep DataIF(handles.currentImageIndex).GreenImagesNames]);

nuc = green;
fimg = red;
% 
% nuc = red;
% fimg = green;

[maskC statsN]=segmentCells(nuc,fimg);
[tmp statsN]=addCellAvr2Stats(maskC,fimg,statsN);

plotHistStats( statsN, handles.currentImageIndex )

%% makeReport.
function makeReport_Callback(hObject, eventdata, handles)
% hObject    handle to makeReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NbmatFileNames = length(dir([handles.experimentFolder '\Ch*out.mat']))
% global DataIF dataTrack
if handles.CCCexpt
    
NbmatFileNames = length(dir([handles.experimentFolder '\Ch*out.mat']));
chamberNumbers = [1:1:96];
compteur2 = 1;
count = 0;
for ii = chamberNumbers
    
    ChNum = num2str(ii);
    if length(ChNum) == 1
        ChNum = ['0' ChNum]
    end
    
    matFileName = [handles.experimentFolder '\Ch' ChNum 'out.mat'];
    
    if exist(matFileName,'file')
        
        count = count + 1;
        
        if mod(count,6)==0
            figureNb = count/6
            subplotNb = 6;
        else
            figureNb = floor(count/6)+1;
            subplotNb = mod(count,6);
        end
        
         try
        load(matFileName)
        
        inds = [cells.good]==1;
        FilteredCells = cells(inds);
        
        figTitle = strrep(matFileName,'out.mat','');
        
        % options for averagePlot_TV3
        
        plotcols=[2 3];
        ps='k.-';
        mkhandle=1;
        includefeedings=1;
        
        figure(figureNb)
        subplotNb;
        subplot(3,2,subplotNb)
       avgreturn = averagePlot_TV3(FilteredCells,plotcols,pictimes,feedings,ps,mkhandle,1);
        title(figTitle)
        % Create xlabel
        xlabel('time (hours)','FontSize',14);
        % Create ylabel
        ylabel('Smad nuc/cyto (green)','FontSize',14);
% %     set X scal here    
%                  set(gca,'XLim',[0 30])
     
      end
        %plot growth
        
    try    
        subplot(3,2,subplotNb+1)
        
        if ~isempty(dataCount)
            dataCount(1,:) = dataCount(1,:)-dataCount(1,end);
            plot(dataCount(1,:),dataCount(2,:),'b-',dataCount2(1,:),dataCount2(2,:),'r-');
        else
            plot(dataCount2(1,:),dataCount2(2,:),'r-');
        end

        % Create xlabel
        xlabel('time (hours)','FontSize',14);
        % Create ylabel
        ylabel('cell number','FontSize',14);
% if exist('dataTrack.dataCount')
%         dataTrack.dataCount = dataCount;
%         dataTrack.dataCount2 = dataCount2;
%         dataTrack.dataCrowdExp = dataCrowdExp;
%         dataTrack.dataCrowdSeed = dataCrowdSeed;
%         dataTrack.feedings = feedings;
%         plotGrowth(dataTrack)
%         title([figTitle '-growth'])
% end
    end
        count = count + 1;
        
        
        set (gcf, 'PaperPosition',[0.25,0.25,8,10.5])
        set(gca,'YTickMode','auto')
%         set(gca,'XLim',[0 30])
        saveas(gcf,[handles.experimentFolder filesep num2str(figureNb)],'pdf')

        %    legend(gca,'FontSize',20)
      
% % %         make a plot with all the curves
        
        
% figure (27)
% 
% couleurs = colorcube(min(NbmatFileNames,length(chamberNumbers)));%['k','r','g','b','m','k','r','g','b','m','k','r','g','b','m']
% hold on
% plot(pictimes,avgreturn,'Color',couleurs(compteur2,:))
% compteur2 = compteur2 + 1;

% set(AX(1),'YLim',[0.65 1.3],'YTickMode','auto','FontSize',14)
% set(AX(2),'YLim',[-0.02 1.02],'YTickMode','auto','YColor','k','FontSize',14)
% set(AX(1),'XLim',[0 40],'XTickMode','auto','FontSize',14)
% set(AX(2),'XLim',[0 40],'XTickMode','auto','FontSize',14)
% 
% set(H1,'LineStyle','-','LineWidth',3)
% set(H2,'LineStyle','-','LineWidth',2,'Color','k')
% 
% set(get(AX(1),'Xlabel'),'String','time (hrs)','FontSize',16) 
% set(get(AX(1),'Ylabel'),'String','Smad 4 nuc/cyto','FontSize',16) 
% set(get(AX(2),'Ylabel'),'String','[TGFb]','FontSize',16) 


        
    end
    
    
end

else
    set(handles.message_text,'String','sorry, available only for CCC experiments','ForegroundColor', 'r')
end

% --- Executes on button press in findCell_pushbutton.
function findCell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to findCell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack

currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
xyRange =  currentGoodCell.xyrange;

% set image window as current
axes(handles.MainFigure)

% get cell coordinates from graphic input
message='pick a cell';
a=axis;
h=text(a(1)+(a(2)-a(1))*0.15,a(3)+(a(4)-a(3))*0.6,sprintf(message),'FontWeight','bold','FontSize',9,'color','w');

[a0,b0]=ginput(1);
delete(h);

x0 = round(a0);
y0 = round(b0);

if handles.Zoomin%
    x0 = x0+xyRange(1);
    y0 = y0+xyRange(3);
end


if x0>handles.ActualImageSize(2) || y0>handles.ActualImageSize(1)
    disp('missed it , try again!')
else
    
    % find the closest cell to the coordinates in the peaks structure
    xy = dataTrack.peaks{1,handles.currentImageIndex}(:,1:2);
    dst = abs(xy(:,1) - x0) + abs(xy(:,2) - y0);
    [mn, ii] = min(dst);
    
    pickedCellid = dataTrack.peaks{1,handles.currentImageIndex}(ii,8);
    
end

if pickedCellid==-1
    set(handles.text_plot,'String','Cell not in cells array, cannot show data');
    return;
end

% store the new current cell in the handles structure
handles.cell2display = pickedCellid;

% switch to cell filtering "all cells"
set(handles.allCells_radio,'Value',1);
CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)

% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);
handles.What2plot = 'single';
% Update image display and the handles structure
if handles.cell2display~=-1
    handles = UpdateImageDisplay(hObject,handles);
end
guidata(hObject, handles);



% --- Executes when selected object is changed in CellFiltering.
function CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in CellFiltering
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global dataTrack

% v = fix(get(hObject, 'Value'));
% tag = get(hObject, 'Tag');

h=get(handles.CellFiltering);
tag = get(h.SelectedObject, 'Tag');

cells2 = dataTrack.allCells;

switch tag
    case 'allCells_radio'
        dataTrack.FilteredCells = cells2;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
    case 'GoodOnly_radio'
        inds = [cells2.good]==1;
        good = cells2(inds);
        dataTrack.FilteredCells = good;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
        handles.cell2display = 1;
        
    case 'MergedOnly_radio'
        
        for aa = 1:length(cells2)
            isMerged(aa) = ~isempty(cells2(aa).merge);
        end
        inds = isMerged==1;
        mergedCells = cells2(inds);
        dataTrack.FilteredCells = mergedCells;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        handles.cell2display = 1;
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
        
        
end
%   get(handles.CellFiltering)


% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);

% Update image display and the handles structure
handles = UpdateImageDisplay(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in CustomFiltering_pushButton.
function CustomFiltering_pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to CustomFiltering_pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dataTrack

cells2 = dataTrack.FilteredCells;

name = 'enter a condtion to filter the cell structure';
prompt = 'use aa as the indice to loop over the "cell" structure. example to filter for the "merged" cells: ';
numlines = 1;
defaultanswer ={'~isempty(cells2(aa).merge)'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
conditionInput = char(answer{1});

for aa = 1:length(cells2)
    
    % define conditon here
    %          conditionVerified(aa) = ~isempty(cells2(aa).merge)';
    % or get it form dialog box
    condition = ['conditionVerified(aa) = ' conditionInput];
    eval(condition);
    %
end

inds = conditionVerified==1;
customFilteredCells = cells2(inds);
dataTrack.FilteredCells = customFilteredCells;

%         update slider bar
handles.cell2display = 1;
NbFilteredCells = length(dataTrack.FilteredCells);
set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);

% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);

% Update image display and the handles structure
handles = UpdateImageDisplay(hObject,handles);
guidata(hObject, handles);

function handles=readImageFiles(handles,s1)

global DataIF;
tic
if ~handles.confocalexpt
    chemin=s1.imagedirectory;
    
    [rangeG, listG] = folderFilesFromKeyword(s1.imagedirectory, s1.smadKeyWord);
    [rangeR, listR] = folderFilesFromKeyword(s1.imagedirectory, s1.nucKeyWord);
    [range,IR,IG] = intersect(rangeR,rangeG);
    GreenImagesNames = listG(IG);
    RedImagesNames = listR(IR);
    handles.onFrames = [1:length(RedImagesNames)];
    %
    
    % load images in memory
    if handles.LoadImages2memory
        
        for ii = 1:length(RedImagesNames)%using parfor (4 workers) here reduced the time to load 110 pictures from 49 to 33 seconds (loading images through network)
            
            DataIF(ii).RedImagesNames = RedImagesNames(ii).name;
            DataIF(ii).GreenImagesNames = GreenImagesNames(ii).name;
            
            red = imread([chemin filesep RedImagesNames(ii).name]);
            DataIF(ii).red = imadjust(red,stretchlim(red,[0.1 0.999]));
            
            green = imread([chemin filesep GreenImagesNames(ii).name]);
            DataIF(ii).green = imadjust(green,stretchlim(green,[0.1 0.999]));
        end
        
    else % only keep images names and display the first picture
        
        for ii = 1:length(RedImagesNames)
            
            DataIF(ii).RedImagesNames = RedImagesNames(ii).name;
            DataIF(ii).GreenImagesNames = GreenImagesNames(ii).name;
        end
        
        red = imread([chemin filesep RedImagesNames(1).name]);
        DataIF(1).red = imadjust(red,stretchlim(red,[0.1 0.999]));
        
        green = imread([chemin filesep GreenImagesNames(1).name]);
        DataIF(1).green = imadjust(green,stretchlim(green,[0.1 0.999]));
        
    end
else
    filename=s1.imagefile;
    handles.LoadImages2memory=1;
    set(handles.Load2mem_checkbox,'Value',1);
    set(handles.Load2mem_checkbox,'enable','off');
    fdata=lsminfo(filename);
    si=[fdata.DimensionX fdata.DimensionY];
    nz=fdata.DimensionZ;
    nt=fdata.DimensionTime;
    chan=s1.chan2use;
    %pictimes=(fdata.TimeStamps.TimeStamps)/3600;
    
    for tt=1:nt
        
        nucmax=zeros(si); nucmax=im2uint8(nucmax);
        sumall=0;
        for zz=1:nz
            imnum=(tt-1)*nz+zz;
            imnum=2*imnum-1;
            nucnow=tiffread27(filename,imnum);
            nucmax=max(nucmax,nucnow.data{chan(1)});
            sumframe=sum(sum(nucnow.data{chan(1)}));
            if sumframe > sumall
                sumall=sumframe;
                frametouse=zz;
            end
        end
        imnum=(tt-1)*nz+frametouse;
        imnum=2*imnum-1;
        imgs=tiffread27(filename,imnum);
        fimg=imgs.data{chan(2)};
        DataIF(tt).red=nucmax;
        DataIF(tt).green=fimg;
        DataIF(tt).RedImagesNames=filename;
        DataIF(tt).GreenImagesName=filename;
        
    end
    
    
end
toc





%%
function handles=readMatFile(handles,matfile)
global dataTrack;

peaks=[];
handles.matFileName=matfile;

load(handles.matFileName)


%     add x y range for of each cell for zoomin

for ii = 1:length(cells)
    if ~isempty(cells(ii).data)
        cells(ii).cellID = ii;
        
        px=cells(ii).data(:,1);
        py=cells(ii).data(:,2);
        maxx = max(px)+100;
        minx = min(px)-100;
        maxy = max(py)+100;
        miny = min(py)-100;
        
        if  maxx > handles.ActualImageSize(2)
            maxx = handles.ActualImageSize(2);
        end
        if  maxy > handles.ActualImageSize(1)
            maxy = handles.ActualImageSize(1);
        end
        if minx<0
            minx = 0;
        end
        if miny<0
            miny = 0;
        end
        cells(ii).xyrange = [minx maxx miny maxy];
    end
end

if handles.CCCexpt
    try
        if exist('dataCount','var')
    dataTrack.dataCount = dataCount;
        else
    dataTrack.dataCount = [];
        end
        
        if exist('dataCount2','var')
    dataTrack.dataCount2 = dataCount2;
        else
    dataTrack.dataCount2 = [];
        end
        
        if exist('feedings','var')
    dataTrack.feedings = feedings;
        else
    dataTrack.feedings = [];
        end
    
        if exist('dataCrowdExp','var')
            dataTrack.dataCrowdExp = dataCrowdExp;
            dataTrack.dataCrowdSeed = dataCrowdSeed;
        else
            dataTrack.dataCrowdExp = [];
            dataTrack.dataCrowdSeed = [];   
        end


        if exist('births','var')
        dataTrack.births = births;
        else
          dataTrack.births = [];  
        end
    catch
    end
else
    dataTrack.feedings=[];
end

dataTrack.allCells = cells;
dataTrack.pictimes = pictimes;
dataTrack.peaks = peaks;
set(handles.message_text,'String','found a mat file','ForegroundColor', 'k');
handles.cell2display = 1;
%     filtered cells only // will also update display
% CellFiltering_SelectionChangeFcn(hObject, eventdata, handles);
set(handles.allCells_radio,'Value',1);
handles.What2plot = 'undefined';
handles.OKdatatrack =1;


% --- Executes on button press in CCCcheckbox.
function CCCcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to CCCcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CCCcheckbox

handles.CCCexpt=get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in loadimages.
function loadimages_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in loadimages
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'CCC_radio'
        handles.CCCexpt=1;
        handles.confocalexpt=0;
        set(handles.Load2mem_checkbox,'enable','on');
        
    case 'confocal_radio'
        handles.CCCexpt=0;
        handles.confocalexpt=1;
        set(handles.Load2mem_checkbox,'Value',1);
        set(handles.Load2mem_checkbox,'enable','off');
    case 'other_radio'
        handles.CCCexpt=0;
        handles.confocalexpt=0;
        set(handles.Load2mem_checkbox,'enable','on');
        
end
% Update handles structure
guidata(hObject, handles);

function missingstring=checkForRequiredFiles(requiredFiles)
%check that necessary .m files are on path. returns a string with
%names of missing files
q=1; missinginds=[];
for ii=1:length(requiredFiles)
    if ~exist(requiredFiles{ii},'file')
        disp(['warning: file ' requiredFiles{ii} ' required.']);
        missinginds=[missinginds ii];
    end
end


missingstring=[];
for ii=1:length(missinginds)
    missingstring=[missingstring requiredFiles{missinginds(ii)} ' '];
end
if ~isempty(missingstring)
missingstring=['warning, missing files:' missingstring];
end

%% plotgrowth
function plotGrowth(dataTrack)

dataCount1 = dataTrack.dataCount;
dataCount2 = dataTrack.dataCount2;
dataCrowdExp = dataTrack.dataCrowdExp ;
dataCrowdSeed = dataTrack.dataCrowdSeed;


try
if ~isempty(dataCount1)
    dataCount1(1,:) = dataCount1(1,:)-dataCount1(1,end);
    plot(dataCount1(1,:),dataCount1(2,:),'b-',dataCount2(1,:),dataCount2(2,:),'r-');
else
    
    plot(dataCount2(1,:),dataCount2(2,:),'r-');
end

hold on

if ~isempty(dataCrowdExp)
    dataCrowdExp(1,:) = dataCrowdExp(1,:)- dataCrowdExp(1,1);
    if ~isempty(dataCrowdSeed)
    dataCrowdSeed(1,:) = dataCrowdSeed(1,:)- dataCrowdSeed(1,end);
    plot(dataCrowdSeed(1,:),dataCrowdSeed(2,:),'g-',dataCrowdExp(1,:),dataCrowdExp(2,:),'g-'); 
    else
            plot(dataCrowdExp(1,:),dataCrowdExp(2,:),'g-'); 
    end

end

hold off
catch
end
% Create xlabel
xlabel('time (hours)','FontSize',14);

% Create ylabel
ylabel('cell number','FontSize',14);


% assignin('base','allPeaks',piques);


%% StatsPeaks_pushbutton.
function StatsPeaks_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StatsPeaks_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataTrack;

data = getMaxstats(dataTrack.allCells,dataTrack.feedings,dataTrack.pictimes,dataTrack.dataCrowdExp,dataTrack.dataCrowdSeed,dataTrack.dataCount,dataTrack.dataCount2,handles.chemin)
assignin('base','donneesJumps',data);