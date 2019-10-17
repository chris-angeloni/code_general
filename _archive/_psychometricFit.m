function fit = psychometricFit(resps,count,fa,snr)

% Initial parameters
PF = @PAL_Logistic;
p0 = [58 .3 fa 0];%[mean(snr) 1/(max(snr)-min(snr))/4 0 0];
pFree = [1 1 0 1];
lapseLimits = [0 1];

% Set search options
options = PAL_minimize('options');
options.TolFun = 1e-9;

% Maximum likelihood fitting using Palamedes
pFit = PAL_PFML_Fit(snr,resps,count,p0,pFree,PF,...
                    'searchOptions',options,...
                    'lapseLimits',lapseLimits);

% Evaluate fit
fit.x = min(snr):.1:max(snr);
fit.y = PF(pFit,fit.x);
fit.func = PF;
fit.params = pFit;
fit.thresh = PF(pFit,.5,'inverse');
