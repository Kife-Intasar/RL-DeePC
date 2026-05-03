function plant = make_silverbox(cfg)

% Expected data file:
%   <package_root>/data/benchmarks/silverbox/Schroeder80mV.mat

if nargin < 1
    cfg = struct();
end

root = fileparts(fileparts(mfilename('fullpath')));
matfile = fullfile(root, 'data', 'benchmarks', 'silverbox', 'Schroeder80mV.mat');

if ~exist(matfile, 'file')
    error('Silverbox dataset not found: %s', matfile);
end

plant = make_silverbox_from_data(cfg, matfile);
end
