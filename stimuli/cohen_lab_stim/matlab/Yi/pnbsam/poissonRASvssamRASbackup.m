%       DESCRIPTION     : Generalized Poison raster with the same spike
%       rate and duation of SAM raster


function [RASp,Rp,MIp]=poissonRASvssamRAS(SAMrate,L,FMAxis,NB)

for FMi=1:length(SAMrate)

for l=1:NB
    j=randsample(size(SAMrate,1),size(SAMrate,1),'true');
    rate_m = mean(SAMrate((find(~isnan(SAMrate(j,FMi)))),FMi));
    
    [spet] = poissongen(rate_m*ones(1,12207*5),12207,12207,1,2);
    RASp(FMi).spet=spet;  RASp(FMi).Fs=12207;
    Tau=[]; Raa=[];
    MaxTau = 1/2/FMAxis(FMi)*1000*4;
    Fsd = min(FMAxis(FMi)*L,RASp(FMi).Fs);
    RAS = rasterexpand(RASp(FMi),Fsd,1/FMAxis(FMi),1);
    taxis=(1:size(RAS,2)-1)/Fsd;
    R=[];
    N=ceil(MaxTau/1000*Fsd);
    Raa=[R;xcorr(RAS,RAS,N)/Fsd/max(taxis)];
    Rp(FMi).R = real(sqrt(Raa));
    temp=Rp(FMi).R(find(Rp(FMi).R<max(Rp(FMi).R)));
    MIp(FMi).boot(l,1) = 1-min(temp)/max(temp);  
end  % end of NB
MIp(FMi).M=mean(MIp(FMi).boot,1);
MIp(FMi).SE=std(MIp(FMi).boot,1);

end  % end of FMi