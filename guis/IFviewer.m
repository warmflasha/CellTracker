%%

function varargout = IFviewer(varargin)
% IFVIEWER M-file for IFviewer.fig
%      IFVIEWER, by itself, creates a new IFVIEWER or raises the existing
%      singleton*.
%
%      H = IFVIEWER returns the handle to a new IFVIEWER or the handle to
%      the existing singleton*.
%
%      IFVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IFVIEWER.M with the given input arguments.
%
%      IFVIEWER('Property','Value',...) creates a new IFVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IFviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IFviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IFviewer

% Last Modified by GUIDE v2.5 19-Apr-2012 16:59:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @IFviewer_OpeningFcn, ...
    'gui_OutputFcn',  @IFviewer_OutputFcn, ...
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


% --- Executes just before IFviewer is made visible.
function IFviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IFviewer (see VARARGIN)

global DataIF

% Choose default command line output for IFviewer
handles.output = hObject;

handles.MinRedValue = 1;
handles.MaxRedValue = 4091;

handles.MinGreenValue = 1;
handles.MaxGreenValue = 4091;

handles.MinBlueValue = 1;
handles.MaxBlueValue = 4091;


set(handles.MinRed_slider,'Max',4091,'Min',1,'Value',handles.MinRedValue,'SliderStep',[0.01 0.2]);
set(handles.MaxRed_slider1,'Max',4091,'Min',1,'Value',handles.MaxRedValue,'SliderStep',[0.01 0.2]);

set(handles.MinGreen_slider,'Max',4091,'Min',1,'Value',handles.MinGreenValue,'SliderStep',[0.01 0.2]);
set(handles.MaxGreen_slider,'Max',4091,'Min',1,'Value',handles.MaxGreenValue,'SliderStep',[0.01 0.2]);

set(handles.MinBlue_slider,'Max',4091,'Min',1,'Value',handles.MinBlueValue,'SliderStep',[0.01 0.2]);
set(handles.MaxBlue_slider,'Max',4091,'Min',1,'Value',handles.MaxBlueValue,'SliderStep',[0.01 0.2]);

handles.channel2display = [1 1 1];

handles.loadCompleteCollection = 0;
handles.LoadImages2memory = 0;
handles.showCellCenters = 0;
handles.chemin = 'Computer';

handles.MMexpt = 0;
handles.confocalExpt = 1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IFviewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IFviewer_OutputFcn(hObject, eventdata, handles)
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


global DataIF
DataIF = [];

handles.showCellCenters = 0;
set(handles.segCheckBox,'Value',0)

if handles.MMexpt
handles = LoadMMData(handles);
elseif handles.confocalExpt
handles = LoadConfocalData(handles);
elseif handles.MetamorphData
handles = LoadMetamorphData(handles)
end

handles.currentImageIndex = 1;


% Update handles structure
guidata(hObject, handles);

% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)








%% checkboxes etc
% --- Executes on slider movement.
function MaxRed_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to MaxRed_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


handles.MaxRedValue = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);

% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MaxRed_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxRed_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function MinRed_slider_Callback(hObject, eventdata, handles)
% hObject    handle to MinRed_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.MinRedValue = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);
% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MinRed_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinRed_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function MaxGreen_slider_Callback(hObject, eventdata, handles)
% hObject    handle to MaxGreen_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.MaxGreenValue = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);
% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MaxGreen_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxGreen_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function MinGreen_slider_Callback(hObject, eventdata, handles)
% hObject    handle to MinGreen_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.MinGreenValue = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);
% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MinGreen_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinGreen_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function MaxBlue_slider_Callback(hObject, eventdata, handles)
% hObject    handle to MaxBlue_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.MaxBlueValue = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);
% update display
UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MaxBlue_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxBlue_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function MinBlue_slider_Callback(hObject, eventdata, handles)
% hObject    handle to MinBlue_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.MinBlueValue = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function MinBlue_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinBlue_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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

UpdateImageDisplay(hObject,handles,handles.MainFigure)

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

UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3

handles.channel2display(3) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles,handles.MainFigure)


% --- Executes when DataType_panel is resized.
function DataType_panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to DataType_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in DataType_panel.
function DataType_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in DataType_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

h=get(handles.DataType_panel);
tag = get(h.SelectedObject, 'Tag');

