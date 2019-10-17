%
%function [Data]=calibacquire(MicGain,NB,Interface,Device,DeviceNum,SoundSelect,AcquireSelect,ChirpGain,MicSensitivity,MicSerialNumber,FsFlag)
% 	
%   FILE NAME   : CALIB ACQUIRE
% 	DESCRIPTION : Acquires input-output data for TDT Calibration.
%
%   MicGain         : Microphone Amplifier Gain (dB) (Default=40)
%   NB              : Number of white noise samples for measurement (Default,
%                     NB=970000, i.e. 10 sec at 97kHz)
%   Interface       : TDT Interface (Default, Interface='GB')
%   Device          : TDT Device for acquiring calibration data ('RX6' or
%                     'RP2'; Default, 'RX6')
%   DeviceNum       : Device Number - Designated in zBUSMon (Default,
%                     DeviceNum=1)
%   SoundSelect     : Noise type selector
%                     Noise Select == 0 for white noise (Default)
%                     Noise Select == 1 for f-Noise
%                     Noise Select == 2 Ripple noise
%                     Noise Select == 3 Linear chirp
%                     Noise Select == 4 Log chirp
%   AcquireSelect   : Selects between calibration mode (direct input) and
%                     validation mode (uses FIR filter to calibrate input).
%                     0 = calibration mode
%                     1 = validation mode
%                     (Default == 0)
%   ChirpGain       : Preemphasis highpass gain for chirp sound. Increasis
%                     the signal gain in dB with time to achieve an overall 
%                     gain of ChirpGain (dB, Default: ChirpGain=0 dB)
%   MicSensitivity  : Microphone sensititivity from data sheet (mV/Pa)
%                     Note:  1 Pa = 1 N/m^2
%                            1 Pa = 10 micro bar
%                     (Default, MicSensitivity=1.3)
%   MicSerialNumber : Serial number from data sheet (Default, MicSerialNumber='None')
%   FsFlag          : Select sampling rate (Default == 4)
%
%                      0 = 6103.515625  (6k)
%                      1 = 12207.03125  (12k)
%                      2 = 24414.0625   (25k)
%                      3 = 48828.125    (50k)
%                      4 = 97656.25     (100k)
%                      5 = 195312.5     (200k)
%RETURNED VARIABLES
%
%   Data        : Data structure containing calibration data
%                 .X                - Input white noise signal
%                 .Y                - Recorded speaker output signal
%                 .Fs               - sampling rate (Hz)
%                 .MicGain          - B&K Amplifier Gain (dB)
%                 .SPL              - RMS SPL (dB re 2.2E-5 Pa)
%                 .SPLmax           - Maximum SPL (dB re 2.2E-5 Pa)
%                 .MicSerialNumber  - Serial number from spec sheet
%                 .DateTime         - Date and time that data was acuired 
%                                     (see 'clock' command for format)

% (C) Monty A. Escabi, November 2007 (Edit Aug 2010)
%                        Ahmad Osman (Edit Jan 2016) RCO Fs functionality & Default Input Values
function [Data]=calibacquire(MicGain,NB,Interface,Device,DeviceNum,SoundSelect,AcquireSelect,ChirpGain,MicSensitivity,MicSerialNumber,FsFlag)

%Input Arguments
if nargin<1 | isempty(MicGain)
    MicGain=40;
end
if nargin<2 | isempty(NB)
    NB=970000;
end
if nargin<3 | isempty(Interface)
    Interface='GB';
end
if nargin<4 | isempty(Device)
    Device='RX6';
end
if nargin<5 | isempty(DeviceNum)
    DeviceNum=1;
end
if nargin<6 | isempty(SoundSelect)
    SoundSelect=0;
end
if nargin<7 | isempty(AcquireSelect)
    AcquireSelect=0;
end
if nargin<8 | isempty(ChirpGain)
    ChirpGain=0;
end
if nargin<9 | isempty(NB) %Edit Jan 2016, AO
    MicSensitivity=1.3;
end
if nargin<10 | isempty(NB) %Edit Jan 2016, AO
    MicSerialNumber='None';
end
if nargin<11 | isempty(NB) %Edit Jan 2016, AO
   Fs= 97656.25;
    FsFlag=4;
else                        %Select Sampling Rate
    if FsFlag==0
        Fs=6103.515625;
    elseif FsFlag==1
        Fs=12207.03125;
    elseif FsFlag==2
        Fs=24414.0625;
    elseif FsFlag==3   
        Fs=48828.125;
    elseif FsFlag==4
        Fs=97656.25;
    elseif FsFlag==5
        Fs=195312.5;
    end
end

