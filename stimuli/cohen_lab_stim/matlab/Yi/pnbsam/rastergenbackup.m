% function [RASspet, RAStt, FMAxis] = rastergen(Data,Flag,OnsetC,numC,Unit,N)
%
%	FILE NAME 	: RASTER GENERATE
%	DESCRIPTION : Generate Raster spet format and time trial format
%
%   Flag        : 0 for SAM; 1 for PNB; 2 for onset
%   N           : the number of trials per stimulus 
%   OnsetC      : Cycle to remove at onset 
%   numC        : the number of cycles that want. numC=0,take all
%   Unit        : Unit Number
%
% RETURNED DATA
%   FMAxis      : FM 
%	RASspet	    : compressed spet RASTER format
%                .spet         - spike event time 
%                .Fs:          - sampling rate
%   RAStt       : time vs trial RASTER format
%                .time         - spike time
%                .trial        -
%                .N            - repetition
% Yi Zheng, Sep 2006

function [RASspet, RAStt, FMAxis] = rastergen(Data,Flag,OnsetC,numC,Unit,N)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('SAMandBurstNoiseLogFMFixedPeriods_param2.mat')
else
    flag=0;
    load('SAMOnsetNoise_param2.mat')
end

if nargin<5
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

% remove the cycles at the onset and take the numC
for k=1:length(FMAxis)
for n=1:N
  if (numC == 0 | Flag==2)
    index = find(RASspet((k-1)*N+n).spet> OnsetC/FMAxis(k)*RASspet((k-1)*N+n).Fs);
  else 
   if (Flag == 0 | Flag ==1)  
     index = find(RASspet((k-1)*N+n).spet> OnsetC/FMAxis(k)*RASspet((k-1)*N+n).Fs & RASspet((k-1)*N+n).spet< (OnsetC+numC)/FMAxis(k)*RASspet((k-1)*N+n).Fs );
    end
  end 
  RASspet((k-1)*N+n).spet = RASspet((k-1)*N+n).spet(index);
end
end  % end of k

% time vs trial raster 
RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end

if Flag == 2
    Timebound = [];
    Trialbound =[];
    for k=1:length(FMAxis)
      Timebound = [Timebound 1/FMAxis(k)*ones(1,N)];
    end
end

figure(2);
if Flag ==0
  plot(RAStt.time,RAStt.trial,'r.');
  title('Raster (SAM noise)');
elseif Flag ==1
  plot(RAStt.time,RAStt.trial,'r.');
  title('Raster (PNB)');
else
  plot(RAStt.time,RAStt.trial,'r.',Timebound,1:length(FM),'b');
  % plot(RAStt.time,RAStt.trial,'r.')
  title('Raster (Onset SAM)');  
end
xlabel('Time (s)');
ylabel('Trial Number');
