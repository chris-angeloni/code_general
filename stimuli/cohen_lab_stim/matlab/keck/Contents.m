%Monty's Keck Toolbox
%Version 1.5   27-Sept-2001
%Copyright (c) Monty A. Escabi, UC Berkeley / UC San Francisco
%Coputight (c) Monty A. Escabi, Univeristy of Connecticut
%
%Spike Sorting
%  xtractch       - Extracts a channel sequence from a 'dat' file
%  ss2spet        - Converts an 'spk' file to a 'mat' file
%  ss2spetbatch   - Performs ss2spet on all 'spk' files in a directory
%  tapextract     - Extracts the contents of a tape and sets up for spikesort
%  filterbatch    - Filters RAW Spike and Eeg files in a Directory 
%  classbat      *- Classifies the contents of a directory
%  classbatch    *- Classifies across recordings using a batch file
%  classbatcross  - Classifies across recordings
%  spkwaveform    - Finds N Spike Waveforms inside a RAW File 
%  getmdlspike    - Gets the Nth model waveform from an MDL File
%  mdlspike       - Finds all Models for an SPK File and Stores to MAT File
%  dat_header     - Extracts the header info from a 'dat' file
%  spikecomp     *- Tool to compare spike waveforms from two files
%  spikecorrcoef *- Computes the corrcoef matrix across all spikes for two files
%  spikeerr	  - Spike Error Analysis
%  spkoutlier     - Finds spike outliers ratios for all spikes in directory 
%  spet2impulse   - Converts a SPET Array to a impulse array
%
%Trigger Files
%  trigfind      *- Find Trigger times for a 'raw' DAT file
%  trigbatch     *- BATCH file runs TRIGFIND on all Trig files in a directory
%  trigbatchall  *- BATCH file runs TRIGFIND and FIX for all analyzis types
%  trigfixall    *- BATCH file runs TRIG FIX for all analysis types
%  trigfixstrf   *- Removes multiple triggers
%  trigfixstrf2  *- Removes multiple triggers for double presentations of sound
%  trigfixdbvsspl*- Finds Tripple and Double Triggers for dB vs SPL Experiment
%  trigfixsplrlf *- Finds Tripple and Double Triggers for SPL RLF Experiment
%  trigpsth      *- Fixes the trigger times for a PSTH sequence
%
%Spike Train Analysis
%  spet2impulse   - Converts a SPET Array to a Impulse Array
%  spet2spetab    - Extracts spetA and spetB for double stimulus presentation
%  psdspike       - Welch Average PSD for Neural Spike Train
%  csdspike       - Welch Average CSD for Neural Spike Train
%  coherespike    - Coherence Function on Neural Spike Train
%  xcorrspike     - X-Correlation of a Neural Spike Train
%  xcorrspikeb    - X-Corr of Neural Spike Train performed via binned Avg 
%  xcovspike      - X-Covariance of a Neural Spike Train
%  xcovspikeb     - X-Cov of Neural Spike Train performed via binned Avg 
%  fanospike      - Fano Facto of a Neural Spike Train
%  poissongen     - Non-Stationary Poison Spike Train Generator
%  iethspike      - Inter Event Time Histogram
%  spikeanalfile  - Performs Xcorr, PSD, Fano, IETH for Spike Train
%  plotspikeanal  - Plots Data from SPIKEANAL
%  condspike      - Conditioned Post Spike Histogram
%  acq2spet       - Converts an Aquire File ( Lee Miller's Program ) to SPET
%
%Wiener Kernel and STRF Analysis
%  rtwstrfdb     *- Real Time Spectro-Temporal Receptive Field - dB Sound Mod
%  rtwstrflin    *- Real Time Spectro-Temporal Receptive Field - Lin Sound Mod
%  rtwstrfdbint  *- Same as RTWSTRFDB but interpolates the STRF
%  rtwstrfdbvar   - Measures the pre-event variability with STRF SI
%rtwstrfdbvarxtract - Xtracts pre-event file segments used for RTWSTRFDBVAR
%rtwstrfdbintboot*- Same as RTWSTRFDBINT but segments for bootstraps
%  strfsvdboot    - Bootstraps the data fo RTWSTRFDBINTBOOT
%  strfchisqr     - Chi-Square Analysis betwen STRF model and STRF
%  rtwstrflinint *- Same as RTWSTRFLIN but interpolates the STRF
%  rtwstrfspec    - Real Time STRF via Spectrogram - Requires SPR File
%  wstrfspec      - Spectro-Temporal Receptive Field via Spectrogram
%  wstrfstat      - Performs a Significance Test on STRF for dB and Lin Sound
%  wstk           - Spectro-Temporal Wiener Kernel
%  xbstrf         - Cross-Spectro-Temporal binaural receptive field
%  wiener0        - Zeroth order wiener kernel
%  wiener1        - First  order Wiener kernel
%  wiener2        - Second order Wiener kernel
%  wstft          - 1st Order Wiener STFT Kernel
%  diagw2         - Diagonal of secondd order Wiener kernel
%  mtfrevcorr     - MTF via REVCORR on the Hilbert X-Form Noise Modulated Tone
%  strfcorrcoef   - Correlation coefficient of two STRFs
%
%Plotting and Pringting Utilities
%  plotstrf      *- Plots an STRF Data File
%  plotstrfs     *- Plots all the STRFs from a spike file sequence
%  plotrtfhist   *- Plots a Ripple Transfer Function Histogram ( MR Sound Only)
%  plotrtfhists  *- Plots all the RTFHs from a spike file sequence
%  plotspikeanal *- Plots Data from SPIKEANAL
%  printbatch    *- Prints all STRF Data from a Directory - Uses Batch File
%  printstrfbatch*- Prints all STRF Data from a Directory
%  plotraster    *- Plots RASTER and PSTH of Prediction Sequences
%  plottc         - Plots a Tuning Curve
%  plotdbsplxcorr*- Plots X-Correlation as a function of dB and SPL
%  plotdbspl     *- Plots  Var, Mean and Var/Mean as a fxn of dB vs SPL
%  plotcfdata    *- Plots data generated by findcftool
%  plotspikes    *- Plots all the spikes and models from a Spike File
%
%STRF and Analysis BATCH Files 
%  trigbatch     *- BATCH file runs TRIGFIND on all Trig files in a directory
%  batchstrfspr  *- BATCH file for STRF using SPR File (Batch for BATCHRTWSTRF)
% batchstrfintspr*- Same as BATCHSTRFSPR but interpolates all STRFs 
%  batchrtwstrf   - BATCH file for RTWSTRFLin and RTWSTRFdB
%  batchrtwstrf2  - BATCH file for RTWSTRFLin and RTWSTRFdB (Shift Predictor)
% batchrtwstrfint2- BATCH for RTWSTRFLin and RTWSTRFdB (Interp Shift Predictor)
%  batchstrfspec  - BATCH file for Spectrogram STRF ( RTWSTRFSPEC )
%  binstrf        - BATCH file for binaural spectro temporal receptive field
%  monstrf        - BATCH file for monaural spectro temporal receptive field
%  batchwiener    - BATCH file for several spectro temporal receptive field
%  batchpsthpre  *- BATCH file for Prediction PSTH ( PSTHPREFILE )
%  batchstrf2rtf *- BATCH file converts STRF file to RTF file
%  batchrtfhist  *- BATCH file Computes RTF Histogram for all MR Units
%  batchdbvsspl  *- BATCH file for generating dB vs. SPL sensitivity function
%  batchspikeanal*- BATCH file computes PSD, FF, XCOV, IETH for all files
%  batchstrfdown *- Down samples all STRF Files in directory
%
%STRF, RTF, MTF, and PRE Analysis Tools
%  dbvsspl       *- Generates Response Curves for RN at various MdB and SPL
%  splrlf        *- Generates Rate Level Function Response Curve
%  dbvssplfile    - Computes and Saves dB vs SPL Response Curve using DBVSSPL
%  strfparam     *- Finds STRF Parameters: CF, BMF, BRF, ...
%  strf2rtf       - Converts an STRF to a Ripple Tranfer Function ( RTF )
%  strf2rtffile   - Generates a File with RTF Data - Saves data from STRF2RTF
%  strf2xcorr    *- X-Corr Prediction from STRF
%  strf2xcorrint *- Interactive X-Corr Prediction from STRF
%  strf2pre      *- Input-Output Prediction using STRF
%  strfsprpre    *- Input-Output Prediction of SPR File using STRF
%  rtfhist        - Ripple Transfer Function Histogram derived for MR Noise 
%  rtfstat        - Finds the statistically significant RTFH
%  rtfparam       - Finds Ripple Transfer Function Parameters
%  hist2         *- Joint two dimmensional histogram of a 2xN array
%  psthprefile    - Computes and saves the PSTH and RASTER for a Prediction File
%  psth           - Computes the PSTH given TRIG and SPET
%  psthclean      - Computes the statistically significant RASTER
%  findcftool    *- Interactive tool for finding CF and Binaurality from STRF
%  rtfanaltool   *- Ripple Transfer Function analysis tool
%  spikecomp     *- Tool to compare spike waveforms from two files 
%  strfdownsam   *- Down samples an STRF by an integer factor
%  strfdownsamf  *- Down samples an STRF File by an integer factor
%  strfexbw	  - Estimates the STRF excitatory Bandwidth and CF
% 
%Population Statistics Batch Files
%  batchcorrcoef  - Correlation Coefficient statistics - MR vs. RN
%  batchdbsplstat - Contrast vs. Intensity statistics
%  batchdbsplind  - Detemines if the intensity vs. Cont. Response is separable
%  batchdbcontstat- STRF Contrast statistics  
%
%DSP / Modeling
%  convfft        - Convolution performed via FFT
%  convlinfft     - Linear convolution performed via FFT
%  xcorrfft       - Cross Correlation performed via FFT
%  convfft2       - 2-D Convolution performed via FFT
%  xcorrfft2      - 2-D Cross Correlation performed via FFT
%  xcorrbined     - X-Correlation using Bined Averages
%  stfft          - Short term fourier transform 
%  intfft         - Signal Integrator - Performed via FFT
%  difffft        - Signal Differentiator - Performed via FFT
%  interp10       - Interpolates an Array by a factor of 10^L for integer L
%  invstfft       - Inverse Short-Time Fourier Transform
%  norm2unif      - Converts a Normal RV to Uniform RV
%  norm1d         - Normalize a signal to [0 1]
%  rect           - Rectifies a signal
%  sat            - Saturates / Clips a signal
%  haircell       - Hair-cell model filter/rectification
%  hcnl           - Outer Hair cell nonlinearity
%  hcwin          - Hair Cell wiener kernel simulation
%  sandwich       - Sandwich model kernel simulation
%  splinewin      - Escabi/Roark Spline Window  
%  prewhiten      - Pre Whitens a signal by dividing the mean Spectrum
%  dbvssplsim     - Generates a VAR and MEAN simulated tunning curve
%  integratefire  - Integrate and fire model neuron
%
%Image processing
%  ibin2mat       - Binary to matlab format 
%  iconvfft       - 2D Convolution performed via FFT
%  idownsam       - Downsample 2D
%  inorm          - Normalize
%  iwavelet       - Wavelet Decomposition
%  lapgaus        - Laplacian of Gaussian filter
%  loadbin        - Load a binary image
%  toimg          - Converts a matrix to matlab image
%  loadbmp        - Loads a windows 3.1 "bmp" image
%  savebmp        - Saves a windows 3.1 "bmp" image
%  tiffread       - Reads a "tiff" file
%  tiff           - Compresses a matirx
%  tiffwrite      - Writes a "tiff" file
%
%Wavelets
%  dwt1d          - Discrete wavelet transform 
%  dwt1dd         - Decimated discrete wavelet transform 
%  decimate1d     - Decimate a 1D signal
%  expand1d       - Expand a 1D signal
%  wavspec        - Wavelet Spectogram
%
%Frequency Tunning Curve Analysis
%  ftcresponse    - Finds a single unit FTC 
%  plotftc        - Plots FTC Data
%
%Other
%  rainbow.mat    - Ranbow Colormap
%  rainbow1.mat   - Alternate Rainbow Colormap
%
%Statistics
%  circularcorrcoef - corrcoef for circular data
%
