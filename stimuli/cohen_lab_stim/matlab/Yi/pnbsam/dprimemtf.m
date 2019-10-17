function [D,M1,SE1,M2,SE2]=dprimemtf(RAB1,RAB2,NB)

for FMi=1:18
    n1=1; n2=1;
    for i=1:length(RAB1)
     % for i=1:65
        if ~isempty(RAB1(i,FMi).Rab) | ~isnan(RAB1(i,FMi).Rab)
          Rab1(n1,:)=RAB1(i,FMi).Rab(1:40)/max(RAB1(i,FMi).Rab);
          n1=n1+1;
        end
        
        if ~isempty(RAB2(i,FMi).Rab) | ~isnan(RAB2(i,FMi).Rab)
          Rab2(n2,:)=RAB2(i,FMi).Rab(1:40)/max(RAB2(i,FMi).Rab);
          n2=n2+1;
        end
    end  % end of i
    
[d,m1,se1,m2,se2]=dprimewave(Rab1,Rab2,NB);
D(FMi,:)=d;
M1(FMi,:)=m1;
SE1(FMi,:)=se1;
M2(FMi,:)=m2;
SE2(FMi,:)=se2;
end  % end of FMi

