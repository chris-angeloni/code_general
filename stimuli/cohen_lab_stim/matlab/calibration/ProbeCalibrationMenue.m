function varargout = ProbeCalibrationMenue(varargin)
% PROBECALIBRATIONMENUE M-file for ProbeCalibrationMenue.fig
% Interface for running Monty Escabi's speaker calibration package.
% Calls function CALIBFIR.M in calibrate mode
% Still needs the functions for running verify mode and tone test mode.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProbeCalibrationMenue_OpeningFcn, ...
                   'gui_OutputFcn',  @ProbeCalibrationMenue_OutputFcn, ...
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


% --- Executes just before ProbeCalibrationMenue is made visible.
function ProbeCalibrationMenue_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProbeCalibrationMenue (see VARARGIN)

% Choose default command line output for ProbeCalibrationMenue
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%load last values used
load calibparams.mat
load MicrophoneInfo.mat
try set(handles.calibdirectory, 'String', parameters.TDTDirectory); end
try set(handles.param1, 'String', parameters.f1); end
try set(handles.param2, 'String', parameters.f2); end
try set(handles.param3, 'String', parameters.ATT); end
try set(handles.param4, 'String', parameters.L); end
try set(handles.param5, 'String', parameters.MaxSPL); end    
try set(handles.param6, 'String', parameters.PA5ATT); end    
try set(handles.param7, 'String', num2str([Microphones.SerialNumber]')); end   
try set(handles.param8, 'String', Microphones(1).Sensitivity); end    
try set(handles.param9, 'String', parameters.MicGain); end    
try set(handles.param10, 'String', parameters.SpeakerID); end    

%Attempt to set path to working directory
try 
    if isunix
        set(handles.calibdirectory, 'String', [pwd '/']);
    else 
        set(handles.calibdirectory, 'String', [pwd '\']);
    end
end  

% UIWAIT makes ProbeCalibrationMenue wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ProbeCalibrationMenue_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function action_Callback(hObject, eventdata, handles)

%Load Parameters - only for NB, Interface, Device, DeviceNum
%All others are obtained below
load 'calibparams.mat'

%Matlab Calibration Directory
MatlabCalibDirectory=which('ProbeCalibrationMenue');
i=findstr(MatlabCalibDirectory,'ProbeCalibrationMenue');
MatlabCalibDirectory=MatlabCalibDirectory(1:i-1)

%Gathering Paremeters and Settings
calibmode1 = get(handles.calibmode1, 'Value');
calibmode2 = get(handles.calibmode2, 'Value');
calibmode3 = get(handles.calibmode3, 'Value');
ProbeSelect=find([calibmode1 calibmode2 calibmode3]); 
soundselect1 = get(handles.soundselect1, 'Value');
soundselect2 = get(handles.soundselect2, 'Value');
soundselect3 = get(handles.soundselect3, 'Value');
SoundSelect=-1+find([soundselect1 0 0 soundselect2 soundselect3])
SpeakerSelect = 1 + get(handles.togglespeaker, 'Value')
AcquireSelect = get(handles.acquireselect, 'Value')
RoomNoiseSelect = setstr('y'*get(handles.roomnoiseselect, 'Value'))
CalibDirectory = [get(handles.calibdirectory, 'String')];

f1 = str2num(get(handles.param1, 'String'));
f2 = str2num(get(handles.param2, 'String'));
ATT = str2num(get(handles.param3, 'String'));
L = str2num(get(handles.param4, 'String'));
MaxSPL = str2num(get(handles.param5, 'String'));
PA5ATT = str2num(get(handles.param6, 'String'));
MicSerialNumber = str2num(get(handles.param7, 'String'));
index=get(handles.param7, 'Value');
MicSerialNumber=MicSerialNumber(index);
MicSensitivity = str2num(get(handles.param8, 'String'));
MicGain = str2num(get(handles.param9, 'String'));
SpeakerID = get(handles.param10, 'String');

%Some parameters
NFFT=1024*4;

    %Acquiring Data
    if ProbeSelect~=3 & AcquireSelect==0    %Calibration mode 1 or 2
    
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Delivering sound and acquiring data ...'])    
        pause(0.1)
        
        %Acquiring Data and Storing
        ChirpGain=0;
        [ProbeData]=calibacquireprobe(MicGain,PA5ATT,parameters.NB,parameters.Interface,parameters.Device,parameters.DeviceNum,SoundSelect,ChirpGain,AcquireSelect,SpeakerSelect,ProbeSelect,RoomNoiseSelect,MicSensitivity,MicSerialNumber,SpeakerID,CalibDirectory,parameters.FsFlag);
        X=ProbeData.X;
        Y=ProbeData.Y;  %Sound at the probe end
        
    elseif ProbeSelect==3 & AcquireSelect==0 %Calibration mode 3
        
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Generating inverse filter ...'])    
        pause(0.1)
        
        %Loading Data
        load([CalibDirectory 'ProbeDataPos1' SpeakerID num2str(SpeakerSelect) '.mat']);
        load([CalibDirectory 'ProbeDataPos2' SpeakerID num2str(SpeakerSelect) '.mat']);

        %Generating Inverse Filter at H2 end. Used to "whiten" spectrum
        [CalibData1] = calibfirprobe1(ProbeData1,ProbeData2,f1,f2,L,ATT,NFFT,'n');
        save([CalibDirectory 'CalibData1' SpeakerID num2str(SpeakerSelect) '.mat'],'CalibData1');
        
        %Storing Filter Coefficients in TDT Directory
        if SpeakerSelect==1
            fid=fopen([MatlabCalibDirectory 'spchan1.f32'],'wb')
            fwrite(fid,CalibData1.h1inv,'float');
            fclose(fid);
        elseif SpeakerSelect==2
            fid=fopen([MatlabCalibDirectory 'spchan2.f32'],'wb')
            fwrite(fid,CalibData1.h1inv,'float');
            fclose(fid);
        end
        
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Delivering sound and acquiring data ...'])   
        pause(0.1)
        
        %Acquiring Data and Storing
        AcquireSelect=1;    %Prefilter using h1inv in TDT, approximately prewhite / preemphasis at ear location
        ChirpGain=0;
        [ProbeData]=calibacquireprobe(MicGain,PA5ATT,parameters.NB,parameters.Interface,parameters.Device,parameters.DeviceNum,SoundSelect,ChirpGain,AcquireSelect,SpeakerSelect,ProbeSelect,RoomNoiseSelect,MicSensitivity,MicSerialNumber,SpeakerID,CalibDirectory,parameters.FsFlag);
        X=conv(ProbeData.X,CalibData1.h1inv);       %Delivered Sound
        Y=conv(ProbeData.Y,CalibData1.hprobeinv);   %Sound at the animal's ear
        Y=Y(L+1:length(Y)-L);                       %Remove edge artifact
        AcquireSelect=0;                            %Actual Mode, put back
        
        %SPL at the animal's ear 
        [eSPL,eSPLmax,eSPLf1f2,eSPLmaxf1f2]=calibinearspl(ProbeData,CalibData1,MicGain,MicSensitivity,f1,f2);
        
    elseif ProbeSelect==3 &  AcquireSelect==1   %Validation Mode
        
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Generating inverse filter ...'])    
        pause(0.1)
        
        %Loading Data
        load([CalibDirectory 'ProbeDataPos1' SpeakerID num2str(SpeakerSelect) '.mat']);
        load([CalibDirectory 'ProbeDataPos2' SpeakerID num2str(SpeakerSelect) '.mat']);
        load([CalibDirectory 'ProbeDataPos3' SpeakerID num2str(SpeakerSelect) '.mat']);
        load([CalibDirectory 'CalibData1'  SpeakerID num2str(SpeakerSelect) '.mat']);
        
        %Generating Inverse Filter at H2 end. Used to "whiten" spectrum
        %[CalibData1] = calibfirprobe1(ProbeData1,ProbeData2,f1,f2,L,ATT,NFFT,'n');
        [CalibData2] = calibfirprobe2(CalibData1,ProbeData3,f1,f2,L,ATT,NFFT,'n');
        save([CalibDirectory 'CalibData2' SpeakerID num2str(SpeakerSelect) '.mat'],'CalibData2');
        
        %[CalibData] = calibfirprobe(ProbeData1,ProbeData2,ProbeData3,f1,f2,L,ATT,NFFT,'n');
        
        %Storing Filter Coefficients in TDT Directory
        if SpeakerSelect==1
            fid=fopen([MatlabCalibDirectory 'spchan1.f32'],'wb')
            fwrite(fid,CalibData2.hinv,'float');
            fclose(fid);
        elseif SpeakerSelect==2
            fid=fopen([MatlabCalibDirectory 'spchan2.f32'],'wb')
            fwrite(fid,CalibData2.hinv,'float');
            fclose(fid);
        end
       
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Delivering sound and acquiring data ...'])   
        pause(0.1)
        
        %Acquiring Data and Storing
        AcquireSelect=1;
        ChirpGain=0;
        [ProbeData]=calibacquireprobe(MicGain,PA5ATT,parameters.NB,parameters.Interface,parameters.Device,parameters.DeviceNum,SoundSelect,ChirpGain,AcquireSelect,SpeakerSelect,ProbeSelect,RoomNoiseSelect,MicSensitivity,MicSerialNumber,[SpeakerID 'Val'],CalibDirectory,parameters.FsFlag); 
        X=conv(ProbeData.X,CalibData2.hinv);        %Delivered Sound, inverse calibration filter applied
        Y=conv(ProbeData.Y,CalibData2.hprobeinv);   %Sound at the animal's ear
        Y=Y(L+1:length(Y)-L);                       %Remove edge artifact
        
        %SPL at the animal's ear 
        [eSPL,eSPLmax,eSPLf1f2,eSPLmaxf1f2]=calibinearspl(ProbeData,CalibData2,MicGain,MicSensitivity,f1,f2);
        
    else
        %Sending Status Message
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', ['Incorrect Calibration Mode. Check Settings!!!'])    
        pause(0.1)
    end
    
    %Sending Status Message and Displaying SPL
    pause(0.1)
    if ProbeSelect==3
        Message=['In ear SPL    = ' num2str(eSPL, '%5.2f') 'dB' setstr(10) 'In ear MaxSPL = ' num2str(eSPLmax, '%5.2f') 'dB', ...
            setstr(10) 'In ear SPL    = ' num2str(eSPLf1f2, '%5.2f') 'dB (f1 to f2)' setstr(10) 'In ear MaxSPL = '  num2str(eSPLmaxf1f2, '%5.2f') 'dB (f1 to f2)']
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message]);
    else
        Message=['Microphone SPL    = ' num2str(ProbeData.SPL, '%5.2f') 'dB' setstr(10) 'Microphone MaxSPL = ' num2str(ProbeData.SPLmax, '%5.2f') 'dB']
        set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message]);
    end
    
     %Plotting Input Time Data
     axes(handles.axes1)
     hold off
     plot((0:length(X)-1)/ProbeData.Fs,X,'k')
     title('TDT Voltage Out - Sent To Speakers')
      axis([0 10 -10 10])
         
     %Plotting Measured Microphone Response 
     axes(handles.axes8)
     hold off
     plot((0:length(ProbeData.Y)-1)/ProbeData.Fs,ProbeData.Y,'k')
     title('TDT Voltage In - Return Signal From Microphone')
     try 
        hold on
        plot((0:length(ProbeData.X)-1)/ProbeData.Fs,ProbeData.YRoomNoise,'g'); 
        title('Microphone Measurement (BLACK) and Room Noise (GREEN)')
        hold off
     catch
        title('Microphone Measurement')
     end
     axis([0 10 -max(abs(ProbeData.Y))*1.5 max(abs(ProbeData.Y))*1.5])
     
     %Plotting Predicted In Ear Signal - Validation and Calibration Mode only
     if ProbeSelect==3
         axes(handles.axes2)
         plot((0:length(Y)-1)/ProbeData.Fs,Y,'r')     %Feb 16, MAE; Changed to Y, previously ProbeData.Y - now plots sound at ear for ProbeSelect=3
         axis([0 10 -max(abs(Y))*1.5 max(abs(Y))*1.5])
         title('Predicted In Ear Voltage')
         xlabel('Time (sec)')
         ylabel('Volts')
         pause(0.1)
     end
     
     %Spectrum Figure
     axes(handles.axes3)
     hold off
     Po=2.2E-5;
     Offset=10*log10((872161/ProbeData.Fs).^2)     
     [ProbeSpectrum] = calibspectrum(ProbeData,ATT,NFFT);
     plot(ProbeSpectrum.F/1000,10*log10(ProbeSpectrum.Pyy/ProbeSpectrum.NFFT*2./Po.^2),'k')
     hold on
     plot(ProbeSpectrum.F/1000,10*log10(ProbeSpectrum.Pyx.^2/ProbeSpectrum.NFFT*2./Po.^2),'color',[0.5 .5 .5])
      if ProbeSelect==3 &  AcquireSelect==0   %Calibration Mode 3
        plot(ProbeSpectrum.F/1000,10*log10(abs(ProbeSpectrum.Pyx).^2./CalibData1.Hprobe.^2/ProbeSpectrum.NFFT*2./Po.^2),'r'); 
     end
     if ProbeSelect==3 &  AcquireSelect==1   %Validation Mode
        plot(ProbeSpectrum.F/1000,10*log10(abs(ProbeSpectrum.Pyx).^2./CalibData2.Hprobe.^2/ProbeSpectrum.NFFT*2./Po.^2),'r'); 
     end
     try
        plot(ProbeSpectrum.F/1000,10*log10(ProbeSpectrum.Pnoise/ProbeSpectrum.NFFT*2./Po.^2),'g'); 
     end
     title('Noise(G), Pyx/Hprobe (In Ear, R), Pyx (Gray), Pyy (Bl)')
     ylabel('SPL (dB)')
     xlabel('Frequency (Hz)')

     
