function dtxPHYLayerVisual()
% This code is licensed under the LGPLv3 license. Please feel free to use the code in your research and development works. 
% We would appreciate a citation to the paper below when this code is helpful in obtaining results in your future publications.

% Publication for citation:
% Ramanathan Subramanian, Benjamin Drozdenko, Eric Doyle, Rameez Ahmed, Miriam Leeser, and Kaushik Chowdhury, 
% "High-Level System Design of IEEE 802.11b Standard-Compliant Link Layer for MATLAB-based SDR", accepted on March 3rd, 2016 
% for publication in IEEE Access Journal.

global aip choice

% Settings for data
% choice: 1 for random binary data of length l, 2 for image selection
choice = 2;

DTxInitParameters;

% aip: IP Address for USRP attached to this machine as a 3-Digit uint8
%      (as of 2/19/15, valid values for N210's in Lab are 102, 103, or 202)

aip = getipa();
% c8f: Count of the Number of 802.11b Frames Sent
c8f = uint8(1);
% cai: Count #ACK Iterations: Counts #iter in which DTx is waiting for ACK
cai = uint16(0);
% cni: Count #No-ACK Iterations: Counts #iter in which no ACK Rx'd
cni = uint16(0);
% cti: Count Total #Iterations: Countsc #iterations of main WHILE loop
cti = uint16(0);
% db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
db  = complex(zeros(usrpFrameLength,1));
% df:  This USRP Data frame: The most-recently-received frame from USRP Rx Buffer
df  = complex(zeros(usrpFrameLength,1));
% d2s: Data To Send: To put on Transmit Buffer while in a Tx Major State
d2s = complex(zeros(usrpFrameLength,1)); %#ok<NASGU>
% f8t: Flag 802.11b frame Transmitted; wait for ACK
f8t = logical(false(1)); %#ok<NASGU>
% fe:  Terminal Flag to Signal End-of-Transmission (EOT)
fe  = logical(false(1));
% fit: Flag Full Image Transmitted; program can exit after last ACK
fit = logical(false(1));
% frt: Flag Retransmit: On ACK timeout, retransmit last 802.11b frame again
frt = logical(false(1));
% ft:  Terminal Flag to release System objects
ft  = logical(false(1));
% st:  State for Designated Transmitter (DTx): 3 Digits, 1st Dig=1 for DTx
%      2nd Digit is 1 for Det Energy, 2 for Transmit DATA, or 3 for Rx ACK
st  = uint8(uint8(111)); %prm.DTxStateEnergyDetDIFS
% smt: DTx Major State: Most Significant 2 Digits of Full DTx State
smt = uint8(11); %DTxStateEnergyDet   %#ok<NASGU>
% swapFreqFlag: set flag for trx, do not swap tx freq. with rx swap
swapFreqFlag = 0;
h=msgbox(['Sending Image of Darth Vader..'],'Three Node Demo:');
set(findobj(h,'style','pushbutton'),'Visible','off')
% hft: Function Handle to transceive() function for this IP Address
trx = eval(sprintf('@transceive%3d_mex',aip));

tic;
while ~fe
    smt = st/uint8(10);
    if (smt==uint8(11)) %prm.DTxStateEnergyDet
        st = dtxMACLayer(st,frt);
        % st = uint8(121); %prm.DTxStateTransmitHeader (to work without the MAC layer)
    elseif (smt==uint8(12)) %prm.DTxStateTransmitDATA
        [d2s,f8t,fit] = dtx_2TransmitDATA(frt,ft);
        trx(d2s,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,swapFreqFlag);
        frt = logical(false(1));
        if (f8t)
            if (vm), fprintf(1,'@%5.2f: 802.11b DATA Packet #%d Transmitted.\n',toc,c8f);  end
            delete(h);
            myicon = imread('transmit.png');
            h=msgbox(['802.11b DATA Packet #' num2str(c8f) ' Transmitted'],'Success','custom',myicon);
            set(findobj(h,'style','pushbutton'),'Visible','off')
            st = uint8(131); %prm.DTxStateRxACKSearchPLCP
        end
    elseif (smt==uint8(13)) %prm.DTxStateRxACK
        df=trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,swapFreqFlag);
        [faf,dfl,flg,nrb,rbs,st] = dtx_3ReceiveACK(df,ft,st);
        if (faf)
            % If ACK received, reset count of #iterations with no ACK
            cai = uint16(0); cni = uint16(0);
            if (vm), fprintf(1,'@%5.2f: 802.11b ACK Packet #%d Received.\n\n',toc,c8f); end
            delete(h);
            myicon = imread('success.png');
            h=msgbox(['802.11b ACK Packet #' num2str(c8f) ' Received'],'Success','custom',myicon);
            set(findobj(h,'style','pushbutton'),'Visible','off')
            % Increment count of #802.11b frames sxsfully transceived
            c8f = c8f + uint8(1);
            %             if c8f==6
            %                 fit=true(1);
            %              %end
            if (fit)
                % If ACK rx'd for last DATA frame & full image was tx'd,
                % Change DTx State to Terminal State: no more Tx/Rx performed
                st = uint8(140); %prm.DTxStateEOT
                % Set exit flag
                fe = logical(true(1));
            else
                st = uint8(111); %prm.DTxStateEnergyDetDIFS
            end
        else
            % Increment count of #iterations with no ACK
            cai = (cai+uint16(1)); cni = (cni+uint16(1));
            % If no ACK received within TOA iterations, resend this DATA frame
            if (cni>=toa)
                % Reset no-ACK count
                cni = uint16(0);
                if (vm), fprintf(1,'@%5.2f: Timeout, No ACK Received in %d iterations, Retransmitting DATA #%d...\n\n',toc,toa,c8f); end
                delete(h);
                h=msgbox(['No ACK Received in ' num2str(toa) ' iterations, Retransmitting DATA #' num2str(c8f) '...'], 'Timeout','error');
                set(findobj(h,'style','pushbutton'),'Visible','off')
                st = uint8(111); %prm.DTxStateEnergyDetDIFS
                % Set flag to retransmit DATA
                frt = logical(true);
            end
        end
    end % END IF DS
    cti = (cti+uint16(1));
    % If no response from DRx received in TO iterations, then exit
    if (cai>=to)
        if (vm), fprintf(1,'@%5.2f: Timeout, No ACK Received in %d iterations, Continue transmit next frame...\n',toc,to); end
        if c8f == numPackets
            % Change DTx State to Terminal State: no more Tx/Rx performed
            st = uint8(140); %prm.DTxStateEOT
            % Set exit flag
            fe  = logical(true(1));
        else
            %set state
            st  = uint8(111); %prm.DTxStateEnergyDetDIFS
            %set retransmit flag to false
            frt = logical(false(1));
            %resets counters
            cai = uint16(0); cni = uint16(0);
            % Increment count of #802.11B frames
            c8f = c8f + uint8(1);
        end
    end % END IF CTI>TO
