% -------------------------------------------------------------------------
%       Acoustic wave equation finite difference simulator
% -------------------------------------------------------------------------

% --------------------------------------------------
% In a homogeneous medium, compute the energy of traces at increasing 
% distance from the source
% Plot the resulting energy vs distance



clear all


% ----------------------------------------
% 1. Model parameters

model.x   = 0:1:1000;    % horizontal x axis sampling
model.z   = 0:1:250;     % vertical   z axis sampling

% temporary variables to compute size of velocity matrix
Nx = numel(model.x);
Nz = numel(model.z);

% example of velocity model assignement
% two layers with an interface at z_interface meters depth
model.vel = zeros(Nz, Nx) + 1500;


% optional receivers in (recx, recz)
% the program round their position on the nearest velocity grid
model.recx  = 120:20:900;
model.recz  = model.recx*0+20;  % ... a trick to have same nr elements  of recx
model.dtrec = 0.004;
Nr=numel(model.recx);

% ----------------------------------------
% 2. Source parameters

source.x    = [100];
source.z    = [20 ]; 
source.f0   = [25 ];
source.t0   = [0.04  ];
source.amp  = [1 ];
source.type = [1];    % 1: ricker, 2: sinusoidal  at f0

% ----------------------------------------
% 3. Simulation and graphic parameters in structure simul

simul.borderAlg=1;
simul.timeMax=1.2;

simul.printRatio=10;
simul.higVal=.03;
simul.lowVal=0.01;
simul.bkgVel=1;

simul.cmap='jet';   % gray, cool, hot, parula, hsv

% ----------------------------------------
% 4. Program call

recfield=acu2Dpro(model,source,simul);

% ------------------------------------------------------------
% ENERGY OF TRACES vs DISTANCE FROM THE SOURCE (homogeneous case)
% ------------------------------------------------------------

% Receiver-source distance (use true distance, not only horizontal offset)
dx = recfield.recx - source.x(1);
dz = recfield.recz - source.z(1);
dist = sqrt(dx.^2 + dz.^2);        % [m]

% Trace energy: E = integral p(t)^2 dt  (numerical sum)
dt = recfield.time(2) - recfield.time(1);
E  = sum(recfield.data.^2, 1) * dt;  % 1 x Nr

% Sort for a clean plot
[distS, idx] = sort(dist);
ES = E(idx);

disp([min(distS) max(distS) min(ES) max(ES)])


% Plot energy vs distance
figure
plot(distS, ES, 'o-', 'LineWidth', 1.5)
grid on
xlabel('Receiver-source distance (m)')
ylabel('Trace energy  \int p(t)^2 dt')
title('Energy vs distance (homogeneous medium)')

% Optional: log scale (often clearer)
figure
semilogy(distS, ES, 'o-', 'LineWidth', 1.5)
grid on
xlabel('Receiver-source distance (m)')
ylabel('Trace energy  \int p(t)^2 dt (log scale)')
title('Energy vs distance (log scale)')


% Plot receivers traces

figure
scal   = 2;  % 1 for global max, 0 for global ave, 2 for trace max
pltflg = 0;  % 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
             % 2 plot wiggle traces only, 3 imagesc gray, 4 pcolor gray
scfact = 5; % scaling factor
colour = ''; % trace colour, default is black
clip   = []; % clipping of amplitudes (if <1); default no clipping



rec_offset = model.recx-source.x;
seisplot2(recfield.data,recfield.time,rec_offset,scal,pltflg,scfact,colour,clip)
xlabel('receiver-source offset (m)')


axis xy

