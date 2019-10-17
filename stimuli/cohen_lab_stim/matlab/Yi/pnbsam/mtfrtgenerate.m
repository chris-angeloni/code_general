% function [MTF] = mtfrtgenerate(RASspet,FMAxis,Flag,stimmod,Onset,num,N)

%   DESCRIPTION : Generates rate MTF, spet-per-cyc normalized MTF and VS
%   MTF from RASspet (Onset has been removed) 
%   INPUT
%   RASspet     : raster of spet format
%   Flag        : 0 for SAM; 1 for PNB; 2 for onset
%   stimmod     : 'duration': based on same stim dur; 'cyc': based on same
%                 cycles
%   Onset       : Cycle to remove at onset 
%   num         : duration time or number of cycles
%   N           : the number of trials per stimulus

% RETURNED DATA
%
%	MTF	        : MTF Data Structure
%                 .FMAxis
%                 .Rate              - Rate MTF
%                 .VS                - Vector Strength MTF
%                 .VSsig
%                 .Spetnorm          - spikes/cycle vurse mod freq


function [MTF] = mtfrtgenerate(RASspet,FMAxis,Flag,stimmod,Onset,num,N)

RAStt.time =[];
RAStt.trial=[];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

% if (Flag == 0 | Flag ==1)
%     flag=0;   % clear flag before load param because param include 'flag' variable
%     % load('SAMandBurstNoiseLogFMFixedPeriods_param2.mat');
%     load('SAMandBurstNoiseFM500int50_param.mat');
% else
%     load('SAMOnsetNoise_param2.mat')
% end

MTF.FMAxis = FMAxis;
MTF.Rate = zeros(size(FMAxis));
MTF.Spetnorm = zeros(size(FMAxis));

if (Flag==0 | Flag==1)
  for k=1:length(FMAxis)
    for n=1:N
       MTF.Rate(k)=length(RASspet(n+(k-1)*N).spet)+MTF.Rate(k);
    end
    if num == 0
      TD = max(Tmin,Nmin./FMAxis(k))-Onset/FMAxis(k);
    elseif strcmp(stimmod,'cyc')
      TD = num/FMAxis(k);
    else strcmp(stimmod, 'duration')
      TD = num;
    end
    MTF.Rate(k)=MTF.Rate(k)/TD/N;
    MTF.Spetnorm(k) = MTF.Rate(k)/MTF.FMAxis(k);
  end
  
else  % Flag =2 for onset
  for k=1:length(FMAxis)
    rasterFM = [];  % raster for a specific FM
    for n=1:N
    tempTime = RAStt.time(find(RAStt.trial==(n+(k-1)*N)));
    rasterTime = tempTime(find(tempTime<1/FMAxis(k))); % remove off-response
    rasterTime = tempTime;  % don't remove off-response
    rasterFM = [rasterFM rasterTime];
    end 
    TD = 1/FMAxis(k);
    Tresp = max(rasterFM)
    if isempty(Tresp)
        Tresp=TD
    end
    MTF.Rate(k)=length(rasterFM)/TD/N;
    MTF.Spetnorm(k) = length(rasterFM)/N;
  end
end % end of if

MTF.VS = zeros(size(FMAxis));
for k=1:length(FMAxis)
    Phase = [];
    for n=1:N
        %Extracting Spike Times
        SpikeTime =RASspet(n+(k-1)*N).spet/RASspet(n+(k-1)*N).Fs;
        Phase =[Phase SpikeTime*FMAxis(k)*2*pi];    
    end
    
    %Vector Strength - Golberg & Brown
    %MTF.VS(k)=sqrt( sum(sin(Phase)).^2 + sum(cos(Phase)).^2 )/length(Phase);
    MTF.VS(k)=sqrt( (sum(sin(Phase))).^2 + (sum(cos(Phase))).^2 )/length(Phase);
    %significance, evaluating by a Rayleigh test (Mardia and Jupp,2000)
    RS(k) = 2*length(Phase)*((MTF.VS(k)).^2);
end
sigvs_index = find(RS>13.8);
MTF.VSsig = nan(length(FMAxis),1)
MTF.VSsig(sigvs_index) = MTF.VS(sigvs_index);

RthrM = 0.5*max(MTF.Rate); RthrP = 0.707*max(MTF.Rate);
NthrM = 0.5*max(MTF.Spetnorm); NthrP = 0.707*max(MTF.Spetnorm);
VSthrM = 0.5*max(MTF.VS); VSthrP = 0.707*max(MTF.VS);

figure
subplot(311)
semilogx(FMAxis,MTF.Rate,'.-',FMAxis,RthrM*ones(1,length(FMAxis)),'r',FMAxis,RthrP*ones(1,length(FMAxis)),'r');
ylabel('spikes/s');
if Flag==0
    title('SAM noise');
elseif Flag==1
    title('PNB');
else
    title('Onset');
end
xlim([1 2000]);
    
subplot(312)
semilogx(FMAxis,MTF.Spetnorm,'.-',FMAxis,NthrM*ones(1,length(FMAxis)),'r',FMAxis,NthrP*ones(1,length(FMAxis)),'r')
ylabel('spikes/cycle');
xlim([1 2000]);

subplot(313)
% semilogx(MTF.FMAxis,MTF.VS);
semilogx(FMAxis,MTF.VS,'g.')
hold on
semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index),'.-',FMAxis,VSthrM*ones(1,length(FMAxis)),'r',FMAxis,VSthrP*ones(1,length(FMAxis)),'r');

% axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
ylabel('vector strength');
axis([1 2000 0 1]);