function togglespeaker_Callback(hObject, eventdata, handles)

a = get(handles.togglespeaker, 'Value');
if a
    set(handles.togglespeaker, 'String', 'Speaker 2 (Right)')
else
    set(handles.togglespeaker, 'String', 'Speaker 1 (Left)')
end

%call one of the function buttons that will toggle all the other names and
%shit.


function param1_Callback(hObject, eventdata, handles)


function param1_CreateFcn(hObject, eventdata, handles)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param2_Callback(hObject, eventdata, handles)


function param2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param3_Callback(hObject, eventdata, handles)


function param3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param4_Callback(hObject, eventdata, handles)


function param4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function setparams_Callback(hObject, eventdata, handles)

%Loading Parameters
load 'calibparams.mat'
device = parameters.Device;
load MicrophoneInfo.mat

%Setting parameters.NB,Interface,Device,DeviceNum
prompt = {'Enter Device Type:','Enter Device Number:', 'Enter Interface','Enter Noise Length in Samples','Enter Fs: 0=6k, 1=12k, 2=25k, 3=50k, 4=100k, 5=200k'};   %Edit Jan 2016, MAE to add Fs functionality
dlg_title = 'Input Parameters';
num_lines = 1;
def = {parameters.Device, num2str(parameters.DeviceNum), parameters.Interface, ...
       num2str(parameters.NB),num2str(parameters.FsFlag)};      %Edit Jan 2016, MAE to add Fs functionality