end % END WHILE ~FE
% Clear persistent data within all helper functions
ft = logical(true(1));
trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,swapFreqFlag);
dtx_2TransmitDATA(frt,ft);
dtx_3ReceiveACK(df,ft,st);
clear('ddd','dtx_2TransmitDATA','dtx_3ReceiveACK','preambleDet','rffe','sms');
clear(sprintf('transceive%3d_mex',aip));
return;
end % End Function DTX_V35

function [d2s,f8t,fit] = dtx_2TransmitDATA(frt,ft)
% DTX_2TRANSMITDATA: Transmits DATA 802.11b frame in consecutive USRP frames
% Function Arguments:
% d2s: Data To Send, frame data in usrpFrameLength samples to put on USRP Tx buffer
% f8t: Flag Full 802.11b Frame Transmitted: If true, specifies to change state to receive ACK
% fit: Flag Full Image Transmitted: If true, specifies to exit program after ACK
% frt: Flag to Retransmit Frame
% ft:  Flag Terminal: If true, specifies to release System objects

% Setting global variables
global usrpFrameLength numBits80211b halfSuperSamples80211b halfUsrpFrameLength numPayloadBits choice l ...
    numSuperFrameBits numMacHdrBits numSuperBits numFcsBits numPhyHdrBits ...
    spreadFactor packet_number aip

