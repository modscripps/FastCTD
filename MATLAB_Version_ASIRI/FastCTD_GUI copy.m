function varargout = FastCTD_GUI(varargin)
% FASTCTD_GUI MATLAB code for FastCTD_GUI_data.fig
%      FASTCTD_GUI, by itself, creates a new FASTCTD_GUI or raises the existing
%      singleton*.
%
%      H = FASTCTD_GUI returns the handle to a new FASTCTD_GUI or the handle to
%      the existing singleton*.
%
%      FASTCTD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FastCTD_GUI_data.M with the given input arguments.
%
%      FASTCTD_GUI('Property','Value',...) creates a new FASTCTD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FastCTD_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FastCTD_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FastCTD_GUI

% Last Modified by GUIDE v2.5 09-May-2013 01:27:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FastCTD_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FastCTD_GUI_OutputFcn, ...
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


% --- Executes just before FastCTD_GUI is made visible.
function FastCTD_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FastCTD_GUI (see VARARGIN)

% Choose default command line output for FastCTD_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FastCTD_GUI wait for user response (see UIRESUME)
% uiwait(handles.FastCTD_GUI);

initialize_FastCTD_GUI(handles);

global FastCTD_GUI_data;
FastCTD_GUI_data.matDir = '/Volumes/RR1513_ASIRI_1/FCTD/MAT/';
%FastCTD_GUI_data.matDir = '/Volumes/RR1513_ASIRI_1/FCTD/MAT';
% update_Plots(hObject, eventdata,handles);
delete(timerfindall('Tag','FastCTD_Timer'));
FastCTD_GUI_Timer = timer();
% FastCTD_GUI_Timer.StartFcn = {@update_Plots,handles};
FastCTD_GUI_Timer.TimerFcn = {@update_Plots,handles};
FastCTD_GUI_Timer.Period = 20;
FastCTD_GUI_Timer.BusyMode = 'drop';
FastCTD_GUI_Timer.ErrorFcn = 'disp([datestr(now,''[yyyy.mm.dd HH:MM:SS]'') ''Error Occurred in update_Plots function'']);';
FastCTD_GUI_Timer.StopFcn = '';
FastCTD_GUI_Timer.TasksToExecute = Inf;
FastCTD_GUI_Timer.Tag = 'FastCTD_Timer';
FastCTD_GUI_Timer.Name = 'FastCTD_Timer';

FastCTD_GUI_Timer.ExecutionMode = 'fixedDelay';
% FastCTD_GUI_Timer.ExecutionMode = 'singleShot';
if FastCTD_GUI_data.settings.isCurrentTime{3}
    start(FastCTD_GUI_Timer);
% update_Plots(hObject,eventdata,handles);
else
    FastCTD_GUI_Timer.ExecutionMode = 'singleShot';
    FastCTD_GUI_Timer.TasksToExecute = 1;
    start(FastCTD_GUI_Timer);
end

% --- Outputs from this function are returned to the command line.
function varargout = FastCTD_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function FastCTD_GUI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FastCTD_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function TimeSpan_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeSpan as text
%        str2double(get(hObject,'String')) returns contents of TimeSpan as a double

global FastCTD_GUI_data;
TimeSpan = str2double(get(hObject,'String'));
if isempty(TimeSpan) || isnan(TimeSpan) || TimeSpan < 0
    set(hObject,'String',FastCTD_GUI_data.settings.TimeSpan{1});
elseif FastCTD_GUI_data.settings.TimeSpan{3} ~= TimeSpan
    FastCTD_GUI_data.settings.TimeSpan{1} = get(hObject,'String');
    FastCTD_GUI_data.settings.TimeSpan{3} = TimeSpan;
    FastCTD_GUI_data.timeSpan = FastCTD_GUI_data.settings.TimeSpan{3}*FastCTD_GUI_data.settings.TimeUnit{3};
    setCorrectAxesProperties(handles);
end


% --- Executes during object creation, after setting all properties.
function TimeSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeUnit.
function TimeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeUnit
global FastCTD_GUI_data;
if FastCTD_GUI_data.settings.TimeUnit{1} ~= get(hObject,'Value')
    FastCTD_GUI_data.settings.TimeUnit{1} = get(hObject,'Value');
    FastCTD_GUI_data.settings.TimeUnit{3} = FastCTD_GUI_data.timeUnits(FastCTD_GUI_data.settings.TimeUnit{1});
    FastCTD_GUI_data.timeSpan = FastCTD_GUI_data.settings.TimeSpan{3}*FastCTD_GUI_data.settings.TimeUnit{3};
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function TimeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isCurrentTime.
function isCurrentTime_Callback(hObject, eventdata, handles)
% hObject    handle to isCurrentTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isCurrentTime
global FastCTD_GUI_data;
FastCTD_GUI_data.settings.isCurrentTime{1} = get(handles.isCurrentTime,'value');
FastCTD_GUI_data.settings.isCurrentTime{3} = FastCTD_GUI_data.settings.isCurrentTime{1};
if FastCTD_GUI_data.settings.isCurrentTime{3}
    set(handles.yyyy,'Enable','off');
    set(handles.mm,'Enable','off');
    set(handles.dd,'Enable','off');
    set(handles.HH,'Enable','off');
    set(handles.MM,'Enable','off');
    set(handles.TimeSet_OK,'Enable','off');
    set(handles.TimeSet_OK,'Visible','off');
    i = timerfindall('Tag','FastCTD_Timer');
    if strcmpi(get(i,'Running'),'on')
        stop(i);
    end
    i.ExecutionMode = 'fixedDelay';
%     i.ExecutionMode = 'singleShot';
    i.TasksToExecute = Inf;
    start(i);   
else
    set(handles.yyyy,'Enable','on');
    set(handles.mm,'Enable','on');
    set(handles.dd,'Enable','on');
    set(handles.HH,'Enable','on');
    set(handles.MM,'Enable','on');
    set(handles.TimeSet_OK,'Enable','on');
    set(handles.TimeSet_OK,'Visible','on');
    i = timerfindall('Tag','FastCTD_Timer');
    i.ExecutionMode = 'singleShot';
    i.TasksToExecute = 1;
    stop(i);
end
save('FastCTD_GUI.mat','FastCTD_GUI_data');



function yyyy_Callback(hObject, eventdata, handles)
% hObject    handle to yyyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yyyy as text
%        str2double(get(hObject,'String')) returns contents of yyyy as a double
str = get(hObject,'String');
if length(str)>4
    set(hObject,'String',str(1:4));
end

% --- Executes during object creation, after setting all properties.
function yyyy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yyyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mm_Callback(hObject, eventdata, handles)
% hObject    handle to mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mm as text
%        str2double(get(hObject,'String')) returns contents of mm as a double
str = get(hObject,'String');
if length(str)>2
    set(hObject,'String',str(1:2));
end

% --- Executes during object creation, after setting all properties.
function mm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dd_Callback(hObject, eventdata, handles)
% hObject    handle to dd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dd as text
%        str2double(get(hObject,'String')) returns contents of dd as a double
str = get(hObject,'String');
if length(str)>2
    set(hObject,'String',str(1:2));
end

% --- Executes during object creation, after setting all properties.
function dd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function HH_Callback(hObject, eventdata, handles)
% hObject    handle to HH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HH as text
%        str2double(get(hObject,'String')) returns contents of HH as a double
str = get(hObject,'String');
if length(str)>2
    set(hObject,'String',str(1:2));
end

% --- Executes during object creation, after setting all properties.
function HH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MM_Callback(hObject, eventdata, handles)
% hObject    handle to yyyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yyyy as text
%        str2double(get(hObject,'String')) returns contents of yyyy as a double
str = get(hObject,'String');
if length(str)>2
    set(hObject,'String',str(1:2));
end

% --- Executes during object creation, after setting all properties.
function MM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yyyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TimeSet_OK.
function TimeSet_OK_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSet_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global FastCTD_GUI_data;

yyyy = str2double(get(handles.yyyy,'String'));
mm = str2double(get(handles.mm,'String'));
dd = str2double(get(handles.dd,'String'));
HH = str2double(get(handles.HH,'String'));
MM = str2double(get(handles.MM,'String'));

daymax = [31, 28+(mod(yyyy,4)==0), 31, 30, 31, 30, 31, 31, 30, 31, 30. 31]; 

if (isempty(yyyy) || isnan(yyyy) || yyyy<2011) ||...
   (isempty(mm) || isnan(mm) || mm<1 || mm > 12) ||... 
   (isempty(dd) || isnan(dd) || dd<1 || dd > daymax(mm)) ||...
   (isempty(HH) || isnan(HH) || HH<1 || HH > 24) ||...
   (isempty(MM) || isnan(MM) || MM<1 || MM > 60)
    set(handles.yyyy,'String',FastCTD_GUI_data.settings.yyyy{1});
    set(handles.mm,'String',FastCTD_GUI_data.settings.mm{1});
    set(handles.dd,'String',FastCTD_GUI_data.settings.dd{1});
    set(handles.HH,'String',FastCTD_GUI_data.settings.HH{1});
    set(handles.MM,'String',FastCTD_GUI_data.settings.MM{1});
else
    FastCTD_GUI_data.settings.yyyy{1} = sprintf('%02d',yyyy);
    FastCTD_GUI_data.settings.mm{1} = sprintf('%02d',mm);
    FastCTD_GUI_data.settings.dd{1} = sprintf('%02d',dd);
    FastCTD_GUI_data.settings.HH{1} = sprintf('%02d',HH);
    FastCTD_GUI_data.settings.MM{1} = sprintf('%02d',MM);
    
    FastCTD_GUI_data.settings.yyyy{3} = FastCTD_GUI_data.settings.yyyy{1};
    FastCTD_GUI_data.settings.mm{3} = FastCTD_GUI_data.settings.mm{1};
    FastCTD_GUI_data.settings.dd{3} = FastCTD_GUI_data.settings.dd{1};
    FastCTD_GUI_data.settings.HH{3} = FastCTD_GUI_data.settings.HH{1};
    FastCTD_GUI_data.settings.MM{3} = FastCTD_GUI_data.settings.MM{1};

    FastCTD_GUI_data.currentTime = datenum([get(handles.yyyy,'String') '-' ...
                                                get(handles.mm,'String') '-' ...
                                                get(handles.dd,'String') ' ' ...
                                                get(handles.HH,'String') ':' ...
                                                get(handles.MM,'String') ':' ...
                                                '00'],'yyyy-mm-dd HH:MM:SS');