answer = inputdlg(prompt,dlg_title,num_lines,def);
if ~isempty(answer)
    parameters.Device = answer{1}; 
    parameters.DeviceNum = str2num(answer{2}); 
    parameters.Interface = answer{3}; 
    parameters.NB = str2num(answer{4}); 
    parameters.FsFlag = str2num(answer{5});                     %Edit Jan 2016, MAE to add Fs functionality
end

%Selecting the sampling rate
 if parameters.FsFlag==0
        parameters.Fs=6103.515625;
    elseif parameters.FsFlag==1
        parameters.Fs=12207.03125;
    elseif parameters.FsFlag==2
        parameters.Fs=24414.0625;
    elseif parameters.FsFlag==3   
        parameters.Fs=48828.125;
    elseif parameters.FsFlag==4
        parameters.Fs=97656.25;
    elseif parameters.FsFlag==5
        parameters.Fs=195312.5;
 end

%Setting Filtering and Mic Parameters to structure
parameters.f1 = str2num(get(handles.param1, 'String'));
parameters.f2 = str2num(get(handles.param2, 'String'));
parameters.ATT = str2num(get(handles.param3, 'String'));
parameters.L = str2num(get(handles.param4, 'String'));
parameters.MaxSPL = str2num(get(handles.param5, 'String'));
parameters.PA5ATT = str2num(get(handles.param6, 'String'));
parameters.MicSerialNumber = str2num(get(handles.param7, 'String'));
parameters.MicSensitivity = str2num(get(handles.param8, 'String'));
parameters.MicGain = str2num(get(handles.param9, 'String'));
parameters.SpeakerID = get(handles.param10, 'String');