%determine addressTx for RA in ACK frame
addressTxStr = num2str(aip);
addressTx1 = str2double(addressTxStr(1:2));
addressTx2 = str2double(addressTxStr(3));

% Persistent Data: Maintained between function calls to drx_1ReceiveData
% c8f: 802.11b Frame Count: Counts #802.11b Frames transmitted
persistent c8f;
% c8s: 802.11b Frame Sample Count: Counts #802.11b Frame samples transmitted
persistent c8s;
% cib: Image Bit Count: Counts #Image Data Bits transmitted
persistent cib;
% cuf: USRP Frame Count: Counts #USRP frames transmitted
persistent cuf;
% d8b: Data 802.11b Frame Bits: Binary seq to partition into USRP frames
persistent d8b;
% d8s: Data 802.11b Frame Samples: Complex seq to partition into USRP frames
persistent d8s;
% dib: Data Image Bits: Binary sequence to be sent in payload segments
persistent dib;
% hcg: Handle to PHY PLCP CRC Generator
persistent hcg;
% hfg: Handle to MAC FCS Generator
persistent hfg;
% hrt: Handle to Raised Cosine Transmit Filter (RCTF) System object
persistent hrt;
% nbb: Number of MSDU/MAC Frame Body Bits per 802.11b Frame (def numPayloadBits)
persistent nbb;
% nib: Number of Image Data Bits: Length of dib vector (def 103,864)
persistent nib;
% nmb: Number of MPDU/MAC Frame Bits per 802.11b Frame (def 16,192)
persistent nmb;
% n8b: Number of PPDU/802.11b Frame Bits: Length of d8b vector (def numBits80211b)
persistent n8b;
% n8f: Number of 802.11b Frames to send the entire binary image data seq
persistent n8f;
% n8s: Number of PPDU/802.11b Frame Spread Samples (def halfSuperSamples80211b)
persistent n8s;
% nuf: Number of USRP Frames for this 802.11b Frame (def 256)
persistent nuf;

% Initialize Persistent Data: Only on first call to dtx_2TransmitDATA
if isempty(c8f),    c8f = uint32(0);        end
if isempty(c8s),    c8s = uint32(0);        end
if isempty(cib),    cib = uint32(0);        end
if isempty(cuf),    cuf = uint32(0);        end
if isempty(d8b),    d8b = zeros(numSuperFrameBits,1);   end
if isempty(d8s),    d8s = complex(zeros(halfSuperSamples80211b,1));  end
if isempty(dib) || isempty(nib)
    
    % Load data
    [dib, nib] = getData(choice, l, aip);
    
end
if isempty(hcg)
    hcg = comm.CRCGenerator('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial',[16,12,5,0]);
end
if isempty(hfg)
    hfg = comm.CRCGenerator('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial', ...
        [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0]);
end
if isempty(hrt)
    hrt = comm.RaisedCosineTransmitFilter('FilterSpanInSymbols',8, ...
        'Gain',1,'OutputSamplesPerSymbol',2,'RolloffFactor',0.3, ...
        'Shape','Square root');
end % IF ISEMPTY(HRT)
% Initial MAC frame bodies have 2012 octets, or numPayloadBits bits
if isempty(nbb),    nbb = uint32(numPayloadBits);        end
% Initial MAC frames have 2024 octets, or numPayloadBits+96=16,192 bits
if isempty(nmb),    nmb = nbb+uint32(numMacHdrBits+numFcsBits) + numSuperBits;       end
% Initial PHY frames have 2048 octets, or 16192+192=numBits80211b bits
if isempty(n8b),    n8b = nmb+uint32(numPhyHdrBits);      end
% Small image takes 103,864/numPayloadBits=6 802.11b Frames
if isempty(n8f),    n8f = uint32(ceil(double(nib)/double(nbb))); end
% Initial PHY frames have numBits80211b*11=halfSuperSamples80211b spread samples
if isempty(n8s),    n8s = n8b*uint32(spreadFactor);       end
% Initial 802.11b Frames take numBits80211b/64=256 USRP frames
if isempty(nuf),    nuf = uint32(ceil(double(n8b)/64)); end
% Local data preallocation
d2s = complex(zeros(usrpFrameLength,1));
dfi = complex(zeros(numBits80211b,1));
dfo = complex(zeros(halfSuperSamples80211b,1));
dss = complex(zeros(halfUsrpFrameLength,1));
f8t = logical(false(1));
fit = logical(false(1));
if (ft)
    % Release System objects: only on final call to dtx_2TransmitDATA()
    release(hcg);
    release(hfg);
    release(hrt);
    % Release System objects created by SMS() function
    sms(d8b,ft,n8b);
    % clear('hcg','hfg','hrt'); % Not supported for code generation
    % Clear persistent data within SMS() function
    % clear('sms'); % Not supported for code generation