%     update_Plots(hObject, eventdata,handles);
    i = timerfindall('Tag','FastCTD_Timer');
    if strcmp(get(i,'Running'),'off')
        start(i);   
    end
end


function DepthMax_Callback(hObject, eventdata, handles)
% hObject    handle to DepthMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthMax as text
%        str2double(get(hObject,'String')) returns contents of DepthMax as a double

global FastCTD_GUI_data;
DepthMax = str2double(get(hObject,'String'));
if isempty(DepthMax) || isnan(DepthMax) || DepthMax <= FastCTD_GUI_data.settings.DepthMin{3}
    set(hObject,'String',FastCTD_GUI_data.settings.DepthMax{1});
else
    FastCTD_GUI_data.settings.DepthMax{3} = DepthMax;
    FastCTD_GUI_data.settings.DepthMax{1} = get(hObject,'String');
    setCorrectAxesProperties(handles)
end


% --- Executes during object creation, after setting all properties.
function DepthMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DepthMin_Callback(hObject, eventdata, handles)
% hObject    handle to DepthMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthMin as text
%        str2double(get(hObject,'String')) returns contents of DepthMin as a double
global FastCTD_GUI_data;
DepthMin = str2double(get(hObject,'String'));
if isempty(DepthMin) || isnan(DepthMin) || DepthMin >= FastCTD_GUI_data.settings.DepthMax{3}
    set(hObject,'String',FastCTD_GUI_data.settings.DepthMin{1});
else
    FastCTD_GUI_data.settings.DepthMin{3} = DepthMin;
    FastCTD_GUI_data.settings.DepthMin{1} = get(hObject,'String');
    setCorrectAxesProperties(handles)
end

% --- Executes during object creation, after setting all properties.
function DepthMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DensMax_Callback(hObject, eventdata, handles)
% hObject    handle to DensMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DensMax as text
%        str2double(get(hObject,'String')) returns contents of DensMax as a double
global FastCTD_GUI_data;
DensMax = str2double(get(hObject,'String'));
if isempty(DensMax) || isnan(DensMax) || DensMax < 0 ||DensMax <= FastCTD_GUI_data.settings.DensMin{3}
    set(hObject,'String',FastCTD_GUI_data.settings.DensMax{1});