switch tag
    
    case 'MMexptRadio'
    handles.MMexpt = 1;
    handles.confocalExpt = 0;
    handles.MetamorphData = 0;

    case 'ConfocalExptRadio'
    handles.MMexpt = 0;
    handles.confocalExpt = 1;
    handles.MetamorphData = 0;
    
    case 'MetaMorph_radiobutton'
    handles.MetamorphData = 1;    
    handles.MMexpt = 0;
    handles.confocalExpt = 0;  
    
end

guidata(hObject, handles);

%% pict slider
% --- Executes on slider movement.
function pictNb_slider_Callback(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global DataIF

handles.PictNbSliderValue = round(get(hObject,'Value'));
handles.currentImageIndex = handles.PictNbSliderValue;


if ~handles.LoadImages2memory && isempty(DataIF(handles.currentImageIndex).red)
    try
        DataIF(handles.currentImageIndex).green = imread([DataIF(handles.currentImageIndex).currentFolder filesep 'img_000000000_green_000.tif']);
    catch
        DataIF(handles.currentImageIndex).green=zeros(512,672);
    end
    try
        DataIF(handles.currentImageIndex).red = imread([DataIF(handles.currentImageIndex).currentFolder filesep 'img_000000000_red_000.tif']);
    catch
        DataIF(handles.currentImageIndex).red=zeros(512,672);
        
    end
    try
        DataIF(handles.currentImageIndex).blue = imread([DataIF(handles.currentImageIndex).currentFolder filesep 'img_000000000_blue_000.tif']);
    catch
        DataIF(handles.currentImageIndex).blue=zeros(512,672);
        
    end
end

% Update handles structure
guidata(hObject, handles);

UpdateImageDisplay(hObject,handles,handles.MainFigure)

% --- Executes during object creation, after setting all properties.
function pictNb_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% UpdateImageDisplay
function UpdateImageDisplay(hObject,handles,whichWindow)

global DataIF

set(handles.text1,'String',DataIF(handles.currentImageIndex).currentFolder);

red = DataIF(handles.currentImageIndex).red;
green = DataIF(handles.currentImageIndex).green;
blue = DataIF(handles.currentImageIndex).blue;

redDisp = ((double(red))/2^12)*handles.channel2display(1);
greenDisp =((double(green))/2^12)*handles.channel2display(2);
blueDisp = ((double(blue))/2^12)*handles.channel2display(3);



minRed = handles.MinRedValue/2^12;
maxRed = handles.MaxRedValue/2^12;

minGreen = handles.MinGreenValue/2^12;
maxGreen = handles.MaxGreenValue/2^12;

minBlue = handles.MinBlueValue/2^12;
maxBlue = handles.MaxBlueValue/2^12;

RGB = cat(3,redDisp,greenDisp,blueDisp);
rgb1 = imadjust(RGB,[minRed minGreen minBlue; maxRed maxGreen maxBlue]);

% plot image
if exist('whichWindow','var')
axes(whichWindow)
else
    figure
end
imshow(rgb1)

% if asked, overlay cell centers as found with segmentCell

if handles.showCellCenters
    
    if isempty(DataIF(handles.currentImageIndex).segmentData)
        outdat=segmentCurrentImage(hObject,handles,handles.currentImageIndex);
        od=outdat;
    else
        od=DataIF(handles.currentImageIndex).segmentData;
    end
    
    axes(handles.MainFigure)
    
    hold on;
%     put a dot on all the cells
    plot(od(:,1),od(:,2),'b.');
%     put a star of the cells that passed the filter 
    inds=od(:,6)>=handles.seuil;
    plot(od(inds,1),od(inds,2),'m.');
%    give the numbers
    message=['total :'  num2str(length(od)) ' positive : ' num2str(sum(inds))];
    
    a=axis;
    h=text(a(1)+(a(2)-a(1))*0.15,a(3)+(a(4)-a(3))*0.6,sprintf(message),'FontWeight','bold','FontSize',9,'color','w');
    hold off;
    
end

%% segment current image
function outdat=segmentCurrentImage(hObject,handles,imageIndex)

%segment the current image and store the data in DataIF().segmentData

global DataIF;

ii=imageIndex;
r=DataIF(ii).blue;%nuclear marker (e.g. DAPI)
g=DataIF(ii).green;%protein of interrest (e.g. myogenin)

setUserParamCCC20x_IFviewerBS(r);

% axes(handles.axes3)
figure(200)
[maskC statsN]=segmentCells(r,g);
% [maskC statsN]=segmentCells(r,[]);
[tmp statsN]=addCellAvr2Stats(maskC,g,statsN);
outdat=outputData4AWTracker(statsN,r);

DataIF(ii).segmentData = outdat;
guidata(hObject,handles);


%%  savePicture
function savePicture_Callback(hObject, eventdata, handles)
% hObject    handle to savePicture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global DataIF

% retreive image data and adjust grey scales
red = DataIF(handles.currentImageIndex).red;
green = DataIF(handles.currentImageIndex).green;
blue = DataIF(handles.currentImageIndex).blue;

redDisp = ((double(red))/2^12)*handles.channel2display(1);
greenDisp =((double(green))/2^12)*handles.channel2display(2);
blueDisp = ((double(blue))/2^12)*handles.channel2display(3);

minRed = handles.MinRedValue/2^12;
maxRed = handles.MaxRedValue/2^12;

minGreen = handles.MinGreenValue/2^12;
maxGreen = handles.MaxGreenValue/2^12;

minBlue = handles.MinBlueValue/2^12;
maxBlue = handles.MaxBlueValue/2^12;

RGB = cat(3,redDisp,greenDisp,blueDisp);
rgb1 = imadjust(RGB,[minRed minGreen minBlue; maxRed maxGreen maxBlue]);

% plot image in a new window

figure(1)
imshow(rgb1)

x0 = 448;
y0 = 342;
% rgb1crop = imcrop(rgb1,[x0 y0 672 512]);

rgb1crop = rgb1;

size(rgb1crop)
size(rgb1)
rgb1crop(493:500,550:650,:) = 1;

% figure(2)
% imshow(rgb1crop,[])
%     hold on;
%     od=DataIF(handles.currentImageIndex).segmentData;
% 
% %     put a dot on all the cells
%     plot(od(:,1),od(:,2),'y.','MarkerSize',20);
% %     put a star of the cells that passed the filter 
%     inds=od(:,6)>=handles.seuil;
%     plot(od(inds,1),od(inds,2),'r.','MarkerSize',20);
% %    give the numbers
%     message=['total :'  num2str(length(od)) ' positive : ' num2str(sum(inds))];
%     a=axis;
% %     h=text(a(1)+(a(2)-a(1))*0.15,a(3)+(a(4)-a(3))*0.6,sprintf(message),'FontWeight','bold','FontSize',9,'color','w');
%     hold off;
% set(gca,'XLim',[0 250],'YLim',[200 500])
imageName = DataIF(handles.currentImageIndex).currentFolder;
bckslsh = strfind(imageName,filesep);
name2save = strrep(imageName(bckslsh(end)+1:length(imageName)),'\','');
% title(name2save)
% 
% A = get(gca,'Position')

% set(gca,'outerPosition',A)
 saveFolder = 'C:\Users\Marcel\Google Drive\Talks\121212-GM\'
 
 name = [saveFolder name2save];
%  export_fig(name,'-transparent','-eps')

 imwrite(rgb1,[saveFolder name2save '.jpg'])


% --- Executes on button press in LoadCompleteCollection.
function LoadCompleteCollection_Callback(hObject, eventdata, handles)
% hObject    handle to LoadCompleteCollection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LoadCompleteCollection
handles.loadCompleteCollection = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in LoadImages2Memory.
function LoadImages2Memory_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImages2Memory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LoadImages2Memory

handles.LoadImages2memory = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in segCheckBox.
function segCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to segCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of segCheckBox
handles.showCellCenters=get(hObject,'value');

guidata(hObject, handles);

UpdateImageDisplay(hObject,handles,handles.MainFigure);

%% data loading functions

function handles = LoadMMData(handles)

global DataIF
% handles.chemin = 'Z:\'
[chemin] = uigetdir(handles.chemin,'ah ah');

handles.chemin = chemin;


if handles.loadCompleteCollection
     
    %get the folder list and clean it
    ParametersIF.path = chemin;
    cd(chemin)
    cd ..
    folderContent = dir(pwd);
    incrementFolder = 1;
    
%     look for folders in the list 
    for cc = 3:length(folderContent)  
        if isdir([pwd filesep folderContent(cc).name])
            folders{incrementFolder} = {[pwd filesep folderContent(cc).name]};
            incrementFolder = incrementFolder + 1;
        end
    end
    
else
    
    %get the folder list and clean it
    ParametersIF.path = chemin;
    cd(chemin)
    cd ..
    folderContent = dir(pwd);
    incrementFolder = 1;
    
%     extract name of the well of interest
    WellName = strrep(chemin,pwd,'');
    underScore = strfind(WellName,'_')

    WellName = WellName(2:(underScore(end)-1));
    
%     look in the folder list for the ones that have the same "well name"

    for cc = 3:length(folderContent)
        if isdir([pwd filesep folderContent(cc).name]) && ~isempty(strmatch(WellName,[folderContent(cc).name]))
            folders{incrementFolder} = {[pwd filesep folderContent(cc).name]};
            incrementFolder = incrementFolder + 1;
        end
    end 
end

NbFichier = length(folders);
if NbFichier == 1
    NbFichier =2;
end
set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 1/(NbFichier-1)]);  
    
