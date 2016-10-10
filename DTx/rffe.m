function dfr = rffe(df,ft,cas,cau,cef)
% RFFE: Radio Freq Front End: AGC's, Freq Compensates, & RCRF's Input Data
% Function Arguments: 
% cas: Constant AGC Step Size (fixed at 1.0)
% cau: Constant AGC Update Rate (fixed at usrpFrameLength)
% cef: Constant Frequency Offset Estimation Freq Resolution (~4.0 Hz)
% df:  This Data Frame: Raw data taken from USRP Rx Buffer (length usrpFrameLength)
% dfr: This Data Frame Recovered: Data after AGC, FOC & RCRF (length halfUsrpFrameLength)
% ft:  Flag Terminal: If true, specifies to release all System objects

% setting global variables
global spreadFactor usrpFrameLength halfUsrpFrameLength samplingRate

% ha: Handle to Automatic Gain Control (AGC) System object
persistent ha;
% hd: Handle to FIR Decimator System object
persistent hd;
% he: Handle to Coarse Frequency Estimator (CFE) System object
persistent he;
% hf: Handle to Frequency Offset Compensator (FOC) System object
persistent hf;
% hrr: Handle to Raised Cosine Receive Filter (RCRF) System object
persistent hrr;
% Initialize Persistent Data: Only on first call to RFFE()
if isempty(ha)
    ha = comm.AGC('MaxPowerGain',30,'AdaptationStepSize',cas);
end % END IF ISEMPTY(HA)
if isempty(hd)
    hd = dsp.FIRDecimator('DecimationFactor',(spreadFactor*2));
end % END IF ISEMPTY(HD)
if isempty(he)
    he = comm.PSKCoarseFrequencyEstimator('Algorithm','FFT-based', ...
        'FrequencyResolution',cef,'ModulationOrder',2,'SampleRate',(samplingRate/(spreadFactor*2)));
end % END IF ISEMPTY(HC)
if isempty(hf)
    hf = comm.PhaseFrequencyOffset('PhaseOffset',0, ...
        'FrequencyOffsetSource','Input port','SampleRate',samplingRate);
end % END IF ISEMPTY(HF)
if isempty(hrr)
    hrr = comm.RaisedCosineReceiveFilter('DecimationFactor',2,...
        'DecimationOffset',0,'FilterSpanInSymbols',8,'Gain',1,...
        'InputSamplesPerSymbol',2,'RolloffFactor',0.3,'Shape','Square root');
end % IF ISEMPTY(HRR)
% Local data preallocation
ddf = complex(zeros(64,1)); %#ok<NASGU>
dfr = complex(zeros(halfUsrpFrameLength,1));
ofs = double(0.0); %#ok<NASGU>
tmp = complex(zeros(usrpFrameLength,1)); %#ok<NASGU>

if ft
    % Release System objects: only on final call to RFFE()
    release(ha);
    release(hd);
    release(he);
    release(hf);
    release(hrr);
    %clear('ha','he','hf','hrr'); %Not supported for code generation
else
    % Automatic Gain Control (AGC)
    tmp = step(ha,df);
    % FIR Decimation
    ddf = step(hd,tmp);
    % Coarse Frequency Offset Estimation (CFE)
    ofs = step(he,ddf);
    % Frequency Offset Compensation (FOC)
    tmp = step(hf,tmp,-ofs);
    % Raised Cosine Receive Filtration (RCRF)
    dfr = step(hrr,tmp);
end % IF FT
end % FUNCTION RFFE