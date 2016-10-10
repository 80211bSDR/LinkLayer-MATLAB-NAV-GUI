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