%     load images data to memory
    
    for ddd = 1:length(folders)

        DataIF(ddd).currentFolder = char(folders{ddd});
        DataIF(ddd).segmentData = [];
        
        try
%             DataIF(ddd).green = imread([DataIF(ddd).currentFolder filesep 'img_000000000_Nluc_000.tif']);
            DataIF(ddd).green = imread([DataIF(ddd).currentFolder filesep 'img_000000000_green_000.tif']);
%             DataIF(ddd).green= imread([DataIF(ddd).currentFolder filesep 'img_000000000_red_000.tif']);
            
        catch
            DataIF(ddd).green=zeros(512*2,672*2); 
        end
        
        try
            DataIF(ddd).red = imread([DataIF(ddd).currentFolder filesep 'img_000000000_rfp657_000.tif']);
%             DataIF(ddd).red = imread([DataIF(ddd).currentFolder filesep 'img_000000000_red_000.tif']);
        catch
%             DataIF(ddd).red=zeros(512,672);
            DataIF(ddd).red=zeros(size(DataIF(ddd).green));
        end
        
        try
%             DataIF(ddd).blue = imread([DataIF(ddd).currentFolder filesep 'img_000000000_rfp657_000.tif']);
             DataIF(ddd).blue = imread([DataIF(ddd).currentFolder filesep 'img_000000000_blue_000.tif']);
