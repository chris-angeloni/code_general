%       DESCRIPTION     : Generalized Poison raster with the same spike
%       rate and duation of SAM raster


function [RASp,Rp,MIp]=poissonRASvssamRAS(SAMrate,L,FMAxis,NB)

% RASp(n,FMi)      : Auto-corr of the poisson spike train for each
%                    condition and each neuron
% Rp

% Generate the auto-corr of the poisson spike for each neuron
for n=1:size(SAMrate,1)
    for FMi=1:length(FMAxis)
        [spet] = poissongen(SAMrate(n,FMi)*ones(1,12207*5),12207,12207,1,2);
        RASp(FMi).spet=spet;  RASp(FMi).Fs=12207;
        Tau=[]; Raa=[];
        MaxTau = 1/2/FMAxis(FMi)*1000*4;
        Fsd = min(FMAxis(FMi)*L,RASp(FMi).Fs);
        RAS = rasterexpand(RASp(FMi),Fsd,1/FMAxis(FMi),1);
        taxis=(1:size(RAS,2)-1)/Fsd;
        R=[];
        N=ceil(MaxTau/1000*Fsd);
        RASp(n,FMi).Raa=[R;xcorr(RAS,RAS,N)/Fsd/max(taxis)];
    end  % end of FMi
end % end of n

for FMi=1:length(FMAxis)
    i=1; Raa=[];
    for n=1:size(SAMrate,1)
        if ~isempty(RASp(:,FMi).Raa)
           Raa(i,:) = real(sqrt(RASp(:,FMi).Raa));
           i=i+1;
        end  % end of if
    end % end of i
for l=1:NB
    j=randsample(size(Raa,1),size(Raa,1),'true');
    Raa_m = mean(Raa(j,:));
    Rp(FMi).R = Raa_m;
    temp=Rp(FMi).R(find(Rp(FMi).R<max(Rp(FMi).R)));
    MIp(FMi).boot(l,1) = 1-min(temp)/max(temp);  
end  % end of NB
MIp(FMi).M=mean(MIp(FMi).boot,1);
MIp(FMi).SE=std(MIp(FMi).boot,1);

end  % end of FMi