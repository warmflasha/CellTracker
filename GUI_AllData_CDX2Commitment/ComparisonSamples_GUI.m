function varargout = ComparisonSamples_GUI(varargin)
% COMPARISONSAMPLES_GUI MATLAB code for ComparisonSamples_GUI.fig
%      COMPARISONSAMPLES_GUI, by itself, creates a new COMPARISONSAMPLES_GUI or raises the existing
%      singleton*.
%
%      H = COMPARISONSAMPLES_GUI returns the handle to a new COMPARISONSAMPLES_GUI or the handle to
%      the existing singleton*.
%
%      COMPARISONSAMPLES_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPARISONSAMPLES_GUI.M with the given input arguments.
%
%      COMPARISONSAMPLES_GUI('Property','Value',...) creates a new COMPARISONSAMPLES_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ComparisonSamples_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ComparisonSamples_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ComparisonSamples_GUI

% Last Modified by GUIDE v2.5 07-Jun-2018 12:52:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ComparisonSamples_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ComparisonSamples_GUI_OutputFcn, ...
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


% --- Executes just before ComparisonSamples_GUI is made visible.
function ComparisonSamples_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ComparisonSamples_GUI (see VARARGIN)

% Choose default command line output for ComparisonSamples_GUI
handles.output = hObject;

% Choose data set 1
data = struct('valDataSet1',1);
set(handles.popupmenu1_Sample1,'UserData',data);

% Choose data set 2
data = struct('valDataSet2',1);
set(handles.popupmenu2_Sample2,'UserData',data);


% Choose Experimental Condition 1
data = struct('valCond1',1);
set(handles.listbox1_Sample1,'UserData',data); %Save the user data
set(handles.listbox1_Sample1,'Value',1); %Show that the user data is that value
 set(handles.listbox1_Sample1,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});

 % Choose Experimental Condition 1
data = struct('valCond2',2);
set(handles.listbox2_Sample2,'UserData',data); %Save the user data
set(handles.listbox2_Sample2,'Value',2); %Show that the user data is that value
 set(handles.listbox2_Sample2,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});

ComparisonData3D(1,1,1,2,[])

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ComparisonSamples_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ComparisonSamples_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1_Sample1.
function popupmenu1_Sample1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1_Sample1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval = get(hObject,'Value');    
data = get(hObject,'UserData');
data.valDataSet1 = sval;



if sval == 1
    set(handles.listbox1_Sample1,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox1_Sample1,'Value',1);
    datacondition = struct('valCond1',1);
    set(handles.listbox1_Sample1,'UserData',datacondition);
    
    
elseif sval == 2
    set(handles.listbox1_Sample1,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox1_Sample1,'Value',1);
    datacondition = struct('valCond1',1);
    set(handles.listbox1_Sample1,'UserData',datacondition);

    
elseif sval == 3
    set(handles.listbox1_Sample1,'String',{'Control';'BMP 1ng/ml 0-28h + SB';'BMP 1ng/ml 0-38h + SB';'BMP 1ng/ml 0-48h + SB';'BMP 10ng/ml 0-48h + SB';'BMP 10ng/ml 0-38h + SB';'BMP 10ng/ml 0-28h + SB';'SB'});
    set(handles.listbox1_Sample1,'Value',1);
    datacondition = struct('valCond1',1);
    set(handles.listbox1_Sample1,'UserData',datacondition);
    
    
elseif sval == 4
    set(handles.listbox1_Sample1,'String',{'Control';'BMP 10ng/ml 0-24h';'BMP 10ng/ml 0-8h';'BMP 10ng/ml 0-24h';'BMP 10ng/ml 0-24h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-32h';'BMP 10ng/ml 0-40h'});
    set(handles.listbox1_Sample1,'Value',1);
    datacondition = struct('valCond1',1);
    set(handles.listbox1_Sample1,'UserData',datacondition);
    
    
elseif sval == 5
    set(handles.listbox1_Sample1,'String',{'Control';'BMP 10ng/ml 0-4h';'BMP 10ng/ml 0-8h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-24h';'BMP 10ng/ml 0-32h';'BMP 10ng/ml 0-40h';'BMP 10ng/ml 0-48h'});
    set(handles.listbox1_Sample1,'Value',1);
    datacondition = struct('valCond1',1);
    set(handles.listbox1_Sample1,'UserData',datacondition);
    
    
