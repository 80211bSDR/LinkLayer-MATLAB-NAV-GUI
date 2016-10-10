function st = dtxMACLayer(st,frt)
% DTX_MAC_Layer Wait DIFS and Random Backoff Time

global usrpFrameLength DIFS cMin energyThreshold txGain rxGain aip ...
    centerFreqTx centerFreqRx intFactor decFactor vm energySamples

persistent k;
persistent swapFreqFlag;
if isempty(k),    k = uint8(1);                 end
if isempty(swapFreqFlag),    swapFreqFlag = 1;                 end


%Random Backoff time
if frt
    k=uint8(min(k+1,3));
else
    k=uint8(1);
end
trb = randi((2^(k))-1)*cMin;


% hft: Function Handle to transceive() function for this IP Address
trx = eval(sprintf('@transceive%3d_mex',aip));

if (st==uint8(111))
    
    % Frame Ready; Start Timer for DIFS
    % if (vm), fprintf('Entering DIFS state..\n'); end
    tic; t = 0;
    EnrFlg  = logical(false(1));
    % Wait for DIFS
    while t < DIFS
        t=toc;
        % ft:  Terminal Flag to release System objects
        ft  = logical(false(1));
        % db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
        db  = complex(zeros(usrpFrameLength,1));
        df = trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,swapFreqFlag);
        if (sum(abs(df).^2)> energyThreshold)
            if (vm), fprintf('Energy detected in DIFS state, Backing off!!\n'); end
            tic;
            EnrFlg=logical(true(1));
        end
    end
    % if (vm), fprintf('...DIFS ends.\n'); end
end

% %Virtual Carrier Sensing
% tic; t = 0;
% if EnrFlg == 1
%     while t < 1
%         t=toc;
%     end
% end

% Reset Timer for Random Backoff
% if (vm), fprintf('Entering Random Backoff state..\n'); end
tic; t = 0;

% Random Backoff
ft=logical(false(1));
tstop_rb = 0; % Backoff epoch
while t < trb
    t=toc;
    % db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
    db  = complex(zeros(usrpFrameLength,1));
    df = trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,1);
    % energySamples = [energySamples sum(abs(df).^2)];
    if (sum(abs(df).^2)> energyThreshold)
        if (vm), fprintf('Energy detected in Random Backoff state, Backing off!!\n'); end
        tstop_rb=toc;
        tic; t=0;
        trb=trb-tstop_rb;
    end
end
% if (vm), fprintf('...Random Backoff ends.\n'); end

st = uint8(121); %prm.DTxStateTransmitHeader;

end
