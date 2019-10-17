function [M,SEM]=boot(P,SIGMA,EFF,NB)

for FMi=1:18
    p=[]; sigma=[]; eff=[];
    i=1;j=1;k=1;
    for n=1:size(P,1)
        if P(n,1)>0 & ~isnan(P(n,FMi))
            p(i)=P(n,FMi);
            i=i+1;
        end
        if SIGMA(n,1)>0 & ~isnan(SIGMA(n,FMi))
            sigma(j)=SIGMA(n,FMi);
            j=j+1;
        end
        if EFF(n,1)>0 & ~isnan(EFF(n,FMi))
            eff(k)=EFF(n,FMi);
            k=k+1;
        end
    end

for l=1:NB
    b = randsample(size(p,2),size(p,2),'true');
    pboot(l,:)=median(p(b));
end
for l=1:NB
    b = randsample(size(sigma,2),size(sigma,2),'true');
    sigmaboot(l,:)=median(sigma(b));
end
for l=1:NB
    b = randsample(size(eff,2),size(eff,2),'true');
    effboot(l,:)=median(eff(b));
end
M.p(FMi)=mean(pboot,1);
M.sigma(FMi)=mean(sigmaboot,1);
M.eff(FMi)=mean(effboot,1);
SEM.p(FMi)=std(pboot,1);
SEM.sigma(FMi)=std(sigmaboot,1);
SEM.eff(FMi)=std(effboot,1);
end % end of FMi

