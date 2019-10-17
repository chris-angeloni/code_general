% function [RASspet, RAStt, FMAxis] =
% rastergen(Data,Flag,stimmod,Onset,num,Unit,N)
%
%	FILE NAME 	: RASTER GENERATE
%	DESCRIPTION : Generate Raster spet format and time trial format
%
%   Flag        : 0: SAM; 1: PNB; 2: onset
%   stimmod     : 'duration': same stimulus duration; 'cyc':same cycles
%   Onset       : initial cycle or time to be discarded 
%   num         : the number of cycles or duration that want. num=0,take all
%   Unit        : Unit Number, usually 0
%   N           : the number of trials per stimulus that want to take
%
% RETURNED DATA
%   FMAxis      : FM 
%	RASspet	    : compressed spet RASTER format
%                .spet         - spike event time 
%                .Fs:          - sampling rate
%                .T            - response duration 
%   RAStt       : time vs trial RASTER format
%                .time         - spike time
%                .trial        -
%                .N            - repetition
% Yi Zheng, Sep 2006

function [RASspet, RAStt, FMAxis] = rastergen(Data,Flag,stimmod,Onset,num,Unit,N)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('E:\project\AM\program\SAMandBurstNoiseLogFMFixedPeriods_param2.mat')
    % load('SAMandBurstNoiseFM500int50_param.mat');
else
    flag=0;
    load('E:\project\AM\program\SAMOnsetNoise_param2.mat')
end

if nargin<7
    N = length(FM)/length(Fm);   % 
end
RAStt.N = N;

if nargin<4
   indexU = 1:length(Data.SortCode);                       %Use all Units
else
   indexU = find(Unit==Data.SortCode);                     %Use specified Unit
end
spet = round(Data.SnipTimeStamp(indexU)*Data.Fs);          %Converint to SPET
Trigall = round(Data.Trig*Data.Fs);                          %Syncrhonization Triggers
Trigall = [Trigall Trigall(length(Trigall))+mean(diff(Trigall))];        %Adding End Trigger

if nargin<3
    OnsetC = 0;
end

if Flag == 2   % onset of just include one type of stimulus
    Trig = Trigall;
    FMAxis = Fm;
else   % Flag = 0 or 1 to seperate two type of stimulus (ex. PNB and SAM)
   FMAxis = Fm(1:length(Fm)/2);
   Trig = Trigall(find(flag==Flag));
   Trig = [Trig Trig(length(Trig))+mean(diff(Trig))];       
end  % end of if

for k=1:length(FMAxis);
    indexFM = find(FM == FMAxis(k));
    if  (Flag == 0 | Flag ==1)  % if there are two types of stim, seperate them   
        fg = flag(indexFM);
        indexFM = indexFM(find(fg==Flag));  
    end
    for n=1:N
        indexSPET = find(spet<Trigall(indexFM(n)+1) & spet>Trigall(indexFM(n)));
        RASspet(n+(k-1)*N).spet = round( (spet(indexSPET)-Trigall(indexFM(n))) );
        RASspet(n+(k-1)*N).Fs = Data.Fs;  
    end
end

% remove the initial onset response and take the num
for k=1:length(FMAxis)
for n=1:N
 if strcmp(stimmod,'cyc')  
  % if (num == 0 | Flag==2)
  if Flag==2
    index = find(RASspet((k-1)*N+n).spet> Onset/FMAxis(k)*RASspet((k-1)*N+n).Fs);
    RASspet(n+(k-1)*N).T = 1/FMAxis(k);  % ONSET, just take 1 cycle
  else 
   if (Flag == 0 | Flag ==1)  
     index = find(RASspet((k-1)*N+n).spet> Onset/FMAxis(k)*RASspet((k-1)*N+n).Fs & RASspet((k-1)*N+n).spet< (Onset+num)/FMAxis(k)*RASspet((k-1)*N+n).Fs );
     RASspet(n+(k-1)*N).T = num/FMAxis(k);  
   end
  end 

 else strcmp(stimmod, 'duration')
  index = find(RASspet((k-1)*N+n).spet> Onset*RASspet((k-1)*N+n).Fs & RASspet((k-1)*N+n).spet< (Onset+num)*RASspet((k-1)*N+n).Fs );
  RASspet(n+(k-1)*N).T = num;  
 end % end of stimmod
 RASspet((k-1)*N+n).spet = RASspet((k-1)*N+n).spet(index);
end % end of n
end  % end of k



% time vs trial raster 
RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end

    Timebound = [];
    for k=1:length(FMAxis)
      Timebound = [Timebound 1/FMAxis(k)*ones(1,N)];
    end

figure;
if Flag ==0
    %plot(RAStt.time,RAStt.trial,'b.')
  plot(RAStt.time,RAStt.trial,'k.',Timebound,1:length(FMAxis)*N,'r');
  title('Raster (SAM noise)');
elseif Flag ==1
    %plot(RAStt.time,RAStt.trial,'b.')
  plot(RAStt.time,RAStt.trial,'k.',Timebound,1:length(FMAxis)*N,'r');
  title('Raster (PNB)');
else
  plot(RAStt.time,RAStt.trial,'k.',Timebound,1:length(FMAxis)*N,'r');
  % plot(RAStt.time,RAStt.trial,'r.')
  title('Raster (Onset SAM)');  
end
xlabel('Time (s)');
ylabel('Trial Number');