%                DataIF(ddd).blue  = imread([DataIF(ddd).currentFolder filesep 'img_000000000_red_000.tif']);
        catch
            DataIF(ddd).blue=zeros(size(DataIF(ddd).green));
        end
        
    end
    
% look for a mat file having "WellNbr" for name

if handles.loadCompleteCollection
    
        for ii = 1:length(DataIF)
        DataIF(ii).segmentData = [];
        end  
        handles.matFileName =  [];   
   
else

% aa = strfind(WellName,'Well');
% WellNbr = WellName(aa+4:aa+5);
%     WellNbr = str2num(ww)
%     if length(WellName) ==1
%         WellNbr = ['0' WellNbr];
%     end
%     WellName = ['Well' WellNbr];

matFileNames = dir(['*.mat']);

matFileName = [pwd filesep WellName '.mat'];

for ff = 1:length(matFileNames)
  
    currentName = strrep(matFileNames(ff).name,'.mat','');
    
    if ~isempty(strfind(WellName,currentName))
        matFileName = [pwd filesep matFileNames(ff).name];
    end
end

 
 if exist(matFileName,'file')
   try
  load(matFileName)

  for ii = 1:length(DataIF)
    DataIF(ii).segmentData = Data2Save(ii).segmentData;
  end
  
    catch
       
   end   
 else
     
 end
 
  handles.matFileName =  matFileName;  
end   
    
function handles = LoadConfocalData(handles)

global DataIF

[filename, pathname, filterindex] = uigetfile('*.lsm','pick one or multiple .lsm file(s)',handles.chemin,'MultiSelect', 'on');

handles.chemin = pathname;

 
if iscell(filename)
    NbFichier = length(filename);
    set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 10/(NbFichier-1)]); 
    filenameList = filename;
