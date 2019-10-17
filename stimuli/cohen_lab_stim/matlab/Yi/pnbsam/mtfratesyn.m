% function [MTF]=mtfratesyn(Data,Flag,OnsetC,Unit,N)
%   DESCRIPTION : Generates rate MTF, spet-per-cyc normalized MTF and VS
%   MTF
%   INPUT
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
function [MTF]=mtfratesyn(Data,Flag,OnsetC,Unit,N)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('E:\projects\AM\program\SAMandBurstNoiseLogFMFixedPeriods_param.mat')
else
    load('E:\projects\AM\program\SAMOnsetNoise_param.mat')
end

if nargin<5
    N = length(FM)/length(Fm);   % usually, it is 10
end

if nargin<4
   indexU = 1:length(Data.SortCode);                       %Use all Units
else
   indexU = find(Unit==Data.SortCode);                     %Use specified Unit
end

if nargin<3
    OnsetC = 0;
end

[RASspet, RAStt, FMAxis] = rastergen(Data,Flag,OnsetC,Unit,N)

MTF.FMAxis = FMAxis;
MTF.Rate = zeros(size(FMAxis));
MTF.Spetnorm = zeros(size(FMAxis));

if (Flag==0 | Flag==1)
  for k=1:length(FMAxis)
    for n=1:N
       MTF.Rate(k)=length(RASspet(n+(k-1)*N).spet)+MTF.Rate(k);
    end
    TD = max(Tmin,Nmin./FMAxis(k))-OnsetC/FMAxis(k);
    MTF.Rate(k)=MTF.Rate(k)/TD/N;
  end
  
else
  for k=1:length(FMAxis)
    rasterFM = [];  % raster for a specific FM
    for n=1:N
    tempTime = RAStt.time(find(RAStt.trial==(n+(k-1)*N)));
    rasterTime = tempTime(find(tempTime<1/FMAxis(k)));
    rasterFM = [rasterFM rasterTime];
    end 
    TD = 1/FMAxis(k);
    MTF.Rate(k)=length(rasterFM)/TD/N;
  end
end % end of if

MTF.Spetnorm = MTF.Rate./FMAxis;

MTF.VS = zeros(size(FMAxis));
for k=1:length(FMAxis)
    Phase = [];
    for n=1:N
        %Extracting Spike Times
        SpikeTime =RASspet(n+(k-1)*N).spet/Data.Fs;
        Phase =[Phase SpikeTime*FMAxis(k)*2*pi];    
    end
    
    %Vector Strength - Golberg & Brown
    %MTF.VS(k)=sqrt( sum(sin(Phase)).^2 + sum(cos(Phase)).^2 )/length(Phase);
    MTF.VS(k)=sqrt( (sum(sin(Phase))).^2 + (sum(cos(Phase))).^2 )/length(Phase);
    %significance, evaluating by a Rayleigh test (Mardia and Jupp,2000)
    %revised by Yi Zheng
    RS(k) = 2*length(Phase)*((MTF.VS(k)).^2);
end
sigvs_index = find(RS>13.8);

figure(3)
subplot(311)
semilogx(FMAxis,MTF.Rate);
ylabel('spikes/s');
% title('rateMTF');
subplot(312)
semilogx(FMAxis,MTF.Spetnorm)
ylabel('spikes/cycle');
subplot(313)
% semilogx(MTF.FMAxis,MTF.VS);
% ylabel('vector strength');
% title('vsMTF');
% axis([0 1000 0 1]);
% subplot(3,2,4)
semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index));
axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
% ylabel('significant VS');
ylabel('vector strength');
% title('vsMTF');