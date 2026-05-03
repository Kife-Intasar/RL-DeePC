function [Ar, Br, Cr, Dr, meta] = irka_reduce_auto(A, B, C, D, r, cfg)

n = size(A,1);
r = max(1, min(r, n));
meta = struct();
meta.target_order = r;
meta.converged = false;
meta.iterations = 0;
meta.shift_history = [];

% BT initialization is numerically safer than random starts.
[Ar, Br, Cr, Dr] = balanced_truncation_raw(A, B, C, D, r);
lam = eig(Ar);
shifts = local_shifts_from_poles(lam, cfg);
meta.shift_history = shifts(:).';

for it = 1:cfg.irka_max_iter
    [V, W] = local_bases(A, B, C, shifts);
    [V, W] = local_biorth(V, W);

    Ar_new = real(W' * A * V);
    Br_new = real(W' * B);
    Cr_new = real(C * V);
    Dr_new = D;
    Ar_new = local_stabilize(Ar_new);

    lam_new = eig(Ar_new);
    shifts_new = local_shifts_from_poles(lam_new, cfg);
    meta.shift_history = [meta.shift_history; shifts_new(:).'];

    denom = max(1, norm(shifts));
    relchg = norm(sort(shifts_new(:)) - sort(shifts(:))) / denom;

    Ar = Ar_new; Br = Br_new; Cr = Cr_new; Dr = Dr_new;
    shifts = shifts_new;
    meta.iterations = it;
    if relchg < cfg.irka_tol
        meta.converged = true;
        break;
    end
end

meta.final_poles = eig(Ar);
meta.final_shifts = shifts;
end

function shifts = local_shifts_from_poles(lam, cfg)
lam = lam(:);
if isempty(lam)
    shifts = cfg.irka_shift_min;
    return;
end
sig = 1 ./ max(abs(lam), 1e-3);
sig = min(max(real(sig), cfg.irka_shift_min), cfg.irka_shift_max);
shifts = sig(:);
end

function [V, W] = local_bases(A, B, C, shifts)
n = size(A,1);
m = size(B,2);
p = size(C,1);
r = numel(shifts);
V = zeros(n,r);
W = zeros(n,r);
I = eye(n);
for i = 1:r
    bi = zeros(m,1); bi(mod(i-1,m)+1) = 1;
    ci = zeros(p,1); ci(mod(i-1,p)+1) = 1;
    V(:,i) = real((shifts(i)*I - A) \ (B*bi));
    W(:,i) = real((shifts(i)*I - A') \ (C'*ci));
end
end

function [Vb, Wb] = local_biorth(V, W)
[Vq, ~] = qr(V, 0);
[Wq, ~] = qr(W, 0);
M = Wq' * Vq;
[U,S,Vh] = svd(M, 'econ');
s = diag(S);
Sinv = diag(1 ./ sqrt(s + 1e-10));
Vb = Vq * Vh * Sinv;
Wb = Wq * U * Sinv;
end

function A = local_stabilize(A)
lam = eig(A);
rho = max(abs(lam));
if rho >= 0.995
    A = A / (1.01 * rho);
end
A = real(A);
end
