
function [SIG,FMmax] = maxFMvsBF(Shuf,FMAxis);

t_value = tinv(.975,44);

for FMi = 1:length(FMAxis)
    Aboot = Shuf(:,FMi).Aboot;
    Aboot = Aboot/max(Aboot);
    SIG(FMi).m = mean(Aboot);
    SIG(FMi).se = std(Aboot);
    A = Shuf(:,FMi).A;
    A = A/max(A);
%     A(FMi).p = length(find((Aboot>A(FMi).m-x*A(FMi).se)&(Aboot<A(FMi).m+x*A(FMi).se)))/length(Aboot);
%     A(FMi).cv = [A(FMi).se]./[A(FMi).m];
    SIG(FMi).t = abs(A-SIG(FMi).m)/SIG(FMi).se;
end % end of FMi

index = find([SIG.t]<t_value);
if isempty(index);
    FMmax=length(FMAxis);
else
FMmax = index(1);
end

figure
semilogx(FMAxis(1:length([SIG(:).t])),[SIG(:).t],'.b-');
hold on;
semilogx(FMAxis,t_value*ones(1,length(FMAxis)),'r-');