else
    FastCTD_GUI_data.settings.DensMax{3} = DensMax;
    FastCTD_GUI_data.settings.DensMax{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function DensMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DensMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DensMin_Callback(hObject, eventdata, handles)
% hObject    handle to DensMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DensMin as text
%        str2double(get(hObject,'String')) returns contents of DensMin as a double
global FastCTD_GUI_data;
DensMin = str2double(get(hObject,'String'));
if isempty(DensMin) || isnan(DensMin) || DensMin < 0 ||DensMin >= FastCTD_GUI_data.settings.DensMax{3}
    set(hObject,'String',FastCTD_GUI_data.settings.DensMin{1});
else
    FastCTD_GUI_data.settings.DensMin{3} = DensMin;
    FastCTD_GUI_data.settings.DensMin{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function DensMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DensMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaltMax_Callback(hObject, eventdata, handles)
% hObject    handle to SaltMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaltMax as text
%        str2double(get(hObject,'String')) returns contents of SaltMax as a double
global FastCTD_GUI_data;
SaltMax = str2double(get(hObject,'String'));
if isempty(SaltMax) || isnan(SaltMax) || SaltMax < 0 ||SaltMax <= FastCTD_GUI_data.settings.SaltMin{3}
    set(hObject,'String',FastCTD_GUI_data.settings.SaltMax{1});
else
    FastCTD_GUI_data.settings.SaltMax{3} = SaltMax;
    FastCTD_GUI_data.settings.SaltMax{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function SaltMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaltMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaltMin_Callback(hObject, eventdata, handles)
% hObject    handle to SaltMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaltMin as text
%        str2double(get(hObject,'String')) returns contents of SaltMin as a double
global FastCTD_GUI_data;
SaltMin = str2double(get(hObject,'String'));
if isempty(SaltMin) || isnan(SaltMin) || SaltMin < 0 || SaltMin >= FastCTD_GUI_data.settings.SaltMax{3}
    set(hObject,'String',FastCTD_GUI_data.settings.SaltMin{1});
else
    FastCTD_GUI_data.settings.SaltMin{3} = SaltMin;
    FastCTD_GUI_data.settings.SaltMin{1} = get(hObject,'String');
    setCorrectAxesProperties(handles)
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function SaltMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaltMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TempMax_Callback(hObject, eventdata, handles)
% hObject    handle to TempMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TempMax as text
%        str2double(get(hObject,'String')) returns contents of TempMax as a double
global FastCTD_GUI_data;
TempMax = str2double(get(hObject,'String'));
if isempty(TempMax) || isnan(TempMax) || TempMax < 0 ||TempMax <= FastCTD_GUI_data.settings.TempMin{3}
    set(hObject,'String',FastCTD_GUI_data.settings.TempMax{1});
else
    FastCTD_GUI_data.settings.TempMax{3} = TempMax;
    FastCTD_GUI_data.settings.TempMax{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function TempMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TempMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TempMin_Callback(hObject, eventdata, handles)
% hObject    handle to TempMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TempMin as text
%        str2double(get(hObject,'String')) returns contents of TempMin as a double
global FastCTD_GUI_data;
TempMin = str2double(get(hObject,'String'));
if isempty(TempMin) || isnan(TempMin) || TempMin < 0 || TempMin >= FastCTD_GUI_data.settings.TempMax{3}
    set(hObject,'String',FastCTD_GUI_data.settings.TempMin{1});
else
    FastCTD_GUI_data.settings.TempMin{3} = TempMin;
    FastCTD_GUI_data.settings.TempMin{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function TempMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TempMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CondMax_Callback(hObject, eventdata, handles)
% hObject    handle to CondMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CondMax as text
%        str2double(get(hObject,'String')) returns contents of CondMax as a double
global FastCTD_GUI_data;
CondMax = str2double(get(hObject,'String'));
if isempty(CondMax) || isnan(CondMax) || CondMax <= FastCTD_GUI_data.settings.CondMin{3}
    set(hObject,'String',FastCTD_GUI_data.settings.CondMax{1});
else
    FastCTD_GUI_data.settings.CondMax{3} = CondMax;
    FastCTD_GUI_data.settings.CondMax{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function CondMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CondMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CondMin_Callback(hObject, eventdata, handles)
% hObject    handle to CondMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CondMin as text
%        str2double(get(hObject,'String')) returns contents of CondMin as a double
global FastCTD_GUI_data;
CondMin = str2double(get(hObject,'String'));
if isempty(CondMin) || isnan(CondMin) || CondMin >= FastCTD_GUI_data.settings.CondMax{3}
    set(hObject,'String',FastCTD_GUI_data.settings.CondMin{1});
else
    FastCTD_GUI_data.settings.CondMin{3} = CondMin;
    FastCTD_GUI_data.settings.CondMin{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
    update_ColorBars(handles);
end

% --- Executes during object creation, after setting all properties.
function CondMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CondMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TempScale_Callback(hObject, eventdata, handles)
% hObject    handle to TempScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TempScale as text
%        str2double(get(hObject,'String')) returns contents of TempScale as a double
global FastCTD_GUI_data;
TempScale = str2double(get(hObject,'String'));
if isempty(TempScale) || isnan(TempScale) || TempScale < 0
    set(hObject,'String',FastCTD_GUI_data.settings.TempScale{1});
else
    FastCTD_GUI_data.settings.TempScale{3} = TempScale;
    FastCTD_GUI_data.settings.TempScale{1} = get(hObject,'String');
    setCorrectAxesProperties(handles)    
end

% --- Executes during object creation, after setting all properties.
function TempScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TempScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DensScale_Callback(hObject, eventdata, handles)
% hObject    handle to DensScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DensScale as text
%        str2double(get(hObject,'String')) returns contents of DensScale as a double
global FastCTD_GUI_data;
DensScale = str2double(get(hObject,'String'));
if isempty(DensScale) || isnan(DensScale) || DensScale < 0
    set(hObject,'String',FastCTD_GUI_data.settings.DensScale{1});
else
    FastCTD_GUI_data.settings.DensScale{3} = DensScale;
    FastCTD_GUI_data.settings.DensScale{1} = get(hObject,'String');
    setCorrectAxesProperties(handles)
end

% --- Executes during object creation, after setting all properties.
function DensScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DensScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeSpan2_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSpan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeSpan2 as text
%        str2double(get(hObject,'String')) returns contents of TimeSpan2 as a double
global FastCTD_GUI_data;
TimeSpan2 = str2double(get(hObject,'String'));
if isempty(TimeSpan2) || isnan(TimeSpan2) || TimeSpan2 < 0
    set(hObject,'String',FastCTD_GUI_data.settings.TimeSpan2{1});
elseif FastCTD_GUI_data.settings.TimeSpan2{3} ~= TimeSpan2
    FastCTD_GUI_data.settings.TimeSpan2{1} = get(hObject,'String');
    FastCTD_GUI_data.settings.TimeSpan2{3} = TimeSpan2;
    FastCTD_GUI_data.timeSpan2 = FastCTD_GUI_data.settings.TimeSpan2{3}*FastCTD_GUI_data.settings.TimeUnit2{3};
    setCorrectAxesProperties(handles)
end

% --- Executes during object creation, after setting all properties.
function TimeSpan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSpan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeUnit2.
function TimeUnit2_Callback(hObject, eventdata, handles)
% hObject    handle to TimeUnit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeUnit2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeUnit2
global FastCTD_GUI_data;
if FastCTD_GUI_data.settings.TimeUnit2{1} ~= get(hObject,'Value')
    FastCTD_GUI_data.settings.TimeUnit2{1} = get(hObject,'Value');
    FastCTD_GUI_data.settings.TimeUnit2{3} = FastCTD_GUI_data.timeUnits(FastCTD_GUI_data.settings.TimeUnit2{1});
    FastCTD_GUI_data.timeSpan2 = FastCTD_GUI_data.settings.TimeSpan2{3}*FastCTD_GUI_data.settings.TimeUnit2{3};
    setCorrectAxesProperties(handles)
end

% --- Executes during object creation, after setting all properties.
function TimeUnit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeUnit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering1Max_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering1Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering1Max as text
%        str2double(get(hObject,'String')) returns contents of Engineering1Max as a double
global FastCTD_GUI_data;
Engineering1Max = str2double(get(hObject,'String'));
if isempty(Engineering1Max) || isnan(Engineering1Max) ||Engineering1Max <= FastCTD_GUI_data.settings.Engineering1Min{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering1Max{1});
else
    FastCTD_GUI_data.settings.Engineering1Max{3} = Engineering1Max;
    FastCTD_GUI_data.settings.Engineering1Max{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering1Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering1Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering1Min_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering1Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering1Min as text
%        str2double(get(hObject,'String')) returns contents of Engineering1Min as a double
global FastCTD_GUI_data;
Engineering1Min = str2double(get(hObject,'String'));
if isempty(Engineering1Min) || isnan(Engineering1Min) || Engineering1Min >= FastCTD_GUI_data.settings.Engineering1Max{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering1Min{1});
else
    FastCTD_GUI_data.settings.Engineering1Min{3} = Engineering1Min;
    FastCTD_GUI_data.settings.Engineering1Min{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering1Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering1Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Engineering1Data.
function Engineering1Data_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering1Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Engineering1Data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Engineering1Data

global FastCTD_GUI_data;

i = get(hObject,'Value');
j = FastCTD_GUI_data.settings.Engineering1Data{1};

FastCTD_GUI_data.availableData(j).dataMin = FastCTD_GUI_data.settings.Engineering1Min{3};
FastCTD_GUI_data.availableData(j).dataMax = FastCTD_GUI_data.settings.Engineering1Max{3};

FastCTD_GUI_data.availableData(j).dispMin = FastCTD_GUI_data.settings.Engineering1Min{1};
FastCTD_GUI_data.availableData(j).dispMax = FastCTD_GUI_data.settings.Engineering1Max{1};

FastCTD_GUI_data.settings.Engineering1Data{1} = i;
FastCTD_GUI_data.settings.Engineering1Data{3} = FastCTD_GUI_data.availableData(i).type;

FastCTD_GUI_data.settings.Engineering1Min{3} = FastCTD_GUI_data.availableData(i).dataMin;
FastCTD_GUI_data.settings.Engineering1Max{3} = FastCTD_GUI_data.availableData(i).dataMax;

FastCTD_GUI_data.settings.Engineering1Min{1} = FastCTD_GUI_data.availableData(i).dispMin;
FastCTD_GUI_data.settings.Engineering1Max{1} = FastCTD_GUI_data.availableData(i).dispMax;

update_ControlPanelParams(handles);
setCorrectAxesProperties(handles);

% --- Executes during object creation, after setting all properties.
function Engineering1Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering1Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering4Max_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering4Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering4Max as text
%        str2double(get(hObject,'String')) returns contents of Engineering4Max as a double
global FastCTD_GUI_data;
Engineering4Max = str2double(get(hObject,'String'));
if isempty(Engineering4Max) || isnan(Engineering4Max) ||Engineering4Max <= FastCTD_GUI_data.settings.Engineering4Min{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering4Max{1});
else
    FastCTD_GUI_data.settings.Engineering4Max{3} = Engineering4Max;
    FastCTD_GUI_data.settings.Engineering4Max{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering4Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering4Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering4Min_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering4Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering4Min as text
%        str2double(get(hObject,'String')) returns contents of Engineering4Min as a double
global FastCTD_GUI_data;
Engineering4Min = str2double(get(hObject,'String'));
if isempty(Engineering4Min) || isnan(Engineering4Min) || Engineering4Min >= FastCTD_GUI_data.settings.Engineering4Max{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering4Min{1});
else
    FastCTD_GUI_data.settings.Engineering4Min{3} = Engineering4Min;
    FastCTD_GUI_data.settings.Engineering4Min{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering4Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering4Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Engineering4Data.
function Engineering4Data_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering4Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Engineering4Data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Engineering4Data

global FastCTD_GUI_data;

i = get(hObject,'Value');
j = FastCTD_GUI_data.settings.Engineering4Data{1};

FastCTD_GUI_data.availableData(j).dataMin = FastCTD_GUI_data.settings.Engineering4Min{3};
FastCTD_GUI_data.availableData(j).dataMax = FastCTD_GUI_data.settings.Engineering4Max{3};

FastCTD_GUI_data.availableData(j).dispMin = FastCTD_GUI_data.settings.Engineering4Min{1};
FastCTD_GUI_data.availableData(j).dispMax = FastCTD_GUI_data.settings.Engineering4Max{1};

FastCTD_GUI_data.settings.Engineering4Data{1} = i;
FastCTD_GUI_data.settings.Engineering4Data{3} = FastCTD_GUI_data.availableData(i).type;

FastCTD_GUI_data.settings.Engineering4Min{3} = FastCTD_GUI_data.availableData(i).dataMin;
FastCTD_GUI_data.settings.Engineering4Max{3} = FastCTD_GUI_data.availableData(i).dataMax;

FastCTD_GUI_data.settings.Engineering4Min{1} = FastCTD_GUI_data.availableData(i).dispMin;
FastCTD_GUI_data.settings.Engineering4Max{1} = FastCTD_GUI_data.availableData(i).dispMax;

update_ControlPanelParams(handles);
setCorrectAxesProperties(handles);(handles);

% --- Executes during object creation, after setting all properties.
function Engineering4Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering4Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering3Max_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering3Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering3Max as text
%        str2double(get(hObject,'String')) returns contents of Engineering3Max as a double
global FastCTD_GUI_data;
Engineering3Max = str2double(get(hObject,'String'));
if isempty(Engineering3Max) || isnan(Engineering3Max) || Engineering3Max <= FastCTD_GUI_data.settings.Engineering3Min{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering3Max{1});
else
    FastCTD_GUI_data.settings.Engineering3Max{3} = Engineering3Max;
    FastCTD_GUI_data.settings.Engineering3Max{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering3Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering3Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering3Min_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering3Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering3Min as text
%        str2double(get(hObject,'String')) returns contents of Engineering3Min as a double
global FastCTD_GUI_data;
Engineering3Min = str2double(get(hObject,'String'));
if isempty(Engineering3Min) || isnan(Engineering3Min) || Engineering3Min >= FastCTD_GUI_data.settings.Engineering3Max{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering3Min{1});
else
    FastCTD_GUI_data.settings.Engineering3Min{3} = Engineering3Min;
    FastCTD_GUI_data.settings.Engineering3Min{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering3Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering3Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Engineering3Data.
function Engineering3Data_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering3Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Engineering3Data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Engineering3Data

global FastCTD_GUI_data;

i = get(hObject,'Value');
j = FastCTD_GUI_data.settings.Engineering3Data{1};

FastCTD_GUI_data.availableData(j).dataMin = FastCTD_GUI_data.settings.Engineering3Min{3};
FastCTD_GUI_data.availableData(j).dataMax = FastCTD_GUI_data.settings.Engineering3Max{3};

FastCTD_GUI_data.availableData(j).dispMin = FastCTD_GUI_data.settings.Engineering3Min{1};
FastCTD_GUI_data.availableData(j).dispMax = FastCTD_GUI_data.settings.Engineering3Max{1};

FastCTD_GUI_data.settings.Engineering3Data{1} = i;
FastCTD_GUI_data.settings.Engineering3Data{3} = FastCTD_GUI_data.availableData(i).type;

FastCTD_GUI_data.settings.Engineering3Min{3} = FastCTD_GUI_data.availableData(i).dataMin;
FastCTD_GUI_data.settings.Engineering3Max{3} = FastCTD_GUI_data.availableData(i).dataMax;

FastCTD_GUI_data.settings.Engineering3Min{1} = FastCTD_GUI_data.availableData(i).dispMin;
FastCTD_GUI_data.settings.Engineering3Max{1} = FastCTD_GUI_data.availableData(i).dispMax;

update_ControlPanelParams(handles);
setCorrectAxesProperties(handles);

% --- Executes during object creation, after setting all properties.
function Engineering3Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering3Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering2Max_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering2Max as text
%        str2double(get(hObject,'String')) returns contents of Engineering2Max as a double
global FastCTD_GUI_data;
Engineering2Max = str2double(get(hObject,'String'));
if isempty(Engineering2Max) || isnan(Engineering2Max) || Engineering2Max <= FastCTD_GUI_data.settings.Engineering2Min{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering2Max{1});
else
    FastCTD_GUI_data.settings.Engineering2Max{3} = Engineering2Max;
    FastCTD_GUI_data.settings.Engineering2Max{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering2Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Engineering2Min_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Engineering2Min as text
%        str2double(get(hObject,'String')) returns contents of Engineering2Min as a double
global FastCTD_GUI_data;
Engineering2Min = str2double(get(hObject,'String'));
if isempty(Engineering2Min) || isnan(Engineering2Min) || Engineering2Min >= FastCTD_GUI_data.settings.Engineering2Max{3}
    set(hObject,'String',FastCTD_GUI_data.settings.Engineering2Min{1});
else
    FastCTD_GUI_data.settings.Engineering2Min{3} = Engineering2Min;
    FastCTD_GUI_data.settings.Engineering2Min{1} = get(hObject,'String');
    setCorrectAxesProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function Engineering2Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Engineering2Data.
function Engineering2Data_Callback(hObject, eventdata, handles)
% hObject    handle to Engineering2Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Engineering2Data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Engineering2Data

global FastCTD_GUI_data;

i = get(hObject,'Value');
j = FastCTD_GUI_data.settings.Engineering2Data{1};

FastCTD_GUI_data.availableData(j).dataMin = FastCTD_GUI_data.settings.Engineering2Min{3};
FastCTD_GUI_data.availableData(j).dataMax = FastCTD_GUI_data.settings.Engineering2Max{3};

FastCTD_GUI_data.availableData(j).dispMin = FastCTD_GUI_data.settings.Engineering2Min{1};
FastCTD_GUI_data.availableData(j).dispMax = FastCTD_GUI_data.settings.Engineering2Max{1};

FastCTD_GUI_data.settings.Engineering2Data{1} = i;
FastCTD_GUI_data.settings.Engineering2Data{3} = FastCTD_GUI_data.availableData(i).type;

FastCTD_GUI_data.settings.Engineering2Min{3} = FastCTD_GUI_data.availableData(i).dataMin;
FastCTD_GUI_data.settings.Engineering2Max{3} = FastCTD_GUI_data.availableData(i).dataMax;

FastCTD_GUI_data.settings.Engineering2Min{1} = FastCTD_GUI_data.availableData(i).dispMin;
FastCTD_GUI_data.settings.Engineering2Max{1} = FastCTD_GUI_data.availableData(i).dispMax;

update_ControlPanelParams(handles);
setCorrectAxesProperties(handles);

% --- Executes during object creation, after setting all properties.
function Engineering2Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Engineering2Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Colormap.
function Colormap_Callback(hObject, eventdata, handles)
% hObject    handle to Colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Colormap
ColorMapChoices = get(hObject,'String');
global FastCTD_GUI_data;
FastCTD_GUI_data.settings.Colormap{1} = get(hObject,'Value');
FastCTD_GUI_data.settings.Colormap{3} = ColorMapChoices{FastCTD_GUI_data.settings.Colormap{1}};
update_Colormap(handles);

% --- Executes during object creation, after setting all properties.
function Colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ColorCount.
function ColorCount_Callback(hObject, eventdata, handles)
% hObject    handle to ColorCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ColorCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorCount
ColorCount = str2double(get(hObject,'String'));

global FastCTD_GUI_data;

if isempty(ColorCount) || isnan(ColorCount) || ColorCount < 2 || ColorCount > 1024 % 1024 is a safety measure for performance
    set(hObject,'String',FastCTD_GUI_data.settings.ColorCount{1});
else
    FastCTD_GUI_data.settings.ColorCount{1} = get(hObject,'String');
    FastCTD_GUI_data.settings.ColorCount{3} = ColorCount;
    update_Colormap(handles);
end

% --- Executes during object creation, after setting all properties.
function ColorCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isReverseColor.
function isReverseColor_Callback(hObject, eventdata, handles)
% hObject    handle to isReverseColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isReverseColor
global FastCTD_GUI_data;
FastCTD_GUI_data.settings.isReverseColor{1} = get(hObject,'Value');
FastCTD_GUI_data.settings.isReverseColor{3} = FastCTD_GUI_data.settings.isReverseColor{1};
update_Colormap(handles);

% --- update Colorbars
function update_ColorBars(handles)
global FastCTD_GUI_data;
fields = {'Dens','Temp','Salt','Cond'};
varNames = {'Density','Temperature','Salinity','Conductivity'};
varUnits = {'kg/m$^3$', '$^\circ$C', 'psu','S/m'};
x = [0 1];
for i = 1:4
   c = linspace(FastCTD_GUI_data.settings.(sprintf('%sMin',fields{i})){3}, FastCTD_GUI_data.settings.(sprintf('%sMax',fields{i})){3},FastCTD_GUI_data.settings.ColorCount{3})';
   imagesc(x,c,c,'parent',handles.(sprintf('CB%1d',i)));
   set(handles.(sprintf('CB%1d',i)),'tickDir','in','xtick',[],'yaxislocation','right','FontName','Times','FontSize',12,'ydir','normal');
   ylabel(handles.(sprintf('CB%1d',i)),[ varNames{i} ' [' varUnits{i} ']'],...
       'Rotation',270,'FontSize',14,'Interpreter','latex','units','normalized','Position',[4.6 .5 1]);
   caxis([FastCTD_GUI_data.settings.(sprintf('%sMin',fields{i})){3}, FastCTD_GUI_data.settings.(sprintf('%sMax',fields{i})){3}]);
end
save('FastCTD_GUI.mat','FastCTD_GUI_data');

% --- update Colormap
function update_Colormap(handles)
global FastCTD_GUI_data;
if FastCTD_GUI_data.settings.isReverseColor{3}
    colormap(flipud(eval(sprintf('%s(FastCTD_GUI_data.settings.ColorCount{3})',FastCTD_GUI_data.settings.Colormap{3}))));
else
    colormap(eval(sprintf('%s(FastCTD_GUI_data.settings.ColorCount{3})',FastCTD_GUI_data.settings.Colormap{3})));
end
drawnow;
save('FastCTD_GUI.mat','FastCTD_GUI_data');

% --- update Control Panels Parameters
function update_ControlPanelParams(handles)

global FastCTD_GUI_data;
parameterNames = fieldnames(FastCTD_GUI_data.settings);
for i = 1:length(parameterNames)
%     disp([num2str(i) ' ' parameterNames{i}]);
    if FastCTD_GUI_data.settings.(parameterNames{i}){2} > 3
        set(handles.(parameterNames{i}),'Value',FastCTD_GUI_data.settings.(parameterNames{i}){1});
%         disp(FastCTD_GUI_data.settings.(parameterNames{i}){1});
    else
        set(handles.(parameterNames{i}),'String',FastCTD_GUI_data.settings.(parameterNames{i}){1});
%         disp(['String ' FastCTD_GUI_data.settings.(parameterNames{i}){1}]);
    end
end

FastCTD_GUI_data.settings.isCurrentTime{1} = get(handles.isCurrentTime,'value');
FastCTD_GUI_data.settings.isCurrentTime{3} = FastCTD_GUI_data.settings.isCurrentTime{1};
if FastCTD_GUI_data.settings.isCurrentTime{3}
    set(handles.yyyy,'Enable','off');
    set(handles.mm,'Enable','off');
    set(handles.dd,'Enable','off');
    set(handles.HH,'Enable','off');
    set(handles.MM,'Enable','off');
    set(handles.TimeSet_OK,'Enable','off');
    set(handles.TimeSet_OK,'Visible','off');
else
    set(handles.yyyy,'Enable','on');
    set(handles.mm,'Enable','on');
    set(handles.dd,'Enable','on');
    set(handles.HH,'Enable','on');
    set(handles.MM,'Enable','on');
    set(handles.TimeSet_OK,'Enable','on');
    set(handles.TimeSet_OK,'Visible','on');
end

save('FastCTD_GUI.mat','FastCTD_GUI_data');

function initialize_FastCTD_GUI(handles)

global FastCTD_GUI_data;


if ~exist('FastCTD_GUI.mat','file')

    setUpDefaultValues(handles);
    
    % first cell will be data used by the UI display
    % third cell will be data used by numerical MATLAB
    % second cell is the type of UI display (1 = textbox, 2 =
    % textbox that is 2 char short, 3 = textbox that is 4 char short, 4 = dropdown, 5 = checkbox)
    
elseif isempty(FastCTD_GUI_data)
    load('FastCTD_GUI.mat');
    if isempty(FastCTD_GUI_data)
        setUpDefaultValues(handles);
    end
end

FastCTD_GUI_data.settings.yyyy{1} = datestr(FastCTD_GUI_data.currentTime,'yyyy');
FastCTD_GUI_data.settings.mm{1} = datestr(FastCTD_GUI_data.currentTime,'mm');
FastCTD_GUI_data.settings.dd{1} = datestr(FastCTD_GUI_data.currentTime,'dd');
FastCTD_GUI_data.settings.HH{1} = datestr(FastCTD_GUI_data.currentTime,'HH');
FastCTD_GUI_data.settings.MM{1} = datestr(FastCTD_GUI_data.currentTime,'MM');
FastCTD_GUI_data.settings.yyyy{3} = FastCTD_GUI_data.settings.yyyy{1};
FastCTD_GUI_data.settings.mm{3} = FastCTD_GUI_data.settings.mm{1};
FastCTD_GUI_data.settings.dd{3} = FastCTD_GUI_data.settings.dd{1};
FastCTD_GUI_data.settings.HH{3} = FastCTD_GUI_data.settings.HH{1};
FastCTD_GUI_data.settings.MM{3} = FastCTD_GUI_data.settings.MM{1};

% set command to do before closing
set(handles.FastCTD_GUI,'DeleteFcn',...
    ['disp([datestr(now,''[yyyy.mm.dd HH:MM:SS]'') '' Done Fast CTD GUI'']); ' ...
    'i = timerfindall(''Tag'',''FastCTD_Timer''); if ~isempty(i), stop(timerfindall(''Tag'',''FastCTD_Timer'')); delete(timerfindall(''Tag'',''FastCTD_Timer'')); end;']);

dataDescriptions = cell(size(FastCTD_GUI_data.availableData));
for i = 1:length(FastCTD_GUI_data.availableData)
    dataDescriptions{i} = FastCTD_GUI_data.availableData(i).description;
end
for i = 1:4
    set(handles.(sprintf('Engineering%1dData',i)),'String',dataDescriptions);
end


% clear all axes
for i=1:4
    cla(handles.(sprintf('Frame%1d',i)),'reset');
    set(handles.(sprintf('Frame%1d',i)),'nextPlot','replace');
    
    cla(handles.(sprintf('Engineering%1d',i)),'reset');
    set(handles.(sprintf('Engineering%1d',i)),'nextPlot','replace');
end

%set axis ij for all Cascading plots
for i=1:2
    cla(handles.(sprintf('CascadePlot%1d',i)),'reset');
    set(handles.(sprintf('CascadePlot%1d',i)),'nextPlot','replace');
end

set(handles.FastCTD_GUI,'PaperType','usletter','PaperSize',[8.5 11],...
    'PaperPositionMode','auto');

update_ControlPanelParams(handles);

setCorrectAxesProperties(handles);

update_ColorBars(handles);
update_Colormap(handles);

function setUpDefaultValues(handles)
global FastCTD_GUI_data;
FastCTD_GUI_data = [];
FastCTD_GUI_data.settings = struct(...
                                    'TimeSpan',         {{'6',   1,      6}},...
                                    'TimeUnit',         {{1,     4,      1/24}},...
                                    'isCurrentTime',    {{1,     5,      true}},...
                                    'yyyy',             {{'2013',3,      '2013'}},...
                                    'mm',               {{'05',  2,      '05'}},...
                                    'dd',               {{'10',  2,      '10'}},...
                                    'HH',               {{'10',  2,      '10'}},...
                                    'MM',               {{'10',  2,      '10'}},...
                                    'Colormap',         {{1,     4,      'jetk'}},...
                                    'ColorCount',       {{'64',  1,      64}},...
                                    'isReverseColor',   {{0,     5,      false}},...
                                    'DepthMin',         {{'0',   1,      0}},...
                                    'DepthMax',         {{'1300',1,      1300}},...
                                    'DensMin',          {{'20',  1,      20}},...
                                    'DensMax',          {{'28',  1,      28}},...
                                    'TempMin',          {{'10',  1,      10}},...
                                    'TempMax',          {{'33',  1,      33}},...
                                    'SaltMin',          {{'33',  1,      30}},...
                                    'SaltMax',          {{'36',  1,      36}},...
                                    'CondMin',          {{'0',   1,      0}},...
                                    'CondMax',          {{'50',  1,      50}},...
                                    'DensScale',        {{'1',   1,      1}},...
                                    'TempScale',        {{'1',   1,      1}},...
                                    'TimeSpan2',        {{'1',   1,      1}},...
                                    'TimeUnit2',        {{1,     4,      1/24}},...
                                    'Engineering1Data', {{1,     4,      'pressure'}},...
                                    'Engineering1Min',  {{'0',   1,      0}},...
                                    'Engineering1Max',  {{'1300',1,      1300}},...
                                    'Engineering2Data', {{1,     4,      'pressure'}},...
                                    'Engineering2Min',  {{'0',   1,      0}},...
                                    'Engineering2Max',  {{'1300',1,      1300}},...
                                    'Engineering3Data', {{1,     4,      'pressure'}},...
                                    'Engineering3Min',  {{'0',   1,      0}},...
                                    'Engineering3Max',  {{'1300',1,      1300}},...
                                    'Engineering4Data', {{1,     4,      'pressure'}},...
                                    'Engineering4Min',  {{'0',   1,      0}},...
                                    'Engineering4Max',  {{'1300',1,      1300}});
    
    FastCTD_GUI_data.availableData(1) = struct('type', 'pressure',...
                                          'description','Pressure',...
                                          'dispText','Pressure',...
                                          'dispUnit','dbar',...
                                          'dataMin', 0,...
                                          'dataMax', 1300,...
                                          'dispMin', '0',...
                                          'dispMax', '1300');                            
    FastCTD_GUI_data.availableData(2) = struct('type', 'temperature',...
                                          'description','Temperature',...
                                          'dispText','Temperature',...
                                          'dispUnit','$^\circ$C',...
                                          'dataMin', 10,...
                                          'dataMax', 33,...
                                          'dispMin', '10',...
                                          'dispMax', '33');
    FastCTD_GUI_data.availableData(3) = struct('type', 'conductivity',...
                                          'description','Conductivity',...
                                          'dispText','Conductivity',...
                                          'dispUnit','S/m',...
                                          'dataMin', 0,...
                                          'dataMax', 5.5,...
                                          'dispMin', '0',...
                                          'dispMax', '5.5');

    FastCTD_GUI_data.availableData(4) = struct('type', 'uConductivity(:,1)',... % micro conductivity
                                          'description',[181 'Conductivity 1'],...
                                          'dispText','$\mu$Conductivity 1',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(5) = struct('type', 'uConductivity(:,2)',...
                                          'description',[181 'Conductivity 2'],...
                                          'dispText','$\mu$Conductivity 2',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(6) = struct('type', 'uConductivity(:,3)',...
                                          'description',[181 'Conductivity 3'],...
                                          'dispText','$\mu$Conductivity 3',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(7) = struct('type', 'uConductivity(:,4)',...
                                          'description',[181 'Conductivity 4'],...
                                          'dispText','$\mu$Conductivity 4',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(8) = struct('type', 'uConductivity(:,5)',... % micro conductivity
                                          'description',[181 'Conductivity 5'],...
                                          'dispText','$\mu$Conductivity 5',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(9) = struct('type', 'uConductivity(:,6)',...
                                          'description',[181 'Conductivity 6'],...
                                          'dispText','$\mu$Conductivity 6',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(10) = struct('type', 'uConductivity(:,7)',...
                                          'description',[181 'Conductivity 7'],...
                                          'dispText','$\mu$Conductivity 7',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(11) = struct('type', 'uConductivity(:,8)',...
                                          'description',[181 'Conductivity 8'],...
                                          'dispText','$\mu$Conductivity 8',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(12) = struct('type', 'uConductivity(:,9)',... % micro conductivity
                                          'description',[181 'Conductivity 9'],...
                                          'dispText','$\mu$Conductivity 9',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(13) = struct('type', 'uConductivity(:,10)',...
                                          'description',[181 'Conductivity 10'],...
                                          'dispText','$\mu$Conductivity 10',...
                                          'dispUnit','',...
                                          'dataMin', 21000,...
                                          'dataMax', 65000,...
                                          'dispMin', '21000',...
                                          'dispMax', '65000');
    FastCTD_GUI_data.availableData(14) = struct('type', 'gyro(:,1)',...
                                          'description','X-Gyro',...
                                          'dispText','gyro-$x$',...
                                          'dispUnit','',...
                                          'dataMin', -4,...
                                          'dataMax', 4,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(15) = struct('type', 'gyro(:,2)',...
                                          'description','Y-Gyro',...
                                          'dispText','gyro-$y$',...
                                          'dispUnit','',...
                                          'dataMin', -4,...
                                          'dataMax', 4,...
                                          'dispMin', '-4',...
                                          'dispMax', '4');
    FastCTD_GUI_data.availableData(16) = struct('type', 'gyro(:,3)',...
                                          'description','Z-Gyro',...
                                          'dispText','gyro-$z$',...
                                          'dispUnit','',...
                                          'dataMin', -4,...
                                          'dataMax', 4,...
                                          'dispMin', '-4',...
                                          'dispMax', '4');
    FastCTD_GUI_data.availableData(17) = struct('type', 'acceleration(:,1)',...
                                          'description','X-Acceleration',...
                                          'dispText','acceleration-$x$',...
                                          'dispUnit','',...
                                          'dataMin', -1,...
                                          'dataMax', 1,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(18) = struct('type', 'acceleration(:,2)',...
                                          'description','Y-Acelleration',...
                                          'dispText','acceleration-$y$',...
                                          'dispUnit','',...
                                          'dataMin', -1,...
                                          'dataMax', 1,...
                                          'dispMin', '-1',...
                                          'dispMax', '1');
    FastCTD_GUI_data.availableData(19) = struct('type', 'acceleration(:,3)',...
                                          'description','Z-Acceleration',...
                                          'dispText','acceleration-$z$',...
                                          'dispUnit','',...
                                          'dataMin', -1,...
                                          'dataMax', 1,...
                                          'dispMin', '-1',...
                                          'dispMax', '1');
    FastCTD_GUI_data.availableData(20) = struct('type', 'compass(:,1)',...
                                          'description','X-Compass',...
                                          'dispText','compass-$x$',...
                                          'dispUnit','',...
                                          'dataMin', -0.4,...
                                          'dataMax', 0.4,...
                                          'dispMin', '-0.4',...
                                          'dispMax', '0.4');
    FastCTD_GUI_data.availableData(21) = struct('type', 'compass(:,2)',...
                                          'description','Y-Compass',...
                                          'dispText','compass-$y$',...
                                          'dispUnit','',...
                                          'dataMin', -0.4,...
                                          'dataMax', 0.4,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(22) = struct('type', 'compass(:,3)',...
                                          'description','Z-Compass',...
                                          'dispText','compass-$z$',...
                                          'dispUnit','',...
                                          'dataMin', -0.4,...
                                          'dataMax', 0.4,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(23) = struct('type', 'gyro',...
                                          'description','Gyro-XYZ',...
                                          'dispText','gyro-$xyz$',...
                                          'dispUnit','',...
                                          'dataMin', -4,...
                                          'dataMax', 4,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(24) = struct('type', 'acceleration',...
                                          'description','Acceleration-XYZ',...
                                          'dispText','acceleration-$xyz$',...
                                          'dispUnit','',...
                                          'dataMin', -1,...
                                          'dataMax', 1,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.availableData(25) = struct('type', 'compass',...
                                          'description','Compass-XYZ',...
                                          'dispText','compass-$zyz$',...
                                          'dispUnit','',...
                                          'dataMin', -0.4,...
                                          'dataMax', 0.4,...
                                          'dispMin', '20',...
                                          'dispMax', '28');
    FastCTD_GUI_data.timeUnits = [1/24, 1/60/24, 1]; % time units in days (hour minute day)%
    FastCTD_GUI_data.currentTime = now;
    FastCTD_GUI_data.timeSpan = FastCTD_GUI_data.settings.TimeSpan{3}*FastCTD_GUI_data.settings.TimeUnit{3};
    FastCTD_GUI_data.timeSpan2 = FastCTD_GUI_data.settings.TimeSpan2{3}*FastCTD_GUI_data.settings.TimeUnit2{3};
    FastCTD_GUI_data.matDir = '/Volumes/S_ChinaSea2013_FCTD_2/RR1305/MAT/';

function setCorrectAxesProperties(handles)

global FastCTD_GUI_data;

save('FastCTD_GUI.mat','FastCTD_GUI_data');

%set axis ij for all Time Series plots
vars4Frames = {'Dens','Temp','Salt','Cond'};
for i=1:4
    set(handles.(sprintf('Frame%1d',i)),...
        'ydir','reverse',...
        'box','on',...
        'xgrid','on',...
        'ygrid','on',...
        'tickdir','in',...
        'fontsize', 12,...
        'fontName','Times',...
        'Units','pixels',...
        'XLim',[-FastCTD_GUI_data.timeSpan 0]+FastCTD_GUI_data.currentTime,...
        'YLim',[FastCTD_GUI_data.settings.DepthMin{3}, FastCTD_GUI_data.settings.DepthMax{3}],...
        'Clim',[FastCTD_GUI_data.settings.(sprintf('%sMin',vars4Frames{i})){3}, FastCTD_GUI_data.settings.(sprintf('%sMax',vars4Frames{i})){3}]);
    
    try
        datetick(handles.(sprintf('Frame%1d',i)),'x','keeplimits');
    catch err
        clear err;
    end
    
    if i == 1
        set(handles.(sprintf('Frame%1d',i)),...
            'XAxisLocation','top');
    elseif i == 4
        set(handles.(sprintf('Frame%1d',i)),...
        'XAxisLocation','bottom');
    else
        set(handles.(sprintf('Frame%1d',i)),...
        'XAxisLocation','bottom',...
        'XTickLabel',{});
    end
    
%     disp(sprintf('Engineering%1dMin',i));
%     disp([FastCTD_GUI_data.settings.(sprintf('Engineering%1dMin',i)){3} FastCTD_GUI_data.settings.(sprintf('Engineering%1dMax',i)){3}]);
    
    if FastCTD_GUI_data.settings.(sprintf('Engineering%1dData',i)){1} == 1
        set(handles.(sprintf('Engineering%1d',i)),...
            'ydir','reverse',...
            'box','on',...
            'xgrid','on',...
            'ygrid','on',...
            'tickdir','in',...
            'fontsize', 12,...
            'fontName','Times',...
            'Units','pixels',...
            'XLim',[-FastCTD_GUI_data.timeSpan2 0]+FastCTD_GUI_data.currentTime,...
            'YLim',[FastCTD_GUI_data.settings.(sprintf('Engineering%1dMin',i)){3}, FastCTD_GUI_data.settings.(sprintf('Engineering%1dMax',i)){3}]);
    else
        set(handles.(sprintf('Engineering%1d',i)),...
            'ydir','normal',...
            'box','on',...
            'xgrid','on',...
            'ygrid','on',...
            'tickdir','in',...
            'fontsize', 12,...
            'fontName','Times',...
            'Units','pixels',...
            'XLim',[-FastCTD_GUI_data.timeSpan2 0]+FastCTD_GUI_data.currentTime,...
            'YLim',[FastCTD_GUI_data.settings.(sprintf('Engineering%1dMin',i)){3}, FastCTD_GUI_data.settings.(sprintf('Engineering%1dMax',i)){3}]);
    end
    try
        datetick(handles.(sprintf('Engineering%1d',i)),'x','keeplimits');
    catch err
        clear err;
    end
    
    if i < 3
        set(handles.(sprintf('Engineering%1d',i)),...
            'XAxisLocation','top');
    else
        set(handles.(sprintf('Engineering%1d',i)),...
        'XAxisLocation','bottom');
    end
    
    
    
    if mod(i,2)
        set(handles.(sprintf('Engineering%1d',i)),...
            'YAxisLocation','left');
        ylabel(handles.(sprintf('Engineering%1d',i)),[FastCTD_GUI_data.availableData(FastCTD_GUI_data.settings.(sprintf('Engineering%1dData',i)){1}).dispText ' [' FastCTD_GUI_data.availableData(FastCTD_GUI_data.settings.(sprintf('Engineering%1dData',i)){1}).dispUnit ']'],...
            'FontSize',12,...
            'FontName','Times',...
            'Interpreter','LaTeX',...
            'Units','Normalize',...
            'Rotation',90,...
            'Position',[-0.18 0.5 1],...
            'VerticalAlignment','top');
    else
        set(handles.(sprintf('Engineering%1d',i)),...
            'YAxisLocation','right');
        ylabel(handles.(sprintf('Engineering%1d',i)),[FastCTD_GUI_data.availableData(FastCTD_GUI_data.settings.(sprintf('Engineering%1dData',i)){1}).dispText ' [' FastCTD_GUI_data.availableData(FastCTD_GUI_data.settings.(sprintf('Engineering%1dData',i)){1}).dispUnit ']'],...
            'FontSize',12,...
            'FontName','Times',...
            'Interpreter','LaTeX',...
            'Units','Normalize',...
            'Rotation',270,...
            'Position',[1.16 0.5 1]);
    end
    
end

xlabel(handles.Frame1,'Time [UTC]',...
    'Interpreter','LaTeX',...
    'Units','normalized',...
    'Position',[.5 1.1 1],...
    'FontSize',12);
xlabel(handles.Frame4,'Time [UTC]',...
    'Interpreter','LaTeX',...
    'Units','normalized',...
    'Position',[.5 -0.12 1],...
    'FontSize',12);
ylabel(handles.Frame2,'Depth [m]',...
    'Rotation',90,...
    'FontSize',12,...
    'Interpreter','latex',...
    'Units','normalized',...
    'Position',[-0.06 0 1]);

xlabel(handles.Engineering1,'Time [UTC]',...
    'Interpreter','LaTeX',...
    'Units','normalized',...
    'Position',[1 1.1 1],...
    'FontSize',12);
xlabel(handles.Engineering3,'Time [UTC]',...
    'Interpreter','LaTeX',...
    'Units','normalized',...
    'Position',[1 -0.15 1],...
    'FontSize',12);

%set axis ij for all Cascading plots
for i=1:2
    % first clear out the old labels before putting new one on
    h = get(handles.(sprintf('CascadePlot%1d',i)),'Children');
    
    for j = 1:length(h)
        if strcmpi(get(h(j),'Tag'),'PlotLabel')
            delete(h(j));
        end
    end
    
    set(handles.(sprintf('CascadePlot%1d',i)),...
        'ydir','reverse',...
        'box','on',...
        'xgrid','on',...
        'ygrid','on',...
        'tickdir','in',...
        'fontsize', 12,...
        'fontName','Times',...
        'Units','pixels',...
        'XLim',[-FastCTD_GUI_data.timeSpan 0]+FastCTD_GUI_data.currentTime,...
        'YLim',[FastCTD_GUI_data.settings.DepthMin{3}, FastCTD_GUI_data.settings.DepthMax{3}]);
    try
        datetick(handles.(sprintf('CascadePlot%1d',i)),'x','keeplimits');
    catch err
        clear('err');
    end
    
    if i == 1
        set(handles.(sprintf('CascadePlot%1d',i)),...
            'XAxisLocation','top');
        xlabel(handles.(sprintf('CascadePlot%1d',i)),'Time [UTC]',...
            'Interpreter','LaTeX',...
            'Units','normalized',...
            'Position',[.5 1.1 1],...
            'FontSize',12);
        axes(handles.(sprintf('CascadePlot%1d',i)));
        text(min(xlim)+0.02*range(xlim),max(ylim)-0.05*range(ylim),'$\sigma_T$',...
            'Interpreter','LaTeX',...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'FontSize',14,...
            'FontName','Times',...
            'BackgroundColor','w',...
            'Color','k',...
            'Tag','PlotLabel');
    else
        set(handles.(sprintf('CascadePlot%1d',i)),...
            'XAxisLocation','bottom');
        xlabel(handles.(sprintf('CascadePlot%1d',i)),'Time [UTC]',...
            'Interpreter','LaTeX',...
            'Units','normalized',...
            'Position',[.5 -0.12 1],...
            'FontSize',12);
        axes(handles.(sprintf('CascadePlot%1d',i)));
        h = text(min(xlim)+0.02*range(xlim),max(ylim)-0.05*range(ylim),'Temperature',...
            'Interpreter','LaTeX',...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'FontSize',14,...
            'FontName','Times',...
            'BackgroundColor','w',...
            'Color','k',...
            'Tag','PlotLabel');
    end

    
end
ylabel(handles.CascadePlot1,'Depth [m]',...
    'Rotation',90,...
    'FontSize',12,...
    'Interpreter','latex',...
    'Units','normalized',...
    'Position',[-0.06 0 1]);

set(handles.UpdateStatusText,'String',['Last updated on ' datestr(now,'yyyy/mm/dd HH:MM:SS') '[UTC]']);
drawnow;

% --- update time 
function update_Time()
global FastCTD_GUI_data;
if FastCTD_GUI_data.settings.isCurrentTime{3}
    FastCTD_GUI_data.currentTime = now;
end
FastCTD_GUI_data.settings.yyyy{1} = datestr(FastCTD_GUI_data.currentTime,'yyyy');
FastCTD_GUI_data.settings.mm{1} = datestr(FastCTD_GUI_data.currentTime,'mm');
FastCTD_GUI_data.settings.dd{1} = datestr(FastCTD_GUI_data.currentTime,'dd');
FastCTD_GUI_data.settings.HH{1} = datestr(FastCTD_GUI_data.currentTime,'HH');
FastCTD_GUI_data.settings.MM{1} = datestr(FastCTD_GUI_data.currentTime,'MM');
FastCTD_GUI_data.settings.yyyy{3} = FastCTD_GUI_data.settings.yyyy{1};
FastCTD_GUI_data.settings.mm{3} = FastCTD_GUI_data.settings.mm{1};
FastCTD_GUI_data.settings.dd{3} = FastCTD_GUI_data.settings.dd{1};
FastCTD_GUI_data.settings.HH{3} = FastCTD_GUI_data.settings.HH{1};
FastCTD_GUI_data.settings.MM{3} = FastCTD_GUI_data.settings.MM{1};


% --- update Color Time Series and Cascade Plots
function update_TimeSeriesCascadePlots(handles,FCTD)
global FastCTD_GUI_data;

persistent Vars2PlotInFrames;

if isempty(Vars2PlotInFrames)
    Vars2PlotInFrames = {'density','temperature','salinity','conductivity'};
end

persistent VarsBoxNames;
if isempty(VarsBoxNames)
    VarsBoxNames = {'Dens','Temp','Salt','Cond'};
end

TimeMin = FastCTD_GUI_data.currentTime - FastCTD_GUI_data.timeSpan;
myFCTD_GridData = [];
if isstruct(FCTD)
    myFCTD_GridData =  FastCTD_GridData(FCTD,'zMin',FastCTD_GUI_data.settings.DepthMin{3},'zMax',FastCTD_GUI_data.settings.DepthMax{3},'zInterval',1,'downcast');
end
% Color Plots
if isstruct(myFCTD_GridData) && size(myFCTD_GridData.tGrid.density,2)>2
    time_ind = myFCTD_GridData.tGrid.time >=TimeMin & myFCTD_GridData.tGrid.time <= FastCTD_GUI_data.currentTime;
    time = myFCTD_GridData.tGrid.time(time_ind);
    depth = myFCTD_GridData.tGrid.depth;
    myFCTD_GridData.tGrid.density = myFCTD_GridData.tGrid.density - 1000;
    myFCTD_GridData.tGrid.conductivity = myFCTD_GridData.tGrid.conductivity*10;
    isopycnals = linspace(FastCTD_GUI_data.settings.DensMin{3},FastCTD_GUI_data.settings.DensMax{3},1000);
    isopycnal_depths = NaN(length(isopycnals),length(myFCTD_GridData.tGrid.time));
    for i = 1:size(isopycnal_depths,2)
        x = myFCTD_GridData.tGrid.density(:,i);
        y = depth;
        nan_x = ~isnan(x);
        y = y(nan_x);
        x = x(nan_x);
        [x, J] = unique(x);
        y = y(J);
        if length(x)> 2
            isopycnal_depths(:,i) = interp1(x,y,isopycnals);
        end
    end
    
    depths2PlotIsopycnals = linspace(FastCTD_GUI_data.settings.DepthMin{3},FastCTD_GUI_data.settings.DepthMax{3},15);
    x = nanmean(isopycnal_depths,2);
    y = isopycnals;
    
    nan_x = ~isnan(x);
    y = y(nan_x);
    x = x(nan_x);
    [x, J] = unique(x);
    y = y(J);
    if numel(x) > 3
        isopycnal2plot = interp1(x,y,depths2PlotIsopycnals);
    else
        isopycnal2plot = [];
    end
    
    for i = 1:3
%         hold(handles.(sprintf('Frame%1d',i)),'off');
        delete(get(handles.(sprintf('Frame%1d',i)),'children'));
        data = myFCTD_GridData.tGrid.(Vars2PlotInFrames{i})(:,time_ind);
        contourf(handles.(sprintf('Frame%1d',i)),time,depth,data,...
            linspace(FastCTD_GUI_data.settings.(sprintf('%sMin',VarsBoxNames{i})){3},FastCTD_GUI_data.settings.(sprintf('%sMax',VarsBoxNames{i})){3},FastCTD_GUI_data.settings.ColorCount{3}*2),'linecolor','none');
        hold(handles.(sprintf('Frame%1d',i)),'on');
        contour(handles.(sprintf('Frame%1d',i)),time,depth+0.005*range([FastCTD_GUI_data.settings.DepthMin{3}, FastCTD_GUI_data.settings.DepthMax{3}]),...
            myFCTD_GridData.tGrid.density(:,time_ind),isopycnal2plot(~isnan(isopycnal2plot)),'color',[1 1 1]*0.3,'linewidth',1);
        contour(handles.(sprintf('Frame%1d',i)),time,depth,myFCTD_GridData.tGrid.density(:,time_ind),...
            isopycnal2plot(~isnan(isopycnal2plot)),'color',[1 1 1],'linewidth',1);
%         hold(handles.(sprintf('Frame%1d',i)),'off');
        shading('flat');
    end
    
    
    % plot N2 instead of conductivity
    for i = 4
%         hold(handles.(sprintf('Frame%1d',i)),'off');
        delete(get(handles.(sprintf('Frame%1d',i)),'children'));
        data = myFCTD_GridData.tGrid.density(:,time_ind);
        [x,y] = meshgrid(time,depth);
        [~,dy] = gradient(y);
        [~,ddata] = gradient(data);
        
        data = log10(abs(-gsw_grav(15,y)./(data+1000).*ddata./dy));
        
        contourf(handles.(sprintf('Frame%1d',i)),time,depth,data,...
            linspace(FastCTD_GUI_data.settings.(sprintf('%sMin',VarsBoxNames{i})){3},FastCTD_GUI_data.settings.(sprintf('%sMax',VarsBoxNames{i})){3},FastCTD_GUI_data.settings.ColorCount{3}*2),'linecolor','none');
        hold(handles.(sprintf('Frame%1d',i)),'on');
        contour(handles.(sprintf('Frame%1d',i)),time,depth+0.005*range([FastCTD_GUI_data.settings.DepthMin{3}, FastCTD_GUI_data.settings.DepthMax{3}]),...
            myFCTD_GridData.tGrid.density(:,time_ind),isopycnal2plot(~isnan(isopycnal2plot)),'color',[1 1 1]*0.3,'linewidth',1);
        contour(handles.(sprintf('Frame%1d',i)),time,depth,myFCTD_GridData.tGrid.density(:,time_ind),...
            isopycnal2plot(~isnan(isopycnal2plot)),'color',[1 1 1],'linewidth',1);
%         hold(handles.(sprintf('Frame%1d',i)),'off');
        shading('flat');
    end


% Cascade Plots


    depths2PlotIsopycnals = linspace(FastCTD_GUI_data.settings.DepthMin{3},FastCTD_GUI_data.settings.DepthMax{3},30);
    x = nanmean(isopycnal_depths,2);
    y = isopycnals;
    
    nan_x = ~isnan(x);
    y = y(nan_x);
    x = x(nan_x);
    [x, J] = unique(x);
    y = y(J);
    if numel(x) > 3
        isopycnal2plot = interp1(x,y,depths2PlotIsopycnals);
    else
        isopycnal2plot = [];
    end

    time_ind2 = myFCTD_GridData.time >=TimeMin & myFCTD_GridData.time <= FastCTD_GUI_data.currentTime;
    time2 = myFCTD_GridData.time(time_ind2);
    depth2 = myFCTD_GridData.depth;
    myFCTD_GridData.density = myFCTD_GridData.density - 1000;
    myFCTD_GridData.conductivity = myFCTD_GridData.conductivity*10;
    [T, D] = meshgrid(time2,depth2);
    
%     % calculate Thorpe Scale
%     density = nanmedfilt1(myFCTD_GridData.density(:,time_ind2),4,[],1);
%     sorted_density = NaN(size(density));
%     sorted_depth2 = NaN(size(density));
%     for i = 1:size(density,2)
%         ind1 = find(~isnan(density(:,i)),1,'first');
%         ind2 = find(~isnan(density(:,i)),1,'last');
%         K = ind1:ind2;
%         [sorted_density(ind1:ind2,i), J] = sort(density(ind1:ind2,i),1,'ascend');
%         sorted_depth2(ind1:ind2,i) = D(K(J), i);
%     end
%         
%     mygausswin = gausswin(9)*gausswin(1)'; 
% 
%     mygausswin = mygausswin/sum(mygausswin(:));
%     L_Th1 = conv2(abs(sorted_depth2-D),mygausswin,'same');
%     
%     % calculate Thorpe Scale
%     temperature = nanmedfilt1(myFCTD_GridData.temperature(:,time_ind2),4,[],1);
%     sorted_temperature = NaN(size(temperature));
%     sorted_depth2 = NaN(size(temperature));
%     for i = 1:size(temperature,2)
%         ind1 = find(~isnan(temperature(:,i)),1,'first');
%         ind2 = find(~isnan(temperature(:,i)),1,'last');
%         K = ind1:ind2;
%         [sorted_temperature(ind1:ind2,i), J] = sort(temperature(ind1:ind2,i),1,'descend');
%         sorted_depth2(ind1:ind2,i) = D(K(J), i);
%     end
%         
%     mygausswin = gausswin(9)*gausswin(1)'; 
% 
%     mygausswin = mygausswin/sum(mygausswin(:));
%     L_Th2 = conv2(abs(sorted_depth2-D),mygausswin,'same');
%     
%     L_Th = NaN(2,size(L_Th1,1),size(L_Th1,2));
%     L_Th(1,:,:) = L_Th1;
%     L_Th(2,:,:) = L_Th2;
    salinity = myFCTD_GridData.salinity(:,time_ind2);
    temperature = myFCTD_GridData.temperature(:,time_ind2);
    pressure = myFCTD_GridData.pressure(:,time_ind2);
    Eps = NaN(size(salinity));
    L_T = NaN(size(salinity));
    L = NaN(size(salinity));
    
    for i = 1:size(Eps,2)
        try
            [Eps(:,i),L_T(:,i),L(:,i)] =...
                computeOverturns(salinity(:,i),temperature(:,i),pressure(:,i),...
                'tempNoiseLevel',0.5e-4,'densNoiseLevel',1e-4,'UseBoth','tempR0Threshold',0.025,'densR0Threshold',0.025,'lat',20);
        catch err2
            disp(err2);
            for j=1:numel(err2.stack)
                disp([err2.stack(j).file ' : ' err2.stack(j).name ' : ' num2str(err2.stack(j).line)]);
            end
        end
    end
    L_Th = NaN(2,size(L_T,1),size(L_T,2));
    L_Th(1,:,:) = L_T;
    L_Th(2,:,:) = L_T;
    for i = 1:2
        dataC = myFCTD_GridData.(Vars2PlotInFrames{i})(:,time_ind2);
        
        p = polyfit(D(~isnan(dataC)),dataC(~isnan(dataC)),1);
        
%         hold(handles.(sprintf('CascadePlot%1d',i)),'off');
        delete(get(handles.(sprintf('CascadePlot%1d',i)),'children'));
        SN_plotCascade(handles.(sprintf('CascadePlot%1d',i)),dataC-polyval(p,D),D,...
            'time',T,'b-','linewidth',0.75,'scale',FastCTD_GUI_data.settings.(sprintf('%sScale',VarsBoxNames{i})){3});
        hold(handles.(sprintf('CascadePlot%1d',i)),'on');
        SN_plotCascade(handles.(sprintf('CascadePlot%1d',i)),dataC-polyval(p,D),D,...
            'time',T,'ro','linewidth',0.5,'scale',FastCTD_GUI_data.settings.(sprintf('%sScale',VarsBoxNames{i})){3},...
            'PointsToPlot',squeeze(L_Th(i,:,:))>2,'markerfacecolor','r','markersize',2);
        
        contour(handles.(sprintf('CascadePlot%1d',i)),time,depth,...
            myFCTD_GridData.tGrid.density(:,time_ind),isopycnal2plot(~isnan(isopycnal2plot)),'color',[1 1 1]*0.5,'linewidth',.5);
%         hold(handles.(sprintf('CascadePlot%1d',i)),'off');
        shading('flat');
    end    
end
% SN_printfig('testimg.pdf','Figure',handles.FastCTD_GUI,'Resolution',300);

% --- update Engineering Plots
function update_EngineeringPlots(handles,FCTD)

global FastCTD_GUI_data;
TimeMin = FastCTD_GUI_data.currentTime - FastCTD_GUI_data.timeSpan2;
if isstruct(FCTD) && size(FCTD.temperature,1) > 2
    DataStruct = struct(...
        'data1',eval(['FCTD.',FastCTD_GUI_data.settings.Engineering1Data{3}]),...
        'data2',eval(['FCTD.',FastCTD_GUI_data.settings.Engineering2Data{3}]),...
        'data3',eval(['FCTD.',FastCTD_GUI_data.settings.Engineering3Data{3}]),...
        'data4',eval(['FCTD.',FastCTD_GUI_data.settings.Engineering4Data{3}]));
    time_ind = FCTD.time >=TimeMin & FCTD.time <= FastCTD_GUI_data.currentTime;
    time = FCTD.time(time_ind);
    
    for i = 1:4
        hold(handles.(sprintf('Engineering%1d',i)),'on');
        delete(get(handles.(sprintf('Engineering%1d',i)),'children'));
        plot(handles.(sprintf('Engineering%1d',i)),time,DataStruct.(sprintf('data%1d',i))(time_ind,:),'-','linewidth',1);
    end
end

% --- function to update data conversion from Raw to MATLAB then Grid data
function update_Plots(hObject, eventdata,handles)

update_Time();

global FastCTD_GUI_data;

TimeMin = FastCTD_GUI_data.currentTime - FastCTD_GUI_data.timeSpan;

% FileList = dir([FastCTD_GUI_data.matDir '/FCTD*.mat']);
try
load([FastCTD_GUI_data.matDir '/FastCTD_MATfile_TimeIndex.mat']);
catch err
    disp(err);
    disp('Error loading time index');
    return;
end
if ~exist('FastCTD_MATfile_TimeIndex','var')
    return;
end
%load up the data at specified time
myFCTD = [];

if exist('FCTD_GridData','var')
    clear FCTD_GridData;
end

if exist('FCTD','var')
    clear FCTD;
end

disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Loading FCTD MAT-Files...']);
ind = find(FastCTD_MATfile_TimeIndex.timeEnd >= TimeMin & FastCTD_MATfile_TimeIndex.timeStart <= FastCTD_GUI_data.currentTime);
for i = 1:length(ind);
    %load data for scientific display
    try
        disp(FastCTD_MATfile_TimeIndex.filenames{ind(i)});
        try
            load([FastCTD_GUI_data.matDir '/' FastCTD_MATfile_TimeIndex.filenames{ind(i)} '.mat']);
        catch
            pause(0.05);
            try
                load([FastCTD_GUI_data.matDir '/' FastCTD_MATfile_TimeIndex.filenames{ind(i)} '.mat']);
            catch err
                disp(err);
                disp([FastCTD_GUI_data.matDir '/' FastCTD_MATfile_TimeIndex.filenames{ind(i)} '.mat']);
            end
        end
        if exist('FCTD','var')
            if isstruct(FCTD) && ~isempty(FCTD.time) && (FCTD.time(end)>=TimeMin && FCTD.time(1) <= FastCTD_GUI_data.currentTime)
                myFCTD = FastCTD_MergeFCTD(myFCTD,FCTD);
            end
            clear FCTD;
        end
    catch err
        disp(['There something wrong loading ' FastCTD_MATfile_TimeIndex.filenames{ind(i)} ]);
        disp(err);
        disp(err.message);
        disp(err.stack);
        disp([FastCTD_GUI_data.matDir '/' FastCTD_MATfile_TimeIndex.filenames{ind(i)} '.mat']);
    end
end
disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Done loading FCTD MAT-Files...']);
disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Plotting...']);
try
    update_TimeSeriesCascadePlots(handles,myFCTD);
    update_EngineeringPlots(handles,myFCTD);
    update_ControlPanelParams(handles);
    setCorrectAxesProperties(handles);
catch err
    disp('There was some error in the plotting, probably because the user closes the programs too early');
    disp(err);
    for i = 1:length(err.stack)
        disp([num2str(i) ' ' err.stack(i).name ' ' num2str(err.stack(i).line)]);
    end
end

disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Done plotting...']);
disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Saving figure...']);

% we find that with all the LaTeX stuff, the renderer doesn't work very
% well for rotated text
try
    SN_printfig([FastCTD_GUI_data.matDir '/../PDF/' 'FastCTD_GUI_data.pdf'],'Figure',handles.FastCTD_GUI);
catch
    disp('There was some error in the plotting, probably because the user closes the programs too early');
end

% SN_printfig('testimg.png','Figure',handles.FastCTD_GUI,'Resolution',300);
% in order to use rotated text we use ImageMagick to do the conversion to
% JPG
unix(['cd ' FastCTD_GUI_data.matDir '; cd ..; /usr/bin/sips -s format png PDF/FastCTD_GUI_data.pdf --out PNG/FastCTD_GUI_data.png; '...
    ' /usr/bin/sips -s format jpeg PNG/FastCTD_GUI_data.png --out JPG/FastCTD_GUI_data.jpg;']);

% save another copy of the PDF and JPG every 10 minutes if the GUI is in
% auto mode
try
%     copyfile([FastCTD_GUI_data.matDir '/../PDF/' 'FastCTD_GUI_data.pdf'],'~/Sites/FCTD/PDF/FastCTD_GUI_data.pdf');
%     copyfile([FastCTD_GUI_data.matDir '/../PNG/' 'FastCTD_GUI_data.png'],'~/Sites/FCTD/PNG/FastCTD_GUI_data.png');
%     copyfile([FastCTD_GUI_data.matDir '/../JPG/' 'FastCTD_GUI_data.jpg'],'~/Sites/FCTD/JPG/FastCTD_GUI_data.jpg');
    copyfile([FastCTD_GUI_data.matDir '/../PDF/' 'FastCTD_GUI_data.pdf'],'/Library/WebServer/Documents/TTide/PDF/FastCTD_GUI_data.pdf');
    copyfile([FastCTD_GUI_data.matDir '/../PNG/' 'FastCTD_GUI_data.png'],'/Library/WebServer/Documents/TTide/PNG/FastCTD_GUI_data.png');
    if mod(floor(now*24*60),10)==0
        i = timerfindall('Tag','FastCTD_Timer');
        if ~isempty(i) && get(i,'TasksToExecute') > 1
            disp('copyfile');
            copyfile([FastCTD_GUI_data.matDir '/../PDF/' 'FastCTD_GUI_data.pdf'],[FastCTD_GUI_data.matDir '/../PDF/' sprintf('FastCTD_GUI_%s.pdf',datestr(now,'yyyy-mm-dd_HHMM'))]);
            copyfile([FastCTD_GUI_data.matDir '/../PNG/' 'FastCTD_GUI_data.png'],[FastCTD_GUI_data.matDir '/../PNG/' sprintf('FastCTD_GUI_%s.png',datestr(now,'yyyy-mm-dd_HHMM'))]);
            copyfile([FastCTD_GUI_data.matDir '/../JPG/' 'FastCTD_GUI_data.jpg'],[FastCTD_GUI_data.matDir '/../JPG/' sprintf('FastCTD_GUI_%s.jpg',datestr(now,'yyyy-mm-dd_HHMM'))]);
            copyfile([FastCTD_GUI_data.matDir '/../PDF/' 'FastCTD_GUI_data.pdf'],['/Library/WebServer/Documents/TTide/PDF/' sprintf('FastCTD_GUI_%s.pdf',datestr(now,'yyyy-mm-dd_HHMM'))]);
            copyfile([FastCTD_GUI_data.matDir '/../PNG/' 'FastCTD_GUI_data.png'],['/Library/WebServer/Documents/TTide/PNG/' sprintf('FastCTD_GUI_%s.png',datestr(now,'yyyy-mm-dd_HHMM'))]);
%             unix(['cd ' FastCTD_GUI_data.matDir '/../PDF/; /usr/bin/scp FastCTD_GUI_data.pdf snguyen@nas-1:~/FCTD/PDF/; '...
%                 sprintf('ssh snguyen@nas-1 ''cd FCTD/PDF/; cp FastCTD_GUI_data.pdf FastCTD_GUI_%s.pdf'';',datestr(now,'yyyy-mm-dd_HH'))]);
        end
    end
catch err
    disp('error in copy file');
    disp(err);
end

disp([datestr(now,'[yyyy.mm.dd HH:MM:SS]') ' Done saving figure...']);

% save user selection/layout as default
save('FastCTD_GUI.mat','FastCTD_GUI_data');
