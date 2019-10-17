%
%function [ProbeData]=calibacquireprobe(MicGain,PA5ATT,NB,Interface,Device,DeviceNum,SoundSelect,ChirpGain,AcquireSelect,SpeakerSelect,ProbeSelect,RoomNoiseSelect,MicSensitivity,MicSerialNumber,SpeakerID,FilePath,FsFlag)
% 	
%   FILE NAME   : CALIB ACQUIRE PROBE
% 	DESCRIPTION : Acquires input-output data for TDT Calibration.
%
%   MicGain         : Microphone Amplifier Gain (dB) (Default=40)
%   PA5ATT          : PA5 Attenuation Setting (dB). PA5 channel is selected by
%                     SpeakerSelect (Default==40 dB, for safety).
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
%   ChirpGain       : Preemphasis highpass gain for chirp sound. Increasis
%                     the signal gain in dB with time to achieve an overall 
%                     gain of ChirpGain (dB, Default: ChirpGain=0 dB)
%   AcquireSelect   : Selects between calibration mode (direct input) and
%                     validation mode (uses FIR filter to calibrate input).
%                     0 = calibration mode
%                     1 = validation mode
%                     (Default == 0)
%   SpeakerSelect   : Selects speaker channels
%                     1 = Spekaer channel 1 (TDT 1)
%                     2 = Speaker channel 2 (TDT 2)
%                     (Default == 1)
%   ProbeSelect      : Probe position selector
%                      1 - at ear location, no animal
%                          (typically use 1/8" microphone)
%                      2 - at probe location, no animal
%                          (typically use 1/2" microphone)
%                      3 - at probe location with animal in place 
%                          (typically use 1/2" microphone)
%                     (Default, ProbeSelect=1)
%   RoomNoiseSelect : Acquire room background noise level ('y' or 'n') (Default, RoomNoiseSelect='y')
%  MicSensitivity  : Microphone sensititivity from data sheet (mV/Pa)
%                     Note:  1 Pa = 1 N/m^2
%                            1 Pa = 10 micro bar
%                     (Default, MicSensitivity=1.3)
%   MicSerialNumber : Serial number from data sheet (Default, MicSerialNumber='None')
%   SpeakerID       : String for speaker identifier. (Default, SpeakerID ='None')
%   FilePath        : Path for storing data. Need to provide full
%                     path. Optional, does not save data if not provided. 
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
%                 .YRoomNoise       - Recorded room noise, no input
%                                     (optional)
%                 .Fs               - sampling rate (Hz)
%                 .MicGain          - B&K Amplifier Gain (dB)
%                 .PA5ATT           - PA5 Attenuition Setting (dB)
%                 .SPL              - RMS SPL (dB re 2.2E-5 Pa)
%                 .SPLmax           - Maximum SPL (dB re 2.2E-5 Pa)
%                 .MicSerialNumber  - Serial number from spec sheet
%                 .DateTime         - Date and time that data was acuired 
%                                     (see 'clock' command for format)
%
% (C) Monty A. Escabi, November 2007 (Edit Aug 2010)
%                        Ahmad Osman (Edit Jan 2016) RCO Fs functionality & Default Input Values
function [ProbeData]=calibacquireprobe(MicGain,PA5ATT,NB,Interface,Device,DeviceNum,SoundSelect,ChirpGain,AcquireSelect,SpeakerSelect,ProbeSelect,RoomNoiseSelect,MicSensitivity,MicSerialNumber,SpeakerID,FilePath,FsFlag)

%Input Arguments
if nargin<1 | isempty(MicGain)
    MicGain=40;
end
if nargin<2 | isempty(PA5ATT)
    PA5ATT=40;
end
if nargin<3 | isempty(NB)
    NB=970000;
end
if nargin<4 | isempty(Interface)
    Interface='GB';
end
if nargin<5 | isempty(Device)
    Device='RX6';
end
if nargin<6 | isempty(DeviceNum)
    DeviceNum=1;
end
if nargin<7 | isempty(SoundSelect)
    SoundSelect=0;
end
if nargin<8 | isempty(ChirpGain)
    ChirpGain=0;
end
if nargin<9 | isempty(AcquireSelect)
    AcquireSelect=0;
end
if nargin<10 | isempty(SpeakerSelect)
    SpeakerSelect=1;
end
if nargin<11 | isempty(NB) %Edit Jan 2016, AO
    ProbeSelect=1;
end
if nargin<12 | isempty(NB) %Edit Jan 2016, AO
    RoomNoiseSelect='y';
end
if nargin<13 | isempty(NB) %Edit Jan 2016, AO
    MicSensitivity=1.3;
end
if nargin<14 | isempty(NB) %Edit Jan 2016, AO
    MicSerialNumber='None';
end
if nargin<15 | isempty(NB) %Edit Jan 2016, AO
    SpeakerID='None';
end
if nargin<16 | isempty(NB) %Edit Jan 2016, AO
    %No need to provide filepath
end
if nargin<17 | isempty(NB) %Edit Jan 2016, AO
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

%Acquiring Data
[ProbeData]=calibacquire2chan(MicGain,PA5ATT,NB,Interface,Device,DeviceNum,SoundSelect,AcquireSelect,SpeakerSelect,ChirpGain,MicSensitivity,MicSerialNumber,FsFlag);
ProbeData.ProbeSelect=ProbeSelect;
ProbeData.SpeakerID=SpeakerID;

%Acquire Bacground Noise if Desired
if strcmp(RoomNoiseSelect,'y')
    [RoomNoiseData]=calibacquiredirectinput(zeros(1,NB),MicGain,PA5ATT,NB,Interface,Device,DeviceNum,0,SpeakerSelect,MicSensitivity,MicSerialNumber,FsFlag);
    ProbeData.YRoomNoise=RoomNoiseData.Y;
    ProbeData=orderfields(ProbeData,[1 2 13 3:12]);
end

%Saving Data to file if desired
if exist('FilePath')
    switch ProbeSelect
        case 1
            ProbeData1=ProbeData;
            save([FilePath 'ProbeDataPos' num2str(ProbeSelect) SpeakerID num2str(SpeakerSelect) '.mat'],'ProbeData1');
        case 2
            ProbeData2=ProbeData;
            save([FilePath 'ProbeDataPos' num2str(ProbeSelect) SpeakerID num2str(SpeakerSelect) '.mat'],'ProbeData2');
        case 3
            ProbeData3=ProbeData;
            save([FilePath 'ProbeDataPos' num2str(ProbeSelect) SpeakerID num2str(SpeakerSelect) '.mat'],'ProbeData3');
    end
end