else
    NbFichier = 1;
    set(handles.pictNb_slider,'Max',NbFichier,'Min',0,'Value',1,'SliderStep',[1 10]); 
    filenameList{1} = filename;
end
    
%     load images data to memory
for ii = 1:NbFichier
        
imageName = [pathname char(filenameList{ii})];
imgs=tiffread27(imageName,1);

DataIF(ii).red = imgs.data{1};
DataIF(ii).green = imgs.data{2};
DataIF(ii).blue = zeros(size(imgs.data{1}));
DataIF(ii).currentFolder = imageName;
DataIF(ii).segmentData = [];

handles.matFileName = imageName
end




function handles = LoadMetamorphData(handles)

global DataIF

if handles.MetaMorphSorted % files sorted into folders. select one folder and all the tiffs in it will be loaded

[currentFolder] = uigetdir(handles.chemin,'ah ah');

handles.chemin = currentFolder;
    
%     what is the well name
backSlash = strfind(currentFolder,'\')

    WellName = currentFolder(backSlash(end)+1:end);
    mainFolder = currentFolder(1:backSlash(end));
    
% currentFolder = [mainfolder WellName filesep];
% dir(currentFolder)
NucFilenames = dir([currentFolder filesep '*w1.TIF'])

% update sliders properties

if length(NucFilenames)>1
    NbFichier = length(NucFilenames);
    set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 10/(NbFichier-1)]); 
%     filenameList = filename;
else
    NbFichier = 1;
    set(handles.pictNb_slider,'Max',NbFichier,'Min',0,'Value',1,'SliderStep',[1 10]); 
%     filenameList{1} = filename;
end

% images loading loop
   
    for ddd = 1:length(NucFilenames)

        DataIF(ddd).currentFolder = NucFilenames(ddd).name;
        DataIF(ddd).segmentData = [];
        
%       blue is nuclear marker
        try
        DataIF(ddd).blue = imread([currentFolder filesep NucFilenames(ddd).name]);
        catch
        DataIF(ddd).blue=zeros(512,672);
        end
        
        try
            DataIF(ddd).green = imread(strrep([currentFolder filesep NucFilenames(ddd).name],'w1','w2'));
        catch
            DataIF(ddd).green=zeros(512,672); 
        end
        
        try
            DataIF(ddd).red = imread([DataIF(ddd).currentFolder filesep 'img_000000000_red_000.tif']);
        catch
%             DataIF(ddd).red=zeros(512,672);
            DataIF(ddd).red=zeros(size(DataIF(ddd).blue));
        end
 
    end  
%         try to load .mat file 

matFileName = [currentFolder '.mat'];

  if exist(matFileName,'file')
   try 
      load(matFileName)
      for ii = 1:length(DataIF)
        DataIF(ii).segmentData = Data2Save(ii).segmentData;
      end 
   catch 
        for ii = 1:length(DataIF)
        DataIF(ii).segmentData = [];
        end       
   end
  end   
  handles.matFileName = matFileName 
  
else % unsorted files. just select by hand the files that you want to load
    
[filename, pathname, filterindex] = uigetfile('*.tif','pick one or multiple .tif file(s) don t worry about the stupid thumb files',handles.chemin,'MultiSelect', 'on');

handles.chemin = pathname;


%%
% eliminate any thumb file
counter = 1;
 for ii = 1:length(filename)
    filename{ii}
    if isempty(strfind(filename{ii},'Thumb')) & ~isempty(strfind(filename{ii},'w1'))
        filename2{counter} = filename{ii};
        counter = counter + 1
    end
    
 end
 
% will crash here if only a 'w2' picture has been selected 
filename = filename2;

%%

if iscell(filename)
    NbFichier = length(filename);
    set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 10/(NbFichier-1)]); 
    filenameList = filename;
else
    NbFichier = 1;
    set(handles.pictNb_slider,'Max',NbFichier,'Min',0,'Value',1,'SliderStep',[1 10]); 
    filenameList{1} = filename;
end