%Setting Parameters in Display
set(handles.param1, 'String', parameters.f1);
set(handles.param2, 'String', parameters.f2);
set(handles.param3, 'String', parameters.ATT);
set(handles.param4, 'String', parameters.L);
set(handles.param5, 'String', parameters.MaxSPL);
set(handles.param6, 'String', parameters.PA5ATT);
set(handles.param7, 'String', num2str([Microphones.SerialNumber]'));
index=get(handles.param7, 'Value');
set(handles.param8, 'String', num2str([Microphones(index).Sensitivity]'));
set(handles.param9, 'String', parameters.MicGain);
set(handles.param10, 'String', parameters.SpeakerID);

%Saving Parameters
MatlabCalibDirectory=which('ProbeCalibrationMenue');
i=findstr(MatlabCalibDirectory,'ProbeCalibrationMenue');
MatlabCalibDirectory=MatlabCalibDirectory(1:i-1);

save([MatlabCalibDirectory 'calibparams'], 'parameters', '-append')

if ~strcmp(parameters.Device, device)
    set(handles.messagebox, 'String', ['Open "SpeakerCAL onlineRX6.rcx" in RPvdsEx. Under the "Interface => Device Setup" menu change "Type" to: ' parameters.Device])
end

function restoredefaults_Callback(hObject, eventdata, handles)

%Setting Parameters
parameters.Device = 'RX6'; 
parameters.DeviceNum = 1; 
parameters.Interface = 'GB';
parameters.NB = 970000;
parameters.Fs = 97656.25;   %Edit Jan 2016,  to add Fs functionality
parameters.FsFlag = 4;      %Edit Jan 2016,  to add Fs functionality

%Load Microphe Info
load MicrophoneInfo.mat

%Setting Filtering and Microphone Parameters
parameters.f1 = 250;
parameters.f2 = 35000;
parameters.ATT = 80;
parameters.L = 395;
parameters.MaxSPL = 100;
parameters.PA5ATT = 30;
parameters.MicSerialNumber = 652315;
parameters.MicSensitivity = 1.3;
parameters.MicGain = 20;
parameters.SpeakerID = 'BeyerA';

%Setting Parameters in Display
set(handles.param1, 'String', parameters.f1);
set(handles.param2, 'String', parameters.f2);
set(handles.param3, 'String', parameters.ATT);
set(handles.param4, 'String', parameters.L);
set(handles.param5, 'String', parameters.MaxSPL);
set(handles.param6, 'String', parameters.PA5ATT);
set(handles.param7, 'String', num2str([Microphones.SerialNumber]'));
set(handles.param7, 'Value',1);
set(handles.param8, 'String', num2str(Microphones(1).Sensitivity));
set(handles.param9, 'String', parameters.MicGain);
set(handles.param10, 'String', parameters.SpeakerID);

%Saving Parameters
MatlabCalibDirectory=which('ProbeCalibrationMenue');
i=findstr(MatlabCalibDirectory,'ProbeCalibrationMenue');
MatlabCalibDirectory=MatlabCalibDirectory(1:i-1);

save([MatlabCalibDirectory 'calibparams'], 'parameters', '-append')


function optionmenu_Callback(hObject, eventdata, handles)


function calibdirectory_Callback(hObject, eventdata, handles)


function calibdirectory_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function figure1_DeleteFcn(hObject, eventdata, handles)

%Saving Paramters when closing ProbeCalibMenue

%Loading Current Parameters
load 'calibparams.mat'

%Setting Filtering and Microphone Parameters
parameters.f1 = 250;
parameters.f2 = 35000;
parameters.ATT = 80;
parameters.L = 395;
parameters.MaxSPL = 100;
parameters.PA5ATT = 30;
MicSerialNumber = str2num(get(handles.param7, 'String'));
index=get(handles.param7, 'Value');
MicSerialNumber=MicSerialNumber(index);
MicSensitivity = str2num(get(handles.param8, 'String'));
parameters.MicGain = 20;

%Saving Parameters
CalibDirectory=which('ProbeCalibrationMenue');
i=findstr(CalibDirectory,'ProbeCalibrationMenue');
CalibDirectory=CalibDirectory(1:i-1);


function param5_Callback(hObject, eventdata, handles)
% hObject    handle to param5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param5 as text
%        str2double(get(hObject,'String')) returns contents of param5 as a double


% --- Executes during object creation, after setting all properties.
function param5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function param6_Callback(hObject, eventdata, handles)
% hObject    handle to param6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param6 as text
%        str2double(get(hObject,'String')) returns contents of param6 as a double


% --- Executes during object creation, after setting all properties.
function param6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in soundtag.
function soundtag_Callback(hObject, eventdata, handles)
% hObject    handle to soundtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns soundtag contents as cell array
%        contents{get(hObject,'Value')} returns selected item from soundtag


% --- Executes during object creation, after setting all properties.
function soundtag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soundtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sound.
function sound_Callback(hObject, eventdata, handles)
% hObject    handle to sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sound





function param9_Callback(hObject, eventdata, handles)
% hObject    handle to param9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param9 as text
%        str2double(get(hObject,'String')) returns contents of param9 as a double


% --- Executes during object creation, after setting all properties.
function param9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








function param8_Callback(hObject, eventdata, handles)
% hObject    handle to param8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param8 as text
%        str2double(get(hObject,'String')) returns contents of param8 as a double


% --- Executes during object creation, after setting all properties.
function param8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on button press in acquireselect.
function acquireselect_Callback(hObject, eventdata, handles)
% hObject    handle to acquireselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acquireselect

a = get(handles.acquireselect, 'Value');
if a
    set(handles.acquireselect, 'String', 'Validation Mode')
    Message=['Validation Mode: applies inverse filter to validate system transfer function.']
    set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])
else
    set(handles.acquireselect, 'String', 'Calibration Mode')
    Message=['Calibration Mode: acquires sound without any inverse filter. Used for measuring system transfer function.']
    set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])
end


% --- Executes on button press in roomnoiseselect.
function roomnoiseselect_Callback(hObject, eventdata, handles)
% hObject    handle to roomnoiseselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of roomnoiseselect

Message=['Room Noise Selector: When depressed will acquire 10 seconds of silence for measuring room noise.']
 set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])    