else
    % ONLY ON 1ST USRP FRAME IN THIS 802.11B FRAME, prepare PPDU samples
    if (cuf == uint32(0))
        if (frt)
            % If retransmit flag set, decrease count of image bits sent
            cib = (cib - nbb);
        else
            % Otherwise, update 802.11b Frame Count
            c8f = (c8f + 1);
            packet_number = packet_number+1;
        end
        % ONLY ON LAST 802.11B FRAME, recalculate NXX persistent variables
        if (c8f == n8f)
            % Recalculate MSDU/MAC frame body length from #remaining bits to send
            nbb = min((nib-cib), uint32(numPayloadBits));
            % Recalculate MPDU/MAC frame length from MSDU length
            nmb = nbb + uint32(numMacHdrBits+numFcsBits) + numSuperBits;%+ numSuperBits
            % Recalculate PPDU/802.11b frame length from MPDU length
            n8b = nmb + uint32(numPhyHdrBits);
            % Recalculate #PPDU samples from #PPDU bits
            n8s = n8b * uint32(spreadFactor);
            % Recalculate #USRP frames per 802.11b frame
            nuf = uint32(ceil(double(n8b)/64));
        end
        % On 1st USRP frame, prepare this 802.11b frame
        % Send SYNC signal in 1st 128 bits
        d8b(001:128) = ones(128,1);
        % Send PHY SFD & PLCP Header in next 64 bits
        d8b(129:144) = [0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1];
        d8b(145:152) = [0;1;0;1;0;0;0;0];
        d8b(153:160) = zeros(8, 1);
        % LENGTH=MACHeader (64)+MSDU/MAC Frame Body(0)+MAC FCS (32)
        d8b(161:176) = de2bi(double(nmb), 16)';
        % Append 16-bit CRC to 32-bit PLCP Header: result is 48 bits
        d8b(145:192) = step(hcg, d8b(145:176));
        % Send MAC Header for DATA frame
        % DATA Frame Control (16 bits): Ver 00, Type 10, Subtype 0000
        ProtocolVer = [0;0];
        TypeBits = [1;0];
        SubType = [0;0;0;0];
        % Rest of Frame Control 8 bits, set to 0's
        ToDS = [0];
        FromDS = [0];
        MoreFlag = [0];
        RetryBit = [0];
        PwrMgmt = [0];
        MoreData = [0];
        WepBit = [0];
        OrderBit = [0];
        d8b(193:208) = [ProtocolVer;TypeBits;SubType;ToDS;FromDS;MoreFlag;...
            RetryBit;PwrMgmt;MoreData;WepBit;OrderBit];
        % DATA Frame Duration/ID Slot (16 bits) holds Frame number in sequence
        d8b(209:224) = de2bi(double(c8f), 16)';
        % DATA Frame Address 1 is RA
        d8b(225:272) = [de2bi(0,32),de2bi(20,8),de2bi(2,8)]';
        % DATA Frame Address 2 is TA
        d8b(273:320) = [de2bi(0,32),de2bi(addressTx1,8),de2bi(addressTx2,8)]';
        % Address 3
        d8b(321:368) = zeros(48,1);
        % Sequence Control
        d8b(369:384) = zeros(16,1);
        % Address 4
        d8b(385:432) = zeros(48,1);
        % DATA MSDU / MAC Frame Body: n8b bits
        d8b(433:(432+nbb)) = dib(cib+1:cib+nbb);
        % Append 32-bit FCS to MAC Header(64)+MSDU(numPayloadBits): res 16,192 bits
        d8b(193:464+nbb) = step(hfg, d8b(193:(432+nbb)));
        % Append 16 zeros to 80211b frame, to satisfy USRP frame 'multiples of 64bit' requirement
        d8b(465+nbb:480+nbb) = zeros(numSuperBits,1);
        % Scramble, Modulate, and Spread this 802.11b Frame
        dfi(1:n8b) = d8b(1:n8b);
        dfo = sms(dfi,ft,n8b);
        d8s(1:n8s) = dfo(1:n8s);
        % Update Image Data Bit Count
        cib = cib + nbb;
    end % IF CUF==0
    dss(1:halfUsrpFrameLength)  = d8s(c8s+1:c8s+halfUsrpFrameLength);
    d2s(1:usrpFrameLength) = step(hrt,dss);
    c8s = c8s + uint32(halfUsrpFrameLength);
    cuf = cuf + uint32(1);
    if ((cuf>=nuf) || (c8s>=n8s))
        % Update 802.11 Frame Transmitted Flag to TRUE
        f8t = logical(true(1));
        if ((c8f>=n8f) || (cib>=nib))
            % Update Entire Image Transmitted Flag to TRUE
            fit = logical(true(1));
        end
        % Reset 802.11b sample count and USRP frame count
        c8s = uint32(0);
        cuf = uint32(0);
    end % IF CUF==NUF
