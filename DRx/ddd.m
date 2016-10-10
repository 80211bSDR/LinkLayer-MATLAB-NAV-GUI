function dfd = ddd(dfr,ft)
% DDD: Despreads, Demodulates, and Descrambles Input Data
% Function Arguments: 
% dfd: This Data Frame Decoded: Output Data after Despreading, Demodulation
%   & Descrambling (length 64)
% dfr: This Data Frame Recovered: Received Input Data after RFFE &
%   Preamble-based Synchronization (length 704)
% ft:  Flag Terminal: If true, specifies to release all System objects
% prm: DBPSK Transceiver Parameter Structure

% setting global variables
global spreadFactor

% Persistent Data: Maintained between function calls to DDD()
% hdm: Handle to Demodulation System object
persistent hdm;
% hds: Handle to Descrambling System object
persistent hds;
% Initialize Persistent Data: Only on first call to DDD()
if isempty(hdm)
    hdm = comm.DBPSKDemodulator('OutputDataType','double','PhaseRotation',0);
end % END IF ISEMPTY(HDM)
if isempty(hds)
    hds = comm.Descrambler('CalculationBase',2,'InitialConditions', ...
        [0,0,0,0,0,0,0],'Polynomial',[1,0,0,0,1,0,0,1]);
end % END IF ISEMPTY(HDS)
% Local data preallocation
dfd = complex(zeros(64,1));
mtx = complex(zeros(spreadFactor,64));
if ft
    % Release System objects: only on final call to DDD()
    release(hdm);
    release(hds);
    %clear('hdm','hds'); %Not supported for code generation
else
    % Despreading 
    mtx(1:spreadFactor,1:64) = reshape(dfr, spreadFactor, 64); 
    dfd(1:64) = (mtx.' * [1;-1;1;1;-1;1;1;1;-1;-1;-1]);
    % Demodulation
    dfd = step(hdm,dfd);
    % Descrambling
    dfd = step(hds,dfd);
end % IF FT
end % FUNCTION DDD