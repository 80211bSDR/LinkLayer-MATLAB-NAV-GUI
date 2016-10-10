function [fpd,ip] = preambleDet(drb)
% PREAMBLEDET: Finds SYNC in Rx Buffer; returns Sync Delay & Updated State
% Function Arguments: 
% fpd: Flag Preamble Detected: If true, move to decode header state
% drb: Data Receive Buffer: 2xUSRP frame len for Preamble Det (2816 samples)
% ip:  Index of Preamble Start (Synchronization Delay+1): Sample# in USRP frame that designates
%      the start of data for this frame; found through Preamble Detection
fpd = logical(false(1));
ip  = uint16(0);

% setting global variables
global usrpFrameLength spreadFactor crosscorr_thresh

% Persistent Data
% fnf: Flag Next Frame: Set true if preamble likely to be contained within
%      the next USRP frame
persistent fnf;
% lsd: Last Sync Delay: Value of sd on the last clock cycle, for comparison
%persistent lsd;
% ssb: Synchronization Signal bits, for comparison w/demodulated data
persistent ssb;
% sss: Synchronization Signal samples, for comparison against post-RCRF data
persistent sss;
% thr: Threshold for Correlation in Preamble Detection
persistent thr;

% SSS
persistent SSS;
% Hcorr: Handle to Crosscorrelator
persistent Hcorr;

if isempty(Hcorr)
    Hcorr=dsp.Crosscorrelator('Method','Fastest'); 
end % END IF ISEMPTY(Hcorr)

% Local Data
cra = double(zeros(21,1));
crv = double(zeros(2));
dfd = complex(zeros(128,1));
% ia:  Iterator Alternate: An integer to iterate through sda array
ia  = uint16(0); %#ok<NASGU>
% im:  Index with Maximum Correlation: Identifies index of best synch delay
im  = uint16(0); %#ok<NASGU>
% ipa: Index of Preamble Alternates: Array of neighboring candidates for ips
ipa = uint16(zeros(21,1));
% mtx: Matrix of Spread Samples: Temporary variable used for Despreading
mtx = complex(zeros(spreadFactor,128));
% xcd: Cross-correlated data
xcd = zeros(2*usrpFrameLength-1,1);
% xcm: Maximum value in cross-correlated data
xcm = double(0.0); %#ok<NASGU>
% xci: Index of maximum lag in cross-correlated data
xci = double(0); %#ok<NASGU>

% Initialize Persistent Data: Only on first call to PREAMBLEDET()
if isempty(fnf),    fnf = logical(false(1));    end
%if isempty(lsd),    lsd = uint16(0);            end 
if (isempty(ssb) || isempty(sss))
    % sds: Saved Data Structure: Contains Information about Expected Preamble
    sds = coder.load('transceiverData.mat','ss','ds','SSS');
    ssb = sds.ds;
    sss = sds.ss;
    SSS = sds.SSS;
end
if isempty(thr),    thr = double(crosscorr_thresh);          end

% Phase 1: Coarse complex cross-correlation (CCXC)
xcd(1:3*usrpFrameLength-1) = abs(step(Hcorr,drb,sss));
[xcm,xci] = max(xcd);
xci=xci+usrpFrameLength;
% Use xcorr function to get coarse estimate of synch delay, sd
% xcd(1:5631) = abs(xcorr(drb, sss));
% [xcm, xci] = max(xcd);
% [xcm, xci] = xcorrfft(drb, SSS); %%% implemented XCORR using FFT!!!!
xcm = xcm/(norm(drb,2)*norm(sss,2));
% xcm1 = xcm1/(norm(drb,2)*norm(sss,2));
if (fnf || (xcm > thr))
    ip = uint16(xci-(2*usrpFrameLength-1));
    if ((ip+(usrpFrameLength-1))>(2*usrpFrameLength))
        fnf = true;
    elseif (ip>0)
        fnf = false;
        % Set flag to say that Preamble detected, so proceed to next state
        fpd = logical(true(1));
%         fprintf('\nsync found!\n');
    end % IF SD+SYNCLEN>FRAMELEN
end % IF XCM>THRESH
% Retain this synchronization delay in memory
%lsd = uint16(sd);
return;
end % FUNCTION PREAMBLEDET

function y = demodnp(x)
% DEMODNP: Non-persistent Demodulation
% x: 128x1 complex double: Modulated Data
% y: 128x1 real double: Demodulated Data
d = real(zeros(128,1));
y = real(ones(128,1));
d(1:128) = mod(diff([mod(angle(x(1))+pi,2*pi);angle(x(1:128))]),(2*pi));
y(d<(pi/2)|d>(3*pi/2))=0;
return;
end % FUNCTION DEMODNP