% DESCRIPTION   - d'=(Mu-mu(k))/sqrt(Sigma^2+sigma(k)^2) 

function [MTF,MTFD] = mtfdprimgen(RASspet,FMAxis,Flag,stimmod,Onset,num,N)

RAStt.time =[]
RAStt.trial=[]
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('SAMandBurstNoiseLogFMFixedPeriods_param2.mat')
else
    load('SAMOnsetNoise_param2.mat')
end

MTF.Rate = zeros(size(FMAxis));
MTF.Norm = zeros(size(FMAxis));
MTFD.Rate = zeros(size(FMAxis));
MTFD.Norm = zeros(size(FMAxis));

if (Flag==0 | Flag==1)
   for k=1:length(FMAxis)
    if strcmp(stimmod,'cyc')
      TD = num/FMAxis(k);
    else strcmp(stimmod, 'duration')
      TD = num;
   end
    for n=1:N
       temp_r(n)=length(RASspet(n+(k-1)*N).spet)/TD;
       temp_n(n)=temp_r(n)/FMAxis(k);
    end
    MTFD.rvar(k) = var(temp_r);
    MTFD.nvar(k) = var(temp_n);
    MTF.Rate(k)=mean(temp_r);
    MTF.Norm(k) = mean(temp_n);
  end
  
else  % Flag =2 for onset
  for k=1:length(FMAxis)
    TD = 1/FMAxis(k);
    Tresp = max(rasterFM)
    if isempty(Tresp)
        Tresp=TD
    end
    rasterFM = [];  % raster for a specific FM
    for n=1:N
        temp_r(n)=length(RASspet(n+(k-1)*N).spet)/TD;
        temp_n(n)=temp_r(n)/FMAxis(k);
    end 
    MTFD.rvar(k) = var(temp_r);
    MTFD.nvar(k) = var(temp_n);
    MTF.Rate(k)=mean(temp_r);
    MTF.Norm(k) = mean(temp_n); 
  end
end % end of if

i_maxr = find(MTF.Rate==max(MTF.Rate)); i_maxr = i_maxr(1);
i_maxn = find(MTF.Norm==max(MTF.Norm)); i_maxn = i_maxn(1);
MTFD.Rprime = (MTF.Rate-MTF.Rate(i_maxr))./sqrt(MTFD.rvar+MTFD.rvar(i_maxr))
MTFD.Nprime = (MTF.Norm-MTF.Norm(i_maxn))./sqrt(MTFD.nvar+MTFD.nvar(i_maxn))

%****************************
MTF.VS = zeros(size(FMAxis));
MTFD.VS = zeros(size(FMAxis));
for k=1:length(FMAxis)
    Phase = [];
    for n=1:N
        %Extracting Spike Times
        SpikeTime =RASspet(n+(k-1)*N).spet/RASspet(n+(k-1)*N).Fs;
        temp_phase=SpikeTime*FMAxis(k)*2*pi;
        temp_vs(n)=sqrt( (sum(sin(temp_phase))).^2 + (sum(cos(temp_phase))).^2 )/length(temp_phase);
        Phase =[Phase temp_phase];    
    end
    MTFD.vsvar(k) = var(temp_vs);
    MTF.VS(k) = mean(temp_vs);
    
%     %Vector Strength - Golberg & Brown
%      MTF.VS(k)=sqrt( (sum(sin(Phase))).^2 + (sum(cos(Phase))).^2 )/length(Phase);
%     %significance, evaluating by a Rayleigh test (Mardia and Jupp,2000)
%     RS(k) = 2*length(Phase)*((MTF.VS(k)).^2);
end
% sigvs_index = find(RS>13.8);

i_maxvs = find(MTF.VS==max(MTF.VS)); i_maxvs = i_maxvs(1);
for k=1:length(FMAxis)
    if MTF.VS(k)==NaN
        MTFD.VSprime = NaN
    else
        MTFD.VSprime(k) = (MTF.VS(k)-MTF.VS(i_maxvs))./sqrt(MTFD.vsvar(k)+MTFD.vsvar(i_maxvs))
    end
end

figure
subplot(321)
semilogx(FMAxis,MTF.Rate,'.-');
ylabel('spikes/s');
if Flag==0
    title('SAM noise');
elseif Flag==1
    title('PNB');
else
    title('Onset');
end
xlim([1 2000]);
    
subplot(323)
semilogx(FMAxis,MTF.Norm,'.-')
ylabel('spikes/cycle');
xlim([1 2000]);

subplot(325)
semilogx(FMAxis,MTF.VS,'.-');
% semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index),'.-');
xlabel('mod freq (Hz)');
ylabel('vector strength');
axis([1 2000 0 1]);

subplot(322)
semilogx(FMAxis,MTFD.Rprime,'.-g');
subplot(324)
semilogx(FMAxis,MTFD.Nprime,'.-g');
subplot(326)
semilogx(FMAxis,MTFD.VSprime,'.-g');

