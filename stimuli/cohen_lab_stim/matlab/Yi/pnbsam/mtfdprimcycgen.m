% DESCRIPTION   - d' obtained across cych
% d'=(Mu-mu(k))/sqrt(Sigma^2+sigma(k)^2) 
                

function [MTF,MTFD] = mtfdprimcycgen(RASspet,FMAxis,Flag,stimmod,Onset,num,N)

RAStt.time =[]
RAStt.trial=[]
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('SAMandBurstNoiseLogFMFixedPeriods_param.mat')
else
    load('SAMOnsetNoise_param.mat')
end

MTF.Rate = zeros(size(FMAxis));
MTF.Norm = zeros(size(FMAxis));
MTFD.Rate = zeros(size(FMAxis));
MTFD.Norm = zeros(size(FMAxis));
MTF.VS = zeros(size(FMAxis));
MTFD.VS = zeros(size(FMAxis));

for k=1:length(FMAxis)
    TD = 1/FMAxis(k);
    if strcmp(stimmod, 'duration')
      numC = floor(num/TD);
      start_t = Onset;
    else strcmp(stimmod, 'cyc')
      numC = num;
      start_t = Onset*TD;
    end
    
    for n=1:N 
        time_trial=RASspet(n+(k-1)*N).spet/RASspet(n+(k-1)*N).Fs; 
       % various rate and normalized rate
       for c=1:numC
         temp_i=find(time_trial>start_t+(c-1)*TD & time_trial<=start_t+c*TD);
         temp_p = time_trial(temp_i)*FMAxis(k)*2*pi;
         temp_r(numC*(n-1)+c)=length(temp_i)/TD;
         temp_n(numC*(n-1)+c)=length(temp_i);
         if isempty(temp_p)
          temp_vs(numC*(n-1)+c)=0;
         else
          temp_vs(numC*(n-1)+c)=sqrt( (sum(sin(temp_p))).^2 + (sum(cos(temp_p))).^2 )/length(temp_p);
         end
       end  %end of c 
    end  % end of n
    MTFD.rvar(k) = var(temp_r);
    MTFD.nvar(k) = var(temp_n);
    MTFD.vsvar(k) = var(temp_vs(find(temp_vs>0)));
    MTF.Rate(k)=mean(temp_r);
    MTF.Norm(k) = mean(temp_n);
    MTF.VS(k) = mean(temp_vs(find(temp_vs>0)));
%     RS(k) = 2*length(Phase)*((MTF.VS(k)).^2);
%     sigvs_index = find(RS>13.8);
end  % end of k

i_maxr = find(MTF.Rate==max(MTF.Rate)); i_maxr = i_maxr(1);
i_maxn = find(MTF.Norm==max(MTF.Norm)); i_maxn = i_maxn(1);
i_maxvs = find(MTF.VS==max(MTF.VS)); i_maxvs = i_maxvs(1);
MTFD.Rprime = (MTF.Rate-MTF.Rate(i_maxr))./sqrt(MTFD.rvar+MTFD.rvar(i_maxr))
MTFD.Nprime = (MTF.Norm-MTF.Norm(i_maxn))./sqrt(MTFD.nvar+MTFD.nvar(i_maxn))
MTFD.VSprime = (MTF.VS-MTF.VS(i_maxvs))./sqrt(MTFD.vsvar+MTFD.vsvar(i_maxvs))

figure
subplot(321)
semilogx(FMAxis,MTF.Rate,'.-');
ylabel('spikes/s');
xlim([1 2000]);
    
subplot(323)
semilogx(FMAxis,MTF.Norm,'.-')
ylabel('spikes/cycle');
xlim([1 2000]);


subplot(325)
% semilogx(MTF.FMAxis,MTF.VS);
semilogx(FMAxis,MTF.VS,'.-');
% axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
ylabel('vector strength');
axis([1 2000 0 1]);

subplot(322)
semilogx(FMAxis,MTFD.Rprime,'.-g');
subplot(324)
semilogx(FMAxis,MTFD.Nprime,'.-g');
subplot(326)
semilogx(FMAxis,MTFD.VSprime,'.-g');

