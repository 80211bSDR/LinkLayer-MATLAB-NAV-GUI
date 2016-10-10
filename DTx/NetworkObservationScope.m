function [ energyThreshold ] = VirtualScope(usrpFrameLength, txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% aip: IP Address for USRP attached to this machine as a 3-Digit uint8
%      (as of 2/19/15, valid values for N210's in Lab are 102, 103, or 202)
aip = getipa();
% Function Handle to transceive() function for this IP Address
trx = eval(sprintf('@transceive%3d_mex',aip));
% ft:  Terminal Flag to release System objects
ft  = logical(false(1));
% db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
db  = complex(zeros(usrpFrameLength,1));

%Initialization
energyThreshold = 0;

% Compute energy across 10000 USRP packet lengths
nEnergySamples = 4e5;
E = zeros(1,nEnergySamples);
for i= 1:nEnergySamples
    df = trx(db,ft,txGain,rxGain,centerFreqRx,centerFreqTx,intFactor,decFactor);
    E(i) = sum(abs(df).^2);
end

% Sort the energy values in ascending order.
% Drop the largest value to suppress the outlier energy value.
% Pick a threshold that's like 4 times the noise floor
save E.mat E

figure(1)
plot(E,'LineWidth',2);
set(gca,'FontSize',12,'FontName','Arial','FontWeight','bold')
xlabel('USRP Frame Number','FontSize',23,'FontName','Arial','FontWeight','bold')
ylabel('Energy in the USRP Frame','FontSize',23,'FontName','Arial','FontWeight','bold')
title('Virtual Scope Pair: N210 with IP Address 103 and Dell Machine 1, DTx: N210 with IP Address 102 and Dell Machine 2','FontSize',25,'FontName','Arial','FontWeight','bold')

% figure(2)
% histogram(E,'LineWidth',2);
% set(gca,'FontSize',12,'FontName','Arial','FontWeight','bold')
% xlabel('Energy in a USRP Frame','FontSize',23,'FontName','Arial','FontWeight','bold')
% ylabel('Frequency of Occurrence','FontSize',23,'FontName','Arial','FontWeight','bold')
% title('Histogram of Energy in USRP Frames','FontSize',25,'FontName','Arial','FontWeight','bold')

% E = sort(E);
% energyThreshold = 4*E(end-2);

% Release the handles to Tx/Rx system object
trx(db,logical(true(1)),txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor);


end