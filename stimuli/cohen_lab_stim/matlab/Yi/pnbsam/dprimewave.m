% Description    : integrated d-prime between two independed population
% waveform

% Yi Zheng, Feb 2008

function [D,M1,SE1,M2,SE2]=dprimewave(RABa,RABb,NB)

n1=1;  n2=1;
for i=1:size(RABa,1)
    if ~isnan(RABa(i,1))
        RAB1(n1,:)=RABa(i,:);
        n1=n1+1;
    end
    if ~isnan(RABb(i,1))
        RAB2(n2,:)=RABb(i,:);
        n2=n2+1;
    end
end % end of i

for l=1:NB
  j1 = randsample(size(RAB1,1),size(RAB1,1),'true');
  j2 = randsample(size(RAB2,1),size(RAB2,1),'true');
  Rabm1_boot(l,:) = mean(RAB1(j1,:),1);
  Rabm2_boot(l,:) = mean(RAB2(j2,:),1);
  Rabse1_boot(l,:) = std(RAB1(j1,:),1);
  Rabse2_boot(l,:) = std(RAB2(j2,:),1);  

m1 = mean(Rabm1_boot,1);
se1 = std(Rabm1_boot,1);
m2 = mean(Rabm2_boot,1);
se2 = std(Rabm2_boot,1);
sd1 = se1.*sqrt(n1);
sd2 = se2.*sqrt(n2);

% D = abs(M1-M2)./sqrt(SD1.^2+SD2.^2);
% Dm = mean(D);
d(l)=sqrt(sum((m1-m2).^2))/sqrt((sum(sd1.^2)+sum(sd1.^2)));

end % end of l(NB)
M1 = mean(Rabm1_boot,1);
SE1 = std(Rabm1_boot,1);
M2 = mean(Rabm2_boot,1);
SE2 = std(Rabm2_boot,1);
SD1 = SE1.*sqrt(n1);
SD2 = SE2.*sqrt(n2);

D.m=mean(d);
D.se=std(d);