end

% Store data in UserData of slider
set(hObject,'UserData',data);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1_Sample1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1_Sample1


% --- Executes during object creation, after setting all properties.
function popupmenu1_Sample1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1_Sample1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2_Sample2.
function popupmenu2_Sample2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2_Sample2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval = get(hObject,'Value');    
data = get(hObject,'UserData');
data.valDataSet2 = sval;



if sval == 1
    set(handles.listbox2_Sample2,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox2_Sample2,'Value',1);
    datacondition = struct('valCond2',1);
    set(handles.listbox2_Sample2,'UserData',datacondition);
    
    
elseif sval == 2
    set(handles.listbox2_Sample2,'String',{'BMP 1ng/ml 0-8h';'BMP 1ng/ml 0-16h';'BMP 1ng/ml 0-28h';'BMP 1ng/ml 0-48h';'BMP 10ng/ml 0-48h';'BMP 10ng/ml 0-28h';'BMP 10ng/ml 0-16h';'BMP 10ng/ml 0-8h'});
    set(handles.listbox2_Sample2,'Value',1);
    datacondition = struct('valCond2',1);
    set(handles.listbox2_Sample2,'UserData',datacondition);

    
elseif sval == 3
    set(handles.listbox2_Sample2,'String',{'Control';'BMP 1ng/ml 0-28h + SB';'BMP 1ng/ml 0-38h + SB';'BMP 1ng/ml 0-48h + SB';'BMP 10ng/ml 0-48h + SB';'BMP 10ng/ml 0-38h + SB';'BMP 10ng/ml 0-28h + SB';'SB'});
    set(handles.listbox2_Sample2,'Value',1);
    datacondition = struct('valCond2',1);
    set(handles.listbox2_Sample2,'UserData',datacondition);
    
    
elseif sval == 4
    set(handles.listbox2_Sample2,'String',{'Control';'BMP 0-24h';'BMP 0-8h';'BMP 0-24h';'BMP 0-24h';'BMP 0-28h';'BMP 0-32h';'BMP 0-40h'});
    set(handles.listbox2_Sample2,'Value',1);
    datacondition = struct('valCond2',1);
    set(handles.listbox2_Sample2,'UserData',datacondition);
    
    
elseif sval == 5
    set(handles.listbox2_Sample2,'String',{'Control';'BMP 0-4h';'BMP 0-8h';'BMP 0-16h';'BMP 0-24h';'BMP 0-32h';'BMP 0-40h';'BMP 0-48h'});
    set(handles.listbox2_Sample2,'Value',1);
    datacondition = struct('valCond2',1);
    set(handles.listbox2_Sample2,'UserData',datacondition);
    
    
end

% Store data in UserData of slider
set(hObject,'UserData',data);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2_Sample2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2_Sample2


% --- Executes during object creation, after setting all properties.
function popupmenu2_Sample2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2_Sample2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1_Sample1.
function listbox1_Sample1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1_Sample1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval = get(hObject,'Value');    
data = get(hObject,'UserData');
data.valCond1 = sval;
% Store data in UserData of slider
set(hObject,'UserData',data);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1_Sample1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1_Sample1


% --- Executes during object creation, after setting all properties.
function listbox1_Sample1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1_Sample1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2_Sample2.
function listbox2_Sample2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2_Sample2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sval = get(hObject,'Value');    
data = get(hObject,'UserData');
data.valCond2 = sval;

% Store data in UserData of slider
set(hObject,'UserData',data);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox2_Sample2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2_Sample2


% --- Executes during object creation, after setting all properties.
function listbox2_Sample2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2_Sample2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_CreatePlot.
function pushbutton_CreatePlot_Callback(hObject, eventdata, handles)

data = get(handles.popupmenu1_Sample1,'UserData');
currentvalSample1 = data.valDataSet1;

data = get(handles.popupmenu2_Sample2,'UserData');
currentvalSample2 = data.valDataSet2;

data = get(handles.listbox1_Sample1,'UserData');
currentvalCond1 = data.valCond1;

data = get(handles.listbox2_Sample2,'UserData');
currentvalCond2 = data.valCond2;

[az,el] = view;
    
ComparisonData3D(currentvalSample1,currentvalCond1,currentvalSample2,currentvalCond2,[az,el])
% hObject    handle to pushbutton_CreatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
