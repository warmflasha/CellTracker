function varargout = CellViewer(varargin)
% CELLVIEWER MATLAB code for CellViewer.fig
%      CELLVIEWER, by itself, creates a new CELLVIEWER or raises the existing
%      singleton*.
%
%      H = CELLVIEWER returns the handle to a new CELLVIEWER or the handle to
%      the existing singleton*.
%
%      CELLVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLVIEWER.M with the given input arguments.
%
%      CELLVIEWER('Property','Value',...) creates a new CELLVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellViewer

% Last Modified by GUIDE v2.5 24-Jun-2016 16:18:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CellViewer_OpeningFcn, ...
    'gui_OutputFcn',  @CellViewer_OutputFcn, ...
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


% --- Executes just before CellViewer is made visible.
function CellViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellViewer (see VARARGIN)

% Choose default command line output for CellViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CellViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CellViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function timeslider_Callback(hObject, eventdata, handles)
% hObject    handle to timeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.currtime = 100*get(hObject,'Value');
guidata(hObject,handles);
updateImageView(handles);
updateDataView(handles);

% --- Executes during object creation, after setting all properties.
function timeslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cellslider_Callback(hObject, eventdata, handles)
% hObject    handle to cellslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.currcell = ceil(hObject.Value);
guidata(hObject,handles);
updateDataView(handles);
updateImageView(handles);

% --- Executes during object creation, after setting all properties.
function cellslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in databutton.
function databutton_Callback(hObject, eventdata, handles)
% hObject    handle to databutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s.directory = { {'uigetdir(''.'')'} };
s.position = 0;
s = StructDlg(s);
handles.pos = s.position;
handles.currtime = 0;

handles.directory = s.directory;
updateImageView(handles);
guidata(hObject, handles);



% --- Executes on button press in matfilebutton.
function matfilebutton_Callback(hObject, eventdata, handles)
% hObject    handle to matfilebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s.matfile = { {'uigetfile(''.'')'} };
s=StructDlg(s);
handles.matfile = s.matfile;
load(handles.matfile);
if exist('peaks','var')
    handles.peaks = peaks;
end
if exist('cells','var')
    handles.cells = cells;
    set(handles.cellslider,'Value',1);
    set(handles.cellslider,'Min',1);
    set(handles.cellslider,'Max',length(cells));
    set(handles.cellslider,'sliderStep',[1/(length(cells)-1), 10/(length(cells)-1)]);
    
end
set(handles.mattext,'String','.mat file loaded');
handles.currcell = 1;
guidata(hObject,handles);
updateDataView(handles);

% --- Executes on button press in redbox.
function redbox_Callback(hObject, eventdata, handles)
% hObject    handle to redbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redbox
guidata(hObject,handles);
updateImageView(handles);

% --- Executes on button press in greenbox.
function greenbox_Callback(hObject, eventdata, handles)
% hObject    handle to greenbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of greenbox
guidata(hObject,handles);
updateImageView(handles);



function updateDataView(handles)

axes(handles.axes2);
tt = floor(handles.currtime)+1;
if isfield(handles,'cells')
    cellnum = handles.currcell;
    cc = handles.cells(cellnum);
    plot(cc.onframes,cc.fluorData(:,2)./cc.fluorData(:,3),'r.-'); hold on;
    ind = find(cc.onframes == tt);
    if ~isempty(ind)
    plot(tt,cc.fluorData(ind,2)./cc.fluorData(ind,3),'ks','MarkerSize',20); hold off;
    end
end

function updateImageView(handles)
ff = readAndorDirectory(handles.directory);
if size(ff.w,2) >2
    img0 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,0);
    img1 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,1);
    axes(handles.axes1)
    zz = zeros(size(img0));
    img2show = {zz,zz,zz};
    if get(handles.redbox,'Value')
        img2show{1} = imadjust(img0);
    end
    if get(handles.greenbox,'Value')
        img2show{2} = imadjust(img1);
    end
    showImg(img2show); hold on;
    if get(handles.celllabelbox,'Value') && isfield(handles,'cells')
        cc = handles.cells;
        for ii = 1:length(cc)
            ind = find(cc(ii).onframes==handles.currtime+1);
            if ~isempty(ind)
                plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'c.','MarkerSize',16);
                text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','c','FontSize',14);
                
                if ii == handles.currcell
                    plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'gs','MarkerSize',16);
                    text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','g','FontSize',14);
                    
                end
            end
        end
    end
end
if size(ff.w,2) == 1
    dirchanel = ff.w;
    if dirchanel == 0 % (if nuc channel directory is selected)
        img0 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,dirchanel);
        % img1 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,1);
        axes(handles.axes1)
        zz = zeros(size(img0));
        img2show = {zz,zz,zz};
        if get(handles.redbox,'Value')
            img2show{1} = imadjust(img0);
        end
        % if get(handles.greenbox,'Value')
        %     img2show{2} = imadjust(img1);
        % end
        showImg(img2show); hold on;
        if get(handles.celllabelbox,'Value') && isfield(handles,'cells')
            cc = handles.cells;
            for ii = 1:length(cc)
                ind = find(cc(ii).onframes==handles.currtime+1);
                if ~isempty(ind)
                    plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'c.','MarkerSize',16);
                    text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','c','FontSize',14);
                    
                    if ii == handles.currcell
                        plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'gs','MarkerSize',16);
                        text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','g','FontSize',14);
                        
                    end
                end
            end
        end
    end
    if dirchanel == 1 % (if cyto channel directory is selected)
        %img0 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,0);
        img1 = andorMaxIntensityBF(ff,handles.pos,handles.currtime,dirchanel);
        axes(handles.axes1)
        zz = zeros(size(img1));
        img2show = {zz,zz,zz};
        % if get(handles.redbox,'Value')
        %     img2show{1} = imadjust(img0);
        % end
        if get(handles.greenbox,'Value')
            img2show{2} = imadjust(img1);
        end
        showImg(img2show); hold on;
        if get(handles.celllabelbox,'Value') && isfield(handles,'cells')
            cc = handles.cells;
            for ii = 1:length(cc)
                ind = find(cc(ii).onframes==handles.currtime+1);
                if ~isempty(ind)
                    plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'r.','MarkerSize',16);
                    text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','c','FontSize',14);
                    
                    if ii == handles.currcell
                        plot(cc(ii).position(ind,1),cc(ii).position(ind,2),'gs','MarkerSize',16);
                        text(cc(ii).position(ind,1),cc(ii).position(ind,2)-5,int2str(ii),'Color','g','FontSize',14);
                        
                    end
                end
            end
        end
    end
end


% --- Executes on button press in celllabelbox.
function celllabelbox_Callback(hObject, eventdata, handles)
% hObject    handle to celllabelbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of celllabelbox
guidata(hObject,handles);
updateImageView(handles);

