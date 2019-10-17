%Monty's Sound and File Utility Toolbox
%Version 1.3   11-24-02
%Copyright (c) Monty A. Escabi, University of Connecticut
%
%Dynamic Moving Ripple and Ripple Noise Generators
%  ripnoise       - Dynamic Ripple Spectrum Noise saved to file
%  ripnoiseb      - Similar to RIPNOISE but arbitrary number of envelopes
%  ripnoise1f     - Same as ripnoiseb but modulation spectrum is fm^(-alpha)
%  ripnoisepitch  - Similar to RIPNOISE but contains dynamic pitch
%  ripplecalibrate- Generates a calibration lookup table for ripple noise
%  noisegensin    - Ripple Generator via sinusoid bank - called by RIPNOISE
%  noisegensinb   - Same as NOISEGENSIN but used by RIPNOISEB
%noisegensinpitch - Same as NOISEGENSIN but used by RIPNOISEPITCH
%  findmrparam    - Finds the fRD and fFM parameters for Moving Ripple
%  findmrerr      - Findst the error in the RTFH as a result of the Fm and RD
%  mripple        - Static moving ripple sound
%  sprreconstruct - Reconstructs the SPR files for a Ripple Noise Signal
%  sprgen	  - Generates the Spectral Profile Data for SPRRECONSTRUCT
%
%Noise and Sound Generators
%  dynripspl         - Dynamic Ripple Spectrum Noise with Spline Modulations
%  ammod             - Add AM noise modulation to a file
%  ammodsquare       - Add sqare wave modulation to a file
%  carier            - Generates a sinusoid carier and saves to file 
%  gausswav          - Generates a .WAV File with Gaussian Noise
%  dynrbuild         - Dynamic Ripple SPR Rebuild from Parameters
%  splinewindow      - B-Spline ramped window
%  swindow           - B-spline smothing window function
%  n1overf           - 1/f Noise
%  noisesquare       - Square Wave Bandlimited Noise
%  synapticnoise     - Simulated synaptic noise
%  synapticnoise2    - Simulated synaptic noise - variable and fixed inputs
%synapticnoiseraddy  - Simulated synaptic inputs - variable and fixed inputs
%batchsynapticraddy  - BATCH file for SYNAPTICNOISERADDY
%  epsp		     - Generates EPSC for SYNAPTICNOISE
%
%Uniformly distributed noise
%  noiseunif      - Low pass Uniformly Distributed noise
%  noiseunifh     - Band pass uniformly distributes noise - uses noiseblh
%
%Gaussian distributed white noise
%  noiseblfft     - Band pass noise designed using FFT
%  noiseblh       - Band pass White Noise desinged by filtering Gausian Noise
%  ngausunif      - Low pass Noise - Gaussian and Uniform properties
%
%Sound Utilities
%  wavwri         - Writes .WAV sound files
%  wavrea         - Reads .WAV sound files
%  wread16        - Reads 16 bit .WAV sound files
%  wreadn2m       - Loads a portion of .WAV file
%  waveinfo       - Gets header info from a .WAV file
%  readaiff       - Read an AIFF sound file
%  readaiffdec    - Read an AIFF sound file on dec alpha
%  readaiffsgi    - Read an AIFF sound file on sgi
%  wav2int        - Converts a .WAV sound file to 'int16'
%  wav2float      - Converts a .WAV sound file to 'float'
%  wav2ch2int1ch  - Converts a two channel WAV File to a one channel int16
%  wav2toint1     - Converts a two channel WAV File to a one channel int16
%  bin2wav        - Converts an Array X to a .WAV file 
%  wavinfo        - Gets WAV file header info
%  wavvolume      - Changes the intensity of a WAV file
%  lin2logquant   - Quantizes a signal using a logarithmic quantizer
%
%Specialized Sound Utilities
%  float2wav4ch   - Converts a 'float' file to 4 channel WAV
%  float2wav4chmod- Converts a 'float' file to 4 channel WAV and Modulates
%  float2wav2ch   - Converts a 'float' file to 2 channel WAV
%  float2wavpre   - Converts a 'float' file to a Prediction WAV File
%  float2wavdbspl - Converts a 'float' file to a dBvsSPL WAV File
%  float2wavrlf   - Converts a 'float' file to a SPL Rate Level Fnx WAV File
%  mtfgen         - Generates a .WAV File used for MTF during Experiment
%  compress       - Compress the dynamic range of a sounds envelope
%  compresswav    - Compress the dynamic range of a .wav sound envelope
%
%File Conversions
%  toint16        - Converts an array X to a binary 'int16' file
%  tofloat        - Converts an array X to a binary 'float' file
%  float2int      - Converts a binary 'float' file to 'int16'
%  int2float      - Converts a binary 'int16' file to 'float'
%
%File Utilities and Analysis
%  xtractch       - Extracts a channel sequence from an 'int16' File
%  getint16       - Extracts a single channel from 'int16' file
%  interlace      - Interlaces two 'int16' files as left and right channels
%  interlace4     - Interlaces four 'int16' files
%  addfile        - Adds two 'int16' files
%  flipfile       - Flips a File so data order is reversed
%  truncfile      - Truncates a file to length L
%  appendfile     - Appends N coppies of infile to outfile
%  catfile        - Concatenates two files
%  filtfile       - Filters the data in a file
%  decimatefile   - Decimates a File by an integer factor
%  fisempty       - Checks tp see if a file is empty
%  combinef       - Combines q sequence of 'Blocked' Files
%  rmmod          - Removes Amplitude Modulations From Infile
%  prewhitenfile  - Pre-Whitens the data in a given file
%  attfile        - Attenuates the data in a file
%  addmod         - Adds amplitude modulations to a file and saves 
%
%Specialized File Converters and Generators
%  trigfile       - Genrates an 'int16' trigger file
%  sprint2float   - Converts an 'int16' SPR File to 'float'
%  sprfloat2int   - Converts an 'float' SPR File to 'int16'
%  spr2rev        - Converts an SPR file to a revere reconstruction REV file
%  wav2spr        - Converts a .WAV File to SPR
%  sprdownsample  - Deown Samples an SPR file 
%
%Sound Callibration
%  ripplecalibrate- Generates a calibration lookup table for ripple noise
%  soundcalibalign- Aligns the input and output waveforms
%  soundcalibcsd  - Determines the transfer function via CSD
%  soundcalibpsd  - Determines the transfer function via PSD
%
%Other
%  zip            - Gzips a sequence of files
%  unzip          - Gunzips a sequence of files
%  tocomplex      - Converts a 2 Element Array to a complex Number
%  int2strconvert - Converts an integer to a string with zeros appended
%
