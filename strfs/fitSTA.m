function [af,at,mdl] = fitSTA(t,f,sta)

mdl = @(a,x) (a(1) .* exp(-((x-a(2)).^2) ./ (2*a(3).^2)));

% fit frequency
yf = nanmean(sta,2);
af0 = [max(yf),f(find(yf==max(yf))),2000];
af = nlinfit(f',yf,mdl,af0);

% fit time
yt = nanmean(sta,1);
at0 = [max(yt),t(find(yt==max(yt))),10];
at = nlinfit(t',yt',mdl,at0);