end
end % End Function DTX_2TRANSMITDATA

% [faf,st] = dtx_3ReceiveACK(df,ft,st)
function [faf,dfl,flg,nrb,rbs,st] = dtx_3ReceiveACK(df,ft,st)
% DRX_1RECEIVEDATA: Gets 802.11b DATA frame in 256 consecutive USRP frames
% Function Arguments:
% df:  This Data Frame, Raw USRP frame data in usrpFrameLength samples
% dfl: Data Flagged: uint16 to accompany data, set when status flag is true
% flg: Status Flags: a 1x5 logical array, carrying the following flags:
% (1): fdf: Flag Detected Preamble: Set true if PLCP Preamble (SYNC) found
% (2): fph: Flag PLCP Header Found: Init false, set true if PHY Header rx'd
% (3): fec: Flag Error CRC: Init false, set true if PHY Header CRC in error
% (4): fmh: Flag MAC Header Found: Init false, set true if MAC Header rx'd
% (5): fpf: Flag All Payload Found: Init false, set true if all payload rxd
% (6): ffc: Flag Frame Control: Set true if FrameCtrl~=DATA (e.g. if ACK)
% ft:  Flag Terminal: If true, specifies to release System objects
% nrb: Number of Recovered (MAC) Bits: Zero if not returning any MAC bits
% rbs: Recovered Binary Sequence: Taken from MAC Hdr/Payload/FCS (64 bits)
% st:  State of Designated Transmitter (DRx), a 3-digit enumeration

% Setting global variables
global halfUsrpFrameLength numUsrpBits doubleUsrpFrameLength ...
    numMpduBits numMacHdrBits numSuperBits aip ...
    syncnum vm

% Persistent Data: Maintained between function calls to drx_1ReceiveData
% chf: Header Frame Count: Counts #USRP frames that have header info (0-2)
persistent chf;
% cp:  Payload Frame Count: Counts #USRP frames w/only payload data (0-251)
persistent cpf;
% dld: Data Last Decoded: Holds bits from last decoded USRP frame (len 64)
persistent dld;
% hcd: Handle to PHY PLCP CRC Detector
persistent hcd;
% i1b: Index of 1st bit in decoded USRP frame; found by SFD Detection
persistent i1b;
% i1s: Index of 1st sample in USRP frame (SYNC Delay+1): the sample# in Rx
%      buffer (rb) that marks start of frame; found by Preamble Detection
persistent i1s;
% n8f: Number in Sequence of MPDU 802.11b frame
persistent n8f;
% nmb: Number of MPDU Bits (from LENGTH in PLCP Header, def. numMpduBits bits)
persistent nmb;
% npf: Number of Payload & FCS Frames =ceil((nmb-numUsrpBits)/numUsrpBits)
persistent npf;
% rb: Receive Buffer: Twice Length of USRP frame for Preamble Det (doubleUsrpFrameLength samples)
persistent rb;

