% function [MTF] = mtfrtgenerate(RASspet,RAStt,FMAxis,Flag,OnsetC,numC,N)
%   DESCRIPTION : Generates rate MTF, spet-per-cyc normalized MTF and VS
%   MTF from raster 
%   INPUT
%   RASspet     : raster of spet format
%   RAStt       : raster of time vs trial format 
%   Flag        : 0 for SAM; 1 for PNB; 2 for onset
%   N           : the number of trials per stimulus
%   OnsetC      : Cycle to remove at onset 
%   Unit        : Unit Number

% RETURNED DATA
%
%	MTF	        : MTF Data Structure
%                 .FMAxis
%                 .Rate              - Rate MTF
%                 .VS                  - Vector Strength MTF
%                 .Spetnorm          - spikes/cycle vurse mod freq


function [MTF] = mtfrtgenerate(RASspet,RAStt,FMAxis,Flag,OnsetC,numC,N)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('SAMandBurstNoiseLogFMFixedPeriods_param2.mat')
else
    load('SAMOnsetNoise_param2.mat')
end

MTF.FMAxis = FMAxis;
MTF.Rate = zeros(size(FMAxis));
MTF.Spetnorm = zeros(size(FMAxis));

if (Flag==0 | Flag==1)
  for k=1:length(FMAxis)
    for n=1:N
       MTF.Rate(k)=length(RASspet(n+(k-1)*N).spet)+MTF.Rate(k);
    end
    if numC == 0
      TD = max(Tmin,Nmin./FMAxis(k))-OnsetC/FMAxis(k);
    else 
      TD = numC/FMAxis(k);
    end
    MTF.Rate(k)=MTF.Rate(k)/TD/N;
    MTF.Spetnorm(k) = MTF.Rate(k)/MTF.FMAxis(k);
  end
  
else  % Flag =2 for onset
  for k=1:length(FMAxis)
    rasterFM = [];  % raster for a specific FM
    for n=1:N
    tempTime = RAStt.time(find(RAStt.trial==(n+(k-1)*N)));
    % rasterTime = tempTime(find(tempTime<1/FMAxis(k))); % remove off-response
    rasterTime = tempTime;
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

figure(3)
subplot(311)
semilogx(FMAxis,MTF.Rate);
ylabel('spikes/s');
if Flag==0
    title('SAM noise');
elseif Flag==1
    title('PNB');
else
    title('Onset');
end
    
subplot(312)
semilogx(FMAxis,MTF.Spetnorm)
ylabel('spikes/cycle');

subplot(313)
% semilogx(MTF.FMAxis,MTF.VS);
semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index));
axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
ylabel('vector strength');

