function [sigMI,sigEI,MI,EI,MIrand,EIrand]=routinesig(Shufreal,Shufrand,Flag,FMAxis)

for FMi=1:length(FMAxis)
    [MI(FMi),EI(FMi)]=meanstdMIEI(Shufreal(1,FMi).R.Rshuf,Shufreal(1,FMi).R.RshufJt,Flag,FMAxis(FMi)*10,FMAxis(FMi));
    [MIrand(FMi),EIrand(FMi)]=meanstdMIEI(Shufrand(1,FMi).R.Rshuf,Shufrand(1,FMi).R.RshufJt,Flag, FMAxis(FMi)*10,FMAxis(FMi));
%     n1=size(Shufreal(1,FMi).R.RshufJt,1);
%     n2=size(Shufrand(1,FMi).R.RshufJt,1);
    [sigMI(1,FMi)]=sigztest(MI(FMi).mean,MI(FMi).se,MIrand(FMi).mean,MIrand(FMi).se,0.01);
    [sigEI(1,FMi)]=sigztest(EI(FMi).mean,EI(FMi).se,EIrand(FMi).mean,EIrand(FMi).se,0.01);
end