%%    
%     load images data to memory
for ii = 1:NbFichier
    
    % blue is nuc
    imageNameNuc = [pathname char(filenameList{ii})];
    imgs=tiffread27(imageNameNuc,1);
    
    DataIF(ii).blue = imgs.data;
    % green is IF
    imageNameIF = strrep(imageNameNuc,'w1','w2');
    imgs2=tiffread27(imageNameIF,1);
    DataIF(ii).green = imgs2.data;
    % red unused for now
    DataIF(ii).red = zeros(size(imgs.data));

    currentString = char(filenameList{ii});
    findUnderScore = strfind(currentString,'_');
    DataIF(ii).PlateName = currentString(1:findUnderScore(1)-1);
    DataIF(ii).WellName = currentString(findUnderScore(1)+1:findUnderScore(1)+3);
    DataIF(ii).position = ['Pos' currentString(findUnderScore(2)+2:findUnderScore(3)-1)];
    DataIF(ii).currentFolder = imageNameNuc;
    DataIF(ii).segmentData = [];
    
end

end

%% analysis functions


% --- Executes on button press in SegmentCurrentPic_Pushbutton.
function SegmentCurrentPic_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SegmentCurrentPic_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF;

% segment current image. will overwrite data for that image if they exist
outdat=segmentCurrentImage(hObject,handles,handles.currentImageIndex);

% handles.showCellCenters=1;

guidata(hObject, handles);
UpdateImageDisplay(hObject,handles,handles.MainFigure);


% --- Executes on button press in AnalyseCurrentPicture_Pushbutton.
function AnalyseCurrentPicture_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyseCurrentPicture_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF;

% retrieve segmentation data for the current frame or segment if no data is
% present for that image
if isempty(DataIF(handles.currentImageIndex).segmentData)
outdat=segmentCurrentImage(hObject,handles,handles.currentImageIndex);
else
    outdat=DataIF(handles.currentImageIndex).segmentData;
end

handles = displayAnalysis(outdat,handles);

guidata(hObject, handles);
UpdateImageDisplay(hObject,handles,handles.MainFigure);
figure(3)

% --- Executes on button press in segmentAllSerie_pushbutton.
function segmentAllSerie_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to segmentAllSerie_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF;

% segment all images that are not already
% maybe add an option giving the oportunity to overwrite?

for ii = 1:length(DataIF)  
    try
    if isempty(DataIF(ii).segmentData)
        outdat=segmentCurrentImage(hObject,handles,ii);
    end
    catch
        DataIF(ii).segmentData = []
    end
end


% --- Executes on button press in AnalyseAllSerie_pushbutton.
function AnalyseAllSerie_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyseAllSerie_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF;

% concatenate data for all the images in the serie in one array

for ii = 1:length(DataIF)  
%     if isempty(DataIF(ii).segmentData)
%         outdat=segmentCurrentImage(hObject,handles,ii);
%     end
   
handles.seuil = 250;
nucSeuil = 00;
pictData = DataIF(ii).segmentData
inds2 = pictData(:,5)>nucSeuil;
fitered4nucIntensity = pictData(inds2,:);
TotalCellNb = length(fitered4nucIntensity)

inds=pictData(:,5)>nucSeuil & pictData(:,6)>handles.seuil;
filtree = pictData(inds,:);
NbmyogeninPos = length(filtree)
ratioMyogeninPos(ii) = (length(filtree)/TotalCellNb)*100




    if ii == 1
        concatData = DataIF(ii).segmentData;
        
        
    else
        concatData = [concatData;DataIF(ii).segmentData]; 
    end
end

handles = displayAnalysis(concatData,handles);

guidata(hObject, handles);
UpdateImageDisplay(hObject,handles,handles.MainFigure);

assignin('base','ratioMyogeninPos',ratioMyogeninPos);

%% --- Executes on button press in SaveData_pushbutton.
function SaveData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF;

filename = handles.matFileName
Data2Save = rmfield(DataIF,{'green','blue','red'})
save(filename, 'Data2Save');
% 

% --- Executes on button press in SegParams_pushbutton.
function SegParams_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SegParams_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    S.nucKeyWord={'red' '* '};
    S.smadKeyWord={'green' '* '};
    S.gaussFilterRadius = { 4 '* (size of gaussian filter. increase to smooth more)' [3 20] };
    S.dontFilterNuc={0 '* (set to 1 to skip img(center) threshold filtering step)'}; % 
    
    S.gaussThreshExcess ={5 '* (lower this to pick dim nuclei)'}; %  5; %BS111110 was 5 -  1 is doing a better job when a few nuc are very bright can be set to an even lower value if necessary
    S.nucIntensityRange = {3 '* (can also be lowered to pick dim nuclei)'}; % 
    
    s1=StructDlg(S)
    
