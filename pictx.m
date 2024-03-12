
% this script reads in a jpeg file, converts
% to 1xN vector, then does convolution with chirp signal and 1xN vector
% then a wave file is created.
% this wave file can be played on pc, and audio sent to 
% am transmitter
% bandwidth:  50hz to 10khz, this is audio bandwidth
%  convert a  image file into wave file

clear all;
close all;

clc;





[filename, pathname] = uigetfile('*.jpg','Pick a JPEG', 'c:\temp');

bb1 = [pathname ];
data = imread([pathname filename]);
data = rgb2gray(data);

% height and width of image
% values displayed on console
% you will need these values for the Pic_RX.m script
% they will dump out at command window
[h, w] = size(data)

data = double(data);






% form to vector  255 to 0 values
data = reshape(data',1,[]);

% scale to 0 to 1
data = data / max(data);




figure(1980)
plot(data)
title('image converted to time vector')

% create chirp signal
fs = 48e3;
f0 = 50;
f1 = 10e3;
nS = 48e3 * 5;
T = nS / fs;
k = (f1 - f0) / T;
t = [ 0: (nS - 1)] / fs;
lfm = sin(2*pi*(f0*t + k/2 * t.^2));
data = [data zeros(1,nS) ];
x = length(data) - length(lfm);
lfm = fft( [lfm zeros(1,x)]);



% freq domain convolution
data = ifft( fft(data).* lfm);
data = real(data);
data = data - mean(data);
data = data / max(data);



figure(1998)
plot(data)
title('lfm waveform')


% create chirp signal at start, preamble for sync
fs = 48e3;
f0 = 10e3;
f1 = 50;
T = 48e3 / fs;
k = (f1 - f0) / T;
t = [ 0: 47999] / fs;
preamblestart = sin(2*pi*(f0*t + k/2 * t.^2));



data = [preamblestart data];

data = data - mean(data);



data = [zeros(1,500e3)  data    zeros(1,200e3) ];

data = data / max(data);


% create wave file at location of jpeg file
% audio file called:  AM_image_audio.wav
fs = 48e3;
x = [bb1 'AM_image_audio.wav'];
audiowrite(x,data,fs);