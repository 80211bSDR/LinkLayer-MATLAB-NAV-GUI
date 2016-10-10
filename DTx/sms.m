function dfs = sms(df,ft,nsi)
% SMS: Scrambles, Modulates, and Spreads Input Data Bit Sequence
% Function Arguments: 
% df:  This Data Frame: Input Data Bits to Transmit (length NSI)
% dfs: This Data Frame Spreaded: Output Data Samples after Scrambling, 
%   Modulation, and Spreading, to be put on USRP Tx buffer (length NSIx11)
% ft:  Flag Terminal: If true, specifies to release all System objects
% nsi: Number of samples in  (max/def numBits80211b)

% setting global variables
global numBits80211b halfSamples80211b spreadFactor

% Persistent Data: Maintained between function calls to SMSRC()
% hm:  Handle to Modulation System object
persistent hm;
% hs:  Handle to Scrambling System object
persistent hs;
% Initialize Persistent Data: Only on first call to DDD()
if isempty(hm)
    hm = comm.DBPSKModulator('OutputDataType','double','PhaseRotation',0);
end % IF ISEMPTY(HM)
if isempty(hs)
    hs = comm.Scrambler('CalculationBase',2,'InitialConditions', ...
        [0,0,0,0,0,0,0],'Polynomial',[1,0,0,0,1,0,0,1]);
end % IF ISEMPTY(HS)
% Local data preallocation
% dfb: Data frame bits scrambled: NSIx1 real double vector
dfb = real(zeros(numBits80211b,1)); 
% dfc: Data frame complex signed bits: NSIx1 complex double vector
dfc = complex(zeros(numBits80211b,1));
% dfm: Data frame matrix spreaded chips: 11xNSI complex double matrix
dfm = complex(zeros(spreadFactor,numBits80211b));
% dfs: Data frame spreaded output: NSOx1 complex double vector
dfs = complex(zeros(halfSamples80211b,1));
% nso: Number of samples out: Length of dfs (max/def halfSamples80211b)
nso = nsi*spreadFactor;
if ft
    % Release System objects: only on final call to DDD()
    release(hm);
    release(hs);
    %clear('hm','hs'); %Not supported for code generation
else
    release(hm);%***************************Undo this change!!!!!!!!!!!!!!!!!!!!!
    release(hs);%***************************Undo this change!!!!!!!!!!!!!!!!!!!!!
    % Scrambling
    dfb(1:nsi) = step(hs,df(1:nsi));
    % Modulation
    dfc(1:nsi) = step(hm,dfb(1:nsi));
    % Spreading 
    dfm(1:spreadFactor,1:nsi) = [1;-1;1;1;-1;1;1;1;-1;-1;-1] * dfc(1:nsi).';
    % Extract first 704 elements of matrix MTX using LINEAR indexing
    dfs(1:nso) = dfm(1:nso);
end % IF FT
end % FUNCTION SMS