%% Display analysis

function handles = displayAnalysis(dataset,handles)
concatData = dataset;
global DataIF;


% inds=concatData(:,7)>0;
% figure
%   hist(concatData(inds,6)./concatData(inds,7),20);
% plot various stuff
% bins=[0:30:300];
% figure
% %  hist(outdat(:,6)./outdat(:,7),20);
% % hist(concatData(:,6)./concatData(:,7),20);
% hist(concatData(:,6),20);
% legend(['mean=' num2str(mean(outdat(inds,6)./outdat(inds,7)))]);
% guidata(hObject, handles);
% outdat
% figure
% plot(concatData(:,5),concatData(:,6),'.')
% figure
% plot(concatData(:,5),concatData(:,6)./concatData(:,7),'.')
% hist(concatData(:,6));


figure(1)
plot(concatData(:,5),log(concatData(:,7)),'.')


handles.seuil = 250;
nucSeuil = 150;

inds2 = concatData(:,5)>nucSeuil;
fitered4nucIntensity = concatData(inds2,:);
TotalCellNb = length(fitered4nucIntensity)

figure(2)
plot(fitered4nucIntensity(:,5),log(fitered4nucIntensity(:,7)),'.')


inds=concatData(:,5)>nucSeuil & concatData(:,7)>handles.seuil;
filtree = concatData(inds,:);
NbmyogeninPos = length(filtree)
ratioMyogeninPos = length(filtree)/TotalCellNb


bins=[1:0.10:9]; 
figure  
hist(log(fitered4nucIntensity(:,7)),bins);


    message1 = [num2str(ratioMyogeninPos*100) ' percent positive (fluo nuc > ' num2str(handles.seuil) '= exp' num2str(log(handles.seuil)) ')']
    message2 = strrep(handles.matFileName,'\','-')
    a=axis;
    h=text(a(1)+(a(2)-a(1))*0.05,a(3)+(a(4)-a(3))*0.95,sprintf(message1),'FontWeight','bold','FontSize',9,'color','k');
    h2=text(a(1)+(a(2)-a(1))*0.05,a(3)+(a(4)-a(3))*0.9,sprintf(message2),'FontWeight','bold','FontSize',9,'color','k');
%     hold off;

% to output histogram values in the workspace
% [N,X] = hist(log(fitered4nucIntensity(:,6)),bins);   
% assignin('base','N',N);
% assignin('base','X',X);

% size (filtree)
% figure
% plot(filtree(:,5),log(filtree(:,6)),'.')

% % keep only good cells (?)
% inds=outdat(:,5)>0;
% 
% % plot various stuff
% 
% %bins=0:0.2:6.0;
% figure(500)
% % hist(outdat(inds,6)./outdat(inds,5),20);
% hist(outdat(inds,6),20);
% % legend(['mean=' num2str(mean(outdat(inds,6)./outdat(inds,7)))]);
% guidata(hObject, handles);
% % outdat
% 
% figure(600)
% % plot(outdat(inds,5),outdat(inds,6),'.')
% plot(outdat(:,5),outdat(:,6),'.')
% plot(outdat(inds,5),outdat(inds,6)./outdat(inds,5),'.')

% rotation in case of bleedthrough
% 
% vecteur(:,1) = concatData(:,5);
% vecteur(:,2) = concatData(:,6);
% 
% theta = pi/10
% rotmat = [cos(theta) sin(theta);-sin(theta) cos(theta)]
% 
% 
% for ii = 1:length(vecteur)
% 
%     vecteurPrime(:,ii) = rotmat * (vecteur(ii,:)');
% end
% 
% 
% figure
% plot(vecteurPrime(1,:),vecteurPrime(2,:),'r.')
% 
% 
% figure
% % hist(outdat(inds,6)./outdat(inds,5),20);
% hist(vecteurPrime(2,:),20);
% filtree = vecteurPrime(2,(vecteurPrime(2,:)>750));
% ratio = length(filtree)/length(vecteurPrime)


% --- Executes on button press in metamorphSorted_checkbox.
function metamorphSorted_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to metamorphSorted_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.MetaMorphSorted=get(hObject,'value');

guidata(hObject, handles);
