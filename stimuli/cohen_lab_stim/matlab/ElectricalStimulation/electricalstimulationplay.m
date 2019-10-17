%
%function []=electricalstimulationplay(S,Fs,ControlMode)
%
%       FILE NAME       : ELECTRICAL STIMULATION PLAY
%       DESCRIPTION     : Delivers a spatio temporal electrical stimulation pattern
%                         across N channels. Signal duration should be an
%                         intergeter multiple of 524288 samples.
%
%       S               : Electrical stimulation signal (NXM, where N is
%                         the number of channels. The signal needs to be
%                         normalized to the correct units so that the
%                         desired maximum current amplitude is provided.
%                         All currents are in units of micro Amps.
%       Fs              : Sampling rate
%       ControlMode     : Feedback control mode for stimulation
%                         (Optioonal, 1=on and 0=off; Defaul=0)
%
% (C) Monty A. Escabi, July 2011
%
function []=electricalstimulationplay(S,Fs,ControlMode)

%Input Args
if nargin<3
    ControlMode=0;
end

%Buffer size
NB=524288;      %Buffer size
N=NB/2;         %Half the buffer size
M=size(S,2);    %signal length, S
L=M/NB;         %Number of buffer segments

%Open A Dummy Figure
figure, set(gcf,'visible','off');
DA = actxcontrol('TDevAcc.X');
DA.ConnectServer('Local');
if DA.CheckServerConnection==0
    clc
    display('Client application not connect to server')
else
    clc
    display('Client application connected to server')
end

%Initialize
DA.SetTargetVal('Amp1.ControlMode',ControlMode);

for k=1:L
    
    %Loading 16 channel stimulation pattern into first half of buffer
    for l=1:16  
        %Writing input to each channel
        ChannelString=['Amp1.InChan' int2str(l)];
        index1=(1:N)+NB*(k-1);
        DA.WriteTargetVEX(ChannelString,0,'F32',S(l,index1));
    end
    display('Stimulation pattern loaded to buffer.')
   
    %Begin playing the buffer
    if k==1
       DA.SetTargetVal('Amp1.RWEnable',1); 
       tic
       display('Begin Stimulus Delivery')
    end
    
    %Checking for buffer index position
    if k>1
        %Checking for buffer index position
        index=DA.GetTargetVal('Amp1.Index16');
        while (index<NB & index>N+1)
            index=DA.GetTargetVal('Amp1.Index16');
        end
        
        time=toc;
        display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
    end
    
    %Loading 16 channel stimulation pattern into second half of buffer
    for l=1:16  
        %Writing input to each channel
        ChannelString=['Amp1.InChan' int2str(l)];
        index2=(1:N)+N+NB*(k-1);
        DA.WriteTargetVEX(ChannelString,N,'F32',S(l,index2));
    end
    display('Stimulation pattern loaded to buffer.')
    
    %Checking for buffer index position
    index=DA.GetTargetVal('Amp1.Index16');
    while (index<N & index>0)
            index=DA.GetTargetVal('Amp1.Index16');
    end
    
    time=toc;
    display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
   
end

%Delivering Last Block
index=DA.GetTargetVal('Amp1.Index16');
while (index<NB & index>N+1)
        index=DA.GetTargetVal('Amp1.Index16');
end
time=toc;
display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
        

%Stop Delivery
DA.SetTargetVal('Amp1.RWEnable',0);

% 
% 
% DA.GetTargetVal('Amp1.Index16')
% 
% 
% 
% %Set system to Preview mode (0=idle; 1=standby; 2=preview; 3=record)
% Mode=DA.GetSysMode;
% DA.SetSysMode(2);
% 
% 
