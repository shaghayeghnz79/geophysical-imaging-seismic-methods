% -------------------------------------------------------------------------
%       Acoustic wave equation finite difference simulator
% -------------------------------------------------------------------------

% --------------------------------------------------
% Create your own model and example....
% --------------------------------------------------
clear all; close all; clc;

% Load image 
I = imread('velocity_model.jpg');
if size(I,3)==3
    I = rgb2gray(I);
end
I = im2double(I);          % values in [0,1]

% Define desired physical size (meters)
xMax = 7500;           
zMax = 2500;

Nz = size(I,1);
Nx = size(I,2);

model.x = linspace(0, xMax, Nx);
model.z = linspace(0, zMax, Nz);

% Map intensity to velocity (choose realistic bounds)
vMin = 1500;               % m/s (sediments / water-ish lower bound)
vMax = 4500;               % m/s (hard rock / salt-ish upper bound)



figure; imshow(I); title('Grayscale model used for mapping');
disp([min(I(:)) max(I(:)) mean(I(:))]);


% If bright = fast, use:
model.vel = vMin + I*(vMax - vMin);

% If bright = slow, invert it:
% model.vel = vMin + (1-I)*(vMax - vMin);


% optional receivers in (recx, recz)
% the program round their position on the nearest velocity grid

model.recx  = 50:50:model.x(end)-50;
model.recz  = model.recx*0 + 20;
model.dtrec = 0.004;

% ----------------------------------------
% 2. Source parameters

source.x = 800; 
source.z = 50;
source.f0 = 10; 
source.t0 = 0.15;
source.type = 1; 
source.amp = 1;

simul.timeMax = 4.0;
simul.borderAlg = 1;


simul.printRatio=10;
simul.higVal=.05;
simul.lowVal=0.03;
simul.bkgVel=1;

simul.cmap='gray';   % gray, cool, hot, parula, hsv

% ----------------------------------------
% 4. Program call

recfield=acu2Dpro(model,source,simul);

% Plot receivers traces

figure
scal   = 1;  % 1 for global max, 0 for global ave, 2 for trace max
pltflg = 0;  % 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
             % 2 plot wiggle traces only, 3 imagesc gray, 4 pcolor gray
scfact = 5;  % scaling factor
colour = '';  % trace colour, default is black
clip   = []; % clipping of amplitudes (if <1); default no clipping

seisplot2(recfield.data,recfield.time,[],scal,pltflg,scfact,colour,clip)
xlabel('receiver nr')
