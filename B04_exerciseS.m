% ============================================================
% B04 Refraction picking + time-intercept method (FINAL, CALIBRATED)
% Works when your input is a PICTURE (PNG) of a plot (not real data).
%
% What it does:
% 1) Shows the PNG
% 2) You CALIBRATE the axes by clicking 4 points on the axis ticks:
%    (1) x=0 tick on x-axis
%    (2) x=450 tick on x-axis
%    (3) t=0 tick on y-axis
%    (4) t=0.4 tick on y-axis
% 3) Then you pick DIRECT points (left-click to add, right-click/ENTER to end)
% 4) Then you pick REFRACTED points (left-click to add, right-click/ENTER to end)
% 5) Converts picks to physical units (m, s), fits lines, computes v1, v2, ti, h
% 6) Saves results and figures
% ============================================================

clear; close all; clc;

gatherFile = 'B04_gather.png';

% ---- Known physical axis values from the figure ----
x_min = 0;        % m
x_max = 450;      % m
t_min = 0;        % s
t_max = 0.4;      % s

% ---- Read image ----
I = imread(gatherFile);
if size(I,3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end

% ============================================================
% 1) CALIBRATION: map pixel coords -> physical coords
% ============================================================
figCal = figure('Color','w','Position',[100 100 1100 650]);
imshow(Igray,'InitialMagnification','fit'); colormap(gray);

title({
    'CALIBRATION (4 clicks):'
    '1) click x=0 tick on x-axis line'
    '2) click x=450 tick on x-axis line'
    '3) click t=0 tick on y-axis line'
    '4) click t=0.4 tick on y-axis line'
    'Tip: click the tick marks on the axis, not the text labels.'
});

% Get 4 calibration clicks (pixel coordinates)
[xp, yp] = ginput(4);

xpix0 = xp(1);  xpix1 = xp(2);
ypix0 = yp(3);  ypix1 = yp(4);

% Linear mapping:
% x_phys = ax*x_pix + bx
ax = (x_max - x_min) / (xpix1 - xpix0);
bx = x_min - ax * xpix0;

% t_phys = at*y_pix + bt
% Pixel y increases down, and seismic time increases down, so consistent.
at = (t_max - t_min) / (ypix1 - ypix0);
bt = t_min - at * ypix0;

pix2x = @(xpix) ax*xpix + bx;
pix2t = @(ypix) at*ypix + bt;

% Show calibration markers 
hold on;
plot(xp(1:2), yp(1:2), 'ys', 'MarkerFaceColor','y', 'MarkerSize',7);
plot(xp(3:4), yp(3:4), 'cs', 'MarkerFaceColor','c', 'MarkerSize',7);

% ============================================================
% 2) PICKING (in pixel space for display, converted to physical units)
% ============================================================

% ---------- DIRECT picks ----------
title('DIRECT picks: LEFT-click to add points. RIGHT-click or ENTER to finish.');
xD = []; tD = [];
xDpix = []; tDpix = [];

hD = plot(nan,nan,'ro','MarkerSize',6,'LineWidth',1.5);

while true
    [xpix, ypix, btn] = ginput(1);

    % ENTER returns empty; right-click gives btn ~= 1
    if isempty(xpix) || isempty(btn) || btn ~= 1
        break;
    end

    % Store physical units
    xD(end+1,1) = pix2x(xpix);
    tD(end+1,1) = pix2t(ypix);

    % Store pixel units (for plotting on the PNG)
    xDpix(end+1,1) = xpix;
    tDpix(end+1,1) = ypix;

    set(hD,'XData',xDpix,'YData',tDpix);
    drawnow;
end

% ---------- REFRACTED picks ----------
title('REFRACTED picks: LEFT-click to add points. RIGHT-click or ENTER to finish.');
xR = []; tR = [];
xRpix = []; tRpix = [];

hR = plot(nan,nan,'bo','MarkerSize',6,'LineWidth',1.5);

while true
    [xpix, ypix, btn] = ginput(1);

    if isempty(xpix) || isempty(btn) || btn ~= 1
        break;
    end

    xR(end+1,1) = pix2x(xpix);
    tR(end+1,1) = pix2t(ypix);

    xRpix(end+1,1) = xpix;
    tRpix(end+1,1) = ypix;

    set(hR,'XData',xRpix,'YData',tRpix);
    drawnow;
end

figPick = figCal; % reuse the same figure handle for saving

% ============================================================
% 3) PROCESSING (fits + velocities + depth)
% ============================================================

% ---- Keep only far-offset refracted picks (avoid mixing with direct) ----
xBreakMin = 200;   
keepR = xR >= xBreakMin;
xR = xR(keepR);
tR = tR(keepR);

% ---- Basic checks ----
if numel(xD) < 3 || numel(xR) < 3
    error('Pick at least 3 points for DIRECT and 3 points for REFRACTED (far offsets).');
end

% Sort by x
[xD, iD] = sort(xD);  tD = tD(iD);
[xR, iR] = sort(xR);  tR = tR(iR);

% ---- Fit lines: t = a + b*x ----
pD = polyfit(xD, tD, 1);      % direct
pR = polyfit(xR, tR, 1);      % refracted

b1 = pD(1);  a1 = pD(2);
b2 = pR(1);  ti = pR(2);

% Velocities (positive)
v1 = 1/abs(b1);
v2 = 1/abs(b2);

% ---- Depth (time-intercept method) ----
h = (ti * v1 * v2) / (2 * sqrt(max(eps, v2^2 - v1^2)));

% ============================================================
% 4) PLOT t-x FIT (physical coords)
% ============================================================
figFit = figure('Color','w','Position',[150 150 900 600]);
plot(xD, tD, 'ro', 'MarkerSize', 6, 'LineWidth', 1.5); hold on;
plot(xR, tR, 'bo', 'MarkerSize', 6, 'LineWidth', 1.5);
grid on;

xx = linspace(x_min, x_max, 300);
plot(xx, a1 + b1*xx, 'r-', 'LineWidth', 2);
plot(xx, ti + b2*xx, 'b-', 'LineWidth', 2);

set(gca,'YDir','reverse'); % seismic convention  %Seismic plots are upside down on purpose.
xlabel('Offset x (m)');
ylabel('First-arrival time t (s)');
legend('Direct picks','Refracted picks','Direct fit','Refracted fit','Location','best');

title(sprintf('v1=%.0f m/s, v2=%.0f m/s, ti=%.3f s, h=%.1f m', v1, v2, ti, h));

% ============================================================
% 5) PRINT + SAVE
% ============================================================
fprintf('\n===== Refraction results =====\n');
fprintf('v1 = %.1f m/s\n', v1);
fprintf('v2 = %.1f m/s\n', v2);
fprintf('ti = %.4f s\n', ti);
fprintf('h  = %.2f m\n', h);
fprintf('=============================\n');

results.v1 = v1; results.v2 = v2; results.ti = ti; results.h = h;
results.direct = [xD tD];
results.refracted = [xR tR];
results.xBreakMin = xBreakMin;
results.calibration.xpix0 = xpix0; results.calibration.xpix1 = xpix1;
results.calibration.ypix0 = ypix0; results.calibration.ypix1 = ypix1;
results.calibration.ax = ax; results.calibration.bx = bx;
results.calibration.at = at; results.calibration.bt = bt;

save('B04_refraction_results.mat','results');

% Save figure with picks 
exportgraphics(figPick,'B04_picture_with_picks.png','Resolution',300);

% Save fit plot
exportgraphics(figFit,'B04_tx_fit.png','Resolution',300);
exportgraphics(figFit,'B04_tx_fit.pdf','ContentType','vector');
