%Monty's Spike Train Correaltion Toolbox
%Version 1.0   08-Aug-2009
%Coputight (c) Monty A. Escabi, Univeristy of Connecticut
%
%Spike Train Correlation Algorithms
%  xcorrspike	- Spike train xcorrelation
%  xcorrspikeb	- Blocked spike train xcorrelation. Returns bootstrap data.
%xcorrspikefast	- Fast xcorrelation.
%xcorrspikesparse - Fast xcorrelation for sparse spike trains. Requires <1 spike/bin
%xcorrspikesparseb - Blocked version of XCORRSPIKESPARSE. Returns bootstrap data.
%
%General Correlation Algorithms
%  xcorrbined   - Blocked crosscorrelation. Reduced memory requirements.
%  xcorrfft     - FFT based crosscorrelation
%  xcorrcircular - Circular crosscorrelation
%  xcorrfft2	- 2D FFT crosscorrelation
%
%Correlation Based Spike Timing Jitter/Reproducibility Analysis
%  batchcorrjitter - Jitter width and trial reproducibility vs. contrast
%  batchrastercorr - Across trial correlation for all PRE files
%  bootstrapcorrcoef - Bootstrap estimate of correlation coefficient
%  corrmodel    - Gaussian correlation model of across-channel correlation
%  corrmodelstd - Gaussian correlation model of across-channel correlation
%  corrmodel2   - 2 Gaussian correlation model to fit across-channel correlation
%  corrmodelfit - Optimal fit of across-trial correlation to CORRMODEL
%  corrmodelfitstd - Fits across-trial corraltion to CORRMODELSTD
%  corrmodelfit2 - Optimal fit of across-trial correlation to CORRMODEL2
%  jittercorrsim - Jitter/reproducibility simulation of noisy spike train
%  jittercorrifsim - Integrate Fire simulation of jitter/trial reproducibility
%
%Integrate Fire Simulation
%  rasterifsim  - Generates a Rastergram for an IF neuron
%  jittercorrifsim - Integrate Fire simulation of jitter/trial reproducibility
%
%Rastergram Analysis
%  rastercorrbottstrap - Bootstrap estimate of RASTERCORR
%  rastercorr   - Across-trial correlation function derived from rastergram
%  rastercorrcoef - Across-Trial Correlation Coefficient derived from rastergram
%