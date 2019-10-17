%Speech and Filter Design Toolbox
%Version 1.0   28-Aug-97
%Copyright (c) Monty A. Escabi, UC berkeley
%
%Sinc(a,p) and Kaiser Filters
%  h            - Sinc(a,p) FIR filter impulse response
%  w            - Sinc(a,p) FIR Window impulse response
%  hi           - Sinc(a,p) interpolator impulse response
%  hc           - Ideal filter impulse response
%  hk           - Kaiser FIR filter impulse response
%  mff          - Kaiser Max Flat Filter
%  bandpass     - Band Pass Filter 
%  lowpass      - Low Pass Filter 
%  finddtdfw    - Finds the Spectro-Temporal resolution of a Window
%  finddtdfh    - Finds the Spectro-Temporal resolution of a Filter
%
%Sinc(a,p) and Kaiser Filter Design 
%  atttw        - ATT and TW for Sinc(a,p) filter
%  atttwk       - ATT and TW for kaiser filter
%  desatttw     - TW*N vs ATT eqution for Sinc(a,p) filter
%  fdeserk      - Sinc(a,p) kaiser aproximation design
%  fdesign      - Sinc(a,p) filter design
%  fdesignk     - Kaiser filter design
%  kaisvser     - Kaiser vs. sinc(a,p) Filter
%  ptoatt       - Convert P parameter to ATT (sinc(a,p) filter)
%
%Sinc(a,p) prototypes
%  hproto       - Sinc(a,p) filter prototype B-Spline frequency response
%  wproto       - Sinc(a,p) window prototype B-Spline frequency response
%  hprotosum    - Sums two orthogonal sinc(a,p) filters
%
%Speech and Jitter Extraction
%  er           - Escabi / Roark method of finding To
%  erfm         - Er simulation for fm signal
%  erfs         - Er simulation for sinusoid signal at multiple Fs
%  foanal       - Fo estimation using analytic signal method
%  witcard      - Whitaker Cardinal Series interpolation
%  titze        - Titze linear interpolation method of finding To
%  titzefm      - Titze simulation for fm signal
%  titzefs      - Titze simulation for sinusoid signal at multiple Fs
%  wm           - Milenkovic's Waveform Matching method for finding To
%  wm1          - Wm but finds only one value of To per waveform cycle
%  wmfm         - Wm simulation for fm modulated signal 
%  wmfm1        - Wm1 simulation for fm modulated signal
%  
%Speech and Jitter Analysis
%  fano         - Aproximate fano factor for continuous curve
%  boxdim       - Box counting dimmension
%  fomatch      - Matches two Fo or To profiles
%  plier        - Correlation Coefficient vs Fs for LI vs ER Methods
%  plierd       - Same as plier but dydadic downsampling
%  lierr        - LI Error Simulation
%  wmerr        - WM Error Simulation
%  ererr        - ER Error Simulation
%  fopsdfit     - Fits the PSD of an Fo Profile to a Power Law
%
%Other
%  fact         - Factorial
%  sinc         - Sinc Function
