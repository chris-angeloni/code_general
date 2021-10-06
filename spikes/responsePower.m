function [NR, uPatt, Ps, Pn] = responsePower(psth,index)

%% function [NR, uPatt] = responsePower(psth,index)
% computes response power ratio ala Sahani & Linden, 2003
% NR (noise ratio) relates how repeatable the neural responses are for the
% same stimulus (NR == 0 is an identical PSTH, NR >> 0 are less repeatable)

% power function
Power = @(x)(mean((x-mean(x,2,'omitnan')).^2,2,'omitnan'));

% for each unique stimulus
[uPatt,~,uPattI] = unique(index,'rows');
for i = 1:length(uPatt)
    
    FR = psth(uPattI == i,:);
    N = size(FR,1);
    
    % power for each trial response
    Pt = Power(FR);
    
    % power of the average response
    Pa = Power(mean(FR,1,'omitnan'));
    
    % power across trials
    Pr = mean(Pt,1);
    
    % signal power
    Ps(i) = (N * Pa - Pr) / (N - 1);
    
    % noise power
    Pn(i) = Pr - Ps(i);
    
    % noise ratio
    NR(i) = Pn(i)/Ps(i);
        
end

    
    