%Path For TDT Circuit
CircuitPath=which('calibacquire');
i=strfind(CircuitPath,'calibacquire.m');
if strcmp(Device,'RX6')
    CircuitPath = [CircuitPath(1:i-2) '\speakerCAL_onlineRX6.rcx'];
else
    CircuitPath = [CircuitPath(1:i-2) '\speakerCAL_onlineRP2.rcx'];
end

%Loading Calibration Noise
if SoundSelect==0
    randn('state',0);
    X=randn(1,NB);
    %X=(rand(1,NB)-.5)*2*8;
elseif SoundSelect==1
    load CalibNoise1f.mat
    X=X(1:NB);
elseif SoundSelect==2
    load MovingRipple.mat
    X=X(1:NB);
elseif SoundSelect==3
    
    L=floor(.5*Fs);
    X=zeros(1,NB);  %The chirp has ~ 0.5 sec of zeros at the beginning and end
    [X(L+1:NB-L)]=chirpwindowed(0,Fs/2,NB-2*L,Fs,8,10,'lin',ChirpGain);  %We cover the whole range - 0 to Fs/2
    if ChirpGain==0
        X=X*sqrt(2);  %Unit variance, note that variance of chirp is A^2/2
    else
        X=X/max(abs(X))*8;  %8 Volts PP
    end
elseif SoundSelect==4
    Fs=97656.25;
    L=floor(.5*Fs);
    X=zeros(1,NB);  %The chirp has ~ 0.5 sec of zeros at the beginning and end
    [X(L+1:NB-L)]=chirpwindowed(50,Fs/2,NB-2*L,Fs,8,10,'log',ChirpGain);  %We cover almost the whole range - 50 to Fs/2
    if ChirpGain==0
        X=X*sqrt(2);  %Unit variance, note that variance of chirp is A^2/2
    else
        X=X/max(abs(X))*8;  %8 Volts PP
    end
end

%Open A Dummy Figure
figure, set(gcf,'visible','off');

%Acquisition 
RP=actxcontrol('RPco.x');

invoke(RP,'ClearCOF'); %Clears all the Buffers and circuits on that RP2

invoke(RP,['Connect' Device],Interface,DeviceNum); %Connects the desired Device via the desired Interface given the proper device number

RP.LoadCOFsf(CircuitPath,Fs); %Edit Jan 2016, AO
%invoke(RP,'LoadCOF',CircuitPath); % Loads circuit'
invoke(RP,'Run'); %Starts Circuit'

%Selecting between calibration and validation mode
invoke(RP, 'WriteTagV','AcquireSelect',0,AcquireSelect*ones(1,NB));

%Writing Noise to RP device
invoke(RP, 'WriteTagV','Noise',0,X); 

%Error Checking
Status=double(invoke(RP,'GetStatus'));%converts value to bin'
if bitget(Status,1)==0;%checks for errors in starting circuit'
   disp(['Error connecting to ' Device ])
elseif bitget(Status,2)==0; %checks for connection'
   disp('Error loading circuit')
elseif bitget(Status,3)==0
   disp('Error running circuit')
else  
   disp('Circuit loaded and running')
end

%Checking Number of Samples Read
curindex=invoke(RP, 'GetTagVal', 'index');
while(curindex<NB-1) 
    curindex=invoke(RP, 'GetTagVal', 'index');
end
curindex=invoke(RP, 'GetTagVal', 'index');

%Reading Input and Output Calibration Data
Data.X=invoke(RP, 'ReadTagV', 'input', 0,NB);
Data.Y=invoke(RP, 'ReadTagV', 'output', 0,NB);
Data.Fs = double(invoke(RP,'GetSfreq'));
%Data.Fs=invoke(RP, 'ReadTagV', 'SR', 0,NB);

%Computing RMS SPL
Gain=10^(MicGain/20);               %Microphone Amplifier Gain
Sensitivity=MicSensitivity/1000;    %Volts/Pascals
Po=2.2E-5;                          %Threshold of hearing in Pascals
Data.SPL=20*log10(std(Data.Y(10000:NB))/Gain/Sensitivity/Po);
Data.SPLmax=20*log10(max(abs(Data.Y(10000:NB)-mean(Data.Y(10000:NB))))/Gain/Sensitivity/Po); 

%Microphone Parmaters
Data.MicGain=MicGain;
Data.MicSensitivity=MicSensitivity;
Data.MicSerialNumber=MicSerialNumber;

%Adding Date and Time Fields
Data.DateTime=fix(clock);

%Closing Devices
%invoke(TTX,'ReleaseServer');
invoke(RP,'Halt');
disp('Done Reading Input and Output Data')

%Closing Dummy Figure
close