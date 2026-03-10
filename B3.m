% Acoustic wave equation finite difference simulator % ------------------------------------------------------------------------- 
% Build a model that "focuses" the wavefield in one direction and/or % against one target. 
% You can use array of sources properly delayed (beam-forming), 
% and/or obstacles (reflectors) properly shaped (acoustic lens/horn) 
% https://en.wikipedia.org/wiki/Architectural_acoustics

clear all; close all; clc

% ----------------------------------------
% 1. Model parameters
model.x = 0:1:1000;     % x grid [m]
model.z = 0:1:300;      % z grid [m]

Nx = numel(model.x);
Nz = numel(model.z);

% Two-layer velocity model
model.vel = zeros(Nz, Nx);
z_int = 200;            % interface depth [m]
for kz = 1:Nz
    if model.z(kz) < z_int
        model.vel(kz, :) = 1000;  % upper layer [m/s]
    else
        model.vel(kz, :) = 2000;  % lower layer [m/s]
    end
end

% ----------------------------------------
% 2. Source parameters (line of point sources)
source.x = 10:1:(model.x(end)-10);
Nsources = numel(source.x);

source.z    = ones(1, Nsources) * 50;   % sources at z=50 m
source.f0   = ones(1, Nsources) * 30;   % [Hz]
source.amp  = tukeywin(Nsources, .5)';  % taper to reduce edge effects
source.type = ones(1, Nsources) * 1;    % 1: Ricker

% ----------------------------------------
% Focus point (target)
xf = 700;    % [m]
zf = 250;    % [m] (same depth as receiver line)  %receiver 66 = (700-50)/10 +1

% Approximate velocity for delay calculation (sources in upper layer)
v0 = 1000;   % [m/s]

% Compute focusing delays: farther sources fire earlier
distF  = sqrt((source.x - xf).^2 + (source.z - zf).^2);

% Choose an intended focus time (makes the result more stable/clear)
Tfocus = 0.35;                 % seconds %Tfocus is the time at which you want all waves to meet at the focus point
t_emit = Tfocus - distF / v0;  % earlier for larger distance

% Shift so all emission times are positive
t_emit = t_emit - min(t_emit) + 0.01; % -min is for solving problem of negative delay %0.01 is a small safety margin

source.t0 = t_emit;

% ----------------------------------------
%  Receivers
% Line receivers + a virtual receiver exactly at the focus point (last one)
recx_line = 50:10:(model.x(end)-50);
recz_line = ones(1, numel(recx_line)) * (model.z(end) - 50);  % z=250 m

model.recx  = [recx_line, xf];
model.recz  = [recz_line, zf];
model.dtrec = 0.004;

idx_focus = numel(model.recx);   % focus receiver is last

% ----------------------------------------
% 3. Simulation parameters
simul.borderAlg  = 1;
simul.timeMax    = max(0.7, Tfocus + 0.25);   % ensure simulation covers focus time

simul.printRatio = 10;
simul.higVal     = .6;
simul.lowVal     = .1;
simul.bkgVel     = 1;
simul.cmap       = 'gray';

% -------------------------------------------------------------------------
% 4. Run FOCUSED case ONLY
rec_foc = acu2Dpro(model, source, simul);

% -------------------------------------------------------------------------
% 5. Focused seismogram (line receivers only, exclude last focus receiver)
figure
seisplot2(rec_foc.data(:,1:end-1), rec_foc.time, [], 2, 0, 2, '', [])
xlabel('receiver nr (line receivers only)')

title('Focused case: seismogram (including focus receiver)')
ylim([0 simul.timeMax])

% -------------------------------------------------------------------------
% 6. Trace energy vs receiver position (SORTED, includes focus receiver)
dt = rec_foc.time(2) - rec_foc.time(1);

Erec = sum(rec_foc.data.^2, 1) * dt;     % energy of each receiver trace

% Use the ACTUAL receiver x positions returned by the simulator
recx = rec_foc.recx;   % safer than model.recx (some receivers can be rejected)

% Sort by receiver x so the line does not "jump" when xf is appended at the end
[recxS, idx] = sort(recx);
ErecS = Erec(idx);

figure
plot(recxS, ErecS,'LineWidth',1.5)
grid on
xlabel('Receiver x (m)')
ylabel('Trace energy  \Sigma p(t)^2 \Deltat')
title('Focused case: trace energy vs receiver position (sorted)')
xline(xf,'--','focus x');


%log scale 
figure
semilogy(recxS, ErecS,'LineWidth',1.5)
grid on
xlabel('Receiver x (m)')
ylabel('Trace energy  \Sigma p(t)^2 \Deltat  (log scale)')
title('Focused case: trace energy vs receiver position (log scale)')
xline(xf,'--','focus x');
