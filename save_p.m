clear; close all; clc;

% 1) Run the .p file (it will create the figure)
B04_exercise;   % <-- change to your .p name (without .p)

drawnow;      % make sure everything is rendered

% 2) Get the axes containing the gather
ax = gca;

% 3) Remove borders/margins and hide axis decorations
axis(ax,'tight');
axis(ax,'off');   % ensures no ticks/labels/title are in the export
set(ax,'LooseInset', get(ax,'TightInset'));

% 4) Export ONLY the axes (data panel only)
exportgraphics(ax, 'B04_gather_data.png', 'Resolution', 300);
