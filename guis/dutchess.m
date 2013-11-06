function varargout = dutchess(varargin)
% DUTCHESS MATLAB code for dutchess.fig
%      DUTCHESS, by itself, creates a new DUTCHESS or raises the existing
%      singleton*.
%
%      H = DUTCHESS returns the handle to a new DUTCHESS or the handle to
%      the existing singleton*.
%
%      DUTCHESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DUTCHESS.M with the given input arguments.
%
%      DUTCHESS('Property','Value',...) creates a new DUTCHESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dutchess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dutchess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dutchess

% Last Modified by GUIDE v2.5 15-Aug-2012 10:33:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dutchess_OpeningFcn, ...
                   'gui_OutputFcn',  @dutchess_OutputFcn, ...
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


% --- Executes just before dutchess is made visible.
function dutchess_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dutchess (see VARARGIN)

% Choose default command line output for dutchess

global userParam;
setUserParamCCC10xBS_cellCounting;

handles.output = hObject;

handles.pathname = 'C:\Users\Marcel\Desktop\';


handles.minAreaTrshld = 40; 
handles.nucIntensityRange = 12;   % value depends on radiusMin/Max 
handles.nucIntensityLoc = 15;  

set(handles. minAreaTrshld_edit,'String',num2str(handles.minAreaTrshld))
set(handles. nucIntensityRange_edit,'String',num2str(handles.nucIntensityRange))
set(handles. nucIntensityLoc_edit,'String',num2str(handles.nucIntensityLoc))
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dutchess wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dutchess_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadPict_pushbutton.
function LoadPict_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPict_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif;*.tiff','image files (.jpg, .png, .tif)'},'pick a file',handles.pathname);
handles.pathname =  pathname;
handles.filename = filename;
%read the image files


nuc=imread([pathname filename]);

% % if rgb   image, convert it to gray 
s = size(nuc);
try s3 = s(3)
  nuc = rgb2gray(nuc);
end

handles.nuc = nuc
imshow(nuc,[])


% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Count_cells_pushbutton.
function Count_cells_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Count_cells_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nuc = handles.nuc;
fimg=[];

global userParam;
% paramfile = 'setUserParamCCC10xBS_cellCounting([1344 1024])';
% try
%     eval(paramfile);
% catch
%     error('Could not evaluate paramfile command');
% end

userParam.nucIntensityRange = handles.nucIntensityRange;   % value depends on radiusMin/Max 
userParam.nucIntensityLoc   = handles.nucIntensityLoc;  
userParam.nucAreaLo =handles.minAreaTrshld; 

%get time from file date stamp in hours, also save picture number
%run EDS routines to segment cells, do stats, and get the output matrix
    [maskC statsN]=segmentCells(nuc,fimg);
    cellnb = length(statsN);
%     nucPos = reshape([statsN(:).Centroid],cellnb,2);
    nucPos = zeros(length(statsN),2);
    for ii = 1:length(statsN)
        nucPos(ii,:) = statsN(ii).Centroid;
    end
    
    
    red = imadjust(nuc,stretchlim(nuc,[0.1 0.999]));
    imshow(red,[])
    hold on
    plot(nucPos(:,1),nucPos(:,2),'ro','MarkerSize',5)
    text(500,500,['counted ' num2str(cellnb) ' cells ==> ' num2str((cellnb*1153)/1e6) ' million cells/ml'],'color','w')
    
    hold off
datestr(now)


function minAreaTrshld_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minAreaTrshld_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minAreaTrshld_edit as text
%        str2double(get(hObject,'String')) returns contents of minAreaTrshld_edit as a double
% Hints: get(hObject,'String') returns contents of nucIntensityLoc_edit as text
handles.minAreaTrshld = str2double(get(hObject,'String')); %returns contents of nucIntensityLoc_edit as a double
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minAreaTrshld_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minAreaTrshld_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nucIntensityRange_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nucIntensityRange_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucIntensityRange_edit as text
%        str2double(get(hObject,'String')) returns contents of nucIntensityRange_edit as a double
% Hints: get(hObject,'String') returns contents of nucIntensityLoc_edit as text
handles.nucIntensityRange = str2double(get(hObject,'String')); %returns contents of nucIntensityLoc_edit as a double
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nucIntensityRange_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucIntensityRange_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nucIntensityLoc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nucIntensityLoc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucIntensityLoc_edit as text
handles.nucIntensityLoc = str2double(get(hObject,'String')); %returns contents of nucIntensityLoc_edit as a double
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nucIntensityLoc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucIntensityLoc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
