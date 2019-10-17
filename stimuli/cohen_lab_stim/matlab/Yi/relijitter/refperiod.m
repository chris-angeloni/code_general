function [M,refp]=refperiod(MTF,FMAxis)

for FMi=5:length(FMAxis)
    Raa=MTF(1,FMi).Raa;
    Fsd = min(50*FMAxis(FMi),12207);
    ctr=length(Raa)/2;
    j=1;
    for i=ctr:-1:round(ctr-Fsd/1000*10) %20ms
        s(j)=sum(Raa(i:ctr));  
        j=j+1;
    end
    if isempty(find(s<1e-10))
        refp(FMi)=0;
    else
        refp(FMi)=(max(find(s<1e-10)))/Fsd;
    end
end  % end of FMi

index=find(refp>0);
M=mean(refp(index));