%address persistent
persistent addressTx;

faf=logical(false(1));

% CONSTANTS: For Construction of System objects
cas = double(0.5);
cau = double(halfUsrpFrameLength);
cef = double(100.0);
% Initialize Persistent Data: Only on first call to drx_1ReceiveData
if isempty(chf),    chf = uint8(0);                 end
if isempty(cpf),    cpf = uint8(0);                 end
if isempty(dld),    dld = real(zeros(64,1));        end
if isempty(n8f),    n8f = uint16(0);                end
if isempty(hcd)
    hcd = comm.CRCDetector('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial',[16,12,5,0]);
end % END IF ISEMPTY(HCD)

if isempty(i1b),    i1b = uint8(1);                 end
if isempty(i1s),    i1s = uint16(1);                end
if isempty(nmb),    nmb = uint16(numMpduBits+numSuperBits);      end
if isempty(npf),    npf = uint8(ceil((nmb-numUsrpBits)/numUsrpBits));               end
if isempty(rb),     rb  = complex(zeros(doubleUsrpFrameLength,1));   end
% Local Function Data: Overwritten on every call to drx_1ReceiveData
cra = zeros(41,1);
crm = zeros(2,2);
% dfb: This Frame + Last Frame Bits
dfb = zeros(numUsrpBits*2,1);
% dfd: This Frame Decoded: 1/11 the Length of this recovered USRP frame (64)
dfd = zeros(numUsrpBits,1);
dfl = uint16(0);
% dfr: This Frame Recovered: Half the Length of this USRP frame tf (halfUsrpFrameLength)
dfr = complex(zeros(halfUsrpFrameLength,1));
flg = logical(false(1,6));
flt = logical(false(1,1)); %#ok<NASGU>
ips = uint16(0); %#ok<NASGU>
nrb = uint16(0);
rbs = zeros(numMacHdrBits,1);
if (ft)
    release(hcd);
    %clear('hcd'); % Not supported for code generation
    rffe(df,ft,cas,cau,cef);
    ddd(dfr,ft);
    % Clear persistent data within RFFE() and DDD() functions
    % clear('rffe','preambleDet','ddd'); % Not supported for code generation
