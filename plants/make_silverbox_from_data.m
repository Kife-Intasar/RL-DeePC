function plant = make_silverbox_from_data(cfg, matfile)

if nargin < 1
    cfg = struct();
end

if nargin < 2 || isempty(matfile)
    error('Path to Silverbox .mat file is required.');
end

if exist('iddata', 'file') ~= 2 || exist('n4sid', 'file') ~= 2
    error(['Silverbox surrogate requires System Identification Toolbox ', ...
           '(missing iddata/n4sid).']);
end

S = load(matfile);
u = S.V1(:);
y = S.V2(:);

u = u - mean(u);
y = y - mean(y);

su = std(u); if su > 0, u = u / su; end
sy = std(y); if sy > 0, y = y / sy; end

N = numel(u);
Ntr = floor(0.60 * N);

u_tr = u(1:Ntr);
y_tr = y(1:Ntr);

Ts = 1;            % use actual Ts later if you have it
nx = 4;            % can try 2,4,6 later

z = iddata(y_tr, u_tr, Ts);
sys = n4sid(z, nx, 'Feedthrough', false);

[A,B,C,D] = ssdata(sys);

plant = struct();
plant.name   = 'silverbox';
plant.domain = 'benchmark_dataset';

plant.A = A;
plant.B = B;
plant.C = C;
plant.D = D;

plant.n = size(A,1);
plant.m = size(B,2);
plant.p = size(C,1);

plant.x0 = zeros(plant.n,1);

% REQUIRED by lti_step.m
plant.proc_noise = 1e-4;%0.0;
plant.meas_noise = 1e-3;%0.0;

% optional bias
plant.y_bias = zeros(plant.p,1);

% constraints
plant.u_min = -3 * ones(plant.m,1);
plant.u_max =  3 * ones(plant.m,1);
plant.y_min = -3 * ones(plant.p,1);
plant.y_max =  3 * ones(plant.p,1);

plant.delta_u_min = -0.5 * ones(plant.m,1);
plant.delta_u_max =  0.5 * ones(plant.m,1);

% LTI scheduling placeholders
plant.lambda_fun = @(k) 0;
plant.lambda_is_time_varying = false;

% reference metadata
plant.ref_type = 'output_tracking';
plant.y_ref_nominal = 0;
plant.make_ref = @(T) zeros(plant.p, T);
end
