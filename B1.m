% -------------------------------------------------------------------------
%       Acoustic wave equation finite difference simulator
% -------------------------------------------------------------------------

% ----------------------------------------
% Practice with the examples (files named "A**_exercise.m"), 
% by changing source/receiver position, source type, velocity values

clear all

% ----------------------------------------
% CONSTANT MODEL AND RECEIVERS ON A CIRCLE
% ----------------------------------------

% ----------------------------------------
% 1. Model parameters

model.x   = 0:1:1000;     % horizontal x axis sampling
model.z   = 0:1:500;      % vertical   z axis sampling

% temporary variables to compute size of velocity matrix
Nx = numel(model.x);
Nz = numel(model.z);

% velocity model assignement: constant velocity

model.vel=zeros(Nz,Nx)+2000;  %zeros(Nz, Nx) + 1800;   % upper layer

%z_interface = 250;                 % interface depth [m]
%iz = find(model.z >= z_interface, 1, 'first');

%model.vel(iz:end, :) = 3000;       % lower layer


% ----------------------------------------

% 2. Source parameters (move source)
source.x    = 400;   % 200
source.z    = 250;   % 100
source.f0   = 40;
source.t0   = 0.04;
source.amp  = 1;
source.type = 1;     % 2



% optional receivers in (recx, recz)
% the program round their position on the nearest velocity grid
Nr     = 100;   % nr of receivers
phi    = linspace(0,2*pi,Nr);
radius = 200;

% Receivers on a Circle
model.recx  = radius * cos(phi) + model.x(end)/2;   %linspace(0, model.x(end), Nr)  (Receivers on a line)
model.recz  = radius * sin(phi) + model.z(end)/2;   %zeros(1, Nr) + 10
model.dtrec = 0.004;




% ----------------------------------------
% 3. Simulation and graphic parameters in structure simul

simul.borderAlg=1;
simul.timeMax=0.5;

simul.printRatio=10;
simul.higVal=.1;
simul.lowVal=0.01;
simul.bkgVel=1;

simul.cmap='gray';  

% ----------------------------------------
% 4. Program call

recfield=acu2Dpro(model,source,simul);

% Plot receivers traces

figure
scal   = 2;  % 1 for global max, 0 for global ave, 2 for trace max
pltflg = 0;  % 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
             % 2 plot wiggle traces only, 3 imagesc gray, 4 pcolor gray
scfact = 1;  % scaling factor
colour = ''; % trace colour, default is black
clip   = 1; % clipping of amplitudes (if <1); default no clipping

seisplot2(recfield.data,recfield.time,1:Nr,scal,pltflg,scfact,colour,clip)
xlabel('receiver nr')