function param10_Callback(hObject, eventdata, handles)
% hObject    handle to param10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param10 as text
%        str2double(get(hObject,'String')) returns contents of param10 as a double


% --- Executes during object creation, after setting all properties.
function param10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in calibmode1.
function calibmode1_Callback(hObject, eventdata, handles)
% hObject    handle to calibmode1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calibmode1

 %Sending Status Message
 Message=['Calibration 1: This mode is for acquiring measurement data at ear location with no animal in place.']
 set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])    
  


% --- Executes on button press in calibmode2.
function calibmode2_Callback(hObject, eventdata, handles)
% hObject    handle to calibmode2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calibmode2

Message=['Calibration 2: This mode is for acquiring probe measurement data at probe end location with NO animal in place.']
 set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])    
 
 
% --- Executes on button press in calibmode3.
function calibmode3_Callback(hObject, eventdata, handles)
% hObject    handle to calibmode3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calibmode3

Message=['Calibration 3: This mode is for acquiring data at probe end location with the animal in place. DOUBLE CHECK Max SPL!!!']
 set(handles.messagebox,'FontSize',10,'FontWeight','Bold','HorizontalAlignment','left', 'String', [Message])    



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
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




% --- Executes on selection change in param7.
function param7_Callback(hObject, eventdata, handles)
% hObject    handle to param7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns param7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from param7

%Loading Microphone Parameters
load MicrophoneInfo.mat

%Chaning Sensitivity
index=get(handles.param7,'Value')
set(handles.param8, 'String', Microphones(index).Sensitivity);

% --- Executes during object creation, after setting all properties.
function param7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