else
    % RF Front End: AGC, Freq Offset Correction, and RCRF
    dfr(1:halfUsrpFrameLength) = rffe(df,ft,cas,cau,cef);
    % Shift left receive buffer data by one recovered frame length (halfUsrpFrameLength)
    rb(1:2112) = rb((halfUsrpFrameLength+1):doubleUsrpFrameLength);
    % Add this recovered frame to end (last halfUsrpFrameLength samples) of receive buffer
    rb(2113:doubleUsrpFrameLength) = dfr(1:halfUsrpFrameLength);
    if (st==uint8(131))     %prm.DRxStateRxSearchPreamble
        % Detect Preamble: Updates Synchronization Delay to Location of Max
        % Correlation with Expected Preamble; when correlation is above a
        % threshold, it updates DRx State to "DecodeHeader"
        [flt,ips] = preambleDet(rb);
        if (flt)
            if (vm), fprintf('ACK''s Preamble Detected!\n'); end
            syncnum = syncnum +1;
            % If detected PLCP Preamble, set flag #1: fdp
            flg(1,1) = logical(true(1));
            % Pass back this Synch Delay value in Flagged Data, dfl
            dfl = uint16(ips);
            % Add 1 USRP frame size to ips to get i1s: idx of 1st sample in frame
            i1s = ips + uint16(halfUsrpFrameLength);
            % Decode SYNC Data (for persistent vars in ddd function)
            dfr(1:halfUsrpFrameLength)  = rb(ips:(ips+uint16((halfUsrpFrameLength-1))));
            ddd(dfr,ft);
            dfr(1:halfUsrpFrameLength)  = rb(i1s:(i1s+uint16((halfUsrpFrameLength-1))));
            dld(1:64)   = ddd(dfr,ft);
            st  = uint8(132); %prm.DRxStateRxDecodeHeader;
        end
    else
        % Prepare only the 1st halfUsrpFrameLength frame bits starting at the synch delay
        dfr(1:halfUsrpFrameLength)  = rb(i1s:(i1s+uint16((halfUsrpFrameLength-1))));
        % Despread, Demodulate, and Descramble Samples to make bitstream
        dfd(1:numUsrpBits)   = ddd(dfr,ft);
        % Combine decoded 64 bits with 64 bits from last decoded frame
        dfb(1:numUsrpBits)   = dld(1:numUsrpBits);
        dfb(numUsrpBits+1:numUsrpBits*2) = dfd(1:numUsrpBits);
        if (st==uint8(132)) %prm.DRxStateRxDecodeHeader
            chf = chf+uint8(1);
            if (chf==uint8(1))
                i1b = uint8(numUsrpBits+1);
                %                 fprintf(1,'\n\nPreSFD dfb bits:');
                %                 fprintf(1,'%d',dfb);
                %                 fprintf(1,'\n\n');
                % Lvl 3 Fine SFD Correlation: Find exact PLCP SFD start
                if ~isequal(dfb(i1b:(i1b+15)),[0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1])
                    % If demodulated sequence is not the same as scrambled Sync,
                    % perform a fine-tuned Correlation to find the index at
                    % which data is closest to start of sequence & readjust sd
                    % iab(1:41) = (i1b-20):(i1b+20);
                    % for ib = 1:41
                    iab(1:128) = (i1b-64):(i1b+63);
                    for ib = 1:113
                        if isequal(dfb(iab(ib):(iab(ib)+15)), ...
                                [0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1]);
                            i1b = iab(ib);
                            break;
                        else
                            i1b = uint8(numUsrpBits+2);
                        end
                        %                         crm(1:2,1:2) = abs(corrcoef(dfb(iab(ib):(iab(ib)+15)), ...
                        %                             [0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1]));
                        %                         cra(ib) = crm(2,1);
                    end % FOR SDI=1:WINLEN
                    %                     [maxVal,imb] = max(cra);
                    %                     i1b = iab(imb);
                    %                     if maxVal == 1
                    %                         i1b = iab(imb);
                    %                     else
                    %                         i1b = uint8(numUsrpBits);
                    %                     end
                    
                end
                if (i1b<=uint8(numUsrpBits+1))
                    flg(1,2) = logical(true(1));
                    % Get MPDU (MAC Hdr+Payload+FCS) Length from PLCP Header
                    nmb = uint16(bi2de(dfb((i1b+32):(i1b+47)).'));
                    % Pass back this Payload length value in dfl
                    dfl = uint16(nmb);
                    % Check CRC in PLCP Header
                    [~,flt] = step(hcd, dfb((i1b+16):(i1b+63)));
                    if (flt)
                        % If CRC check fails, set flag #3: fec to true
                        flg(1,3) = logical(true(1));
                        % Use default MPDU length: numMpduBits
                        nmb = uint16(numMpduBits+numSuperBits); dfl = nmb;
                    end
                else
                    % If index of 1st bit>65, wait until next USRP frame is
                    % decoded, then take
                    chf = chf-uint8(1);
                end
                % Calculate number of Payload Frames from MPDU length
                npf = ceil((nmb-numUsrpBits)/numUsrpBits);
            elseif (chf==uint8(2)) %prm.NumHeaderFrames
                % Process frame control in MAC Header
                if isequal(dfb(i1b:(i1b+15),1),[0;0;0;1;1;1;0;1;1;1;1;1;1;1;1;1])
                    if (vm),
                        fprintf(1,'ACK''s Frame-Control Readout:');%%%%************Checking frame control at DRx
                        fprintf(1,'%d',dfb(i1b:(i1b+15),1));
                        fprintf(1,'\n');
                    end
                    % Pass back all MAC bits, Header+Payload+FCS
                    rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
                    nrb = uint16(numUsrpBits);
                    % Get Number in Duration of 802.11b Frame from MAC Header
                    n8f = uint16(bi2de(dfb((i1b+16):(i1b+31)).'));
                    % Set flag #4: fmh true when MAC Header is found
                    flg(1,4) = logical(true(1));
                    % Pass back Sequence Number in Flagged Data, dfl
                    dfl = uint16(n8f);
                    
                    %                     faf=logical(true(1));
                    %                     chf = uint8(0);
                    %                     st  = uint8(111); %prm.DRxStateRxGetPayload
                    
                else
                    % Set flag #6: ffc true when MAC Frame Control ~DATA
                    flg(1,6) = logical(true(1));
                    % Send back the Frame Control Received in dfl
                    dfl = uint16(bi2de(dfb(i1b:(i1b+15),1).'));
                    % Return to Search for Preamble
                    st  = uint8(131); %prm.DRxStateRxSearchPreamble
                    % Reset all count variables internal to function
                    chf = uint8(0);
                    cpf = uint8(0);
                    if (vm), fprintf('Returning To Detect Preamble..\n'); end
                    rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
                end
            elseif (chf==uint8(3)) %prm.NumHeaderFrames
                %CHECK ADDRESS BEFORE PROCEEDING
                %extract addresses
                addressTx = str2double(strcat(num2str(bi2de(dfb(i1b:(i1b+7)).')),num2str(bi2de(dfb(i1b+8:(i1b+15)).'))));
                addressTxString=strcat(num2str(bi2de(dfb(i1b:(i1b+7)).')),'.',num2str(bi2de(dfb(i1b+8:(i1b+15)).')));
                %print addresses
                if (vm), fprintf(1,'ACK Addresed to DTx: 192.168.%s \n',addressTxString); end
                %if packet is addressed to this receiver
                if addressTx == aip
                    faf=logical(true(1));
                    chf = uint8(0);
                    st  = uint8(111); %prm.DRxStateRxGetPayload
                else
                    if (vm), fprintf('Wrong MAC Address, Resetting to Detect Preamble..\n'); end
                    % Set flag #6: ffc true when MAC Frame Control ~DATA
                    flg(1,6) = logical(true(1));
                    % Send back the Frame Control Received in dfl
                    % Return to Search for Preamble
                    st  = uint8(131); %prm.DRxStateRxSearchPreamble
                    % Reset all count variables internal to function
                    chf = uint8(0);
                    cpf = uint8(0);
                    rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
                end
            end % END IF CH==#
            
            %         elseif (st==uint8(213)) %prm.DRxStateRxGetPayload
            %
            %             % Update Payload Frame Count
            %             cpf = cpf+uint8(1);
            %             if (cpf<npf) %prm.NumPayloadFrames
            %                 % Store All Payload Bits in rbs and update bit count nrb
            %                 nrb = uint16(numUsrpBits);
            %                 rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
            %             else  % On last payload frame for this 802.11b frame,
            %                 % Calculate #bits to return from remainder after division
            %                 % of #MPDU bits by 64 bits/USRPframe
            %                 nrb = uint16(rem(nmb,uint16(numUsrpBits)));
            %                 if (nrb==uint16(0)), nrb=uint16(numUsrpBits); end
            %                 % Pass back all bits, even FCS used to verify no error
            %                 rbs(uint8(1):uint8(nrb)) = dfb(i1b:(i1b+uint8(nrb)-uint8(1)));
            %                 % Set flag #5 true to signify all payload data recovered
            %                 flg(1,5) = logical(true(1));
            %                 % Pass back total #payload frames in flagged data, dfl
            %                 dfl = uint16(npf);
            %                 % Change Major State from Rx DATA to Tx ACK
            %                 st = uint8(220); %prm.DRxStateTxACKSendACK
            %                 % Reset all count variables internal to function
            %                 chf = uint8(0);
            %                 cpf = uint8(0);
            %                 rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
            %             end
            
        end % END IF SR==#
        % Store bits from this frame for use in next frame's processing
        dld(1:numUsrpBits) = dfd(1:numUsrpBits);
    end % END IF SR==211U
end % END IF FT
end % END FUNCTION DRX_1RECEIVEACK


