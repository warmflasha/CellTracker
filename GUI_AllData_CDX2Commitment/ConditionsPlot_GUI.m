function varargout = ConditionsPlot_GUI(varargin)
% CONDITIONSPLOT_GUI MATLAB code for ConditionsPlot_GUI.fig
%      CONDITIONSPLOT_GUI, by itself, creates a new CONDITIONSPLOT_GUI or raises the existing
%      singleton*.
%
%      H = CONDITIONSPLOT_GUI returns the handle to a new CONDITIONSPLOT_GUI or the handle to
%      the existing singleton*.
%
%      CONDITIONSPLOT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONDITIONSPLOT_GUI.M with the given input arguments.
%
%      CONDITIONSPLOT_GUI('Property','Value',...) creates a new CONDITIONSPLOT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConditionsPlot_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConditionsPlot_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConditionsPlot_GUI

% Last Modified by GUIDE v2.5 06-Jun-2018 15:11:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConditionsPlot_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ConditionsPlot_GUI_OutputFcn, ...
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


% --- Executes just before ConditionsPlot_GUI is made visible.
function ConditionsPlot_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConditionsPlot_GUI (see VARARGIN)

% Choose default command line output for ConditionsPlot_GUI
handles.output = hObject;

% Choose data set
data = struct('valDataSet',1);
set(handles.popupmenu1,'UserData',data);

% Choose Experimental Condition
data = struct('valCond',1);
set(handles.listbox_Conditions,'UserData',data); %Save the user data
set(handles.listbox_Conditions,'Value',1); %Show that the user data is that value
 set(handles.listbox_Conditions,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});

DataWellsPlot3D(1,1,[])

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConditionsPlot_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConditionsPlot_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_Conditions.
function listbox_Conditions_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval2 = get(hObject,'Value');     
data = get(hObject,'UserData');
data.valCond = sval2;

currentvaldataset = get(handles.popupmenu1,'Value');

[az,el] = view;
DataWellsPlot3D(currentvaldataset,sval2,[az,el])

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Conditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Conditions


% --- Executes during object creation, after setting all properties.
function listbox_Conditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1_CreatePlot.
function pushbutton1_CreatePlot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_CreatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval = get(hObject,'Value');    
data = get(hObject,'UserData');
data.valDataSet = sval;


if sval == 1
    set(handles.listbox_Conditions,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox_Conditions,'Value',1);
    datacondition = struct('valCond',1);
    set(handles.listbox_Conditions,'UserData',datacondition);
    
    [az,el] = view;
    DataWellsPlot3D(sval,1,[az,el])
    
elseif sval == 2
    set(handles.listbox_Conditions,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox_Conditions,'Value',1);
    datacondition = struct('valCond',1);
    set(handles.listbox_Conditions,'UserData',datacondition);
    
    [az,el] = view;
    DataWellsPlot3D(sval,1,[az,el])
    
elseif sval == 3
    set(handles.listbox_Conditions,'String',{'Control';'BMP 1ng/ml 0-28h + SB';'BMP 1ng/ml 0-38h + SB';'BMP 1ng/ml 0-48h + SB';'BMP 10ng/ml 0-48h + SB';'BMP 10ng/ml 0-38h + SB';'BMP 10ng/ml 0-28h + SB';'SB'});
    set(handles.listbox_Conditions,'Value',1);
    datacondition = struct('valCond',1);
    set(handles.listbox_Conditions,'UserData',datacondition);
    
    [az,el] = view;
    DataWellsPlot3D(sval,1,[az,el])
    
elseif sval == 4
    set(handles.listbox_Conditions,'String',{'Control';'BMP 0-24h';'BMP 0-8h';'BMP 0-24h';'BMP 0-24h';'BMP 0-28h';'BMP 0-32h';'BMP 0-40h'});
    set(handles.listbox_Conditions,'Value',1);
    datacondition = struct('valCond',1);
    set(handles.listbox_Conditions,'UserData',datacondition);
    
    [az,el] = view;
    DataWellsPlot3D(sval,1,[az,el])
    
elseif sval == 5
    set(handles.listbox_Conditions,'String',{'Control';'BMP 0-4h';'BMP 0-8h';'BMP 0-16h';'BMP 0-24h';'BMP 0-32h';'BMP 0-40h';'BMP 0-48h'});
    set(handles.listbox_Conditions,'Value',1);
    datacondition = struct('valCond',1);
    set(handles.listbox_Conditions,'UserData',datacondition);
    
    [az,el] = view;
    DataWellsPlot3D(sval,1,[az,el])
    
end
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
