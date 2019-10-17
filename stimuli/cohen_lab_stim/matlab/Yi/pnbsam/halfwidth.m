function [HWab,HWr]=halfwidth(Rab,FMAxis)

for FMi=1:18
    rab = Rab{FMi};
    Fsd = min(FMAxis(FMi)*50,12207);
    N=round((length(rab)-1)/8);
    Tau = (-N:N)/Fsd;
    rab1 = rab(((length(rab)-1)/2-N):((length(rab)-1)/2+N)); % center rab
    b=abs(rab1-max(rab1)/2);
    HWab(FMi) = 2*abs((length(rab1)-1)/2 - find(b==min(b)))/Fsd;
    HWr(FMi) = HWab(FMi)/FMAxis(FMi);
end % end of FMi



