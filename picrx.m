close all
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% enter height and width of image
% units in pixels
h = 1000;
w = 998;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





[filename, pathname] = uigetfile('*.wav','Pick a wave file', 'C:\temp\');
x = [pathname filename];

[data,fswave] = audioread(x);
data = data(:,1);
data = data';

% data = single(data);
x = gcd(48000,fswave);
a = 48000 / x;
b = fswave / x;

if fswave ~= 48000
    data = resample(data,a,b);
end

msamples = length(data);

figure()
plot(data);



fs = 48e3;
f0 = 10e3;
f1 = 50;
T = 48e3 / fs;
k = (f1 - f0) / T;
t = [ 0: 47999] / fs;
preamblestart = sin(2*pi*(f0*t + k/2 * t.^2));
preamblestart = preamblestart(end:-1:1);
psamples = length(preamblestart);
dsamples = msamples - psamples;
syncfft = fft( [preamblestart zeros(1,dsamples) ]);

sync = ifft( fft(data) .* syncfft);
sync = abs(real(sync));
figure()
plot(sync)
[sync imax] = max(sync);





fs = 48e3;
f0 = 50;
f1 = 10e3;
nS = 48e3*5;
T = nS / fs;
k = (f1 - f0) / T;
t = [ 0: (nS - 1)] / fs;
lfm = sin(2*pi*(f0*t + k/2 * t.^2));
lfm =  lfm(end:-1:1);
lfmsamples = length(lfm);
dsamples = msamples - lfmsamples;
lfm = fft( [ lfm zeros(1,dsamples) ] );

data = ifft( fft(data).* lfm);

data = real(data);
data = data/max(data);




a = imax + nS; 
b = a + (w*h) - 1;

data = data(a:b);
n = length(data);






figure(2003)
plot(data)
title('waveform before reshape to image dim');

data = reshape(data,w,[]);

data = data';


% if image appears shifted, then set variable below
% to amount of pixels image seems shifted, 
% number can be negative or positive
% if shifted by 250 pixels, then enter in 250 below
% for now i set it to zero
shift_image_samples = 0;
 data = circshift(data,shift_image_samples,2);




% display the image in different color maps

figure(3001)
 set(3001,'Position',[ 40 60 w h])
colormap('bone')
imagesc(data);



figure(3002)
set(3002,'Position',[1000 60 w h])
colormap('gray')
imagesc(data);


figure(3003)
colormap('copper')
imagesc(data);









