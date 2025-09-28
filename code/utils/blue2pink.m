function colors = blue2pink(nRows)
% Define colors
dark_blue = [0.172, 0, 0.627];  % Dark blue (pastel)
purple = [0.494, 0, 0.835];    % Purple (Pastel)
dark_red = [0.627, 0.129, 0.302]; % Dark red (pastel)

% Define transition points (dark pink -> violet -> purple)
colors = [
    dark_blue;
    purple;
    dark_red;
    ];
% Interpolate to create the colormap
x = linspace(1, size(colors, 1), nRows); % Target range
xi = 1:size(colors, 1); % Original range
colors = interp1(xi, colors, x);
end